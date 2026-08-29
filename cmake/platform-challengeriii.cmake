# ---------------------------------------------------------------------------
# Platform: challengeriii (Ohio Scientific Challenger III)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-challengeriii/Makefile's `image` rule.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0100), -S split/common base (0xD000).
set(LINK_FLAGS -b -C 0x0100 -S 0xD000 -f CLDBbXSs)
# Boot goes via a 6502/z80 loader packed into an OSI floppy image by custom
# host tools (osifloppy/makeosihd); not mechanised here -> fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/challengeriii/crt0.S)       # FIRST (load origin)
fuzix_compile(kernel/platform/challengeriii/commonmem.S)
fuzix_compile(kernel/platform/challengeriii/challenger.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)

fuzix_compile(kernel/platform/challengeriii/tricks.S)
fuzix_compile(kernel/platform/challengeriii/main.c)
fuzix_compile(kernel/platform/challengeriii/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/challengeriii/devices.c)
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
fuzix_compile(kernel/platform/challengeriii/devhd.c)
fuzix_compile(kernel/platform/challengeriii/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)

# --- CPU usermem ---
fuzix_compile(${CPU_USERMEM})
