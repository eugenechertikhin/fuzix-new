# ---------------------------------------------------------------------------
# Platform: v8080 (Z80Pack virtual 8080 machine)   CPU: i8080
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# / disk-image parameters. Mirrors platform-v8080/Makefile's `image` rule.
#
# Uses these caller-provided variables:
#   MM_SOURCE, MEMALLOC_SOURCE, BLK_SOURCE, CPU_LOWLEVEL, CPU_USERMEM,
#   GEN (generated dir with version.c), FUZIX_FS_NATIVE, FUZIX_EXECFORMAT,
#   driver options.
# ---------------------------------------------------------------------------

# Shared z80pack driver tree: PREPEND so its devfd.h (declares hd_*) wins over
# the generic kernel/dev/devfd.h.  Only z80pack-family boards pull this tree.
list(PREPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/dev/z80pack)

# ld8080: -C load origin, -S split/common base.
set(LINK_FLAGS -b -C 0x0100 -S 0xE800 -f CLDBbXSs)
# Bytes of the kernel image to skip when laying it on the boot floppy
# (= load origin, 0x0100).
set(DISK_SKIP 256)

# --- Platform ---
fuzix_compile(kernel/platform/v8080/crt0.S)          # FIRST (load origin)
fuzix_compile(kernel/platform/v8080/devices.c)
fuzix_compile(kernel/platform/v8080/main.c)
fuzix_compile(kernel/platform/v8080/commonmem.S)
fuzix_compile(kernel/platform/v8080/tricks.S)
fuzix_compile(kernel/platform/v8080/v8080.S)
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/v8080/devtty.c)
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

# --- CPU user copy + block device ---
fuzix_compile(${CPU_USERMEM})
fuzix_compile(kernel/${BLK_SOURCE})

# --- Drivers ---
if(FUZIX_DRIVER_Z80PACK_FD)
    fuzix_compile(kernel/dev/z80pack/devfd.c)
endif()
