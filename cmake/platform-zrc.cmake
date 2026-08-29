# ---------------------------------------------------------------------------
# Platform: zrc (Z80 RC / RCBus IDE + WizNet SBC)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-zrc/Makefile's `image` rule.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0100), -S split/common base (0xF400).
set(LINK_FLAGS -b -C 0x0100 -S 0xF400 -f CLDBbXSs)
# Upstream image is packed (pack85) into an IDE partition via parttab + dd.
# Not mechanised here -> build produces fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/zrc/crt0.S)            # FIRST (load origin)
fuzix_compile(kernel/platform/zrc/commonmem.S)
fuzix_compile(kernel/platform/zrc/zrc.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)

fuzix_compile(kernel/platform/zrc/tricks.S)
fuzix_compile(kernel/platform/zrc/main.c)
fuzix_compile(kernel/platform/zrc/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/zrc/devices.c)
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
# NOTE: network.c + syscall_net.c are compiled centrally in CMakeLists.txt
# under if(FUZIX_NET); do not duplicate them here (would double-link).

# --- tty / memory / swap / sys devices ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/devsys.c)

# --- Character + block drivers ---
fuzix_compile(kernel/platform/zrc/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)

# --- Networking (WizNet W5x00 + native/SLIP) ---
if(FUZIX_NET)
    fuzix_compile(kernel/dev/net/net_native.c)
    fuzix_compile(kernel/dev/net/net_w5x00.c)
    fuzix_compile(kernel/platform/zrc/wiznet.c)
endif()

# --- RTC (DS1302) ---
fuzix_compile(kernel/dev/ds1302_rcbusu.S)
fuzix_compile(kernel/dev/ds1302.c)
fuzix_compile(kernel/dev/ds1302_discard.c EXTRA -Tdiscard)
