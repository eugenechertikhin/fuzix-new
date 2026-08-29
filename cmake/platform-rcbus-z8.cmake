# ---------------------------------------------------------------------------
# Platform: rcbus-z8 (RC2014-style bus with a Zilog Z8 CPU card)   CPU: z8
#
# A compact board: TinyDisk block layer over SD + IDE, no VT/net/SCSI/RTC.
# Mirrors platform-rcbus-z8/Makefile's `image` rule. The z8 linker (ldz8)
# emits the loadable binary directly (LINK_STYLE fcc-raw, set in cpu-z8.cmake),
# so there is no pack85 step.
#
# NOTE: upstream rcbus-z8 is an unfinished sketch and ships NO plt_ide.h even
# though its config.h enables CONFIG_TD_IDE. We provide one copied from the
# sibling rcbus-super8 board, which shares the identical RCBus indirect-IDE
# register map (CONFIG_TINYIDE_INDIRECT); without it tinyide.c cannot compile.
# ---------------------------------------------------------------------------

# ldz8: -Z 48 (zero-page reserve), -C load origin (0x0200), -S split/common
# base (0xF000).
set(LINK_FLAGS -b -Z 48 -C 0x0200 -S 0xF000 -f CLDBbXSs)

# Boots via a separate loader + partitioned IDE image (custom dd recipe upstream);
# not mechanised here -> only fuzix.bin is produced.
set(DISKIMAGE_STYLE none)

# --- Platform core ---
fuzix_compile(kernel/platform/rcbus-z8/crt0.S)            # FIRST (load origin)
fuzix_compile(kernel/platform/rcbus-z8/devices.c)
fuzix_compile(kernel/platform/rcbus-z8/main.c)
fuzix_compile(kernel/platform/rcbus-z8/discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/rcbus-z8/commonmem.S)
fuzix_compile(kernel/platform/rcbus-z8/tricks.S)
fuzix_compile(kernel/platform/rcbus-z8/rcbus-z8.S)
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/rcbus-z8/devtty.c)
endif()

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})

# --- Memory management + core services ---
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})
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

# --- TinyDisk block stack (SD + IDE) ---
if(FUZIX_DRIVER_TINYDISK)
    fuzix_compile(kernel/dev/tinydisk.c)
endif()
fuzix_compile(kernel/dev/tinysd.c)                # SD is the board's storage
if(FUZIX_DRIVER_IDE)
    fuzix_compile(kernel/dev/tinyide.c)
endif()
if(FUZIX_DRIVER_TINYDISK)
    fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
endif()
fuzix_compile(kernel/dev/tinysd_discard.c EXTRA -Tdiscard)
if(FUZIX_DRIVER_IDE)
    fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
endif()

# --- Block device ---
fuzix_compile(kernel/${BLK_SOURCE})

# --- CPU user copy (linked last, before libc) ---
fuzix_compile(${CPU_USERMEM})
