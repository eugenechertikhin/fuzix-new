# ---------------------------------------------------------------------------
# Platform: c128-z80 (Commodore 128, Z80 side)                  CPU: z80 (SDCC)
#
# Single-image, swap-only (mm/simple.c, single process resident) port that runs
# on the C128's Z80. Simple VT console (vt.c + CONFIG_VT_SIMPLE, no font table -
# the VDC/VIC character generator is used), an SD card (devsd + the classic
# blkdev/mbr block layer) and an internal RAM disk. No input/net.
#
# Its rules.mk collapses ALL code groups into CODE (the address map is tight),
# which is exactly the fragment default (no --codeseg), so almost nothing needs
# a per-source segment override: only blkdev goes high into COMMONMEM and the
# discardable init code into DISCARD. Transcribes platform-c128-z80/fuzix.lnk.
# The bootable image is a CP/M .d71 floppy built with external tools (ctools);
# here we produce fuzix.bin (== fuzix.com).
# ---------------------------------------------------------------------------

set(LINK_SDCC_BASES "_BOOT=0x0100" "_CODE=0x1000" "_COMMONMEM=0xE800"
                    "_DISCARD=0xD400")
set(DISKIMAGE_STYLE "none")   # .d71 floppy needs external ctools + a cpm.d71

set(_seg_common  EXTRA --codeseg COMMONMEM)
set(_seg_discard EXTRA --codeseg DISCARD)     # c128-z80: codeseg only

# --- Platform low level (crt0 FIRST) + banking + start ---
fuzix_compile(kernel/platform/c128-z80/crt0.s)
fuzix_compile(kernel/platform/c128-z80/commonmem.s)
fuzix_compile(kernel/platform/c128-z80/c128.s)
fuzix_compile(kernel/core/start.c ${_seg_discard})
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/platform/c128-z80/tricks.s)

# --- Main + core services (all default -> CODE) ---
fuzix_compile(kernel/platform/c128-z80/main.c)
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/c128-z80/devices.c)
fuzix_compile(kernel/core/devio.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/filesys.c)
endif()
fuzix_compile(kernel/${BLK_SOURCE})
fuzix_compile(kernel/core/process.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/inode.c)
endif()

# --- exec / loader + syscalls ---
fuzix_compile(kernel/core/syscall_exec.c)
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c)
endif()
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs.c)
endif()
fuzix_compile(kernel/core/syscall_proc.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs2.c)
    fuzix_compile(kernel/core/syscall_fs3.c)
endif()
fuzix_compile(kernel/core/syscall_other.c)

# --- mm / swap + console + user copy ---
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/${MM_SOURCE})            # simple (swap-only)
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c)               # CONFIG_VT_SIMPLE (no font)
fuzix_compile(kernel/core/devsys.c)
fuzix_compile(kernel/core/usermem.c)
fuzix_compile(kernel/cpu/z80/usermem_std-z80.s)

# --- Platform drivers + SD block stack ---
fuzix_compile(kernel/platform/c128-z80/discard.c ${_seg_discard})
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/c128-z80/devtty.c)
endif()
fuzix_compile(kernel/dev/mbr.c ${_seg_discard})
fuzix_compile(kernel/dev/blkdev.c ${_seg_common})
fuzix_compile(kernel/dev/devsd.c)
fuzix_compile(kernel/dev/devsd_discard.c ${_seg_discard})
fuzix_compile(kernel/platform/c128-z80/sd.c)
fuzix_compile(kernel/platform/c128-z80/devrd.c)
