# ---------------------------------------------------------------------------
# Platform: cpc6128 (Amstrad CPC 6128 / 664 with 128K)          CPU: z80 (SDCC)
#
# Single-image, swap-only (mm/simple.c, but CONFIG_MULTI on) Amstrad CPC. CPC
# video text console (vt.c + cpcvideo + 8x8 font), the CPC keyboard as input,
# an internal RAM disk, and multiple storage back ends: the uPD765 floppy
# (devfdc765 + fdc765), CPC-IDE/Albireo (TinyIDE/TinyDisk) and a CH375. config.h
# hard-wires CONFIG_VT / CONFIG_INPUT; CONFIG_NET and CONFIG_KMOD are OFF (their
# stub objects link empty upstream), so net/kmod are omitted here.
#
# The ordered list transcribes platform-cpc6128/fuzix.lnk. Segment layout: the
# board Makefile compiles its platform/driver C into CODE3 and its rules.mk puts
# the SYS5 group there too; the core code groups keep the default CODE/CODE2.
# ---------------------------------------------------------------------------

# CPC driver headers (cpcide/devinput/ch375 in kernel/dev/cpc).
list(PREPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/dev/cpc)

set(LINK_SDCC_BASES "_CODE=0x0100" "_COMMONMEM=0xF280")
set(DISKIMAGE_STYLE "none")   # .sna/.dsk need createSnapshot/raw2dskcpc/sfdisk

set(_seg_code2   EXTRA --codeseg CODE2)
set(_seg_code3   EXTRA --codeseg CODE3)   # platform/driver C + SYS5
set(_seg_code    EXTRA --codeseg CODE)
set(_seg_video   EXTRA --codeseg VIDEO)
set(_seg_font    EXTRA --constseg FONT)
set(_seg_discard EXTRA --codeseg DISCARD --constseg DISCARD)

# --- Platform low level + video + main ---
fuzix_compile(kernel/platform/cpc6128/crt0.s)
fuzix_compile(kernel/platform/cpc6128/commonmem.s)
fuzix_compile(kernel/platform/cpc6128/cpc6128.s)
fuzix_compile(kernel/platform/cpc6128/rd_cpcsme.c ${_seg_code3})
fuzix_compile(kernel/platform/cpc6128/cpcvideo.s)
fuzix_compile(kernel/platform/cpc6128/main.c ${_seg_code3})
fuzix_compile(kernel/platform/cpc6128/discard.c ${_seg_discard})

# --- Startup + version + CPU low level + tricks ---
fuzix_compile(kernel/core/start.c ${_seg_discard})
fuzix_compile(${GEN}/version.c    ${_seg_code})
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/cpu/z80/usermem_std-z80.s)
fuzix_compile(kernel/platform/cpc6128/tricks.s)

# --- Core services (core C3 -> CODE2) ---
fuzix_compile(kernel/core/timer.c ${_seg_code2})
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/core/usermem.c ${_seg_code2})
fuzix_compile(kernel/platform/cpc6128/devices.c ${_seg_code3})
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

# --- Console + mm + input ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c ${_seg_video})
fuzix_compile(kernel/dev/font8x8.c ${_seg_font})
fuzix_compile(kernel/core/mm.c ${_seg_code2})
fuzix_compile(kernel/${MEMALLOC_SOURCE} ${_seg_code3})   # SYS5 -> CODE3
fuzix_compile(kernel/${MM_SOURCE} ${_seg_code2})         # simple (swap-only)
fuzix_compile(kernel/core/swap.c ${_seg_code2})
fuzix_compile(kernel/core/devsys.c ${_seg_code2})
fuzix_compile(kernel/core/devinput.c ${_seg_code2})      # core input layer

# --- Platform tty + storage (IDE/TinyDisk + fdc765 + CH375) + CPC input ---
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/cpc6128/devtty.c ${_seg_code3})
endif()
fuzix_compile(kernel/dev/tinyide.c ${_seg_code3})
fuzix_compile(kernel/dev/tinyide_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/cpc/cpcide.c ${_seg_code3})
fuzix_compile(kernel/dev/tinydisk.c ${_seg_code3})
fuzix_compile(kernel/dev/tinydisk_discard.c ${_seg_discard})
fuzix_compile(kernel/dev/cpc/devinput.c ${_seg_code3})   # CPC joystick input
fuzix_compile(kernel/dev/cpc/cpckeyboard.c ${_seg_code3})
fuzix_compile(kernel/dev/devfdc765.c ${_seg_code3})
fuzix_compile(kernel/platform/cpc6128/fdc765.s)
fuzix_compile(kernel/dev/ch375.c ${_seg_code3})
fuzix_compile(kernel/dev/cpc/albireo.c ${_seg_code3})
fuzix_compile(kernel/platform/cpc6128/devrd.c ${_seg_code3})
