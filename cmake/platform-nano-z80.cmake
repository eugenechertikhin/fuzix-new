# ---------------------------------------------------------------------------
# Platform: nano-z80 (Nano Z80 / N8VEM-style SBC)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-nano-z80/Makefile's `image` rule.
#
# NOTE: this board hard-wires CONFIG_NET / CONFIG_NET_NATIVE and CONFIG_VT in
# config.h (like ibmpc's CONFIG_VT), so the networking + console-video sources
# are part of the platform base list and are compiled unconditionally rather
# than gated behind FUZIX_NET / FUZIX_VT.
# ---------------------------------------------------------------------------

# ldz80: -C load origin (0x0088, CP/M loader), -X discard base (0xD400),
#        -S split/common base (0xF000).
set(LINK_FLAGS -b -C 0x0088 -X 0xD400 -S 0xF000 -f CLDBbXSs)
# Upstream wraps fuzix.bin in a CP/M .com loader + parttab disk; not mechanised
# here -> build produces fuzix.bin only.
set(DISKIMAGE_STYLE none)

# --- Platform ---
fuzix_compile(kernel/platform/nano-z80/crt0.S)       # FIRST (load origin)
fuzix_compile(kernel/platform/nano-z80/commonmem.S)
fuzix_compile(kernel/platform/nano-z80/nano-z80.S)
fuzix_compile(kernel/platform/nano-z80/vt.S)
fuzix_compile(kernel/platform/nano-z80/tricks.S)
fuzix_compile(kernel/platform/nano-z80/devtty.c)
fuzix_compile(kernel/platform/nano-z80/sdxfer.c)
fuzix_compile(kernel/platform/nano-z80/main.c)
fuzix_compile(kernel/platform/nano-z80/discard.c EXTRA -Tdiscard)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/usermem.c)
fuzix_compile(${CPU_USERMEM})

fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/devsys.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/nano-z80/devices.c)
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

# --- networking (hard-wired CONFIG_NET in config.h) ---

# --- block drivers ---
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)


# --- tty / memory / swap / sys devices ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})
fuzix_compile(kernel/${MM_SOURCE})

# --- console video (hard-wired CONFIG_VT in config.h) ---
fuzix_compile(kernel/core/vt.c)

# --- networking (config.h hard-wires CONFIG_NET, so the core net stack and the
#     native driver are compiled unconditionally here rather than under
#     if(FUZIX_NET); do not also build this board with -DFUZIX_NET=ON). ---
fuzix_compile(kernel/core/syscall_net.c)
fuzix_compile(kernel/core/network.c)
fuzix_compile(kernel/dev/net/net_native.c)
