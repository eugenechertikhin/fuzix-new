# ---------------------------------------------------------------------------
# Platform: amprolb (Ampro Little Board / Bookshelf Z80)        CPU: z80 (SDCC)
#
# Single-image, swap-only (mm/simple.c) Z80 SBC with a serial console (Z80
# DART/SIO), a uPD765 floppy controller, an NCR5380 SCSI bus (TinySCSI +
# TinyDisk block stack) and a parallel printer. Boots from CP/M (cpmboot.s) or a
# partitioned SCSI/IDE disk. No video/input/net. config.h has CONFIG_SWAP_ONLY
# (FUZIX_MM=simple) and leaves CONFIG_MULTI undefined (single process resident).
#
# The ordered list transcribes platform-amprolb/fuzix.lnk. This board has an
# unusual segment layout (its rules.mk): the platform/driver C files and the
# SYS4/SYS5 syscall groups are pushed into COMMONMEM to free the low CODE space;
# SEG3/SYS1-3 stay in CODE, SEG2 in CODE2. Those per-source --codeseg overrides
# are encoded below.
# ---------------------------------------------------------------------------

# SDCC bank base addresses (mirror fuzix.lnk).
set(LINK_SDCC_BASES "_CODE=0x0500" "_COMMONMEM=0xB000" "_DISCARD=0x8200"
                    "_INITIALIZER=0xA000" "_SERIAL=0xFE00")
set(DISKIMAGE_STYLE "amprolb")

set(_seg_code    EXTRA --codeseg CODE)       # SEG1/SEG3/SYS1-3/SEG4
set(_seg_code2   EXTRA --codeseg CODE2)      # SEG2
set(_seg_common  EXTRA --codeseg COMMONMEM)  # SYS4/SYS5 + platform/driver C (CC_HIGH)
set(_seg_discard EXTRA --codeseg DISCARD)    # amprolb: codeseg only (no constseg)

# --- Platform low level (crt0 FIRST) + banking + start/version ---
fuzix_compile(kernel/platform/amprolb/crt0.s)
fuzix_compile(kernel/platform/amprolb/commonmem.s)
fuzix_compile(kernel/platform/amprolb/lb.s)
fuzix_compile(kernel/core/start.c ${_seg_discard})
fuzix_compile(${GEN}/version.c    ${_seg_code})
fuzix_compile(${CPU_LOWLEVEL})               # lowlevel-z80.s (plain)
fuzix_compile(kernel/platform/amprolb/tricks.s)

# --- Main + core services ---
fuzix_compile(kernel/platform/amprolb/main.c ${_seg_common})
fuzix_compile(kernel/core/timer.c ${_seg_code})
fuzix_compile(kernel/core/kdata.c ${_seg_code})
fuzix_compile(kernel/platform/amprolb/devices.c ${_seg_common})
fuzix_compile(kernel/core/devio.c ${_seg_code})
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/filesys.c ${_seg_code})
endif()
fuzix_compile(kernel/${BLK_SOURCE} ${_seg_code})
fuzix_compile(kernel/core/process.c ${_seg_code2})
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/inode.c ${_seg_code})
endif()

# --- exec / loader (SYS5 -> COMMONMEM) ---
fuzix_compile(kernel/core/syscall_exec.c ${_seg_common})
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c ${_seg_common})
endif()

# --- syscalls ---
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs.c ${_seg_code})       # SYS1 -> CODE
endif()
fuzix_compile(kernel/core/syscall_proc.c ${_seg_code2})        # SEG2 -> CODE2
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs2.c ${_seg_code})      # SYS2 -> CODE
    fuzix_compile(kernel/core/syscall_fs3.c ${_seg_code})      # SYS3 -> CODE
endif()
fuzix_compile(kernel/core/syscall_other.c ${_seg_common})      # SYS4 -> COMMONMEM

# --- mm / swap + core services ---
fuzix_compile(kernel/core/mm.c ${_seg_code})
fuzix_compile(kernel/${MEMALLOC_SOURCE} ${_seg_common})        # SYS5 -> COMMONMEM
fuzix_compile(kernel/core/swap.c ${_seg_code})
fuzix_compile(kernel/${MM_SOURCE} ${_seg_code2})               # simple.c (C2 -> CODE2)
fuzix_compile(kernel/core/tty.c ${_seg_code})
fuzix_compile(kernel/core/devsys.c ${_seg_code})
fuzix_compile(kernel/core/usermem.c ${_seg_code})

# --- Platform drivers (C -> COMMONMEM; discard -> DISCARD) ---
fuzix_compile(kernel/platform/amprolb/discard.c ${_seg_discard})
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/amprolb/devtty.c ${_seg_common})
endif()
fuzix_compile(kernel/platform/amprolb/dart.s)
fuzix_compile(kernel/platform/amprolb/devlpr.c ${_seg_common})
fuzix_compile(kernel/platform/amprolb/devfd.c ${_seg_common})
fuzix_compile(kernel/platform/amprolb/floppy.s)

# --- TinyDisk + TinySCSI (NCR5380) block stack ---
fuzix_compile(kernel/dev/tinydisk.c ${_seg_common})
fuzix_compile(kernel/dev/tinydisk_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/tinyscsi.c ${_seg_common})
fuzix_compile(kernel/dev/tinyscsi_discard.c ${_seg_discard})
# devscsi.c trips an SDCC 4.x register-allocator ICE (gen.c:1407) at the default
# --max-allocs-per-node; force it low for this one file (last value wins).
fuzix_compile(kernel/platform/amprolb/devscsi.c
              EXTRA --codeseg COMMONMEM --max-allocs-per-node 1)
fuzix_compile(kernel/platform/amprolb/ncr5380.s)
