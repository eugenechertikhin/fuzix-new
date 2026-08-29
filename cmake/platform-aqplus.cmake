# ---------------------------------------------------------------------------
# Platform: aqplus (Aquarius+ with I/O coprocessor)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-aqplus/Makefile's `image` rule.
#
# NOTE: this board uses the 4x16K banked memory manager (CONFIG_BANK16), so it
# must be built with -DFUZIX_MM=bank16k (the tree default is bankfixed).
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0100), -X discard base (0xC800), -S split base (0xF000).
set(LINK_FLAGS -b -C 0x0100 -X 0xC800 -S 0xF000 -f CLDBbXSs)
# Boot is via a separate romwbw bootstrap + partition (dd), not a z80pack-style
# bootblock floppy. Not mechanised here -> build produces fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/aqplus/crt0.S)         # FIRST (load origin)
fuzix_compile(kernel/platform/aqplus/commonmem.S)
fuzix_compile(kernel/platform/aqplus/aqplus.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(${CPU_USERMEM})
fuzix_compile(kernel/core/usermem.c)

fuzix_compile(kernel/platform/aqplus/tricks.S)
fuzix_compile(kernel/platform/aqplus/main.c)
fuzix_compile(kernel/platform/aqplus/discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/aqplus/iop.c)
fuzix_compile(kernel/platform/aqplus/vt.S)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/aqplus/devices.c)
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

# --- tty / vt / input / memory / swap / sys devices ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c)
fuzix_compile(kernel/core/devinput.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/devsys.c)

# --- Character + block drivers ---
fuzix_compile(kernel/platform/aqplus/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
