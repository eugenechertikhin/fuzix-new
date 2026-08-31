# ---------------------------------------------------------------------------
# Platform: zx+3 (Amstrad/Sinclair ZX Spectrum +3)              CPU: z80 (SDCC)
#
# Swap-only ZX +3: mm/simple.c, a ZX video console (vt.c + zxvideo + 8x8 font),
# ZX keyboard input, WIZnet W5x00 networking (CONFIG_NET), and multiple storage
# back ends: the built-in uPD765 floppy (devfdc765 + fdc765), TinyIDE/TinySD +
# DivIDE + ZXMMC. config.h hard-wires CONFIG_VT / CONFIG_INPUT / CONFIG_NET (but
# NOT CONFIG_KMOD, so the kmod stub is omitted). Transcribes platform-zx+3/
# fuzix.lnk. Its rules.mk remaps the SEG3 and SYS5 code groups to CODE3 (the
# default CODE region overflows), so those files carry --codeseg CODE3 here.
# ---------------------------------------------------------------------------

list(PREPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/dev/zx)

set(LINK_SDCC_BASES "_CODE=0x0100" "_COMMONMEM=0xF300")
set(DISKIMAGE_STYLE "none")   # plus3 .dsk packaging needs plus3boot/raw2dsk

set(_seg_code2   EXTRA --codeseg CODE2)
set(_seg_code3   EXTRA --codeseg CODE3)   # zx+3 SEG3/SYS5 remap
set(_seg_code    EXTRA --codeseg CODE)
set(_seg_video   EXTRA --codeseg VIDEO)
set(_seg_font    EXTRA --constseg FONT)
set(_seg_discard EXTRA --codeseg DISCARD --constseg DISCARD)

# --- Platform low level + video + main (platform C -> CODE3) ---
fuzix_compile(kernel/platform/zx+3/crt0.s)
fuzix_compile(kernel/platform/zx+3/commonmem.s)
fuzix_compile(kernel/platform/zx+3/plus3.s)
fuzix_compile(kernel/platform/zx+3/zxvideo.s)
fuzix_compile(kernel/platform/zx+3/main.c    ${_seg_code3})
fuzix_compile(kernel/platform/zx+3/discard.c ${_seg_discard})

# --- Startup + version + CPU low level + tricks ---
fuzix_compile(kernel/core/start.c ${_seg_discard})
fuzix_compile(${GEN}/version.c    ${_seg_code})
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/cpu/z80/usermem_std-z80.s)
fuzix_compile(kernel/platform/zx+3/tricks.s)

# --- Core services ---
fuzix_compile(kernel/core/timer.c ${_seg_code3})
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/core/usermem.c ${_seg_code3})
fuzix_compile(kernel/platform/zx+3/devices.c ${_seg_code3})
fuzix_compile(kernel/core/devio.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/filesys.c ${_seg_code})
endif()
fuzix_compile(kernel/${BLK_SOURCE} ${_seg_code})
fuzix_compile(kernel/core/process.c ${_seg_code2})
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/inode.c)
endif()

# --- exec / loader (SYS5 -> CODE3) ---
fuzix_compile(kernel/core/syscall_exec.c ${_seg_code3})
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c ${_seg_code3})
endif()

# --- syscalls ---
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs.c ${_seg_code2})
    fuzix_compile(kernel/core/syscall_fs2.c ${_seg_code2})
    fuzix_compile(kernel/core/syscall_fs3.c ${_seg_code2})
endif()
fuzix_compile(kernel/core/syscall_proc.c ${_seg_code2})
fuzix_compile(kernel/core/syscall_other.c ${_seg_code2})
fuzix_compile(kernel/core/syscall_net.c ${_seg_code2})   # CONFIG_NET

# --- Console + mm + input ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c ${_seg_video})
fuzix_compile(kernel/dev/font8x8.c ${_seg_font})
fuzix_compile(kernel/core/mm.c ${_seg_code3})
fuzix_compile(kernel/${MEMALLOC_SOURCE} ${_seg_code3})
fuzix_compile(kernel/${MM_SOURCE} ${_seg_code2})     # simple (swap-only)
fuzix_compile(kernel/core/swap.c ${_seg_code3})
fuzix_compile(kernel/core/devsys.c ${_seg_code3})
fuzix_compile(kernel/core/devinput.c ${_seg_code3})
fuzix_compile(kernel/core/network.c ${_seg_code2})       # CONFIG_NET

# --- Platform tty + storage (fdc765 floppy + TinyIDE/SD + DivIDE/ZXMMC) ---
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/zx+3/devtty.c ${_seg_code3})
endif()
fuzix_compile(kernel/dev/tinyide.c ${_seg_code3})
fuzix_compile(kernel/dev/tinyide_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/zx/divide.c ${_seg_code3})
fuzix_compile(kernel/dev/tinysd.c ${_seg_code3})
fuzix_compile(kernel/dev/tinysd_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/zx/zxmmc.c ${_seg_code3})
fuzix_compile(kernel/dev/tinydisk.c ${_seg_code3})
fuzix_compile(kernel/dev/tinydisk_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/zx/devinput.c ${_seg_code3})
fuzix_compile(kernel/dev/zx/zxkeyboard.c ${_seg_code3})
fuzix_compile(kernel/dev/devfdc765.c ${_seg_code3})
fuzix_compile(kernel/platform/zx+3/fdc765.s)
fuzix_compile(kernel/dev/net/net_w5x00.c)                # NOBJS -> default CODE
