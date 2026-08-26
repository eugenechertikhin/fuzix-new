# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the Intel 8080 (Fuzix Compiler Kit / Bintools)
#
# Pass to cmake with:
#     cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake ...
#
# The location of the cross toolchain is fully configurable. By default we
# look under /opt/fcc (the standard Fuzix Compiler Kit install prefix), but
# every path can be overridden from the command line or environment, e.g.
#
#     cmake -B build \
#       -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake \
#       -DFUZIX_TOOLCHAIN_PREFIX=$HOME/cross/fcc
#
# or component by component:
#
#       -DFUZIX_CC=/path/to/fcc -DFUZIX_LD=/path/to/ld8080 \
#       -DFUZIX_LIBC=/path/to/lib8080.a
# ---------------------------------------------------------------------------

set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_PROCESSOR  i8080)

# --- Root of the cross toolchain --------------------------------------------
# Order of precedence: -D on the command line, then the environment, then
# the conventional /opt/fcc install location.
if(NOT DEFINED FUZIX_TOOLCHAIN_PREFIX)
    if(DEFINED ENV{FUZIX_TOOLCHAIN_PREFIX})
        set(FUZIX_TOOLCHAIN_PREFIX "$ENV{FUZIX_TOOLCHAIN_PREFIX}")
    else()
        set(FUZIX_TOOLCHAIN_PREFIX "/opt/fcc")
    endif()
endif()
set(FUZIX_TOOLCHAIN_PREFIX "${FUZIX_TOOLCHAIN_PREFIX}"
    CACHE PATH "Install prefix of the Fuzix cross toolchain (fcc/ld8080)")

# --- Compiler driver (the linker binary and C library are CPU-specific and
#     are derived in CMakeLists.txt from the selected CPU + this prefix, so
#     the same toolchain file serves every fcc-based CPU: i8080, z80u, ...) ---
set(FUZIX_CC   "${FUZIX_TOOLCHAIN_PREFIX}/bin/fcc"
    CACHE FILEPATH "Fuzix C compiler driver (fcc)")

# FUZIX_LD / FUZIX_LIBC may still be overridden explicitly on the command line;
# otherwise CMakeLists.txt fills them in from the CPU fragment + prefix.

# Tell CMake about the compiler but do NOT let it run its normal compiler
# probe: fcc is a freestanding cross driver with a non-standard CLI and is
# usually absent on the build host at configure time. We drive compilation
# and linking ourselves through custom commands (see cmake/FuzixBuild.cmake).
set(CMAKE_C_COMPILER   "${FUZIX_CC}")
set(CMAKE_C_COMPILER_ID GNU)
set(CMAKE_C_COMPILER_WORKS  TRUE)
set(CMAKE_C_COMPILER_FORCED TRUE)

# Never try to run target binaries or link host test programs.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Do not look on the host for libraries/headers/programs.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
