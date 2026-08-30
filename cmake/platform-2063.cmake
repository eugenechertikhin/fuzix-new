# ---------------------------------------------------------------------------
# Platform: 2063 (Z80 2063 SBC)                                    CPU: z80 (SDCC)
#
# John Winans' Z80-2063 "Z80 Retro" single board computer: Z80 with fixed-bank RAM
# banking, an SD card (bit-banged SPI, TinyDisk/TinySD stack), a Z80 SIO
# serial console, a TMS9918 VDP text/graphics console (core vt.c + vdp1 + a
# 6x8 font) and joystick input. config.h hard-wires CONFIG_VT and CONFIG_INPUT,
# so the video/input sources are compiled here unconditionally rather than
# under FUZIX_VT / FUZIX_INPUT.
#
# The ordered source list below is a faithful transcription of the upstream
# platform-2063/fuzix.lnk link line. Each C source carries the SDCC segment
# override (EXTRA --codeseg/--constseg ...) that the upstream top-level
# Makefile assigns it via its CROSS_CC_SEG* source lists:
#   (default / C1 / SEG1) -> _CODE/CONST (no override)
#   C2/C3/SYS*/NETWORK    -> --codeseg CODE2
#   C4 (filesys/version/blk) -> --codeseg CODE
#   discard (CD/*_discard)   -> --codeseg DISCARD --constseg DISCARD
#   vt.c   -> --codeseg VIDEO
#   fonts  -> --constseg FONT
# ---------------------------------------------------------------------------

# SDCC bank base addresses for the generated .lnk (mirror fuzix.lnk).
set(LINK_SDCC_BASES "_CODE=0x0100" "_COMMONMEM=0xF000" "_SERIAL=0xFE00")

# Boot floppy + partitioned SD image (dd of parttab + filesys + kernel + boot).
set(DISKIMAGE_STYLE "2063")

set(_seg_code2   EXTRA --codeseg CODE2)
set(_seg_code    EXTRA --codeseg CODE)
set(_seg_video   EXTRA --codeseg VIDEO)
set(_seg_font    EXTRA --constseg FONT)
set(_seg_discard EXTRA --codeseg DISCARD --constseg DISCARD)

# --- Platform low level (crt0 FIRST) + banking ---
fuzix_compile(kernel/platform/2063/crt0.s)
fuzix_compile(kernel/platform/2063/commonmem.s)
fuzix_compile(kernel/platform/2063/2063.s)

# --- Startup (discard) + version + CPU low level + tricks ---
fuzix_compile(kernel/core/start.c ${_seg_discard})
fuzix_compile(${GEN}/version.c    ${_seg_code})
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/platform/2063/tricks.s)

# --- Main + core services ---
fuzix_compile(kernel/platform/2063/main.c)
fuzix_compile(kernel/core/timer.c ${_seg_code2})
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/2063/devices.c)
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
endif()
fuzix_compile(kernel/core/syscall_proc.c ${_seg_code2})
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs2.c ${_seg_code2})
    fuzix_compile(kernel/core/syscall_fs3.c ${_seg_code2})
endif()
fuzix_compile(kernel/core/syscall_other.c ${_seg_code2})

# --- Memory manager + allocator + core mm services ---
fuzix_compile(kernel/${MEMALLOC_SOURCE} ${_seg_code2})
fuzix_compile(kernel/core/mm.c ${_seg_code2})
fuzix_compile(kernel/core/swap.c ${_seg_code2})
fuzix_compile(kernel/${MM_SOURCE} ${_seg_code2})

# --- Console: tty + VDP video + font (CONFIG_VT hard-wired) ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c ${_seg_video})
fuzix_compile(kernel/dev/font6x8.c ${_seg_font})

# --- Input layer (CONFIG_INPUT hard-wired) + devsys + user copy ---
fuzix_compile(kernel/core/devinput.c ${_seg_code2})
fuzix_compile(kernel/core/devsys.c ${_seg_code2})
fuzix_compile(kernel/core/usermem.c ${_seg_code2})

# --- Platform drivers ---
fuzix_compile(kernel/platform/2063/discard.c ${_seg_discard})
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/2063/devtty.c)
endif()
fuzix_compile(kernel/platform/2063/devlpr.c)
fuzix_compile(kernel/platform/2063/devinput.c)      # joystick hooks

# --- TinyDisk + TinySD block stack ---
if(FUZIX_DRIVER_TINYDISK)
    fuzix_compile(kernel/dev/tinydisk_discard.c ${_seg_discard})
    fuzix_compile(kernel/dev/tinydisk.c)
    fuzix_compile(kernel/dev/tinysd_discard.c ${_seg_discard})
    fuzix_compile(kernel/dev/tinysd.c)
endif()

# --- Platform assembly back ends (SD SPI, SIO serial, VDP) ---
fuzix_compile(kernel/platform/2063/sd.s)
fuzix_compile(kernel/platform/2063/serial.s)
fuzix_compile(kernel/platform/2063/vdp.s)
