# ---------------------------------------------------------------------------
# Platform: sbcv2 (RC2014 / SBCv2-class Z80 SBC, ROMWBW boot)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-sbcv2/Makefile's `image` rule.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0100), -S split/common base (0xF400).
set(LINK_FLAGS -b -C 0x0100 -S 0xF400 -f CLDBbXSs)
# ROMWBW boot: upstream packs fuzix.bin into a boot-romwbw image via pack85/dd.
# Not mechanised here -> build produces fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/sbcv2/crt0.S)          # FIRST (load origin)
fuzix_compile(kernel/platform/sbcv2/commonmem.S)
fuzix_compile(kernel/platform/sbcv2/sbcv2.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)

fuzix_compile(kernel/platform/sbcv2/tricks.S)
fuzix_compile(kernel/platform/sbcv2/main.c)
fuzix_compile(kernel/platform/sbcv2/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/sbcv2/devices.c)
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
# NOTE: network.c + syscall_net.c are appended centrally by CMakeLists.txt
# when FUZIX_NET is set, so they are intentionally NOT listed here.

# --- tty / memory / swap / sys devices ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/devsys.c)

# --- Character + block drivers ---
fuzix_compile(kernel/platform/sbcv2/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/propio2.c)
fuzix_compile(kernel/dev/rbcfd9266_hw.S)

# --- Networking (WizNet W5x00 + native/SLIP) ---
if(FUZIX_NET)
    fuzix_compile(kernel/dev/net/net_native.c)
    fuzix_compile(kernel/dev/net/net_w5x00.c)
    fuzix_compile(kernel/platform/sbcv2/wiznet.c)
endif()

fuzix_compile(kernel/dev/ds1302_rbc.S)
fuzix_compile(kernel/dev/ds1302.c)
fuzix_compile(kernel/dev/ds1302_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide_ppide_rbc.S)
fuzix_compile(kernel/dev/devfd.c)
