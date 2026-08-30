# ---------------------------------------------------------------------------
# Platform: ibmpc (IBM PC / clones, BIOS)   CPU: i8086
#
# Mirrors platform-ibmpc/Makefile's `image` rule (link order preserved). Links
# with a linker script (fuzix.ld) via ia16-elf-ld, producing an ELF kernel
# image directly (no objcopy) - see cmake/link-image-8086.sh.in.
#
# This port is build-testing only upstream (no loader, no task switching, no
# usable drivers yet), so there is no bootable floppy. We still package the root
# half of v8080's diskimage rule: a FUZIX filesystem populated with the i8086
# userland (`bin`) as the hda disk image (DISKIMAGE_STYLE=rootdisk, see
# cmake/diskimage-ibmpc.sh.in), built by the `diskimage` target.
#
# The 8086 banking memory manager (mm/bank8086.c, CONFIG_BANK_8086) is selected
# through FUZIX_MM=bank8086. Upstream also links mm/simple.c, but without
# CONFIG_SWAP_ONLY that source is an empty translation unit, so it is omitted.
# ---------------------------------------------------------------------------

# Linker script + no pack85-style origin flags.
set(LINK_SCRIPT "${KDIR}/platform/ibmpc/fuzix.ld")
# No boot sector upstream, but we still build a populated root disk (hda) image
# from the userland - see the "rootdisk" branch of the diskimage section.
set(DISKIMAGE_STYLE "rootdisk")

# --- Platform + CPU low level ---
fuzix_compile(kernel/platform/ibmpc/crt0.S)          # FIRST (STARTUP in fuzix.ld)
fuzix_compile(kernel/core/start.c)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(kernel/platform/ibmpc/main.c)

# --- Memory / scheduling ---
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/ibmpc/devices.c)

# --- I/O, filesystem, process ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/devio.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/filesys.c)
endif()
fuzix_compile(kernel/core/process.c)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/inode.c)
    fuzix_compile(kernel/core/syscall_fs.c)
endif()
fuzix_compile(kernel/platform/ibmpc/ibmpc.S)
fuzix_compile(kernel/core/syscall_proc.c)
fuzix_compile(kernel/core/syscall_other.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/core/devsys.c)
fuzix_compile(kernel/core/usermem.c)

# --- exec / loader (16-bit split I/D) ---
if(NOT FUZIX_EXECFORMAT STREQUAL "none")
    fuzix_compile(kernel/core/syscall_exec${FUZIX_EXECFORMAT}.c)
endif()
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs2.c)
endif()
fuzix_compile(kernel/platform/ibmpc/tricks.S)
if(FUZIX_FS_NATIVE)
    fuzix_compile(kernel/core/syscall_fs3.c)
endif()

# --- block/disk, console video, banking, interrupt controller ---
fuzix_compile(kernel/platform/ibmpc/biosdisk.c)
fuzix_compile(kernel/core/vt.c)                      # CONFIG_VT (console video)
fuzix_compile(kernel/platform/ibmpc/bioscon.c)
fuzix_compile(kernel/platform/ibmpc/biosvid.S)
fuzix_compile(kernel/${MM_SOURCE})                   # bank8086 (CONFIG_BANK_8086)
fuzix_compile(kernel/${MEMALLOC_SOURCE})             # memalloc_none (_memalloc/_memfree; bank8086 doesn't define them)
fuzix_compile(kernel/platform/ibmpc/8259a.c)

# --- CPU user copy + platform tty/libc ---
fuzix_compile(${CPU_USERMEM})
if(FUZIX_DRIVER_TTY)
    fuzix_compile(kernel/platform/ibmpc/devtty.c)
endif()
fuzix_compile(kernel/platform/ibmpc/libc.c)
