# ---------------------------------------------------------------------------
# Platform: pdp11 (DEC PDP-11, swap-only)   CPU: pdp11
#
# Mirrors platform-pdp11/Makefile's `image` rule. Links with a linker script
# (fuzix.ld) via pdp11-aout-ld, then objcopy -O binary. Swap-only machine, so
# the memory manager is `simple` + memalloc_none. No banking, no `-Tdiscard`.
# ---------------------------------------------------------------------------

# Linker script + no pack85-style origin flags.
set(LINK_SCRIPT "${KDIR}/platform/pdp11/fuzix.ld")
# This port has no disk-image packaging rule upstream (build-testing only).
set(DISKIMAGE_STYLE "none")

# --- Platform + CPU low level ---
fuzix_compile(kernel/platform/pdp11/crt0.S)          # FIRST (STARTUP in fuzix.ld)
fuzix_compile(kernel/core/start.c)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/platform/pdp11/main.c)

# --- Memory / scheduling ---
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/${MM_SOURCE})          # simple (swap-only)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/pdp11/devices.c)

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
fuzix_compile(kernel/platform/pdp11/pdp11.S)
fuzix_compile(kernel/core/syscall_proc.c)
fuzix_compile(kernel/core/syscall_other.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})    # memalloc_none
fuzix_compile(kernel/core/devsys.c)
fuzix_compile(kernel/core/usermem.c)

# --- exec / loader ---
fuzix_compile(kernel/core/syscall_exec.c)
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c)
endif()
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs2.c)
endif()
fuzix_compile(kernel/platform/pdp11/tricks.S)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs3.c)
endif()

# --- block device + CPU user copy + platform tty/libc ---
fuzix_compile(kernel/${BLK_SOURCE})
fuzix_compile(${CPU_USERMEM})
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/pdp11/devtty.c)
endif()
fuzix_compile(kernel/platform/pdp11/libc.c)
