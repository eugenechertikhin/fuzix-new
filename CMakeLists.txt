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

# ---------------------------------------------------------------------------
# Raspberry Pi Pico (armm0) uses the Pico SDK, which must be imported BEFORE
# project() and needs C/CXX/ASM enabled. Detect it here (FUZIX_PLATFORM is a
# -D / cache value, available pre-project) and set up the SDK; every other
# target keeps LANGUAGES NONE (compiles are driven by custom commands).
# FUZIX_USERLAND_ONLY builds only the armm0 userland (lib/bin) for the flash
# filesystem, NOT the Pico-SDK kernel, so it skips this hook (see toolchain-armm0).
# ---------------------------------------------------------------------------
if(FUZIX_PLATFORM STREQUAL "rpipico" AND NOT FUZIX_USERLAND_ONLY)
    if(NOT DEFINED PICO_SDK_PATH AND NOT DEFINED ENV{PICO_SDK_PATH})
        set(PICO_SDK_PATH "${CMAKE_CURRENT_LIST_DIR}/toolchain/pico-sdk")
    endif()
    if(NOT DEFINED PICO_TOOLCHAIN_PATH AND NOT DEFINED ENV{PICO_TOOLCHAIN_PATH}
       AND EXISTS "${CMAKE_CURRENT_LIST_DIR}/toolchain/arm-none-eabi/bin/arm-none-eabi-gcc")
        set(PICO_TOOLCHAIN_PATH "${CMAKE_CURRENT_LIST_DIR}/toolchain/arm-none-eabi/bin")
    endif()
    if(NOT DEFINED PICO_BOARD)
        set(PICO_BOARD "pico")
    endif()
    include("${CMAKE_CURRENT_LIST_DIR}/cmake/pico_sdk_import.cmake")
    set(_fuzix_langs C CXX ASM)
else()
    set(_fuzix_langs NONE)
endif()

project(fuzix_new
        VERSION 0.5
        DESCRIPTION "FUZIX kernel, CMake build (i8080 / z80u / armm0 / …)"
        LANGUAGES ${_fuzix_langs})

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(FuzixBuild)

# Pico SDK must be initialised after project() and before the fuzix executable
# target is defined (in cmake/platform-rpipico.cmake).
if(FUZIX_PLATFORM STREQUAL "rpipico" AND NOT FUZIX_USERLAND_ONLY)
    pico_sdk_init()
endif()

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
set_property(CACHE FUZIX_CPU      PROPERTY STRINGS i8080 i8085 8070 6800 z8 super8 z80u z80 pdp11 i8086 armm4 armm0)
set_property(CACHE FUZIX_PLATFORM PROPERTY STRINGS
    v8080 z80pack rcbus-8080 rcbus-8085 rcbus-8070 rcbus-6800 rcbus-z8 rcbus-super8 rcbus-80c188 tm4c129x rpipico pdp11 ibmpc
    # z80u boards
    aqplus challengeriii lobo-max80 nascom nano-z80 rc2014-tiny rcbus-tp128
    sbcv2 sbc2g sc720 z80membership z1013 zrc z80all z80-mbc2 z80retro
    searle tomssbc simple80
    # classic SDCC z80 boards
    2063)

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
# the 8086 4K-page banking model). Several z80u boards are swap-only
# (mm/simple.c) or use the 4x16K banked model (mm/bank16k.c) rather than the
# generic fixed-bank default; encode those here so a bare -DFUZIX_PLATFORM=<b>
# picks the right MM without extra flags. An explicit -DFUZIX_MM still wins.
if(FUZIX_PLATFORM STREQUAL "pdp11")
    set(_mm_default "simple")
elseif(FUZIX_PLATFORM STREQUAL "ibmpc")
    set(_mm_default "bank8086")
elseif(FUZIX_PLATFORM MATCHES "^(searle|tomssbc|rc2014-tiny|z1013|simple80|rcbus-80c188)$")
    set(_mm_default "simple")     # swap-only boards
elseif(FUZIX_PLATFORM MATCHES "^(aqplus|z80retro)$")
    set(_mm_default "bank16k")    # 4x16K banked boards
elseif(FUZIX_PLATFORM MATCHES "^(rcbus-8070|rcbus-6800)$")
    set(_mm_default "bank16kfc")  # 4x16K flash-friendly banked
elseif(FUZIX_PLATFORM STREQUAL "tm4c129x")
    set(_mm_default "flat")       # ARM Cortex-M flat address space
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

# Swap-only boards run one process resident at a time (upstream config.h has
# CONFIG_MULTI undefined); default multiprocess OFF for them so a bare build
# matches the board. An explicit -DFUZIX_MULTIPROCESS=ON/OFF still wins.
if(FUZIX_PLATFORM MATCHES "^(searle|tomssbc|rc2014-tiny|z1013|simple80)$")
    set(_mp_default OFF)
else()
    set(_mp_default ON)
endif()
option(FUZIX_MULTIPROCESS "Allow multiple processes resident in memory" ${_mp_default})

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
    -I${KDIR}/include)
# A board's own kernel/dev/<platform> drivers, if any, go BEFORE the generic
# kernel/dev so a board-specific header wins over the generic one.
if(IS_DIRECTORY "${KDIR}/dev/${FUZIX_PLATFORM}")
    list(APPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/dev/${FUZIX_PLATFORM})
endif()
# NOTE: shared driver trees whose headers COLLIDE with the generic kernel/dev
# ones must NOT be added globally, or they shadow the generic header for boards
# that don't use them.  Case in point: kernel/dev/z80pack/devfd.h declares hd_*
# but omits fd_close, while the generic kernel/dev/devfd.h is the reverse — so a
# global -I would break either the z80pack boards or everyone else.  Instead each
# board that actually pulls such a tree PREPENDs it in its own platform-*.cmake
# (see platform-z80pack/v8080 -> dev/z80pack, platform-nascom -> dev/80bus).
list(APPEND FUZIX_INCLUDE_FLAGS
    -I${KDIR}/dev
    -I${KDIR}/lib
    -I${GEN}/include)               # generated sysinfoblk.h
# Shared network driver headers (net_w5x00.h, enc28j60.h, ...) have unique names
# that don't collide with the generic kernel/dev, so this tree is safe globally.
if(IS_DIRECTORY "${KDIR}/dev/net")
    list(APPEND FUZIX_INCLUDE_FLAGS -I${KDIR}/dev/net)
endif()

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

# Host tools + userland + rootfs. Skipped for the Pico SDK build (rpipico),
# which produces only the kernel image via the SDK and has no fcc/gcc userland
# wired here.
if(NOT FUZIX_PLATFORM STREQUAL "rpipico" OR FUZIX_USERLAND_ONLY)
    # Host-side standalone utilities (mkfs/fsck/ucp/... ). Built via `tools` target.
    include(HostTools)

    # Board-specific root fs size. The 2063 disk image places the root fs in the
    # first partition of parttab.20M, which is 16385 blocks (~8MB) - the generic
    # 65535-block default would overflow the partition, so cap it here. Set as a
    # (non-FORCE) cache default before RootFS so an explicit -DFUZIX_ROOTFS_BSIZE
    # still wins.
    if(FUZIX_PLATFORM STREQUAL "2063")
        set(FUZIX_ROOTFS_BSIZE "16384" CACHE STRING "Root fs block count (mkfs fsize)")
        # Populate the root fs with the programs the `bin` target builds.
        set(FUZIX_ROOTFS_GEN_BIN ON CACHE BOOL "Install all built userland executables into /bin")
    endif()
    # rcbus-6800 boots from a 40MB IDE disk whose root partition is 65536 blocks
    # (32MB), so the default 65535-block fs fits; just populate /bin.
    if(FUZIX_PLATFORM STREQUAL "rcbus-6800")
        set(FUZIX_ROOTFS_GEN_BIN ON CACHE BOOL "Install all built userland executables into /bin")
    endif()

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
endif()

# Userland-only build (armm0 for the rpipico flash filesystem): the lib/bin
# targets above are all we need; no kernel image is produced.
if(FUZIX_USERLAND_ONLY)
    return()
endif()

set(FUZIX_EXTRA_DEPENDS "${GEN}/include/sysinfoblk.h")

# ---------------------------------------------------------------------------
# Ordered source list comes from the platform fragment (mirrors that board's
# Makefile image rule). It also sets LINK_FLAGS and DISK_SKIP.
# ---------------------------------------------------------------------------
set_property(GLOBAL PROPERTY FUZIX_OBJECTS "")   # reset accumulator

include("${CMAKE_SOURCE_DIR}/cmake/platform-${FUZIX_PLATFORM}.cmake")

# rpipico defines its `fuzix` executable entirely inside the platform fragment
# (Pico SDK add_executable + pico_add_extra_outputs); the fcc/gcc object-list
# link, diskimage and config summary below do not apply, so stop here.
if(FUZIX_PLATFORM STREQUAL "rpipico")
    return()
endif()

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
elseif(LINK_STYLE STREQUAL "arm-elf")
    # gcc/armm4: arm-none-eabi-ld -T <script> --entry=start -> ELF image.
    configure_file("${CMAKE_SOURCE_DIR}/cmake/link-image-armm4.sh.in"
                   "${CMAKE_BINARY_DIR}/link-image.sh" @ONLY)
    set(_link_dep "${LINK_SCRIPT}")
    set(_link_comment "arm-ld -T --entry=start -> fuzix.elf")
elseif(LINK_STYLE STREQUAL "sdcc-ihx")
    # sdcc/z80: sdldz80 + .lnk -> Intel HEX, then makebin + binman -> fuzix.bin.
    set(MAKEBIN_BIN "${FUZIX_TOOLCHAIN_PREFIX}/bin/makebin")
    set(BINMAN_BIN  "${CMAKE_BINARY_DIR}/tools/binman")
    add_custom_command(
        OUTPUT  "${BINMAN_BIN}"
        COMMAND "${HOSTCC}" -O2 -o "${BINMAN_BIN}" "${CMAKE_SOURCE_DIR}/tools/binman.c"
        DEPENDS "${CMAKE_SOURCE_DIR}/tools/binman.c"
        COMMENT "host cc  tools/binman")
    string(REPLACE ";" " " LINK_SDCC_BASES_STR "${LINK_SDCC_BASES}")
    configure_file("${CMAKE_SOURCE_DIR}/cmake/link-image-sdcc.sh.in"
                   "${CMAKE_BINARY_DIR}/link-image.sh" @ONLY)
    set(_link_dep "${BINMAN_BIN}")
    set(_link_comment "sdldz80 + makebin + binman -> fuzix.bin")
elseif(LINK_STYLE STREQUAL "fcc-raw")
    # fcc/z8: ldz8 emits the loadable binary directly, no pack85 step.
    string(REPLACE ";" " " LINK_FLAGS_STR "${LINK_FLAGS}")
    configure_file("${CMAKE_SOURCE_DIR}/cmake/link-image-z8.sh.in"
                   "${CMAKE_BINARY_DIR}/link-image.sh" @ONLY)
    set(_link_dep "${CMAKE_BINARY_DIR}/link-image.sh")
    set(_link_comment "${CPU_LD_TOOL} -> fuzix.bin (no pack85)")
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
elseif(DISKIMAGE_STYLE STREQUAL "rootdisk")
    # No boot sector (ibmpc): package just a populated root filesystem as the
    # hda disk image (mkfs + ucp + fsck), mirroring v8080's drivep half. Pulls
    # the built userland from the `bin` target's output dir.
    set(MKFS_BIN "${CMAKE_BINARY_DIR}/tools/mkfs")
    set(UCP_BIN  "${CMAKE_BINARY_DIR}/tools/ucp")
    set(FSCK_BIN "${CMAKE_BINARY_DIR}/tools/fsck")
    set(ETC_DIR  "${CMAKE_SOURCE_DIR}/tools/filesystem-src/etc-files")
    set(DISKIMAGE_FS_ISIZE "512")
    set(DISKIMAGE_FS_BSIZE "65535")
    configure_file("${CMAKE_SOURCE_DIR}/cmake/diskimage-ibmpc.sh.in"
                   "${CMAKE_BINARY_DIR}/diskimage.sh" @ONLY)
    add_custom_target(diskimage
        COMMAND /bin/sh "${CMAKE_BINARY_DIR}/diskimage.sh"
        DEPENDS "${CMAKE_BINARY_DIR}/diskimage.sh"
        COMMENT "Building hd0.img (root fs populated with the i8086 userland)"
        VERBATIM)
    # The disk image is a filesystem built from the userland + host fs tools, so
    # build them first. It deliberately does NOT depend on the kernel: ibmpc is
    # upstream build-testing-only (its 8086 MM / exec paths do not yet compile
    # with a real toolchain), so the image is the userland root disk; the script
    # copies fuzix.elf alongside only if the kernel happens to be built.
    add_dependencies(diskimage bin tools)
    set(DISKIMAGE_SKIP_KERNEL_DEP ON)
else()
    if(DISKIMAGE_STYLE STREQUAL "rcbus-6800")
        # Motorola 6800 RCBus: loader + parttab.40M + fs + kernel, plus an
        # idehdr-prefixed emulator image.
        if(NOT FUZIX_PARTTAB)
            set(FUZIX_PARTTAB "${CMAKE_SOURCE_DIR}/tools/filesystem-src/parttab.40M")
        endif()
        set(FUZIX_IDEHDR "${CMAKE_SOURCE_DIR}/tools/filesystem-src/idehdr.40M")
        configure_file("${CMAKE_SOURCE_DIR}/cmake/diskimage-rcbus-6800.sh.in"
                       "${CMAKE_BINARY_DIR}/diskimage.sh" @ONLY)
        set(_diskimage_dep "${PLATFORM_DIR}/loader.S")
        set(_diskimage_comment "Building loader + 40MB IDE disk.img")
    elseif(DISKIMAGE_STYLE STREQUAL "2063")
        # Classic SDCC Z80 SD image: assemble boot.s, dd parttab + fs + kernel.
        set(MAKEBIN_BIN "${FUZIX_TOOLCHAIN_PREFIX}/bin/makebin")
        if(NOT FUZIX_PARTTAB)
            set(FUZIX_PARTTAB "${CMAKE_SOURCE_DIR}/tools/filesystem-src/parttab.20M")
        endif()
        configure_file("${CMAKE_SOURCE_DIR}/cmake/diskimage-2063.sh.in"
                       "${CMAKE_BINARY_DIR}/diskimage.sh" @ONLY)
        set(_diskimage_dep "${PLATFORM_DIR}/boot.s")
        set(_diskimage_comment "Building boot.bin + SD disk.img")
    elseif(DISKIMAGE_STYLE STREQUAL "rcbus-ide")
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
if(NOT DISKIMAGE_SKIP_KERNEL_DEP)
    add_dependencies(diskimage fuzix)
endif()

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
