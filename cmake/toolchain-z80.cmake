# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the classic Z80 port (SDCC / sdasz80 / sdldz80).
#
# Unlike z80u (which reuses the Fuzix Compiler Kit), this is the original SDCC
# build path: sdcc compiles C into .rel objects, sdasz80 assembles, and the
# banking-aware sdldz80 links via a .lnk command file into an Intel HEX image.
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-z80.cmake \
#         -DFUZIX_CPU=z80 -DFUZIX_PLATFORM=2063
#
# The SDCC install prefix defaults to ./toolchain/sdcc but can be overridden
# with -DFUZIX_TOOLCHAIN_PREFIX=... (or the FUZIX_TOOLCHAIN_PREFIX env var).
# ---------------------------------------------------------------------------

set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_PROCESSOR  z80)

if(NOT DEFINED FUZIX_TOOLCHAIN_PREFIX)
    if(DEFINED ENV{FUZIX_TOOLCHAIN_PREFIX})
        set(FUZIX_TOOLCHAIN_PREFIX "$ENV{FUZIX_TOOLCHAIN_PREFIX}")
    else()
        # Bundled SDCC install. Resolve to an absolute path (this file lives in
        # <root>/cmake) so the tools resolve regardless of the build directory.
        get_filename_component(FUZIX_TOOLCHAIN_PREFIX
            "${CMAKE_CURRENT_LIST_DIR}/../toolchain/sdcc" ABSOLUTE)
    endif()
endif()
set(FUZIX_TOOLCHAIN_PREFIX "${FUZIX_TOOLCHAIN_PREFIX}"
    CACHE PATH "Install prefix of the SDCC toolchain (sdcc/sdasz80/sdldz80)")

# Compiler / assembler / linker. The linker and library are Z80-specific and
# are wired up in cmake/cpu-z80.cmake from this prefix.
set(FUZIX_CC "${FUZIX_TOOLCHAIN_PREFIX}/bin/sdcc"
    CACHE FILEPATH "SDCC C compiler driver")

# Tell CMake about the compiler but suppress its normal probe: compilation and
# linking are driven by custom commands (see cmake/FuzixBuild.cmake).
set(CMAKE_C_COMPILER   "${FUZIX_CC}")
set(CMAKE_C_COMPILER_ID SDCC)
set(CMAKE_C_COMPILER_WORKS  TRUE)
set(CMAKE_C_COMPILER_FORCED TRUE)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
