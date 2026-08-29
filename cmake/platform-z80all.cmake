# ---------------------------------------------------------------------------
# Platform: z80all (Z80-ALL homebrew SBC with video + PS/2 kbd)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-z80all/Makefile's `image` rule.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0100), -S split/common base (0xF400).
set(LINK_FLAGS -b -C 0x0100 -S 0xF400 -f CLDBbXSs)
# Kernel is packed (tools/pack85) into a partitioned IDE image via parttab +
# boot block + dd. Not mechanised here -> build produces fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/z80all/crt0.S)         # FIRST (load origin)
fuzix_compile(kernel/platform/z80all/commonmem.S)
fuzix_compile(kernel/platform/z80all/z80all.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)

fuzix_compile(kernel/platform/z80all/tricks.S)
fuzix_compile(kernel/platform/z80all/main.c)
fuzix_compile(kernel/platform/z80all/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/z80all/devices.c)
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

# --- video / console ---
fuzix_compile(kernel/dev/font8x8.c)
fuzix_compile(kernel/core/vt.c)
fuzix_compile(kernel/platform/z80all/video.S)

# --- Character + block drivers ---
fuzix_compile(kernel/platform/z80all/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)

# --- input (PS/2 keyboard + core input layer) ---
fuzix_compile(kernel/dev/ps2kbd.c)
fuzix_compile(kernel/core/devinput.c)                # core input layer
fuzix_compile(kernel/platform/z80all/devinput.c)     # platform input glue
