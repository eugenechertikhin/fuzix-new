# ---------------------------------------------------------------------------
# CPU settings: Intel 8086 (ia16-elf GCC)
# Included by the top-level CMakeLists once FUZIX_CPU == i8086.
#
# This is a gcc-kind toolchain (like pdp11): compilation uses the standard
# `gcc -c -o` form and .S sources are assembled through the same driver.
# Linking is done with a linker script (fuzix.ld) via ia16-elf-ld; upstream
# produces an ELF image (fuzix.elf) directly, with no objcopy step.
# ---------------------------------------------------------------------------

set(FUZIX_TOOLCHAIN_KIND "gcc")

# Was CROSS_CCOPTS in cpu-8086/rules.mk (the -I/-c parts are added by the
# build helper; only the real optimisation flag lives here).
set(CPU_OPT "-Os")
set(FUZIX_CC_LABEL "ia16-gcc")

# No machine flag / linker binary / libc archive to derive (gcc link).
set(CPU_MACHINE      "")
set(CPU_LD_TOOL      "")
set(CPU_LIBC_SUBPATH "")

# Low level (context switch / user<->kernel copy).
set(CPU_LOWLEVEL "kernel/cpu/i8086/lowlevel-8086.S")
set(CPU_USERMEM  "kernel/cpu/i8086/usermem_std-8086.S")

# Link via linker-script producing an ELF image (no objcopy). See
# cmake/link-image-8086.sh.in.
set(LINK_STYLE "ld-elf")
