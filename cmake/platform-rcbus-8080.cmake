# ---------------------------------------------------------------------------
# Platform: rcbus-8080 (RC2014-style bus with an 8080 CPU card)   CPU: i8080
#
# A much fuller board than v8080: TinyDisk stack (IDE/PPIDE + SCSI/NCR5380 +
# CH375 USB), DS1302 RTC, joystick input. Mirrors platform-rcbus-8080/Makefile's
# `image` rule and its loader-based IDE disk image.
# ---------------------------------------------------------------------------

# ld8080: -C load origin (0x0100), -S split/common base (0xF000, 8K common).
set(LINK_FLAGS -b -C 0x0100 -S 0xF000 -f CLDBbXSs)

# This board boots via a loader + partitioned IDE image, not a boot floppy.
set(DISKIMAGE_STYLE "rcbus-ide")

# --- Platform core ---
fuzix_compile(kernel/platform/rcbus-8080/crt0.S)          # FIRST (load origin)
fuzix_compile(kernel/platform/rcbus-8080/devices.c)
fuzix_compile(kernel/platform/rcbus-8080/main.c)
fuzix_compile(kernel/platform/rcbus-8080/discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/rcbus-8080/commonmem.S)
fuzix_compile(kernel/platform/rcbus-8080/tricks.S)
fuzix_compile(kernel/platform/rcbus-8080/rcbus-8080.S)
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/rcbus-8080/devtty.c)
endif()

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})

# --- Memory management ---
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})

# --- I/O, process, filesystem ---
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

# --- TinyDisk block stack + peripherals ---
if(FUZIX_DRIVER_TINYDISK)
    fuzix_compile(kernel/dev/tinydisk.c)
endif()
if(FUZIX_DRIVER_SCSI)
    fuzix_compile(kernel/dev/tinyscsi.c)
endif()
if(FUZIX_DRIVER_IDE)
    fuzix_compile(kernel/dev/tinyide.c)
endif()
if(FUZIX_DRIVER_TINYDISK)
    fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
endif()
if(FUZIX_DRIVER_IDE)
    fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
endif()
if(FUZIX_DRIVER_SCSI)
    fuzix_compile(kernel/dev/tinyscsi_discard.c EXTRA -Tdiscard)
endif()
if(FUZIX_DRIVER_IDE)
    fuzix_compile(kernel/platform/rcbus-8080/ppide.S)
endif()

# --- Input: joystick (platform) + core input layer ---
if(FUZIX_DRIVER_JOYSTICK)
    fuzix_compile(kernel/platform/rcbus-8080/devinput.c)   # platform joystick
    fuzix_compile(kernel/core/devinput.c)                  # core input layer
endif()

# --- SCSI back end ---
if(FUZIX_DRIVER_SCSI)
    fuzix_compile(kernel/platform/rcbus-8080/devscsi.c)
    fuzix_compile(kernel/platform/rcbus-8080/ncr5380.S)
endif()

# --- CH375 USB ---
if(FUZIX_DRIVER_CH375)
    fuzix_compile(kernel/dev/ch375.c)
endif()

# --- Block device + RTC ---
fuzix_compile(kernel/${BLK_SOURCE})
if(FUZIX_DRIVER_RTC_DS1302)
    fuzix_compile(kernel/dev/ds1302.c)
    fuzix_compile(kernel/dev/ds1302_discard.c EXTRA -Tdiscard)
    fuzix_compile(kernel/dev/ds1302_8080.S)
endif()

# --- CPU user copy (linked last, before libc) ---
fuzix_compile(${CPU_USERMEM})
