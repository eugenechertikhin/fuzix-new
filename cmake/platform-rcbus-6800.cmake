# ---------------------------------------------------------------------------
# Platform: rcbus-6800 (RC2014-style bus with a Motorola 6800 CPU card)
# CPU: 6800
#
# TinyDisk over IDE, a serial console, and a separate bootstrap loader booting
# from a partitioned IDE disk. Mirrors platform-rcbus-6800/Makefile's `image`
# rule (the ordered link line below is a faithful transcription of it). The 6800
# linker (ld6800) emits the loadable binary directly (LINK_STYLE fcc-raw, set in
# cpu-6800.cmake), so there is no pack85 step. Memory manager is the 4x16K
# flash-friendly banked model (mm/bank16kfc.c, CONFIG_BANK16FC), selected per
# board in CMakeLists.txt.
# ---------------------------------------------------------------------------

# ld6800: -C load origin (0x0100), -S split/common base (0xF200), -Z 0x20
# (zero-page reserve).
set(LINK_FLAGS -b -C 0x0100 -S 0xF200 -Z 0x20)

# Boots via a separate loader + partitioned 40MB IDE image.
set(DISKIMAGE_STYLE "rcbus-6800")

# --- Platform low level (crt0 FIRST) + banking ---
fuzix_compile(kernel/platform/rcbus-6800/crt0.S)          # FIRST (load origin)
fuzix_compile(kernel/platform/rcbus-6800/commonmem.S)
fuzix_compile(kernel/platform/rcbus-6800/rcbus-6800.S)

# --- Startup (discard) + version + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})

# --- tricks + main + discard + core services ---
fuzix_compile(kernel/platform/rcbus-6800/tricks.S)
fuzix_compile(kernel/platform/rcbus-6800/main.c)
fuzix_compile(kernel/platform/rcbus-6800/discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/rcbus-6800/devices.c)

# --- TinyDisk block stack (IDE) ---
if(FUZIX_DRIVER_TINYDISK)
    fuzix_compile(kernel/dev/tinydisk.c)
    fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
endif()
if(FUZIX_DRIVER_IDE)
    fuzix_compile(kernel/dev/tinyide.c)
    fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
endif()
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
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c)
endif()
fuzix_compile(kernel/core/syscall_exec.c)
fuzix_compile(kernel/${BLK_SOURCE})

# --- CPU user copy + platform tty ---
fuzix_compile(kernel/core/usermem.c)
fuzix_compile(${CPU_USERMEM})
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/rcbus-6800/devtty.c)
endif()
