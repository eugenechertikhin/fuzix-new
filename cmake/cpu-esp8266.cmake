# ---------------------------------------------------------------------------
# CPU settings: Espressif ESP8266 (Xtensa LX106, xtensa-lx106-elf GCC)
# Included by the top-level CMakeLists once FUZIX_CPU == esp8266.
#
# A gcc-kind toolchain (like pdp11 / i8086 / armm4): `gcc -c -o` compiles, and
# .S sources assemble through the same driver. Linking is done with the C
# compiler as the linker driver plus TWO linker scripts (kernel.ld +
# addresses.ld) and -flto -mlongcalls -nostdlib -> an ELF image (image.elf).
# See cmake/link-image-esp8266.sh.in and LINK_STYLE "xtensa-elf".
#
# 32-bit target with a custom memory model: no standard mm/bank*.c is linked -
# the platform provides its own swapper.c + malloc (FUZIX_MM=custom), and its
# own exec loader (FUZIX_EXECFORMAT=none, platform syscall_exec.c). Those are
# defaulted per-board in the top-level CMakeLists.
# ---------------------------------------------------------------------------

set(FUZIX_TOOLCHAIN_KIND "gcc")

# From cpu-esp8266/rules.mk CROSS_CCOPTS (the -c / -I parts are added by the
# build helper). A CMake list of flags, like armm4's CPU_OPT.
#
# NOTE: upstream targets the classic xtensa-lx106-elf toolchain. We build with
# the in-repo ESP toolchain (toolchain/xtensa-esp-elf, gcc 15.3, an ESP32-core
# multilib build - there is no lx106 core here), so the lx106-only
# `-mforce-l32` is dropped (unrecognised by this gcc); `-mlongcalls` and
# `-mforce-no-pic` are kept. This makes the port build-testing only (the ELF is
# not a runnable lx106 image - see docs).
set(CPU_OPT
    -g -Os -fno-strict-aliasing -fomit-frame-pointer -fno-builtin -Wall
    -mlongcalls -mforce-no-pic
    # FUZIX is pre-C99-strict K&R-ish C; gcc 14+ makes implicit function/int
    # declarations HARD errors by default (upstream's older gcc only warned).
    # Demote them back to warnings so the sources build unmodified.
    -Wno-error=implicit-function-declaration -Wno-error=implicit-int)
set(FUZIX_CC_LABEL "xtensa-gcc")

# No machine flag / linker binary / libc archive to derive (gcc-driver link).
set(CPU_MACHINE      "")
set(CPU_LD_TOOL      "")
set(CPU_LIBC_SUBPATH "")

# Low level (context switch / user<->kernel copy).
set(CPU_LOWLEVEL "kernel/cpu/esp8266/lowlevel-esp8266.S")
set(CPU_USERMEM  "kernel/cpu/esp8266/usermem_std-esp8266.S")

# Link via the gcc driver + two linker scripts producing an ELF image. See
# cmake/link-image-esp8266.sh.in.
set(LINK_STYLE "xtensa-elf")
