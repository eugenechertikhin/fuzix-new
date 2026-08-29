# ---------------------------------------------------------------------------
# Platform: rcbus-tp128 (RC2014 / rcbus with 128K TP board)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-rcbus-tp128/Makefile's `image` rule.
# ---------------------------------------------------------------------------

# ldz80: -S split/common base (0x0080), no separate load origin/discard args.
set(LINK_FLAGS -b -S 0x0080 -f SsLDBbXC)
# Upstream attaches a boot block (loader.bin) and dd's kernel + filesystem into
# a partitioned disk image. Not mechanised here -> build produces fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/rcbus-tp128/crt0.S)        # FIRST (load origin)
fuzix_compile(kernel/platform/rcbus-tp128/commonmem.S)
fuzix_compile(kernel/platform/rcbus-tp128/tp128.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)

fuzix_compile(kernel/platform/rcbus-tp128/tricks.S)
fuzix_compile(kernel/platform/rcbus-tp128/main.c)
fuzix_compile(kernel/platform/rcbus-tp128/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/rcbus-tp128/devices.c)
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
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/${MEMALLOC_SOURCE})
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/core/devsys.c)

# --- Character + block drivers ---
fuzix_compile(kernel/platform/rcbus-tp128/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/rcbus-tp128/ide.S)
fuzix_compile(kernel/dev/ds1302.c)
fuzix_compile(kernel/dev/ds1302_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/ds1302_rcbusu.S)

# --- Networking (WizNet) ---
if(FUZIX_NET)
    fuzix_compile(kernel/dev/net/net_native.c)
    fuzix_compile(kernel/dev/net/net_w5x00.c)
    fuzix_compile(kernel/dev/net/net_w5300.c)
    fuzix_compile(kernel/platform/rcbus-tp128/wiznet.c)
endif()
