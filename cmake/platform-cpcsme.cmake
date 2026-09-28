# ---------------------------------------------------------------------------
# Platform: cpcsme (Amstrad CPC + M4 board / "SME")             CPU: z80 (SDCC)
#
# Single-image Amstrad CPC build using the M4 wifi/SD board. Fixed-bank RAM
# (mm/bankfixed.c) with the THUNKED z80 low level (whole-64K switch, no shared
# common RAM window - lowlevel-z80-thunked.s + the platform's own usermem.s).
# CPC multi-VT console (vt.c + cpcvideo, CONFIG_VT_MULTI - no font table),
# CPC keyboard input, uPD765 floppy, CPC-IDE (TinyIDE/TinyDisk), CH375, a
# DS12885 RTC, and TCP/IP networking over the M4 board / a WIZnet W5x00.
#
# Segments follow the base cpu-z80 scheme (no board override): core SEG2/SEG3/
# SYS -> CODE2, platform/driver/net C -> CODE. Transcribes platform-cpcsme/
# fuzix.lnk. The bootable image is CPC-specific (BASIC loader + .dsk) and needs
# external tools, so DISKIMAGE is none here.
# ---------------------------------------------------------------------------

list(PREPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/dev/cpc -I${KDIR}/dev/net)

set(LINK_SDCC_BASES "_CODE=0x0100" "_COMMONMEM=0xF200")
set(DISKIMAGE_STYLE "none")

set(_seg_code2   EXTRA --codeseg CODE2)
set(_seg_video   EXTRA --codeseg VIDEO)
set(_seg_discard EXTRA --codeseg DISCARD --constseg DISCARD)

# --- Platform low level + video + main ---
fuzix_compile(kernel/platform/cpcsme/crt0.s)
fuzix_compile(kernel/platform/cpcsme/commonmem.s)
fuzix_compile(kernel/platform/cpcsme/cpcsme.s)
fuzix_compile(kernel/platform/cpcsme/cpcvideo.s)
fuzix_compile(kernel/platform/cpcsme/main.c)
fuzix_compile(kernel/platform/cpcsme/discard.c ${_seg_discard})

# --- Startup + version + THUNKED CPU low level + platform user copy + tricks ---
fuzix_compile(kernel/core/start.c ${_seg_discard})
fuzix_compile(${GEN}/version.c)
fuzix_compile(kernel/cpu/z80/lowlevel-z80-thunked.s)   # thunked (no common RAM)
fuzix_compile(kernel/platform/cpcsme/usermem.s)        # platform user copy
fuzix_compile(kernel/platform/cpcsme/tricks.s)

# --- Core services ---
fuzix_compile(kernel/core/timer.c ${_seg_code2})
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/core/usermem.c ${_seg_code2})
fuzix_compile(kernel/platform/cpcsme/devices.c)
fuzix_compile(kernel/dev/cpc/devinput.c)               # CPC input driver
fuzix_compile(kernel/core/devio.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/filesys.c)
endif()
fuzix_compile(kernel/${BLK_SOURCE})
fuzix_compile(kernel/core/process.c ${_seg_code2})
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/inode.c)
endif()

# --- exec / loader + syscalls (incl. net) ---
fuzix_compile(kernel/core/syscall_exec.c ${_seg_code2})
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c ${_seg_code2})
endif()
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs.c ${_seg_code2})
    fuzix_compile(kernel/core/syscall_fs2.c ${_seg_code2})
    fuzix_compile(kernel/core/syscall_fs3.c ${_seg_code2})
endif()
fuzix_compile(kernel/core/syscall_proc.c ${_seg_code2})
fuzix_compile(kernel/core/syscall_other.c ${_seg_code2})
fuzix_compile(kernel/core/syscall_net.c ${_seg_code2})   # CONFIG_NET (M4 board)

# --- Console + mm + input + net core ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c ${_seg_video})
fuzix_compile(kernel/core/mm.c ${_seg_code2})
fuzix_compile(kernel/core/swap.c ${_seg_code2})
fuzix_compile(kernel/${MEMALLOC_SOURCE} ${_seg_code2})
fuzix_compile(kernel/${MM_SOURCE} ${_seg_code2})         # bankfixed
fuzix_compile(kernel/core/devsys.c ${_seg_code2})
fuzix_compile(kernel/core/devinput.c ${_seg_code2})      # core input layer
fuzix_compile(kernel/core/network.c ${_seg_code2})       # CONFIG_NET

# --- M4 board + RTC + storage + keyboard + fdc + net back ends ---
fuzix_compile(kernel/platform/cpcsme/m4board.s)
fuzix_compile(kernel/platform/cpcsme/devm4board.c)
fuzix_compile(kernel/dev/cpc/ds12885.c)
fuzix_compile(kernel/dev/ds12885_z80.c)
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/cpcsme/devtty.c)
endif()
fuzix_compile(kernel/dev/cpc/td_block_io.c)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/cpc/cpcidesme.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/cpc/ch375.c)
fuzix_compile(kernel/dev/cpc/ch375_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/cpc/cpckeyboard.c)
fuzix_compile(kernel/platform/cpcsme/devfdc765.c)
fuzix_compile(kernel/platform/cpcsme/fdc765.s)
fuzix_compile(kernel/dev/net/net_native.c)
fuzix_compile(kernel/dev/net/net_w5x00.c)
fuzix_compile(kernel/platform/cpcsme/wiznet.c)
fuzix_compile(kernel/dev/cpc/net_m4board.c)
