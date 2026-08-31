# ---------------------------------------------------------------------------
# Platform: zxevo (ZX Evolution, ATM/Pentagon-style)            CPU: z80 (SDCC)
#
# Single-image ZX board with 4x16K user banking (mm/bank16k.c), a ZX video
# console (vt.c + video + 8x8 font), the ZX keyboard input, and IDE + SD storage
# via the classic block layer (devide + devsd + blkdev + mbr) plus the EVO MMC.
# config.h hard-wires CONFIG_VT / CONFIG_INPUT / CONFIG_FONT8X8. Transcribes
# platform-zxevo/fuzix.lnk. Uses the plain SDCC z80 low level. CONFIG_NET is
# NOT enabled upstream (the net stub objects link empty), so net is omitted.
# ---------------------------------------------------------------------------

list(PREPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/dev/zx)

set(LINK_SDCC_BASES "_CODE=0x0100" "_COMMONDATA=0xF200" "_DISCARD=0xE200")
set(DISKIMAGE_STYLE "none")   # esxdos/FAT loaders need external packaging

set(_seg_code2   EXTRA --codeseg CODE2)
set(_seg_code    EXTRA --codeseg CODE)
set(_seg_video   EXTRA --codeseg VIDEO)
set(_seg_font    EXTRA --constseg FONT)
set(_seg_discard EXTRA --codeseg DISCARD --constseg DISCARD)

# --- Platform low level + video + main ---
fuzix_compile(kernel/platform/zxevo/crt0.s)
fuzix_compile(kernel/platform/zxevo/commonmem.s)
fuzix_compile(kernel/platform/zxevo/zxevo.s)
fuzix_compile(kernel/platform/zxevo/video.s)
fuzix_compile(kernel/platform/zxevo/main.c)
fuzix_compile(kernel/platform/zxevo/discard.c ${_seg_discard})

# --- Startup + version + CPU low level + tricks ---
fuzix_compile(kernel/core/start.c ${_seg_discard})
fuzix_compile(${GEN}/version.c    ${_seg_code})
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/cpu/z80/usermem_std-z80.s)
fuzix_compile(kernel/platform/zxevo/tricks.s)

# --- Core services ---
fuzix_compile(kernel/core/timer.c ${_seg_code2})
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/core/usermem.c ${_seg_code2})
fuzix_compile(kernel/platform/zxevo/devices.c)
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

# --- Console + mm + input ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c ${_seg_video})
fuzix_compile(kernel/dev/font8x8.c ${_seg_font})
fuzix_compile(kernel/core/mm.c ${_seg_code2})
fuzix_compile(kernel/${MEMALLOC_SOURCE} ${_seg_code2})
fuzix_compile(kernel/${MM_SOURCE} ${_seg_code2})     # bank16k
fuzix_compile(kernel/core/swap.c ${_seg_code2})
fuzix_compile(kernel/core/devsys.c ${_seg_code2})
fuzix_compile(kernel/core/devinput.c ${_seg_code2})

# --- Platform tty + storage (classic IDE/SD block layer) + ZX input ---
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/zxevo/devtty.c)
endif()
fuzix_compile(kernel/dev/devide.c)
fuzix_compile(kernel/dev/devide_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/devsd.c)
fuzix_compile(kernel/dev/devsd_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/zx/evommc.c)
fuzix_compile(kernel/dev/mbr.c)
fuzix_compile(kernel/dev/blkdev.c)
fuzix_compile(kernel/dev/zx/devinput.c)
fuzix_compile(kernel/dev/zx/zxkeyboard.c)
