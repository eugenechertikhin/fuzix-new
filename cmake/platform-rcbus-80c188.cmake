# ---------------------------------------------------------------------------
# Platform: rcbus-80c188 (RC2014-style bus with an Intel 80C188 card)  CPU: i8086
#
# gcc-kind (ia16-elf) target like ibmpc: links with a linker script (fuzix.ld)
# via ia16-elf-ld producing the kernel image directly (LINK_STYLE ld-elf, set
# in cpu-i8086.cmake). Mirrors platform-rcbus-80c188/Makefile's `image` rule.
# crt0 is pulled in first by STARTUP(crt0.o) in fuzix.ld; we still compile it so
# the object exists for the linker.
#
# Swap-only board (config.h: CONFIG_SWAP_ONLY) -> mm/simple.c, selected per
# board in CMakeLists.txt (FUZIX_MM=simple). Build-testing only (no real ia16
# task switching upstream), so no disk-image packaging.
# ---------------------------------------------------------------------------

set(LINK_SCRIPT "${KDIR}/platform/rcbus-80c188/fuzix.ld")
set(DISKIMAGE_STYLE none)

# --- Startup + core + CPU low level ---
fuzix_compile(kernel/platform/rcbus-80c188/crt0.S)   # STARTUP(crt0.o) in fuzix.ld
fuzix_compile(kernel/core/start.c)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/platform/rcbus-80c188/main.c)

# --- Memory / scheduling ---
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/${MM_SOURCE})                   # simple (CONFIG_SWAP_ONLY)
fuzix_compile(kernel/${MEMALLOC_SOURCE})             # memalloc_none (_memalloc/_memfree)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/rcbus-80c188/devices.c)

# --- I/O, filesystem, process ---
fuzix_compile(kernel/core/tty.c)
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
fuzix_compile(kernel/core/devsys.c)
fuzix_compile(kernel/core/usermem.c)

# --- exec / loader (16-bit split I/D) ---
fuzix_compile(kernel/core/syscall_exec.c)
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c)
endif()
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs2.c)
endif()
fuzix_compile(kernel/platform/rcbus-80c188/tricks.S)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs3.c)
endif()
fuzix_compile(kernel/${BLK_SOURCE})

# --- CPU user copy ---
fuzix_compile(${CPU_USERMEM})

# --- Block device stack (classic devide/blkdev + MBR) ---
fuzix_compile(kernel/dev/devide.c)
fuzix_compile(kernel/dev/devide_discard.c)
fuzix_compile(kernel/dev/blkdev.c)
fuzix_compile(kernel/dev/mbr.c)

# --- Platform low level + tty + libc ---
fuzix_compile(kernel/platform/rcbus-80c188/80c188.S)
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/rcbus-80c188/devtty.c)
endif()
fuzix_compile(kernel/platform/rcbus-80c188/libc.c)
