# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the Espressif ESP8266 (Xtensa LX106).
#
# Like pdp11 / i8086 / armm4 this is a standard GCC cross toolchain
# (xtensa-lx106-elf-gcc / -ld). The kernel is linked with the compiler driver
# and two linker scripts (kernel.ld + addresses.ld) into an ELF image; there is
# no objcopy step in our build (the ELF is the deliverable; esptool elf2image
# is a downstream flashing step, done outside CMake).
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-esp8266.cmake \
#         -DFUZIX_CPU=esp8266 -DFUZIX_PLATFORM=esp8266
#
# Uses the in-repo ESP toolchain toolchain/xtensa-esp-elf (crosstool-NG esp,
# gcc 15.3), tool prefix `xtensa-esp-elf-` (NOT the classic `xtensa-lx106-elf-`
# upstream assumes). That toolchain is an ESP32-core multilib build - it has no
# ESP8266/lx106 core - so this is build-testing only: the sources compile and
# link into an ELF, but the result is not a runnable lx106 image. Point
# FUZIX_XTENSA_PREFIX elsewhere (e.g. a real xtensa-lx106-elf) to override.
# ---------------------------------------------------------------------------

set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_PROCESSOR  xtensa)

set(FUZIX_TOOLCHAIN_KIND "gcc")

set(FUZIX_XTENSA_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../toolchain/xtensa-esp-elf/bin" CACHE PATH
    "Directory holding the xtensa-*-elf-* tools")
set(FUZIX_XTENSA_TUPLE "xtensa-esp-elf" CACHE STRING
    "Cross tool prefix tuple (xtensa-esp-elf | xtensa-lx106-elf | ...)")
if(FUZIX_XTENSA_PREFIX)
    set(_p "${FUZIX_XTENSA_PREFIX}/")
else()
    set(_p "")
endif()

set(FUZIX_CC      "${_p}${FUZIX_XTENSA_TUPLE}-gcc"     CACHE FILEPATH "ESP8266 C compiler / link driver")
set(FUZIX_LD      "${_p}${FUZIX_XTENSA_TUPLE}-ld"      CACHE FILEPATH "ESP8266 linker (unused; link goes through gcc)")
set(FUZIX_OBJCOPY "${_p}${FUZIX_XTENSA_TUPLE}-objcopy" CACHE FILEPATH "ESP8266 objcopy (unused in-CMake)")

# For the config summary; keep FUZIX_TOOLCHAIN_PREFIX defined but unused.
if(NOT DEFINED FUZIX_TOOLCHAIN_PREFIX)
    set(FUZIX_TOOLCHAIN_PREFIX "${FUZIX_XTENSA_PREFIX}" CACHE PATH "unused for esp8266")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
