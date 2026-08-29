# ---------------------------------------------------------------------------
# Platform: sc720 (SC720 RC2014-class Z80 SBC, ROMWBW)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-sc720/Makefile's `image` rule.
#
# NOTE: this board hard-wires CONFIG_NET / CONFIG_NET_WIZNET / CONFIG_NET_W5300
# in config.h (like nano-z80), so the networking core + WizNet drivers are part
# of the platform base list and are compiled unconditionally rather than gated
# behind FUZIX_NET.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0100), -S split/common base (0xF400).
set(LINK_FLAGS -b -C 0x0100 -S 0xF400 -f CLDBbXSs)
# Boot is via a ROMWBW boot block + dd packaging, not a z80pack bootblock
# boot-floppy -> no mechanised disk image here.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/sc720/crt0.S)          # FIRST (load origin)
fuzix_compile(kernel/platform/sc720/commonmem.S)
fuzix_compile(kernel/platform/sc720/sc720.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)

fuzix_compile(kernel/platform/sc720/tricks.S)
fuzix_compile(kernel/platform/sc720/main.c)
fuzix_compile(kernel/platform/sc720/discard.c EXTRA -Tdiscard)

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/sc720/devices.c)
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

# --- networking (hard-wired CONFIG_NET in config.h) ---

# --- tty / memory / swap / sys devices ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/${MEMALLOC_SOURCE})
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/core/devsys.c)

# --- Character + block drivers ---
fuzix_compile(kernel/platform/sc720/devtty.c)
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/platform/sc720/ide.S)
fuzix_compile(kernel/dev/ds1302.c)
fuzix_compile(kernel/dev/ds1302_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/ds1302_rcbusu.S)

# --- networking (config.h hard-wires CONFIG_NET, so the core net stack and the
#     WizNet drivers are compiled unconditionally here rather than under
#     if(FUZIX_NET); do not also build this board with -DFUZIX_NET=ON). ---
fuzix_compile(kernel/core/syscall_net.c)
fuzix_compile(kernel/core/network.c)
fuzix_compile(kernel/dev/net/net_native.c)
fuzix_compile(kernel/dev/net/net_w5x00.c)
fuzix_compile(kernel/dev/net/net_w5300.c)
fuzix_compile(kernel/platform/sc720/wiznet.c)
