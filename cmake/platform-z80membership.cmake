# ---------------------------------------------------------------------------
# Platform: z80membership (Z80 Membership Card)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-z80membership/Makefile's `image` rule.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0100), -S split/common base (0xF400).
set(LINK_FLAGS -b -C 0x0100 -S 0xF400 -f CLDBbXSs)
# Upstream image is packed via pack85 then dd'd into a partitioned disk with a
# separate FAT loader. Not mechanised here -> build produces fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform (crt0 FIRST = load origin) ---
fuzix_compile(kernel/platform/z80membership/crt0.S)
fuzix_compile(kernel/platform/z80membership/commonmem.S)
fuzix_compile(kernel/platform/z80membership/z80membership.S)
fuzix_compile(kernel/platform/z80membership/tricks.S)
fuzix_compile(kernel/platform/z80membership/main.c)
fuzix_compile(kernel/platform/z80membership/discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/z80membership/devices.c)
fuzix_compile(kernel/platform/z80membership/devtty.c)
fuzix_compile(kernel/platform/z80membership/sdcard.c)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(kernel/core/usermem.c)
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
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
fuzix_compile(kernel/core/syscall_exec.c)
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c)
endif()
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
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/devsys.c)

# --- Block drivers ---
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinysd.c)
fuzix_compile(kernel/dev/tinysd_discard.c EXTRA -Tdiscard)

# --- CPU low level ---
fuzix_compile(${CPU_LOWLEVEL})
