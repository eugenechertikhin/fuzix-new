# ---------------------------------------------------------------------------
# Platform: rcbus-8085 (RC2014-style bus with an 80C85 CPU card)   CPU: i8085
#
# Like rcbus-8080 but for the 8085 (8/56K banking) and with a VT console:
# core vt.c + the TMS9918 VDP driver (vdp1) + a 6x8 font + joystick input, on
# top of the TinyDisk stack (IDE/PPIDE + SCSI/NCR5380 + CH375) and DS1302 RTC.
# Mirrors platform-rcbus-8085/Makefile's `image` rule. config.h hard-wires
# CONFIG_VT and CONFIG_INPUT, so the video/input sources are compiled
# unconditionally here rather than under FUZIX_VT / FUZIX_INPUT.
# ---------------------------------------------------------------------------

# ld8080: -C load origin (0x0100), -S split/common base (0xE000).
set(LINK_FLAGS -b -C 0x0100 -S 0xE000 -f CLDBbXSs)

# Boots via a loader + partitioned IDE image, like rcbus-8080.
set(DISKIMAGE_STYLE "rcbus-ide")

# --- Platform core ---
fuzix_compile(kernel/platform/rcbus-8085/crt0.S)          # FIRST (load origin)
fuzix_compile(kernel/platform/rcbus-8085/devices.c)
fuzix_compile(kernel/platform/rcbus-8085/main.c)
fuzix_compile(kernel/platform/rcbus-8085/discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/rcbus-8085/commonmem.S)
fuzix_compile(kernel/platform/rcbus-8085/tricks.S)
fuzix_compile(kernel/platform/rcbus-8085/rcbus-8085.S)
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/rcbus-8085/devtty.c)
endif()

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})

# --- Memory management + core services ---
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/core/devio.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/filesys.c)
endif()
fuzix_compile(kernel/core/process.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/inode.c)
    fuzix_compile(kernel/core/syscall_fs.c)
endif()
fuzix_compile(kernel/core/syscall_proc.c)
fuzix_compile(kernel/core/syscall_other.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c)              # console (CONFIG_VT hard-wired)
fuzix_compile(kernel/core/devsys.c)
fuzix_compile(kernel/core/usermem.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs2.c)
    fuzix_compile(kernel/core/syscall_fs3.c)
endif()

# --- exec / loader ---
fuzix_compile(kernel/core/syscall_exec.c)
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c)
endif()

# --- Input: joystick (platform) + core input layer (CONFIG_INPUT hard-wired) ---
fuzix_compile(kernel/platform/rcbus-8085/devinput.c)
fuzix_compile(kernel/core/devinput.c)

# --- Block device + allocator ---
fuzix_compile(kernel/${BLK_SOURCE})
fuzix_compile(kernel/${MEMALLOC_SOURCE})

# --- TinyDisk block stack ---
if(FUZIX_DRIVER_TINYDISK)
    fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
    fuzix_compile(kernel/dev/tinydisk.c)
endif()
if(FUZIX_DRIVER_IDE)
    fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
    fuzix_compile(kernel/dev/tinyide.c)
    fuzix_compile(kernel/platform/rcbus-8085/ppide.S)
endif()
if(FUZIX_DRIVER_CH375)
    fuzix_compile(kernel/dev/ch375.c)
endif()

# --- Video: TMS9918 VDP + font (CONFIG_VT hard-wired) ---
fuzix_compile(kernel/platform/rcbus-8085/vdp1.S)
fuzix_compile(kernel/dev/font6x8.c)

# --- SCSI back end ---
if(FUZIX_DRIVER_SCSI)
    fuzix_compile(kernel/dev/tinyscsi_discard.c EXTRA -Tdiscard)
    fuzix_compile(kernel/dev/tinyscsi.c)
    fuzix_compile(kernel/platform/rcbus-8085/devscsi.c)
    fuzix_compile(kernel/platform/rcbus-8085/ncr5380.S)
endif()

# --- RTC ---
if(FUZIX_DRIVER_RTC_DS1302)
    fuzix_compile(kernel/dev/ds1302.c)
    fuzix_compile(kernel/dev/ds1302_discard.c EXTRA -Tdiscard)
    fuzix_compile(kernel/dev/ds1302_8085.S)
endif()

# --- CPU user copy (linked last, before libc) ---
fuzix_compile(${CPU_USERMEM})
