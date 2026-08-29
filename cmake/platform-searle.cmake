# ---------------------------------------------------------------------------
# Platform: searle (Grant Searle / Z80 + CF/IDE SBC)   CPU: z80u (THUNKED)
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-searle/Makefile's `image` rule. THUNKED z80u
# variant: ${CPU_LOWLEVEL} resolves to lowlevel-z80u-thunked.o when built with
# -DFUZIX_Z80U_MODE=thunked. Swap-only board (mm/simple).
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0100), -S split/common base (0xF000).
set(LINK_FLAGS -b -C 0x0100 -S 0xF000 -f CLDBbXSs)
# Upstream image is packed via loader.bin + dd into a partitioned disk image.
# Not mechanised here -> build produces fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/searle/crt0.S)         # FIRST (load origin)
fuzix_compile(kernel/platform/searle/commonmem.S)
fuzix_compile(kernel/platform/searle/searle.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)
fuzix_compile(kernel/platform/searle/usermem.S)
fuzix_compile(kernel/platform/searle/tricks.S)
fuzix_compile(kernel/platform/searle/main.c)
fuzix_compile(kernel/platform/searle/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/searle/devices.c)
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

# --- Character + block drivers ---
fuzix_compile(kernel/platform/searle/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/searle/ide.S)
