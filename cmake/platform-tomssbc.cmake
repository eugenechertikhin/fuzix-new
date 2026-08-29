# ---------------------------------------------------------------------------
# Platform: tomssbc (Tom's SBC)   CPU: z80u (THUNKED low-level variant)
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-tomssbc/Makefile's `image` rule.
#
# THUNKED board: image line references cpu-z80u/lowlevel-z80u-thunked.o, which
# ${CPU_LOWLEVEL} already selects when built with -DFUZIX_Z80U_MODE=thunked.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0100), -S split/common base (0xF000).
set(LINK_FLAGS -b -C 0x0100 -S 0xF000 -f CLDBbXSs)
# Boot via a separate loader.bin/rompatch + dd (not a z80pack bootblock).
# Not mechanised here -> build produces fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/tomssbc/crt0.S)        # FIRST (load origin)
fuzix_compile(kernel/platform/tomssbc/commonmem.S)
fuzix_compile(kernel/platform/tomssbc/tom.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)
fuzix_compile(kernel/platform/tomssbc/usermem.S)

fuzix_compile(kernel/platform/tomssbc/tricks.S)
fuzix_compile(kernel/platform/tomssbc/main.c)
fuzix_compile(kernel/platform/tomssbc/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/tomssbc/devices.c)
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
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/devsys.c)

# --- Character + block drivers ---
fuzix_compile(kernel/platform/tomssbc/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/tomssbc/ide.S)
