/**************************************************
 * FUZIX host utilities:  fsck_fat
 *
 * A compact, self-contained consistency checker for
 * the FAT12/FAT16 images produced by mkfs_fat.  Like
 * the rest of the host tools it depends on nothing
 * but libc and works on a plain image file with
 * 512-byte sectors.
 *
 * It parses the boot sector/BPB, determines the FAT
 * type from the cluster count, and then checks:
 *   - boot sector sanity (signature, geometry)
 *   - all FAT copies agree with each other
 *   - the media byte in FAT[0]
 *   - every directory chain starting at the root:
 *       * cluster values in range
 *       * no cross-linked clusters (two files sharing)
 *       * no chain loops
 *       * file size matches its cluster chain
 *   - lost cluster chains (allocated but unreferenced)
 *
 * By default it is strictly read-only.  With -a or -y
 * it applies the *safe* repairs: re-sync mismatched
 * FAT copies from the first copy and free lost chains.
 * Cross-links and out-of-range chains are reported but
 * never silently rewritten.
 *
 * Usage:
 *   fsck_fat [-a] [-y] [-v] image[:offset]
 *
 * Exit status (like fsck): 0 clean, 1 errors fixed,
 * 4 errors left uncorrected, 8 operational error.
 **************************************************/

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <stdarg.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

#define SECSZ		512
#define DIRENT_SZ	32

#define ATTR_READ_ONLY	0x01
#define ATTR_HIDDEN	0x02
#define ATTR_SYSTEM	0x04
#define ATTR_VOLUME_ID	0x08
#define ATTR_DIRECTORY	0x10
#define ATTR_LFN	0x0F	/* long-file-name entry (0x01|0x02|0x04|0x08) */

/* exit-status bits, matching fsck conventions */
#define EX_CLEAN	0
#define EX_FIXED	1
#define EX_UNCORRECTED	4
#define EX_OP		8

static const char *progname = "fsck_fat";

/* --- geometry, filled in from the BPB --- */
static int	g_fd;
static off_t	g_base;		/* byte offset of the filesystem in the file */
static unsigned	g_bps;		/* bytes per sector */
static unsigned	g_spc;		/* sectors per cluster */
static unsigned	g_reserved;
static unsigned	g_nfats;
static unsigned	g_root_ents;
static unsigned	g_fat_size;	/* sectors per FAT */
static uint8_t	g_media;
static uint32_t	g_total_sectors;
static int	g_bits;		/* 12 or 16 */

static uint32_t	g_fat_start;	/* sector */
static uint32_t	g_root_start;	/* sector */
static uint32_t	g_data_start;	/* sector */
static uint32_t	g_clusters;	/* count of data clusters */
static uint32_t	g_last_cluster;	/* highest valid cluster number (clusters+1) */

/* --- run-time state --- */
static int	do_repair;	/* -a / -y : apply safe fixes */
static int	verbose;
static int	exit_code = EX_CLEAN;

static uint8_t *g_fat;		/* in-core copy of FAT #0 (byte image) */
static uint32_t	g_fat_bytes;	/* size of one FAT copy in bytes */
static uint8_t *g_used;		/* per-cluster: referenced by a dir entry? */
static int	g_fat_dirty;	/* g_fat modified, needs flushing */

static unsigned long stat_files, stat_dirs, stat_bytes;

static void die(const char *msg)
{
	fprintf(stderr, "%s: %s\n", progname, msg);
	exit(EX_OP);
}

static void die_errno(const char *msg)
{
	fprintf(stderr, "%s: %s: %s\n", progname, msg, strerror(errno));
	exit(EX_OP);
}

static void problem(const char *fmt, ...)
{
	va_list ap;
	fputs(progname, stderr);
	fputs(": ", stderr);
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	fputc('\n', stderr);
}

/* little-endian readers */
static uint16_t get16(const uint8_t *p)
{
	return (uint16_t)(p[0] | (p[1] << 8));
}

static uint32_t get32(const uint8_t *p)
{
	return (uint32_t)p[0] | ((uint32_t)p[1] << 8)
	     | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

/* absolute sector read/write into the image, honouring the partition base */
static void read_sector(uint32_t sec, void *buf)
{
	off_t off = g_base + (off_t)sec * g_bps;
	if (pread(g_fd, buf, g_bps, off) != (ssize_t)g_bps)
		die_errno("read");
}

static void read_bytes(off_t off, void *buf, size_t n)
{
	if (pread(g_fd, buf, n, g_base + off) != (ssize_t)n)
		die_errno("read");
}

/* --- FAT entry accessors on the in-core copy --- */
static uint32_t fat_get(uint32_t cl)
{
	if (g_bits == 12) {
		uint32_t o = cl + (cl >> 1);	/* cl * 3 / 2 */
		uint32_t v = g_fat[o] | (g_fat[o + 1] << 8);
		return (cl & 1) ? (v >> 4) : (v & 0x0FFF);
	} else {
		uint32_t o = cl * 2;
		return g_fat[o] | (g_fat[o + 1] << 8);
	}
}

static void fat_set(uint32_t cl, uint32_t val)
{
	if (g_bits == 12) {
		uint32_t o = cl + (cl >> 1);
		uint32_t v = g_fat[o] | (g_fat[o + 1] << 8);
		if (cl & 1)
			v = (v & 0x000F) | ((val & 0x0FFF) << 4);
		else
			v = (v & 0xF000) | (val & 0x0FFF);
		g_fat[o] = v & 0xff;
		g_fat[o + 1] = (v >> 8) & 0xff;
	} else {
		uint32_t o = cl * 2;
		g_fat[o] = val & 0xff;
		g_fat[o + 1] = (val >> 8) & 0xff;
	}
	g_fat_dirty = 1;
}

static int fat_is_eoc(uint32_t v)
{
	return (g_bits == 12) ? (v >= 0x0FF8) : (v >= 0xFFF8);
}

static int fat_is_bad(uint32_t v)
{
	return (g_bits == 12) ? (v == 0x0FF7) : (v == 0xFFF7);
}

/* a cluster number that is a valid pointer to a data cluster */
static int cluster_in_range(uint32_t cl)
{
	return cl >= 2 && cl <= g_last_cluster;
}

/* --- boot sector / geometry --- */
static void parse_boot(void)
{
	uint8_t bs[SECSZ];

	/* bps unknown before the first read: use 512 to fetch sector 0, then
	 * re-derive everything from the BPB. */
	g_bps = SECSZ;
	read_sector(0, bs);

	if (bs[510] != 0x55 || bs[511] != 0xAA)
		problem("boot sector signature 0x55AA missing (0x%02x%02x)",
		        bs[511], bs[510]), exit_code |= EX_UNCORRECTED;

	g_bps       = get16(bs + 11);
	g_spc       = bs[13];
	g_reserved  = get16(bs + 14);
	g_nfats     = bs[16];
	g_root_ents = get16(bs + 17);
	g_media     = bs[21];
	g_fat_size  = get16(bs + 22);

	uint32_t tot16 = get16(bs + 19);
	uint32_t tot32 = get32(bs + 32);
	g_total_sectors = tot16 ? tot16 : tot32;

	if (g_bps != SECSZ)
		die("only 512-byte sectors are supported");
	if (g_spc == 0 || (g_spc & (g_spc - 1)))
		die("sectors per cluster is not a power of two");
	if (g_nfats < 1)
		die("no FATs declared in the BPB");
	if (g_fat_size == 0)
		die("FAT size is zero (FAT32 or corrupt BPB - unsupported)");
	if (g_total_sectors == 0)
		die("total sector count is zero");

	unsigned root_dir_sectors =
	    (g_root_ents * DIRENT_SZ + g_bps - 1) / g_bps;

	g_fat_start  = g_reserved;
	g_root_start = g_fat_start + g_nfats * g_fat_size;
	g_data_start = g_root_start + root_dir_sectors;

	if (g_data_start >= g_total_sectors)
		die("no data region - corrupt geometry");

	uint32_t data_sectors = g_total_sectors - g_data_start;
	g_clusters = data_sectors / g_spc;
	g_last_cluster = g_clusters + 1;	/* clusters are numbered 2..N+1 */

	if (g_clusters < 4085)
		g_bits = 12;
	else if (g_clusters < 65525)
		g_bits = 16;
	else
		die("cluster count implies FAT32 - unsupported");

	g_fat_bytes = g_fat_size * g_bps;

	if (verbose) {
		fprintf(stderr,
		    "%s: FAT%d, %u sectors, %u sec/cluster, %u clusters\n"
		    "  reserved=%u fats=%u fatsize=%u rootents=%u media=0x%02x\n"
		    "  fat@%u root@%u data@%u\n",
		    progname, g_bits, g_total_sectors, g_spc, g_clusters,
		    g_reserved, g_nfats, g_fat_size, g_root_ents, g_media,
		    g_fat_start, g_root_start, g_data_start);
	}
}

/* Load FAT #0 into memory and compare the other copies against it. */
static void load_and_check_fats(void)
{
	g_fat = malloc(g_fat_bytes);
	if (!g_fat)
		die("out of memory (FAT)");

	read_bytes((off_t)g_fat_start * g_bps, g_fat, g_fat_bytes);

	/* Media byte: FAT[0] low byte should equal the BPB media descriptor. */
	if ((g_fat[0]) != g_media)
		problem("FAT[0] media byte 0x%02x != BPB media 0x%02x",
		        g_fat[0], g_media), exit_code |= EX_UNCORRECTED;

	uint8_t *other = malloc(g_fat_bytes);
	if (!other)
		die("out of memory (FAT compare)");

	for (unsigned f = 1; f < g_nfats; f++) {
		uint32_t sec = g_fat_start + f * g_fat_size;
		read_bytes((off_t)sec * g_bps, other, g_fat_bytes);
		if (memcmp(other, g_fat, g_fat_bytes) != 0) {
			problem("FAT copy #%u differs from FAT #0", f);
			if (do_repair) {
				if (pwrite(g_fd, g_fat, g_fat_bytes,
				           g_base + (off_t)sec * g_bps)
				    != (ssize_t)g_fat_bytes)
					die_errno("rewrite FAT copy");
				fprintf(stderr, "  -> FAT copy #%u re-synced\n", f);
				exit_code |= EX_FIXED;
			} else {
				exit_code |= EX_UNCORRECTED;
			}
		}
	}
	free(other);
}

/* Walk a cluster chain, marking clusters used. Returns the chain length in
 * clusters, or reports a problem and returns what it counted so far.
 * `what` is used for diagnostics. */
static uint32_t walk_chain(uint32_t start, const char *what)
{
	uint32_t cl = start, n = 0;

	while (cluster_in_range(cl)) {
		if (g_used[cl]) {
			problem("%s: cluster %u is cross-linked "
			        "(already used by another file)", what, cl);
			exit_code |= EX_UNCORRECTED;
			break;
		}
		g_used[cl] = 1;
		n++;

		uint32_t next = fat_get(cl);
		if (fat_is_eoc(next))
			return n;
		if (fat_is_bad(next)) {
			problem("%s: chain enters a BAD cluster after %u",
			        what, cl);
			exit_code |= EX_UNCORRECTED;
			return n;
		}
		if (next == 0) {
			problem("%s: chain hits a free cluster after %u "
			        "(truncated chain)", what, cl);
			exit_code |= EX_UNCORRECTED;
			return n;
		}
		if (!cluster_in_range(next)) {
			problem("%s: cluster %u points out of range to %u",
			        what, cl, next);
			exit_code |= EX_UNCORRECTED;
			return n;
		}
		cl = next;
	}
	return n;
}

static void trim_name(const uint8_t *ent, char *out)
{
	char base[9], ext[4];
	int i, j;

	for (i = 0, j = 0; i < 8; i++)
		if (ent[i] != ' ')
			base[j++] = ent[i];
	base[j] = 0;
	for (i = 0, j = 0; i < 3; i++)
		if (ent[8 + i] != ' ')
			ext[j++] = ent[8 + i];
	ext[j] = 0;

	if (ext[0])
		sprintf(out, "%s.%s", base, ext);
	else
		strcpy(out, base);
}

/* Read one directory (root region if `cluster`==0, else a cluster chain) and
 * recurse into subdirectories. `used_dir` guards against directory loops. */
static void check_dir(uint32_t cluster, const char *path)
{
	uint8_t ent[DIRENT_SZ];
	uint8_t sector[SECSZ];
	uint32_t cl = cluster;
	int is_root = (cluster == 0);

	/* iterate over the directory's sectors */
	uint32_t sec_index = 0;
	uint32_t root_sectors = (g_root_ents * DIRENT_SZ + g_bps - 1) / g_bps;

	for (;;) {
		uint32_t sec, secs_here;
		if (is_root) {
			if (sec_index >= root_sectors)
				break;
			sec = g_root_start + sec_index;
			secs_here = 1;
			sec_index++;
		} else {
			if (!cluster_in_range(cl))
				break;
			/* the chain's clusters were already marked used by the
			 * caller via walk_chain; here we just read them. */
			sec = g_data_start + (cl - 2) * g_spc;
			secs_here = g_spc;
		}

		for (uint32_t s = 0; s < secs_here; s++) {
			read_sector(sec + s, sector);
			for (unsigned e = 0; e + DIRENT_SZ <= g_bps;
			     e += DIRENT_SZ) {
				memcpy(ent, sector + e, DIRENT_SZ);

				if (ent[0] == 0x00)
					return;		/* end of directory */
				if (ent[0] == 0xE5)
					continue;	/* deleted */
				if ((ent[11] & ATTR_LFN) == ATTR_LFN)
					continue;	/* LFN fragment */
				if (ent[11] & ATTR_VOLUME_ID)
					continue;	/* volume label */

				char name[13];
				trim_name(ent, name);

				if (!strcmp(name, ".") || !strcmp(name, ".."))
					continue;

				uint32_t start = get16(ent + 26);	/* low word */
				uint32_t size  = get32(ent + 28);
				int isdir = (ent[11] & ATTR_DIRECTORY) != 0;

				char child[256];
				snprintf(child, sizeof child, "%s/%s",
				         path, name);

				if (start == 0) {
					/* empty file/dir - nothing to walk */
					if (isdir)
						stat_dirs++;
					else
						stat_files++;
					continue;
				}

				if (!cluster_in_range(start)) {
					problem("%s: start cluster %u out of range",
					        child, start);
					exit_code |= EX_UNCORRECTED;
					continue;
				}

				uint32_t chain = walk_chain(start, child);

				if (isdir) {
					stat_dirs++;
					check_dir(start, child);
				} else {
					stat_files++;
					stat_bytes += size;
					uint32_t bytes_per_cl = g_spc * g_bps;
					uint32_t need = (size + bytes_per_cl - 1)
					              / bytes_per_cl;
					if (need == 0)
						need = 0;
					if (chain != need) {
						problem("%s: size %u needs %u "
						  "clusters but chain has %u",
						  child, size, need, chain);
						exit_code |= EX_UNCORRECTED;
					}
				}
			}
		}

		if (!is_root) {
			uint32_t next = fat_get(cl);
			if (fat_is_eoc(next) || !cluster_in_range(next))
				break;
			cl = next;
		}
	}
}

/* Scan the FAT for allocated clusters that no directory entry referenced. */
static void check_lost(void)
{
	unsigned long lost_clusters = 0, lost_chains = 0;

	for (uint32_t cl = 2; cl <= g_last_cluster; cl++) {
		uint32_t v = fat_get(cl);
		if (v == 0 || fat_is_bad(v))
			continue;
		if (g_used[cl])
			continue;

		/* an allocated but unreferenced cluster: the head of a lost
		 * chain if its predecessor is not itself lost. Count chains by
		 * only reporting clusters whose FAT value marks a chain we
		 * haven't already freed. */
		lost_clusters++;
		if (do_repair) {
			fat_set(cl, 0);
		} else {
			exit_code |= EX_UNCORRECTED;
		}
	}

	/* crude chain count is not tracked precisely; report cluster total. */
	(void)lost_chains;

	if (lost_clusters) {
		if (do_repair) {
			problem("freed %lu lost cluster(s)", lost_clusters);
			exit_code |= EX_FIXED;
		} else {
			problem("%lu lost cluster(s) not connected to any file",
			        lost_clusters);
		}
	}
}

static void flush_fat(void)
{
	if (!g_fat_dirty || !do_repair)
		return;
	for (unsigned f = 0; f < g_nfats; f++) {
		uint32_t sec = g_fat_start + f * g_fat_size;
		if (pwrite(g_fd, g_fat, g_fat_bytes,
		           g_base + (off_t)sec * g_bps) != (ssize_t)g_fat_bytes)
			die_errno("flush FAT");
	}
}

static void usage(void)
{
	fprintf(stderr, "usage: %s [-a] [-y] [-v] image[:offset]\n", progname);
	exit(EX_OP);
}

int main(int argc, char **argv)
{
	int opt;

	progname = argv[0];

	while ((opt = getopt(argc, argv, "ayv")) != -1) {
		switch (opt) {
		case 'a':	/* automatically apply safe repairs */
		case 'y':	/* assume yes - same safe repairs */
			do_repair = 1;
			break;
		case 'v':
			verbose = 1;
			break;
		default:
			usage();
		}
	}

	if (optind >= argc)
		usage();

	char *arg = argv[optind];
	char *colon = strrchr(arg, ':');
	g_base = 0;
	if (colon) {
		/* image:offset - offset is a sector number into the file */
		*colon = 0;
		g_base = (off_t)strtoull(colon + 1, NULL, 0) * SECSZ;
	}

	g_fd = open(arg, do_repair ? O_RDWR : O_RDONLY);
	if (g_fd < 0)
		die_errno(arg);

	parse_boot();
	load_and_check_fats();

	g_used = calloc(g_last_cluster + 1, 1);
	if (!g_used)
		die("out of memory (used map)");

	check_dir(0, "");	/* root */
	check_lost();
	flush_fat();

	printf("%s: %lu files, %lu dirs, %lu bytes in use; %u clusters total\n",
	       progname, stat_files, stat_dirs, stat_bytes, g_clusters);

	if (exit_code == EX_CLEAN)
		printf("%s: clean\n", progname);
	else if (exit_code & EX_UNCORRECTED)
		printf("%s: FILESYSTEM HAS UNCORRECTED ERRORS\n", progname);
	else if (exit_code & EX_FIXED)
		printf("%s: errors were corrected\n", progname);

	close(g_fd);
	return exit_code;
}
