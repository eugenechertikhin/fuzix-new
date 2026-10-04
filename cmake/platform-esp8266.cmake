# ---------------------------------------------------------------------------
# Platform: esp8266 (Espressif ESP8266, Xtensa LX106)   CPU: esp8266
#
# Faithful transcription of platform-esp8266/Makefile's KOBJS link order
# (there is no crt0 - boot.c is the entry, placed by kernel.ld's ENTRY). The
# link is driven by the gcc compiler with two linker scripts + LTO, see
# LINK_STYLE "xtensa-elf" in the top-level CMakeLists and
# cmake/link-image-esp8266.sh.in.
#
# Custom memory model: NO standard mm/bank*.c (FUZIX_MM=custom -> MM_SOURCE
# empty). The platform's swapper.c is the manager and mm/malloc.c
# (MEMALLOC_SOURCE) is the allocator. Exec is a custom format
# (FUZIX_EXECFORMAT=none): both the platform syscall_exec.c and the core
# syscall_exec.c are linked (as upstream KOBJS does).
#
# Networking is hard-wired in config.h (CONFIG_ESP_W5500 -> CONFIG_NET), so the
# core net sources are compiled here unconditionally rather than via FUZIX_NET
# (which stays OFF to avoid compiling them twice).
# ---------------------------------------------------------------------------

# Some esp8266 sources use kernel-root-relative includes ("lib/dhara/map.h",
# "dev/devsd.h") - upstream compiles with -I<Kernel root>. Add the kernel root
# to the include path so those resolve (the per-dir -I set alone does not).
list(APPEND FUZIX_INCLUDE_FLAGS -I${KDIR})

# Two linker scripts; the second holds ROM address PROVIDE()s. The link driver
# takes both via -T (see the xtensa-elf branch / link-image-esp8266.sh.in).
set(LINK_SCRIPT  "${KDIR}/platform/esp8266/kernel.ld")
set(LINK_SCRIPT2 "${KDIR}/platform/esp8266/addresses.ld")
# No boot-disk packaging wired yet (needs mkftl + esptool + ROM-dependent flash
# layout, done downstream). Build-testing only, like ibmpc.
set(DISKIMAGE_STYLE "none")

# --- Platform low level (context switch) ---
fuzix_compile(kernel/platform/esp8266/tricks.S)

# --- Shared block + net + FTL drivers (all already in-tree) ---
fuzix_compile(kernel/dev/blkdev.c)
fuzix_compile(kernel/dev/mbr.c)
fuzix_compile(kernel/dev/devsd_discard.c)
fuzix_compile(kernel/dev/devsd.c)
fuzix_compile(kernel/dev/net/net_w5x00.c)          # CONFIG_NET_W5500 (hard-wired)
fuzix_compile(kernel/lib/dhara/error.c)            # Dhara flash FTL
fuzix_compile(kernel/lib/dhara/journal.c)
fuzix_compile(kernel/lib/dhara/map.c)

# --- Platform sources ---
fuzix_compile(kernel/platform/esp8266/boot.c)
fuzix_compile(kernel/platform/esp8266/devices.c)
fuzix_compile(kernel/platform/esp8266/devflash.c)
fuzix_compile(kernel/platform/esp8266/devsdspi.c)
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/esp8266/devtty.c)
endif()
fuzix_compile(kernel/platform/esp8266/interrupt.c)
fuzix_compile(kernel/platform/esp8266/lib.c)
fuzix_compile(kernel/platform/esp8266/main.c)
fuzix_compile(kernel/platform/esp8266/misc.c)
fuzix_compile(kernel/platform/esp8266/rawflash.c)
fuzix_compile(kernel/platform/esp8266/swapper.c)   # custom memory manager
fuzix_compile(kernel/platform/esp8266/syscall_exec.c)  # custom exec loader

# --- Core ---
fuzix_compile(kernel/${BLK_SOURCE})                # blk512
fuzix_compile(kernel/core/devio.c)
fuzix_compile(kernel/core/devsys.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/filesys.c)
    fuzix_compile(kernel/core/inode.c)
endif()
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(${CPU_LOWLEVEL})                     # cpu/esp8266/lowlevel-esp8266.S
fuzix_compile(kernel/${MEMALLOC_SOURCE})           # mm/malloc.c
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/core/network.c)               # CONFIG_NET (hard-wired)
fuzix_compile(kernel/core/process.c)
fuzix_compile(kernel/core/start.c)
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/core/syscall_exec.c)          # generic exec dispatcher
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs.c)
    fuzix_compile(kernel/core/syscall_fs2.c)
    fuzix_compile(kernel/core/syscall_fs3.c)
endif()
fuzix_compile(kernel/core/syscall_net.c)           # CONFIG_NET (hard-wired)
fuzix_compile(kernel/core/syscall_other.c)
fuzix_compile(kernel/core/syscall_proc.c)
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/usermem.c)               # CONFIG_USERMEM_DIRECT
fuzix_compile(${GEN}/version.c)
