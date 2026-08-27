cmake_minimum_required(VERSION 3.16)

# ===========================================================================
# FUZIX (fuzix-new) - CMake port
#
# A CMake-driven build of the FUZIX kernel where the target CPU, platform,
# memory manager, filesystem and device drivers are all selected through build
# flags rather than per-platform Makefiles.
#
# Ported CPUs / platforms so far (both use the Fuzix Compiler Kit / fcc):
#   i8080  + v8080    (Z80Pack virtual 8080 machine)
#   z80u   + z80pack  (Z80Pack virtual Z80 machine, new-compiler Z80 port)
#
# Per-CPU settings live in cmake/cpu-<cpu>.cmake, per-platform link recipes in
# cmake/platform-<platform>.cmake.
#
# Configure, for example:
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake \
#         -DFUZIX_CPU=i8080 -DFUZIX_PLATFORM=v8080
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-z80u.cmake \
#         -DFUZIX_CPU=z80u  -DFUZIX_PLATFORM=z80pack
#   cmake --build build
# ===========================================================================

project(fuzix_new
        VERSION 0.5
        DESCRIPTION "FUZIX kernel, CMake build (i8080 / z80u)"
        LANGUAGES NONE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(FuzixBuild)

# ---------------------------------------------------------------------------
# 0. Version strings (were version.mk in the original tree)
# ---------------------------------------------------------------------------
set(FUZIX_VERSION    "0.5" CACHE STRING "FUZIX major.minor version")
# The original passes the literal two-character string "" as the subversion.
set(FUZIX_SUBVERSION "\"\"" CACHE STRING "FUZIX subversion string")

# ---------------------------------------------------------------------------
# 1. Target selection (CPU + platform)
# ---------------------------------------------------------------------------
set(FUZIX_CPU      "i8080" CACHE STRING "Target CPU: i8080 | z80u")
set(FUZIX_PLATFORM "v8080" CACHE STRING "Target platform/board: v8080 | z80pack")
set_property(CACHE FUZIX_CPU      PROPERTY STRINGS i8080 z80u pdp11 i8086)
set_property(CACHE FUZIX_PLATFORM PROPERTY STRINGS v8080 z80pack rcbus-8080 pdp11 ibmpc)

# Toolchain kind: "fcc" (Fuzix Compiler Kit, ld8080/ldz80 + pack85) or "gcc"
# (standard gcc + linker script + objcopy, e.g. pdp11). Set by the toolchain
# file / cpu fragment; default fcc.
if(NOT DEFINED FUZIX_TOOLCHAIN_KIND)
    set(FUZIX_TOOLCHAIN_KIND "fcc")
endif()

if(NOT EXISTS "${CMAKE_SOURCE_DIR}/cmake/cpu-${FUZIX_CPU}.cmake")
    message(FATAL_ERROR "Unsupported FUZIX_CPU='${FUZIX_CPU}' (no cmake/cpu-${FUZIX_CPU}.cmake)")
endif()
if(NOT EXISTS "${CMAKE_SOURCE_DIR}/cmake/platform-${FUZIX_PLATFORM}.cmake")
    message(FATAL_ERROR "Unsupported FUZIX_PLATFORM='${FUZIX_PLATFORM}'")
endif()

# ---------------------------------------------------------------------------
# 1a. Board config file (optional)
# ---------------------------------------------------------------------------
# A named config in configs/<name>.cmake may pre-set any of the options below
# (memory manager, drivers, and especially the FUZIX_PKG_* / FUZIX_BINARIES_*
# program selection used by the `bin` target). It is included EARLY so it can
# override option() defaults; values it sets with `set(... CACHE ...)` are
# non-FORCE, so an explicit -D... on the command line still wins.
set(FUZIX_CONFIG "default" CACHE STRING "Board config file: configs/<name>.cmake")
file(GLOB _fuzix_configs RELATIVE "${CMAKE_SOURCE_DIR}/configs"
     "${CMAKE_SOURCE_DIR}/configs/*.cmake")
list(TRANSFORM _fuzix_configs REPLACE "\\.cmake$" "")
set_property(CACHE FUZIX_CONFIG PROPERTY STRINGS ${_fuzix_configs})
set(_fuzix_config_file "${CMAKE_SOURCE_DIR}/configs/${FUZIX_CONFIG}.cmake")
if(NOT EXISTS "${_fuzix_config_file}")
    message(FATAL_ERROR
        "Unknown FUZIX_CONFIG='${FUZIX_CONFIG}' (no ${_fuzix_config_file}). "
        "Available: ${_fuzix_configs}")
endif()
message(STATUS "Board config     : ${FUZIX_CONFIG}  (configs/${FUZIX_CONFIG}.cmake)")
include("${_fuzix_config_file}")

# ---------------------------------------------------------------------------
# 2. Memory manager selection  (exactly one)
# ---------------------------------------------------------------------------
# Default memory manager depends on the board (pdp11 is swap-only, ibmpc uses
# the 8086 4K-page banking model).
if(FUZIX_PLATFORM STREQUAL "pdp11")
    set(_mm_default "simple")
elseif(FUZIX_PLATFORM STREQUAL "ibmpc")
    set(_mm_default "bank8086")
else()
    set(_mm_default "bankfixed")
endif()
set(FUZIX_MM "${_mm_default}" CACHE STRING "Kernel memory manager")
set_property(CACHE FUZIX_MM PROPERTY STRINGS
    bankfixed banksplit simple
    bank8k bank16k bank16k_low bank32k bank16kfc bank8086 bank65c816
    flat flat_small unbanked)

set(_mm_bankfixed_src   mm/bankfixed.c)
set(_mm_bankfixed_def   CONFIG_BANK_FIXED)
set(_mm_banksplit_src   mm/banksplit.c)
set(_mm_banksplit_def   CONFIG_BANK_FIXED)
set(_mm_simple_src      mm/simple.c)
set(_mm_simple_def      CONFIG_SWAP_ONLY)
set(_mm_bank8k_src      mm/bank8k.c)
set(_mm_bank8k_def      CONFIG_BANK8)
set(_mm_bank16k_src     mm/bank16k.c)
set(_mm_bank16k_def     CONFIG_BANK16)
set(_mm_bank16k_low_src mm/bank16k_low.c)
set(_mm_bank16k_low_def CONFIG_BANK16_LOW)
set(_mm_bank32k_src     mm/bank32k.c)
set(_mm_bank32k_def     CONFIG_BANK32)
set(_mm_bank16kfc_src   mm/bank16kfc.c)
set(_mm_bank16kfc_def   CONFIG_BANK16FC)
set(_mm_bank8086_src    mm/bank8086.c)
set(_mm_bank8086_def    CONFIG_BANK_8086)
set(_mm_bank65c816_src  mm/bank65c816.c)
set(_mm_bank65c816_def  CONFIG_BANK_65C816)
set(_mm_flat_src        mm/flat.c)
set(_mm_flat_def        CONFIG_FLAT)
set(_mm_flat_small_src  mm/flat_small.c)
set(_mm_flat_small_def  CONFIG_FLAT_SMALL)
set(_mm_unbanked_src    mm/unbanked.c)
set(_mm_unbanked_def    "")

if(NOT DEFINED _mm_${FUZIX_MM}_src)
    message(FATAL_ERROR "Unknown FUZIX_MM='${FUZIX_MM}'")
endif()
set(MM_SOURCE "${_mm_${FUZIX_MM}_src}")
set(MM_DEFINE "${_mm_${FUZIX_MM}_def}")

set(FUZIX_MEMALLOC "none" CACHE STRING "User memory allocator (none|malloc)")
set_property(CACHE FUZIX_MEMALLOC PROPERTY STRINGS none malloc)
if(FUZIX_MEMALLOC STREQUAL "none")
    set(MEMALLOC_SOURCE mm/memalloc_none.c)
else()
    set(MEMALLOC_SOURCE mm/malloc.c)
endif()

option(FUZIX_MULTIPROCESS "Allow multiple processes resident in memory" ON)

# ---------------------------------------------------------------------------
# 3. Filesystem selection
# ---------------------------------------------------------------------------
option(FUZIX_FS_NATIVE "Native FUZIX filesystem (inode/superblock)" ON)

set(FUZIX_BLOCKSIZE "512" CACHE STRING "Block device buffer size (512|400)")
set_property(CACHE FUZIX_BLOCKSIZE PROPERTY STRINGS 512 400)
if(FUZIX_BLOCKSIZE STREQUAL "512")
    set(BLK_SOURCE core/blk512.c)
else()
    set(BLK_SOURCE core/blk400.c)
endif()

set(FUZIX_EXECFORMAT "16" CACHE STRING "Executable loader (16|32|elf32|none)")
set_property(CACHE FUZIX_EXECFORMAT PROPERTY STRINGS 16 32 elf32 none)

# ---------------------------------------------------------------------------
# 4. Optional kernel subsystems
# ---------------------------------------------------------------------------
option(FUZIX_NET      "TCP/IP networking (BSD sockets)"        OFF)
option(FUZIX_LEVEL2   "Level 2 features (sessions, job ctrl)"  OFF)
option(FUZIX_SELECT   "select()/poll() support"                OFF)
option(FUZIX_VT       "Virtual terminal / console video layer" OFF)
option(FUZIX_AUDIO    "Audio device layer"                     OFF)
option(FUZIX_INPUT    "Input device layer"                     OFF)
option(FUZIX_KMOD     "Loadable kernel modules"                OFF)

# ---------------------------------------------------------------------------
# 5. Device drivers
# ---------------------------------------------------------------------------
# v8080
option(FUZIX_DRIVER_TTY        "Console/serial TTY driver (platform devtty)" ON)
# z80pack character drivers
option(FUZIX_DRIVER_Z80PACK_TTY "Z80Pack console/serial TTY driver" ON)
option(FUZIX_DRIVER_Z80PACK_LPR "Z80Pack line printer driver"       ON)
option(FUZIX_DRIVER_Z80PACK_RTC "Z80Pack real-time clock driver"    ON)
# shared block driver
option(FUZIX_DRIVER_Z80PACK_FD  "Z80Pack virtual floppy block driver" ON)
# rcbus-8080 drivers (TinyDisk stack + peripherals)
option(FUZIX_DRIVER_TINYDISK    "TinyDisk generic block layer"        ON)
option(FUZIX_DRIVER_IDE         "IDE / PPIDE disk (TinyIDE)"          ON)
option(FUZIX_DRIVER_SCSI        "SCSI disk (TinySCSI + NCR5380)"      ON)
option(FUZIX_DRIVER_CH375       "CH375 USB mass storage"             ON)
option(FUZIX_DRIVER_RTC_DS1302  "DS1302 real-time clock"             ON)
option(FUZIX_DRIVER_JOYSTICK    "Joystick input (platform + core input layer)" ON)

# ---------------------------------------------------------------------------
# 6. Disk image (diskimage target)
# ---------------------------------------------------------------------------
set(FUZIX_IMAGES_DIR "${CMAKE_BINARY_DIR}/images"
    CACHE PATH "Output directory for boot.dsk / drivep.dsk")
set(FUZIX_FILESYS_IMG ""
    CACHE FILEPATH "Root filesystem image written to the start of drivep.dsk (optional)")

# ===========================================================================
# CPU settings + derived toolchain paths
# ===========================================================================
include("${CMAKE_SOURCE_DIR}/cmake/cpu-${FUZIX_CPU}.cmake")

set(FUZIX_CC_MACHINE "${CPU_MACHINE}")
set(FUZIX_CC_OPT     "${CPU_OPT}")

# For fcc targets the linker + C library are derived from the CPU fragment and
# the toolchain prefix (unless overridden). gcc targets (pdp11) set their own
# tools in the toolchain file.
if(FUZIX_TOOLCHAIN_KIND STREQUAL "fcc")
    if(NOT DEFINED FUZIX_LD OR FUZIX_LD STREQUAL "")
        set(FUZIX_LD "${FUZIX_TOOLCHAIN_PREFIX}/bin/${CPU_LD_TOOL}")
    endif()
    if(NOT DEFINED FUZIX_LIBC OR FUZIX_LIBC STREQUAL "")
        set(FUZIX_LIBC "${FUZIX_TOOLCHAIN_PREFIX}/lib/${CPU_LIBC_SUBPATH}")
    endif()
endif()

# ===========================================================================
# Build wiring
# ===========================================================================
set(KDIR "${CMAKE_SOURCE_DIR}/kernel")
set(GEN  "${CMAKE_BINARY_DIR}/generated")
set(FUZIX_OBJ_DIR   "${CMAKE_BINARY_DIR}/obj")
set(FUZIX_IMAGE_DIR "${CMAKE_BINARY_DIR}/image")
file(MAKE_DIRECTORY "${GEN}/include" "${FUZIX_OBJ_DIR}" "${FUZIX_IMAGE_DIR}")

# Include search path. Quoted path-style includes in the original tree were
# flattened to plain filenames, so kernel/lib and the cpu/platform dirs must
# all be searchable.
set(FUZIX_INCLUDE_FLAGS
    -I${KDIR}/cpu/${FUZIX_CPU}
    -I${KDIR}/platform/${FUZIX_PLATFORM}
    -I${KDIR}/include
    -I${KDIR}/dev
    -I${KDIR}/dev/z80pack
    -I${KDIR}/lib
    -I${GEN}/include)               # generated sysinfoblk.h

# Preprocessor defines derived from the options above.
set(FUZIX_DEFS "")
if(MM_DEFINE)
    list(APPEND FUZIX_DEFS -D${MM_DEFINE})
endif()
if(FUZIX_MULTIPROCESS)
    list(APPEND FUZIX_DEFS -DCONFIG_MULTI)
endif()
if(FUZIX_NET)
    list(APPEND FUZIX_DEFS -DCONFIG_NET)
endif()
if(FUZIX_LEVEL2)
    list(APPEND FUZIX_DEFS -DCONFIG_LEVEL_2)
endif()

# ---------------------------------------------------------------------------
# Host tools (built with the host compiler, not the cross compiler)
# ---------------------------------------------------------------------------
find_program(HOSTCC NAMES cc gcc clang REQUIRED)

set(MAKEVERSION_BIN "${CMAKE_BINARY_DIR}/tools/makeversion")
set(PACK85_BIN      "${CMAKE_BINARY_DIR}/tools/pack85")
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/tools")

add_custom_command(
    OUTPUT  "${MAKEVERSION_BIN}"
    COMMAND "${HOSTCC}" -O2 -o "${MAKEVERSION_BIN}" "${KDIR}/tools/makeversion.c"
    DEPENDS "${KDIR}/tools/makeversion.c"
    COMMENT "host cc  tools/makeversion")

add_custom_command(
    OUTPUT  "${PACK85_BIN}"
    COMMAND "${HOSTCC}" -O2 -o "${PACK85_BIN}" "${KDIR}/tools/pack85.c"
    DEPENDS "${KDIR}/tools/pack85.c"
    COMMENT "host cc  tools/pack85")

add_custom_command(
    OUTPUT  "${GEN}/version.c" "${GEN}/include/sysinfoblk.h"
    COMMAND "${MAKEVERSION_BIN}" "${FUZIX_VERSION}" "${FUZIX_SUBVERSION}" "${FUZIX_PLATFORM}"
    WORKING_DIRECTORY "${GEN}"
    DEPENDS "${MAKEVERSION_BIN}"
    COMMENT "gen  version.c + sysinfoblk.h")

# Host-side standalone utilities (mkfs/fsck/ucp/... ). Built via `tools` target.
include(HostTools)

# Root filesystem image (target: rootfs). May override FUZIX_FILESYS_IMG below.
include(RootFS)

# Userland C library (target: lib). Builds libc<usercpu>.a + crt0 + liberror.txt
# (and optionally libm/termcap/readline/curses) for the selected CPU.
include(UserLib)

# Userland programs (target: bin). Curated sh + coreutils, linked against
# crt0 + libc<usercpu>.a. Depends on the `lib` target.
include(UserBin)

# The root filesystem pulls build artifacts (liberror.txt, /init) from the
# userland lib/bin output dirs, so those targets must be built first. The `lib`
# and `bin` targets only exist after UserBin/UserLib, hence wiring it here.
if(TARGET rootfs)
    add_dependencies(rootfs lib bin)
endif()

set(FUZIX_EXTRA_DEPENDS "${GEN}/include/sysinfoblk.h")

# ---------------------------------------------------------------------------
# Ordered source list comes from the platform fragment (mirrors that board's
# Makefile image rule). It also sets LINK_FLAGS and DISK_SKIP.
# ---------------------------------------------------------------------------
set_property(GLOBAL PROPERTY FUZIX_OBJECTS "")   # reset accumulator

include("${CMAKE_SOURCE_DIR}/cmake/platform-${FUZIX_PLATFORM}.cmake")

# --- Optional subsystems (shared, appended after the platform base list) ---
if(FUZIX_SELECT)
    fuzix_compile(kernel/core/select.c)
endif()
if(FUZIX_LEVEL2)
    fuzix_compile(kernel/core/level2.c)
    fuzix_compile(kernel/core/syscall_level2.c)
endif()
if(FUZIX_NET)
    fuzix_compile(kernel/core/network.c)
    fuzix_compile(kernel/core/syscall_net.c)
endif()
if(FUZIX_VT)
    fuzix_compile(kernel/core/vt.c)
endif()
if(FUZIX_AUDIO)
    fuzix_compile(kernel/core/audio.c)
endif()
if(FUZIX_INPUT)
    fuzix_compile(kernel/core/devinput.c)
endif()
if(FUZIX_KMOD)
    fuzix_compile(kernel/core/kmod.c)
endif()

# ---------------------------------------------------------------------------
# Link + pack into the final kernel image.
# ---------------------------------------------------------------------------
get_property(FUZIX_OBJECTS GLOBAL PROPERTY FUZIX_OBJECTS)

if(NOT DEFINED LINK_STYLE)
    set(LINK_STYLE "pack85")
endif()

if(LINK_STYLE STREQUAL "ld-objcopy")
    # gcc/pdp11: ld -T <script> then objcopy -O binary. No pack85.
    configure_file("${CMAKE_SOURCE_DIR}/cmake/link-image-pdp11.sh.in"
                   "${CMAKE_BINARY_DIR}/link-image.sh" @ONLY)
    set(_link_dep "${LINK_SCRIPT}")
    set(_link_comment "ld + objcopy -> fuzix.bin")
elseif(LINK_STYLE STREQUAL "ld-elf")
    # gcc/i8086: ld -T <script> -> ELF image (fuzix.elf), copied to fuzix.bin.
    # No objcopy step (upstream ships the ELF directly).
    configure_file("${CMAKE_SOURCE_DIR}/cmake/link-image-8086.sh.in"
                   "${CMAKE_BINARY_DIR}/link-image.sh" @ONLY)
    set(_link_dep "${LINK_SCRIPT}")
    set(_link_comment "ld -T -> fuzix.elf")
else()
    # fcc: ld8080/ldz80 + pack85.
    string(REPLACE ";" " " LINK_FLAGS_STR "${LINK_FLAGS}")
    configure_file("${CMAKE_SOURCE_DIR}/cmake/link-image.sh.in"
                   "${CMAKE_BINARY_DIR}/link-image.sh" @ONLY)
    set(_link_dep "${PACK85_BIN}")
    set(_link_comment "${CPU_LD_TOOL} + pack85 -> fuzix.bin")
endif()

add_custom_command(
    OUTPUT  "${FUZIX_IMAGE_DIR}/fuzix.bin"
    COMMAND /bin/sh "${CMAKE_BINARY_DIR}/link-image.sh" ${FUZIX_OBJECTS}
    DEPENDS ${FUZIX_OBJECTS} "${_link_dep}"
            "${CMAKE_BINARY_DIR}/link-image.sh"
    COMMENT "${_link_comment}"
    VERBATIM)

add_custom_target(fuzix ALL DEPENDS "${FUZIX_IMAGE_DIR}/fuzix.bin")

# ---------------------------------------------------------------------------
# diskimage target (not part of ALL). The recipe is platform-specific:
#   "bootblock" (v8080, z80pack) -> boot floppy + 512MB root disk
#   "rcbus-ide" (rcbus-8080)     -> loader + kernel + fs into an IDE image
# The platform fragment sets DISKIMAGE_STYLE (default: bootblock).
# ---------------------------------------------------------------------------
set(PLATFORM_DIR    "${KDIR}/platform/${FUZIX_PLATFORM}")
set(DISKIMAGE_WORK  "${CMAKE_BINARY_DIR}/diskimage")
file(MAKE_DIRECTORY "${DISKIMAGE_WORK}")
if(NOT DEFINED DISKIMAGE_STYLE)
    set(DISKIMAGE_STYLE "bootblock")
endif()

# Optional external assets for the rcbus-ide flow.
set(FUZIX_PARTTAB "" CACHE FILEPATH "Partition-table base image for the IDE disk (rcbus-8080, optional)")

if(DISKIMAGE_STYLE STREQUAL "none")
    # Platform has no disk-image packaging (e.g. pdp11 is build-testing only).
    add_custom_target(diskimage
        COMMAND ${CMAKE_COMMAND} -E echo
                "diskimage: not available for platform '${FUZIX_PLATFORM}' (only fuzix.bin is produced)"
        VERBATIM)
else()
    if(DISKIMAGE_STYLE STREQUAL "rcbus-ide")
        configure_file("${CMAKE_SOURCE_DIR}/cmake/diskimage-rcbus-ide.sh.in"
                       "${CMAKE_BINARY_DIR}/diskimage.sh" @ONLY)
        set(_diskimage_dep "${PLATFORM_DIR}/loader.S")
        set(_diskimage_comment "Building loader + IDE disk.img")
    else()
        configure_file("${CMAKE_SOURCE_DIR}/cmake/diskimage.sh.in"
                       "${CMAKE_BINARY_DIR}/diskimage.sh" @ONLY)
        set(_diskimage_dep "${PLATFORM_DIR}/bootblock.S")
        set(_diskimage_comment "Building boot.dsk + drivep.dsk")
    endif()

    add_custom_target(diskimage
        COMMAND /bin/sh "${CMAKE_BINARY_DIR}/diskimage.sh"
        DEPENDS "${FUZIX_IMAGE_DIR}/fuzix.bin"
                "${_diskimage_dep}"
                "${CMAKE_BINARY_DIR}/diskimage.sh"
        COMMENT "${_diskimage_comment}"
        VERBATIM)
endif()
add_dependencies(diskimage fuzix)

# If the root fs is built here, make diskimage build it first.
if(FUZIX_ROOTFS_FEEDS_DISKIMAGE)
    add_dependencies(diskimage rootfs)
endif()

# ---------------------------------------------------------------------------
# Configuration summary
# ---------------------------------------------------------------------------
list(LENGTH FUZIX_OBJECTS _nobj)
message(STATUS "==================== FUZIX build configuration ====================")
message(STATUS "CPU / platform    : ${FUZIX_CPU} / ${FUZIX_PLATFORM}")
message(STATUS "Toolchain prefix  : ${FUZIX_TOOLCHAIN_PREFIX}")
message(STATUS "Toolchain kind    : ${FUZIX_TOOLCHAIN_KIND}")
message(STATUS "  compiler        : ${FUZIX_CC} ${CPU_MACHINE}")
message(STATUS "  linker          : ${FUZIX_LD}")
if(FUZIX_TOOLCHAIN_KIND STREQUAL "gcc")
message(STATUS "  objcopy         : ${FUZIX_OBJCOPY}")
message(STATUS "  link script     : ${LINK_SCRIPT}")
else()
message(STATUS "  libc            : ${FUZIX_LIBC}")
endif()
message(STATUS "Memory manager    : ${FUZIX_MM}  (${MM_SOURCE}, -D${MM_DEFINE})")
message(STATUS "User memalloc     : ${FUZIX_MEMALLOC}  (${MEMALLOC_SOURCE})")
message(STATUS "Multiprocess      : ${FUZIX_MULTIPROCESS}")
message(STATUS "Block size        : ${FUZIX_BLOCKSIZE}  (${BLK_SOURCE})")
message(STATUS "Exec loader       : ${FUZIX_EXECFORMAT}")
message(STATUS "Low level         : ${CPU_LOWLEVEL}")
message(STATUS "Link flags        : ${LINK_FLAGS}")
message(STATUS "Objects to link   : ${_nobj}")
message(STATUS "-- Filesystems --")
fuzix_report_module(${FUZIX_FS_NATIVE} "native fs" "inode/superblock + syscall_fs*")
message(STATUS "-- Optional subsystems --")
fuzix_report_module(${FUZIX_NET}    "net"    "network.c + syscall_net.c")
fuzix_report_module(${FUZIX_LEVEL2} "level2" "sessions/job control")
fuzix_report_module(${FUZIX_SELECT} "select" "select()/poll()")
fuzix_report_module(${FUZIX_VT}     "vt"     "console video")
fuzix_report_module(${FUZIX_AUDIO}  "audio"  "audio layer")
fuzix_report_module(${FUZIX_INPUT}  "input"  "input layer")
fuzix_report_module(${FUZIX_KMOD}   "kmod"   "loadable modules")
message(STATUS "-- Disk image (target: diskimage) --")
message(STATUS "  output dir      : ${FUZIX_IMAGES_DIR}")
if(FUZIX_FILESYS_IMG)
    message(STATUS "  root fs image   : ${FUZIX_FILESYS_IMG}")
else()
    message(STATUS "  root fs image   : (none - set -DFUZIX_FILESYS_IMG=...)")
endif()
message(STATUS "===================================================================")
