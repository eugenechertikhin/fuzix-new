# ---------------------------------------------------------------------------
# FUZIX cross toolchain for ARM Cortex-M4 (arm-none-eabi GCC).
#
# A standard bare-metal GCC cross toolchain (arm-none-eabi-gcc / -ld). The
# kernel is linked with a linker script (fuzix.ld) into an ELF image; no
# objcopy step. Tools are expected on PATH; point FUZIX_ARM_PREFIX at a bin
# directory if they live elsewhere (e.g. the in-tree toolchain/arm-none-eabi/bin).
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-armm4.cmake \
#         -DFUZIX_CPU=armm4 -DFUZIX_PLATFORM=tm4c129x \
#         -DFUZIX_ARM_PREFIX=$PWD/toolchain/arm-none-eabi/bin
# ---------------------------------------------------------------------------
set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_PROCESSOR  arm)

set(FUZIX_TOOLCHAIN_KIND "gcc")

set(FUZIX_ARM_PREFIX "" CACHE PATH
    "Directory holding the arm-none-eabi-* tools (empty = search PATH)")
if(FUZIX_ARM_PREFIX)
    set(_p "${FUZIX_ARM_PREFIX}/")
else()
    set(_p "")
endif()

set(FUZIX_CC      "${_p}arm-none-eabi-gcc"     CACHE FILEPATH "ARM C compiler")
set(FUZIX_LD      "${_p}arm-none-eabi-ld"      CACHE FILEPATH "ARM linker")
set(FUZIX_OBJCOPY "${_p}arm-none-eabi-objcopy" CACHE FILEPATH "ARM objcopy (unused)")

if(NOT DEFINED FUZIX_TOOLCHAIN_PREFIX)
    set(FUZIX_TOOLCHAIN_PREFIX "${FUZIX_ARM_PREFIX}" CACHE PATH "unused for armm4")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
