/**************************************************
 * FUZIX host utilities:  mkfs_fat
 *
 * A compact, self-contained FAT12/FAT16 filesystem
 * formatter for building boot/data images on the
 * host.  No external dependencies (no mtools, no
 * dosfstools) - it only ever writes a plain image
 * file with 512-byte sectors.
 *
 * Usage:
 *   mkfs_fat [options] image [size-in-sectors]
 *
 * If the size is omitted the tool sizes itself to
 * the existing image/device.  Options:
 *   -F 12|16   force FAT type (default: auto)
 *   -s N       sectors per cluster (default: auto)
 *   -f N       number of FATs           (default 2)
 *   -r N       root directory entries    (default 512)
 *   -R N       reserved sectors          (default 1)
 *   -n LABEL   volume label (<=11 chars, default NO NAME)
 *   -i HEX     volume id / serial (default from time)
 *   -v         verbose: print the geometry
 *
 * Example:
 *   ./mkfs_fat -F 16 -n FUZIX disk.img 40960   (20MB FAT16)
 **************************************************/

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <time.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

#define SECSZ		512
#define DIRENT_SZ	32

#define ATTR_VOLUME_ID	0x08

/* Cluster-count boundaries from the Microsoft FAT spec. A volume with fewer
 * than 4085 clusters is FAT12, up to 65524 is FAT16. */
#define FAT12_MAX_CLUSTERS	4084UL
#define FAT16_MAX_CLUSTERS	65524UL

static const char *progname = "mkfs_fat";

static void die(const char *msg)
{
	fprintf(stderr, "%s: %s\n", progname, msg);
	exit(1);
}

static void die_errno(const char *msg)
{
	fprintf(stderr, "%s: %s: %s\n", progname, msg, strerror(errno));
	exit(1);
}

/* little-endian store helpers - the on-disk BPB is always little-endian
 * regardless of the host byte order. */
static void put16(uint8_t *p, uint16_t v)
{
	p[0] = v & 0xff;
	p[1] = (v >> 8) & 0xff;
}

static void put32(uint8_t *p, uint32_t v)
{
	p[0] = v & 0xff;
	p[1] = (v >> 8) & 0xff;
	p[2] = (v >> 16) & 0xff;
	p[3] = (v >> 24) & 0xff;
}

/* Pick a reasonable sectors-per-cluster for a FAT16 volume of the given size
 * (mirrors the classic dosfstools/DOS size table). FAT12 always uses 1 unless
 * the user overrides it. */
static unsigned default_spc16(uint32_t total_sectors)
{
	uint32_t mb = (uint32_t)((uint64_t)total_sectors * SECSZ / (1024 * 1024));
	if (mb <= 16)   return 1;
	if (mb <= 128)  return 4;
	if (mb <= 256)  return 8;
	if (mb <= 512)  return 16;
	if (mb <= 1024) return 32;
	return 64;
}

static void usage(void)
{
	fprintf(stderr,
	    "usage: %s [-F 12|16] [-s spc] [-f nfats] [-r rootents]\n"
	    "          [-R reserved] [-n label] [-i hexid] [-v] image [sectors]\n",
	    progname);
	exit(1);
}

int main(int argc, char **argv)
{
	int fat_bits = 0;		/* 0 = auto */
	unsigned spc = 0;		/* 0 = auto */
	unsigned num_fats = 2;
	unsigned root_ents = 512;
	unsigned reserved = 1;
	unsigned verbose = 0;
	uint32_t volid = 0;
	int have_volid = 0;
	char label[12] = "NO NAME    ";
	int opt;

	progname = argv[0];

	while ((opt = getopt(argc, argv, "F:s:f:r:R:n:i:v")) != -1) {
		switch (opt) {
		case 'F':
			fat_bits = atoi(optarg);
			if (fat_bits != 12 && fat_bits != 16)
				die("FAT type must be 12 or 16");
			break;
		case 's':
			spc = atoi(optarg);
			if (spc == 0 || (spc & (spc - 1)))
				die("sectors per cluster must be a power of two");
			break;
		case 'f':
			num_fats = atoi(optarg);
			if (num_fats < 1 || num_fats > 4)
				die("number of FATs must be 1..4");
			break;
		case 'r':
			root_ents = atoi(optarg);
			if (root_ents == 0)
				die("root entries must be > 0");
			break;
		case 'R':
			reserved = atoi(optarg);
			if (reserved == 0)
				die("reserved sectors must be > 0");
			break;
		case 'n': {
			size_t i, n = strlen(optarg);
			if (n > 11)
				die("volume label too long (max 11 chars)");
			memset(label, ' ', 11);
			for (i = 0; i < n; i++)
				label[i] = toupper((unsigned char)optarg[i]);
			label[11] = 0;
			break;
		}
		case 'i':
			volid = (uint32_t)strtoul(optarg, NULL, 16);
			have_volid = 1;
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

	const char *path = argv[optind++];
	uint32_t total_sectors = 0;

	if (optind < argc)
		total_sectors = (uint32_t)strtoul(argv[optind++], NULL, 0);

	int fd = open(path, O_RDWR | O_CREAT, 0666);
	if (fd < 0)
		die_errno(path);

	/* Without an explicit size, format the whole of the existing file. */
	if (total_sectors == 0) {
		struct stat st;
		if (fstat(fd, &st) < 0)
			die_errno("fstat");
		if (st.st_size == 0)
			die("no size given and image is empty");
		total_sectors = (uint32_t)(st.st_size / SECSZ);
	}

	if (total_sectors < 64)
		die("image is too small for a FAT filesystem");

	/* Ensure the file is at least total_sectors long, zero filled. */
	if (ftruncate(fd, (off_t)total_sectors * SECSZ) < 0)
		die_errno("ftruncate");

	unsigned root_dir_sectors =
	    (root_ents * DIRENT_SZ + SECSZ - 1) / SECSZ;

	/* Auto-select FAT type: try FAT16 geometry, fall back to FAT12 if the
	 * volume ends up too small for it. The user's -F always wins. */
	int try_bits = fat_bits ? fat_bits : 16;

	unsigned fat_size = 0;
	uint32_t clusters = 0;

	for (;;) {
		unsigned this_spc = spc;
		if (this_spc == 0)
			this_spc = (try_bits == 12) ? 1
			                            : default_spc16(total_sectors);

		/* Iteratively solve for the FAT size: it depends on the cluster
		 * count, which itself depends on how many sectors the FATs eat. */
		unsigned fs = 0, prev;
		uint32_t cl = 0;
		int i;
		for (i = 0; i < 16; i++) {
			prev = fs;
			long data = (long)total_sectors - reserved
			            - root_dir_sectors
			            - (long)num_fats * prev;
			if (data <= 0) { cl = 0; break; }
			cl = (uint32_t)(data / this_spc);
			/* +2 for the two reserved FAT entries (0 and 1). */
			uint64_t entbytes = (try_bits == 12)
			    ? ((uint64_t)(cl + 2) * 3 + 1) / 2
			    : (uint64_t)(cl + 2) * 2;
			fs = (unsigned)((entbytes + SECSZ - 1) / SECSZ);
			if (fs == prev)
				break;
		}

		/* If auto-typing, verify the cluster count matches the type; if
		 * FAT16 yields too few clusters, retry as FAT12. */
		if (fat_bits == 0 && try_bits == 16 && cl < 4085) {
			try_bits = 12;
			continue;
		}

		if (try_bits == 12 && cl > FAT12_MAX_CLUSTERS)
			die("too many clusters for FAT12 (use -F 16 or a larger -s)");
		if (try_bits == 16 && cl > FAT16_MAX_CLUSTERS)
			die("too many clusters for FAT16 (increase -s)");
		if (cl < 1)
			die("no data clusters - image too small");

		fat_bits = try_bits;
		spc = this_spc;
		fat_size = fs;
		clusters = cl;
		break;
	}

	if (!have_volid)
		volid = (uint32_t)time(NULL);

	uint32_t fat_start = reserved;
	uint32_t root_start = fat_start + num_fats * fat_size;
	uint32_t data_start = root_start + root_dir_sectors;

	if (verbose) {
		fprintf(stderr,
		    "%s: FAT%d, %u sectors, %u sec/cluster, %u clusters\n"
		    "  reserved=%u fats=%u fatsize=%u rootents=%u\n"
		    "  fat@%u root@%u data@%u\n",
		    progname, fat_bits, total_sectors, spc, clusters,
		    reserved, num_fats, fat_size, root_ents,
		    fat_start, root_start, data_start);
	}

	/* --- Build the boot sector / BPB --- */
	uint8_t boot[SECSZ];
	memset(boot, 0, sizeof boot);

	boot[0] = 0xEB;			/* jmp short + nop */
	boot[1] = 0x3C;
	boot[2] = 0x90;
	memcpy(boot + 3, "mkfs.fat", 8);	/* OEM name */
	put16(boot + 11, SECSZ);		/* bytes per sector */
	boot[13] = (uint8_t)spc;		/* sectors per cluster */
	put16(boot + 14, (uint16_t)reserved);	/* reserved sectors */
	boot[16] = (uint8_t)num_fats;		/* number of FATs */
	put16(boot + 17, (uint16_t)root_ents);	/* root entry count */
	if (total_sectors < 0x10000)
		put16(boot + 19, (uint16_t)total_sectors); /* total sec 16 */
	else
		put16(boot + 19, 0);
	boot[21] = 0xF8;			/* media descriptor (fixed) */
	put16(boot + 22, (uint16_t)fat_size);	/* sectors per FAT */
	put16(boot + 24, 32);			/* sectors per track */
	put16(boot + 26, 2);			/* number of heads */
	put32(boot + 28, 0);			/* hidden sectors */
	if (total_sectors < 0x10000)
		put32(boot + 32, 0);
	else
		put32(boot + 32, total_sectors);	/* total sec 32 */

	/* FAT12/16 extended boot record. */
	boot[36] = 0x80;			/* drive number */
	boot[37] = 0;				/* reserved */
	boot[38] = 0x29;			/* extended boot signature */
	put32(boot + 39, volid);		/* volume serial */
	memcpy(boot + 43, label, 11);		/* volume label */
	memcpy(boot + 54, (fat_bits == 12) ? "FAT12   " : "FAT16   ", 8);

	boot[510] = 0x55;			/* boot signature */
	boot[511] = 0xAA;

	if (pwrite(fd, boot, SECSZ, 0) != SECSZ)
		die_errno("write boot sector");

	/* --- Initialise the first sector of each FAT copy --- */
	uint8_t fat0[SECSZ];
	memset(fat0, 0, sizeof fat0);
	/* Reserved entries 0 and 1: entry 0 holds the media byte in its low
	 * bits, entry 1 is the end-of-chain marker. */
	if (fat_bits == 12) {
		fat0[0] = 0xF8;
		fat0[1] = 0xFF;
		fat0[2] = 0xFF;
	} else {
		fat0[0] = 0xF8;
		fat0[1] = 0xFF;
		fat0[2] = 0xFF;
		fat0[3] = 0xFF;
	}
	for (unsigned f = 0; f < num_fats; f++) {
		off_t off = (off_t)(fat_start + f * fat_size) * SECSZ;
		if (pwrite(fd, fat0, SECSZ, off) != SECSZ)
			die_errno("write FAT");
	}

	/* --- Root directory: write a volume-label entry if one was given --- */
	if (strncmp(label, "NO NAME    ", 11) != 0) {
		uint8_t dirent[DIRENT_SZ];
		time_t now = time(NULL);
		struct tm *tm = localtime(&now);
		uint16_t dtime = 0, ddate = 0;
		if (tm) {
			dtime = (uint16_t)((tm->tm_hour << 11)
			      | (tm->tm_min << 5) | (tm->tm_sec / 2));
			ddate = (uint16_t)(((tm->tm_year - 80) << 9)
			      | ((tm->tm_mon + 1) << 5) | tm->tm_mday);
		}
		memset(dirent, 0, sizeof dirent);
		memcpy(dirent, label, 11);
		dirent[11] = ATTR_VOLUME_ID;
		put16(dirent + 22, dtime);
		put16(dirent + 24, ddate);
		if (pwrite(fd, dirent, DIRENT_SZ,
		           (off_t)root_start * SECSZ) != DIRENT_SZ)
			die_errno("write volume label");
	}

	if (close(fd) < 0)
		die_errno("close");

	if (verbose)
		fprintf(stderr, "%s: done\n", progname);

	return 0;
}
