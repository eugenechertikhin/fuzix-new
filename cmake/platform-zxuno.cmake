# ---------------------------------------------------------------------------
# Platform: zxuno (ZX-Uno / ZX Spectrum clone, FPGA)             CPU: z80 (SDCC)
#
# Single-image ZX Spectrum-family board: 56K user banking (bankfixed), a
# ZX video text console (core vt.c + zxvideo + 8x8 font), the ZX keyboard as
# input, and DivMMC/TinySD + TinyDisk SD-card storage. config.h hard-wires
# CONFIG_VT / CONFIG_INPUT / CONFIG_FONT8X8, so those sources are compiled here
# unconditionally. The ordered list transcribes platform-zxuno/fuzix.lnk; per-C
# segment overrides (EXTRA) match the upstream top-Makefile CROSS_CC_SEG* lists.
#
# Uses the plain (non-banked) SDCC z80 low level, like 2063. The bootable image
# is an esxdos .hdf built with external tools (hdfmonkey/mkfs.fat + the ESXDOS
# distribution in toolchain/esxdos); here we produce fuzix.bin + rootfs.img.
# ---------------------------------------------------------------------------

# ZX driver headers (zxuno.h, devinput.h in kernel/dev/zx).
list(PREPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/dev/zx)

# SDCC bank base addresses for the generated .lnk (mirror fuzix.lnk).
set(LINK_SDCC_BASES "_FONTCOMMON=0x0100" "_COMMONDATA=0x2000" "_CODE=0x4000")

# esxdos .hdf/.mmc image: hdfstart + FAT16 (esxdos + loader + FUZIX.BIN) + the
# FUZIX root filesystem. Uses host-built mkfs_fat + hdfmonkey + toolchain/esxdos.
set(DISKIMAGE_STYLE "zxuno-esxdos")

set(_seg_code2   EXTRA --codeseg CODE2)
set(_seg_code    EXTRA --codeseg CODE)
set(_seg_video   EXTRA --codeseg VIDEO)
set(_seg_font    EXTRA --constseg FONT)
set(_seg_discard EXTRA --codeseg DISCARD --constseg DISCARD)

# --- Platform low level (crt0 FIRST) + video + main ---
fuzix_compile(kernel/platform/zxuno/crt0.s)
fuzix_compile(kernel/platform/zxuno/commonmem.s)
fuzix_compile(kernel/platform/zxuno/zx128.s)
fuzix_compile(kernel/platform/zxuno/zxvideo.s)
fuzix_compile(kernel/platform/zxuno/main.c)
fuzix_compile(kernel/platform/zxuno/discard.c ${_seg_discard})
fuzix_compile(kernel/dev/zx/zxuno.c ${_seg_discard})

# --- Startup + version + CPU low level + user copy + tricks ---
fuzix_compile(kernel/core/start.c ${_seg_discard})
fuzix_compile(${GEN}/version.c    ${_seg_code})
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/cpu/z80/usermem_std-z80.s)
fuzix_compile(kernel/platform/zxuno/tricks.s)

# --- Core services ---
fuzix_compile(kernel/core/timer.c ${_seg_code2})
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/core/usermem.c ${_seg_code2})
fuzix_compile(kernel/platform/zxuno/devices.c)
fuzix_compile(kernel/core/devio.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/filesys.c ${_seg_code})
endif()
fuzix_compile(kernel/${BLK_SOURCE} ${_seg_code})
fuzix_compile(kernel/core/process.c ${_seg_code2})
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/inode.c)
endif()

# --- exec / loader ---
fuzix_compile(kernel/core/syscall_exec.c ${_seg_code2})
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c ${_seg_code2})
endif()

# --- syscalls ---
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs.c ${_seg_code2})
    fuzix_compile(kernel/core/syscall_fs2.c ${_seg_code2})
    fuzix_compile(kernel/core/syscall_fs3.c ${_seg_code2})
endif()
fuzix_compile(kernel/core/syscall_proc.c ${_seg_code2})
fuzix_compile(kernel/core/syscall_other.c ${_seg_code2})

# --- Console (CONFIG_VT/FONT8X8) + mm + input (CONFIG_INPUT) ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c ${_seg_video})
fuzix_compile(kernel/dev/font8x8.c ${_seg_font})
fuzix_compile(kernel/core/mm.c ${_seg_code2})
fuzix_compile(kernel/${MEMALLOC_SOURCE} ${_seg_code2})
fuzix_compile(kernel/${MM_SOURCE} ${_seg_code2})
fuzix_compile(kernel/core/swap.c ${_seg_code2})
fuzix_compile(kernel/core/devsys.c ${_seg_code2})
fuzix_compile(kernel/core/devinput.c ${_seg_code2})

# --- Platform tty + storage (TinySD + DivMMC + TinyDisk) + ZX input ---
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/zxuno/devtty.c)
endif()
fuzix_compile(kernel/dev/tinysd.c)
fuzix_compile(kernel/dev/tinysd_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/zx/divmmc.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/zx/devinput.c)
fuzix_compile(kernel/dev/zx/zxkeyboard.c)
