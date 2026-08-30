# ---------------------------------------------------------------------------
# CPU settings: ARM Cortex-M0+ / RP2040 (Raspberry Pi Pico SDK)
# Included by the top-level CMakeLists once FUZIX_CPU == armm0.
#
# Unlike every other CPU, armm0 is NOT built through fuzix_compile + a single
# ld link. Its only board (rpipico) is built with the **Raspberry Pi Pico SDK**:
# the SDK owns the compiler, startup, linker script and image (.uf2) generation.
# We integrate the SDK's build COMMANDS into our own CMake rather than shelling
# out to the upstream sub-project:
#   * the top-level CMakeLists includes pico_sdk_import.cmake BEFORE project(),
#     enables C/CXX/ASM, and calls pico_sdk_init();
#   * cmake/platform-rpipico.cmake defines the `fuzix` executable (add_executable
#     over our in-tree kernel sources) + pico_add_extra_outputs();
#   * the normal fcc/gcc compile/link/diskimage machinery is skipped.
# This fragment only records the toolchain kind + a marker for those guards.
# ---------------------------------------------------------------------------

set(FUZIX_TOOLCHAIN_KIND "gcc")
set(FUZIX_BUILD_STYLE    "pico-sdk")
set(FUZIX_CC_LABEL       "arm-gcc")

set(CPU_MACHINE      "")
set(CPU_OPT          "")
set(CPU_LD_TOOL      "")
set(CPU_LIBC_SUBPATH "")
set(CPU_LOWLEVEL     "kernel/cpu/armm0/lowlevel-armm0.c")
set(CPU_USERMEM      "")
