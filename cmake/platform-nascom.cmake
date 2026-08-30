# ---------------------------------------------------------------------------
# Platform: nascom (Nascom / 80-BUS system)   CPU: z80u
#
# Emits the kernel object list in link order (crt0 first) and sets the linker
# parameters. Mirrors platform-nascom/Makefile's `image` rule.
#
# Many drivers come from the shared kernel/dev/80bus/ tree (on the -I path).
# ---------------------------------------------------------------------------

# Shared 80-BUS driver tree: PREPEND so its plain-filename headers resolve ahead
# of any generic kernel/dev ones.  Only nascom-family boards pull this tree.
list(PREPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/dev/80bus)

# ldz80: -C load origin (0x0100), -8 second base (0xFC00), -S split/common
# base (0xC000). Note: the image is right on the edge (see upstream comment) -
# if it grows past C000 the -S value must be revisited.
set(LINK_FLAGS -b -C 0x0100 -8 0xFC00 -S 0xC000 -f CLDBSbXs)
# No bootblock; upstream image is packed into a floppy/partition via dd.
set(DISKIMAGE_STYLE none)

# --- Platform (crt0 first = load origin) ---
fuzix_compile(kernel/platform/nascom/crt0.S)         # FIRST (load origin)
fuzix_compile(kernel/platform/nascom/commonmem.S)
fuzix_compile(kernel/platform/nascom/nascom.S)
fuzix_compile(kernel/dev/80bus/nascom-pagemode.S)
fuzix_compile(kernel/dev/80bus/map80.S)

# --- Core + CPU low level ---
fuzix_compile(kernel/core/start.c EXTRA -Tdiscard)
fuzix_compile(${GEN}/version.c)
fuzix_compile(${CPU_LOWLEVEL})
fuzix_compile(${CPU_USERMEM})
fuzix_compile(kernel/core/usermem.c)

fuzix_compile(kernel/platform/nascom/tricks.S)
fuzix_compile(kernel/platform/nascom/main.c)
fuzix_compile(kernel/platform/nascom/discard.c EXTRA -Tdiscard)

# --- 80bus + platform drivers (pre-core, per upstream order) ---
fuzix_compile(kernel/dev/80bus/devfdc.c)
fuzix_compile(kernel/dev/80bus/floppy.S)
fuzix_compile(kernel/platform/nascom/ide.c)
fuzix_compile(kernel/dev/80bus/nascom-vt.S)
fuzix_compile(kernel/platform/nascom/devnascom.c)
fuzix_compile(kernel/dev/80bus/devgm833.c)
fuzix_compile(kernel/platform/nascom/mm58174.c)
fuzix_compile(kernel/dev/80bus/gmsasi.S)
fuzix_compile(kernel/dev/80bus/devgmsasi.c)

# --- Core ---
fuzix_compile(kernel/core/timer.c)
fuzix_compile(kernel/core/kdata.c)
fuzix_compile(kernel/platform/nascom/devices.c)
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

# --- tty / vt / memory / swap / sys devices ---
fuzix_compile(kernel/core/tty.c)
fuzix_compile(kernel/core/vt.c)
fuzix_compile(kernel/core/mm.c)
fuzix_compile(kernel/${MEMALLOC_SOURCE})
fuzix_compile(kernel/core/swap.c)
fuzix_compile(kernel/${MM_SOURCE})
fuzix_compile(kernel/core/devsys.c)

# --- Block drivers (tinydisk / tinyide / tinyscsi) ---
fuzix_compile(kernel/dev/tinydisk.c)
fuzix_compile(kernel/dev/tinydisk_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyide.c)
fuzix_compile(kernel/dev/tinyide_discard.c EXTRA -Tdiscard)
fuzix_compile(kernel/dev/tinyscsi.c)
fuzix_compile(kernel/dev/tinyscsi_discard.c EXTRA -Tdiscard)
