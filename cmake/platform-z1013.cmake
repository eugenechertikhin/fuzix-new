# ---------------------------------------------------------------------------
# Platform: z1013 (Robotron Z1013 homebrew system)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-z1013/Makefile's `image` rule.
#
# NOTE: this board is swap-only / single-process. Build with
#   -DFUZIX_MM=simple -DFUZIX_MULTIPROCESS=OFF
# so CMake supplies CONFIG_SWAP_ONLY (mm/simple.c) and omits CONFIG_MULTI.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x8000), -S split/common base (0x0100),
#        -X discard base (0x6200).
set(LINK_FLAGS -b -C 0x8000 -S 0x0100 -X 0x6200 -f CXSsLDBb)
# No bootblock; upstream image is packed into a partition via parttab + dd.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/z1013/crt0.S)          # FIRST (load origin)
fuzix_compile(kernel/platform/z1013/commonmem.S)
fuzix_compile(kernel/platform/z1013/z1013.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)

fuzix_compile(kernel/platform/z1013/tricks.S)
fuzix_compile(kernel/platform/z1013/main.c)
fuzix_compile(kernel/platform/z1013/discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/z1013/devrd.c)
fuzix_compile(kernel/platform/z1013/devrtc.c)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/z1013/devices.c)
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

# --- tty / video / memory / swap / sys devices ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/devsys.c)

# --- Character + block drivers ---
fuzix_compile(kernel/platform/z1013/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinysd.c)
fuzix_compile(kernel/dev/tinysd_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/z1013/sd.c)
fuzix_compile(kernel/dev/z80usoftsd.S)
fuzix_compile(kernel/dev/z80usoftspi.S)
fuzix_compile(kernel/dev/devfdc765.c)
fuzix_compile(kernel/platform/z1013/fdc765.S)
fuzix_compile(kernel/platform/z1013/video-poppe.S)
fuzix_compile(kernel/platform/z1013/video-32x32.S)
