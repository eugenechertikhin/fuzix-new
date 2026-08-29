# ---------------------------------------------------------------------------
# Platform: rcbus-super8 (RC2014-style bus with a Zilog Super8 CPU card)
# CPU: super8
#
# Sister board to rcbus-z8: TinyDisk block layer over SD + IDE, no VT/net/SCSI.
# Mirrors platform-rcbus-super8/Makefile's `image` rule. ldsuper8 emits the
# loadable binary directly (LINK_STYLE fcc-raw, set in cpu-super8.cmake), so
# there is no pack85 step.
# ---------------------------------------------------------------------------

# rcbus-super8/tricks.S reuses the Z8 kernel def upstream
# (#include "../../cpu-z8/kernel-z8.def"), so put the ported cpu/z8 directory on
# the include path for this board.
list(APPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/cpu/z8)

# ldsuper8: -i (separate I/D), -Z 48 (zero-page reserve), -C load origin
# (0x0100), -D data origin (0x0000, distinct CPU space), -S split/common base
# (0xF000). The Super8's Z space overlaps D but is a different CPU space.
set(LINK_FLAGS -i -b -Z 48 -C 0x0100 -D 0x0000 -S 0xF000 -f CXSDLBbs)

# Boots via a separate loader + partitioned IDE image upstream; not mechanised
# here -> only fuzix.bin is produced.
set(DISKIMAGE_STYLE none)

# --- Platform core ---
fuzix_compile(kernel/platform/rcbus-super8/crt0.S)        # FIRST (load origin)
fuzix_compile(kernel/platform/rcbus-super8/devices.c)
fuzix_compile(kernel/platform/rcbus-super8/main.c)
fuzix_compile(kernel/platform/rcbus-super8/discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/rcbus-super8/commonmem.S)
fuzix_compile(kernel/platform/rcbus-super8/tricks.S)
fuzix_compile(kernel/platform/rcbus-super8/rcbus-super8.S)
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/rcbus-super8/devtty.c)
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
