# ---------------------------------------------------------------------------
# Platform: simple80 (Simple 80 homebrew Z80 SBC)   CPU: z80u (THUNKED)
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-simple80/Makefile's `image` rule. This is a
# THUNKED z80u board: ${CPU_LOWLEVEL} resolves to lowlevel-z80u-thunked.S when
# built with -DFUZIX_Z80U_MODE=thunked.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0100), -S split/common base (0xF000).
set(LINK_FLAGS -b -C 0x0100 -S 0xF000 -f CLDBbXSs)
# Upstream image is loaded via loader.bin + partition and packed with pack85;
# no z80pack-style bootblock floppy -> build produces fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/simple80/crt0.S)        # FIRST (load origin)
fuzix_compile(kernel/platform/simple80/commonmem.S)
fuzix_compile(kernel/platform/simple80/simple80.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)
fuzix_compile(kernel/platform/simple80/usermem.S)

fuzix_compile(kernel/platform/simple80/tricks.S)
fuzix_compile(kernel/platform/simple80/main.c)
fuzix_compile(kernel/platform/simple80/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/simple80/devices.c)
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
fuzix_compile(kernel/platform/simple80/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/simple80/ide.S)
fuzix_compile(kernel/dev/ds1302_rcbusu.S)
fuzix_compile(kernel/dev/ds1302.c)
fuzix_compile(kernel/dev/ds1302_discard.c EXTRA -Tdiscard)
