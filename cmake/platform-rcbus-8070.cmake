# ---------------------------------------------------------------------------
# Platform: rcbus-8070 (RC2014-style bus with a National INS8070 CPU card)
# CPU: 8070
#
# Compact board: TinyDisk over IDE + a DS12885 RTC, no VT/net/SCSI/SD. Mirrors
# platform-rcbus-8070/Makefile's `image` rule. The 8070 linker (ld8070) emits
# the loadable binary directly (LINK_STYLE fcc-raw, set in cpu-8070.cmake), so
# there is no pack85 step. Memory manager is the 4x16K flash-friendly banked
# model (mm/bank16kfc.c, CONFIG_BANK16FC) selected per board in CMakeLists.txt.
# ---------------------------------------------------------------------------

# ld8070: -C load origin (0x0000), -S split/common base (0xF000), -Z 0xFFC0
# (zero-page / vector reserve). No -f flag on this board.
set(LINK_FLAGS -b -C 0x0000 -S 0xF000 -Z 0xFFC0)

# Boots via a separate loader + partitioned IDE image upstream; not mechanised
# here -> only fuzix.bin is produced.
set(DISKIMAGE_STYLE none)

# --- Platform core ---
fuzix_compile(kernel/platform/rcbus-8070/crt0.S)          # FIRST (load origin)
fuzix_compile(kernel/platform/rcbus-8070/commonmem.S)
fuzix_compile(kernel/platform/rcbus-8070/rcbus-8070.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})

fuzix_compile(kernel/platform/rcbus-8070/tricks.S)
fuzix_compile(kernel/platform/rcbus-8070/main.c)
fuzix_compile(kernel/platform/rcbus-8070/discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/rcbus-8070/devices.c)

# --- TinyDisk block stack (IDE) + RTC ---
if(FUZIX_DRIVER_TINYDISK)
    fuzix_compile(kernel/dev/tinydisk.c)
    fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
endif()
if(FUZIX_DRIVER_IDE)
    fuzix_compile(kernel/dev/tinyide.c)
    fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
endif()
fuzix_compile(kernel/dev/ds12885.c)                  # DS12885 RTC
fuzix_compile(kernel/${MEMALLOC_SOURCE})

# --- I/O, filesystem, process ---
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
fuzix_compile(kernel/${MM_SOURCE})                   # bank16kfc (CONFIG_BANK16FC)
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/devsys.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs2.c)
    fuzix_compile(kernel/core/syscall_fs3.c)
endif()

# --- exec / loader ---
fuzix_compile(kernel/core/syscall_exec.c)
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c)
endif()
fuzix_compile(kernel/${BLK_SOURCE})

# --- CPU user copy + platform tty ---
fuzix_compile(kernel/core/usermem.c)
fuzix_compile(${CPU_USERMEM})
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/rcbus-8070/devtty.c)
endif()
