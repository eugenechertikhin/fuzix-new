# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the Intel 8086 (ia16-elf GCC).
#
# Like the PDP-11 target, the 8086 uses a standard GCC cross toolchain
# (ia16-elf-gcc / -ld) rather than the fcc/SDCC 8-bit tools. The kernel is
# linked with a linker script (fuzix.ld) into an ELF image; there is no
# objcopy step (upstream ships fuzix.elf as the deliverable).
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8086.cmake \
#         -DFUZIX_CPU=i8086 -DFUZIX_PLATFORM=ibmpc
#
# The tools are expected on PATH (ia16-elf-gcc, -ld). Point FUZIX_IA16_PREFIX
# at a bin directory if they live elsewhere, or override any tool individually.
# ---------------------------------------------------------------------------

set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_PROCESSOR  i8086)

set(FUZIX_TOOLCHAIN_KIND "gcc")

set(FUZIX_IA16_PREFIX "" CACHE PATH
    "Directory holding the ia16-elf-* tools (empty = search PATH)")
if(FUZIX_IA16_PREFIX)
    set(_p "${FUZIX_IA16_PREFIX}/")
else()
    set(_p "")
endif()

set(FUZIX_CC      "${_p}ia16-elf-gcc"     CACHE FILEPATH "8086 C compiler")
set(FUZIX_LD      "${_p}ia16-elf-ld"      CACHE FILEPATH "8086 linker")
set(FUZIX_OBJCOPY "${_p}ia16-elf-objcopy" CACHE FILEPATH "8086 objcopy (unused)")

# For the config summary; keep FUZIX_TOOLCHAIN_PREFIX defined but unused.
if(NOT DEFINED FUZIX_TOOLCHAIN_PREFIX)
    set(FUZIX_TOOLCHAIN_PREFIX "${FUZIX_IA16_PREFIX}" CACHE PATH "unused for i8086")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
