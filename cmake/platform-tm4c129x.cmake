# ---------------------------------------------------------------------------
# Platform: tm4c129x (TI Tiva C TM4C129x, ARM Cortex-M4)   CPU: armm4
#
# gcc-kind (arm-none-eabi) target. Links with the board's linker script
# (fuzix.ld) via arm-none-eabi-ld --entry=start into an ELF image (LINK_STYLE
# arm-elf, set in cpu-armm4.cmake). Mirrors platform-tm4c129x/Makefile's image
# rule. crt0.o is pulled first by STARTUP(crt0.o) in fuzix.ld; we compile it so
# the object exists.
#
# config.h hard-wires CONFIG_FLAT (flat MM, selected per board in CMakeLists),
# CONFIG_MULTI, CONFIG_LEVEL_2 and CONFIG_NET/CONFIG_NET_NATIVE, so the level2,
# select, net and flat-malloc sources are compiled unconditionally here rather
# than under the FUZIX_LEVEL2 / FUZIX_SELECT / FUZIX_NET options. 32-bit exec
# loader (syscall_exec32.c). Build-testing only (no on-hardware verification).
# ---------------------------------------------------------------------------

set(LINK_SCRIPT "${KDIR}/platform/tm4c129x/fuzix.ld")
set(DISKIMAGE_STYLE none)

# --- Platform sources (CSRCS + ASRCS + DSRCS + NSRCS + crt0) ---
fuzix_compile(kernel/platform/tm4c129x/crt0.c)       # STARTUP(crt0.o) in fuzix.ld
fuzix_compile(kernel/platform/tm4c129x/libc.c)
fuzix_compile(kernel/platform/tm4c129x/tm4c129x.c)
fuzix_compile(kernel/platform/tm4c129x/devtty.c)
fuzix_compile(kernel/platform/tm4c129x/devsdspi.c)
fuzix_compile(kernel/platform/tm4c129x/devices.c)
fuzix_compile(kernel/platform/tm4c129x/systick.c)
fuzix_compile(kernel/platform/tm4c129x/syscall.c)
fuzix_compile(kernel/platform/tm4c129x/ssi.c)
fuzix_compile(kernel/platform/tm4c129x/procman.c)
fuzix_compile(kernel/platform/tm4c129x/eth.c)
fuzix_compile(kernel/platform/tm4c129x/gpio.c)
fuzix_compile(kernel/platform/tm4c129x/interrupt.c)
fuzix_compile(kernel/platform/tm4c129x/clock.c)
fuzix_compile(kernel/platform/tm4c129x/tricks.S)
fuzix_compile(kernel/platform/tm4c129x/arm_exception.S)
fuzix_compile(kernel/dev/blkdev.c)
fuzix_compile(kernel/dev/mbr.c)
fuzix_compile(kernel/dev/devsd.c)
fuzix_compile(kernel/dev/devsd_discard.c)
fuzix_compile(kernel/dev/net/net_native.c)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)

# --- I/O, filesystem, process ---
fuzix_compile(kernel/core/devio.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/filesys.c)
endif()
fuzix_compile(kernel/core/process.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/inode.c)
    fuzix_compile(kernel/core/syscall_fs.c)
endif()
fuzix_compile(kernel/core/syscall_proc.c)
fuzix_compile(kernel/core/syscall_net.c)     # CONFIG_NET hard-wired
fuzix_compile(kernel/core/syscall_other.c)
fuzix_compile(kernel/core/network.c)         # CONFIG_NET hard-wired
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/${MM_SOURCE})           # flat (CONFIG_FLAT)
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/devsys.c)
fuzix_compile(kernel/core/usermem.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs2.c)
    fuzix_compile(kernel/core/syscall_fs3.c)
endif()

# --- exec / loader (32-bit) + level2 + select ---
fuzix_compile(kernel/core/syscall_exec.c)
fuzix_compile(kernel/core/syscall_exec32.c)
fuzix_compile(kernel/lib/armrelocate.c)      # plt_relocate() for 32-bit exec
fuzix_compile(kernel/core/syscall_level2.c)  # CONFIG_LEVEL_2 hard-wired
fuzix_compile(kernel/core/level2.c)
fuzix_compile(kernel/core/select.c)
fuzix_compile(kernel/${BLK_SOURCE})

# --- CPU user copy + console/font + flat malloc ---
fuzix_compile(${CPU_USERMEM})
fuzix_compile(kernel/core/vt.c)
fuzix_compile(kernel/mm/malloc.c)
fuzix_compile(kernel/dev/font8x8.c)
