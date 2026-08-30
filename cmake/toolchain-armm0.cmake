# ---------------------------------------------------------------------------
# FUZIX USERLAND cross toolchain for ARM Cortex-M0+ (arm-none-eabi GCC).
#
# Used to build the armm0 USERLAND (`lib`/`bin`) that fills the rpipico flash
# filesystem. The rpipico KERNEL is built via the Pico SDK (no toolchain file);
# this file is for the userland-only configure:
#
#   cmake -B build-armm0-user -DFUZIX_CPU=armm0 -DFUZIX_PLATFORM=rpipico \
#         -DFUZIX_USERLAND_ONLY=ON \
#         -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-armm0.cmake \
#         -DFUZIX_ARM_PREFIX=$PWD/toolchain/arm-none-eabi/bin
#   cmake --build build-armm0-user --target lib
#   cmake --build build-armm0-user --target bin
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
set(FUZIX_OBJCOPY "${_p}arm-none-eabi-objcopy" CACHE FILEPATH "ARM objcopy")

if(NOT DEFINED FUZIX_TOOLCHAIN_PREFIX)
    set(FUZIX_TOOLCHAIN_PREFIX "${FUZIX_ARM_PREFIX}" CACHE PATH "unused for armm0")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
