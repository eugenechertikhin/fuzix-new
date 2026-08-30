# ---------------------------------------------------------------------------
# Platform: z80pack (Z80Pack virtual Z80 machine)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# / disk-image parameters. Mirrors platform-z80pack/Makefile's `image` rule.
# ---------------------------------------------------------------------------

# Shared z80pack driver tree: PREPEND so its devfd.h (declares hd_*) wins over
# the generic kernel/dev/devfd.h.  Only z80pack-family boards pull this tree.
list(PREPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/dev/z80pack)

# ldz80: -C load origin (0x0088), -S split/common base (0xF400),
#        -X discard segment base (0xE900).
set(LINK_FLAGS -b -C 0x0088 -S 0xF400 -X 0xE900 -f CLDBbXSs)
# Load origin is 0x0088 -> skip 136 bytes onto the boot floppy.
set(DISK_SKIP 136)

# --- Platform ---
fuzix_compile(kernel/platform/z80pack/crt0.S)        # FIRST (load origin)
fuzix_compile(kernel/platform/z80pack/commonmem.S)
fuzix_compile(kernel/platform/z80pack/z80pack.S)
fuzix_compile(kernel/platform/z80pack/main.c)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(${CPU_USERMEM})

fuzix_compile(kernel/platform/z80pack/tricks.S)
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/core/usermem.c)

# --- Drivers (block) + platform devices ---
if(FUZIX_DRIVER_Z80PACK_FD)
    fuzix_compile(kernel/dev/z80pack/devfd.c)
endif()
fuzix_compile(kernel/platform/z80pack/devices.c)

# --- I/O, filesystem, process ---
fuzix_compile(kernel/core/devio.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/filesys.c)
endif()
fuzix_compile(kernel/${BLK_SOURCE})
fuzix_compile(kernel/core/process.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/inode.c)
endif()

# --- exec / loader ---
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c)
endif()
fuzix_compile(kernel/core/syscall_exec.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs.c)
    fuzix_compile(kernel/core/syscall_fs2.c)
    fuzix_compile(kernel/core/syscall_fs3.c)
endif()
fuzix_compile(kernel/core/syscall_proc.c)
fuzix_compile(kernel/core/syscall_other.c)

# --- tty / memory / swap / sys devices ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/core/devsys.c)

# --- Character drivers (z80pack) ---
if(FUZIX_DRIVER_Z80PACK_LPR)
    fuzix_compile(kernel/dev/z80pack/devlpr.c)
endif()
if(FUZIX_DRIVER_Z80PACK_TTY)
    fuzix_compile(kernel/dev/z80pack/devtty.c)
endif()
if(FUZIX_DRIVER_Z80PACK_RTC)
    fuzix_compile(kernel/dev/z80pack/devrtc.c)
endif()
