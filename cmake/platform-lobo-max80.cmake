# ---------------------------------------------------------------------------
# Platform: lobo-max80 (Lobo MAX-80)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-lobo-max80/Makefile's `image` rule.
# ---------------------------------------------------------------------------

# ldz80: -S split/common base (0x1003). No -C origin: the kernel is glued to
# the separately-built boot block (boot.S -> boot.bin), which is not linked in.
set(LINK_FLAGS -b -S 0x1003 -f SsLDBbXC)
# Boot via a boot block + boot floppy (dd), not a z80pack bootblock image.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/lobo-max80/crt0.S)       # FIRST (load origin)
fuzix_compile(kernel/platform/lobo-max80/commonmem.S)
fuzix_compile(kernel/platform/lobo-max80/lobo.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)

fuzix_compile(kernel/platform/lobo-max80/tricks.S)
fuzix_compile(kernel/platform/lobo-max80/main.c)
fuzix_compile(kernel/platform/lobo-max80/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/lobo-max80/devices.c)
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
fuzix_compile(kernel/dev/font8x8.c)
fuzix_compile(kernel/core/devinput.c)                  # core input layer
fuzix_compile(kernel/platform/lobo-max80/devinput.c)   # platform input
fuzix_compile(kernel/core/vt.c)
fuzix_compile(kernel/platform/lobo-max80/devsasi.c)
fuzix_compile(kernel/platform/lobo-max80/devlpr.c)
fuzix_compile(kernel/platform/lobo-max80/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyscsi.c)
fuzix_compile(kernel/dev/tinyscsi_discard.c EXTRA -Tdiscard)
