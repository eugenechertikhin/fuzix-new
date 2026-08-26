# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the PDP-11 (pdp11-aout GCC).
#
# Unlike the fcc/SDCC 8-bit targets, PDP-11 uses a standard GCC cross toolchain
# producing a.out, linked with a linker script and flattened with objcopy.
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-pdp11.cmake \
#         -DFUZIX_CPU=pdp11 -DFUZIX_PLATFORM=pdp11
#
# The tools are expected on PATH (pdp11-aout-gcc, -ld, -as, -objcopy). Point
# FUZIX_PDP11_PREFIX at a bin directory if they live elsewhere, or override any
# tool individually.
# ---------------------------------------------------------------------------

set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_PROCESSOR  pdp11)

set(FUZIX_TOOLCHAIN_KIND "gcc")

set(FUZIX_PDP11_PREFIX "" CACHE PATH
    "Directory holding the pdp11-aout-* tools (empty = search PATH)")
if(FUZIX_PDP11_PREFIX)
    set(_p "${FUZIX_PDP11_PREFIX}/")
else()
    set(_p "")
endif()

set(FUZIX_CC      "${_p}pdp11-aout-gcc"     CACHE FILEPATH "PDP-11 C compiler")
set(FUZIX_LD      "${_p}pdp11-aout-ld"      CACHE FILEPATH "PDP-11 linker")
set(FUZIX_OBJCOPY "${_p}pdp11-aout-objcopy" CACHE FILEPATH "PDP-11 objcopy")
set(FUZIX_AS_BOOT "${_p}pdp11-aout-as"      CACHE FILEPATH "PDP-11 assembler (boot block)")

# For the config summary; keep FUZIX_TOOLCHAIN_PREFIX defined but unused.
if(NOT DEFINED FUZIX_TOOLCHAIN_PREFIX)
    set(FUZIX_TOOLCHAIN_PREFIX "${FUZIX_PDP11_PREFIX}" CACHE PATH "unused for pdp11")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
