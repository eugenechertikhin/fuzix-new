# ---------------------------------------------------------------------------
# Platform: rc2014-tiny (RC2014 minimal / low-level variant)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-rc2014-tiny/Makefile's `image` rule.
#
# This board is swap-only (upstream links mm/simple.o + CONFIG_SWAP_ONLY),
# so configure with -DFUZIX_MM=simple.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0080), -S split/common base (0xC000),
# -X discard base (0x8200).
set(LINK_FLAGS -b -C 0x0080 -S 0xC000 -X0x8200 -f CXSsLDBb)
# ROM/disk image is assembled with dd from fuzix.bin; not mechanised here.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/rc2014-tiny/crt0.S)       # FIRST (load origin)
fuzix_compile(kernel/platform/rc2014-tiny/commonmem.S)
fuzix_compile(kernel/platform/rc2014-tiny/rc2014.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)
fuzix_compile(${CPU_USERMEM})

fuzix_compile(kernel/platform/rc2014-tiny/tricks.S)
fuzix_compile(kernel/platform/rc2014-tiny/main.c)
fuzix_compile(kernel/platform/rc2014-tiny/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/rc2014-tiny/devices.c)
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
fuzix_compile(kernel/platform/rc2014-tiny/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/rc2014-tiny/ide.S)
fuzix_compile(kernel/dev/ds1302_rcbusu.S)
fuzix_compile(kernel/dev/ds1302.c)
fuzix_compile(kernel/dev/ds1302_discard.c EXTRA -Tdiscard)
