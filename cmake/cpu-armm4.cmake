# ---------------------------------------------------------------------------
# CPU settings: ARM Cortex-M4 (arm-none-eabi GCC, thumb / armv7e-m)
# Included by the top-level CMakeLists once FUZIX_CPU == armm4.
#
# gcc-kind, 32-bit ELF. Links via arm-none-eabi-ld with the board's linker
# script and --entry=start (LINK_STYLE "arm-elf"; see link-image-armm4.sh.in).
# The full cortex-m4 flag set lives in CPU_OPT (a CMake list so it expands to
# separate compiler arguments).
# ---------------------------------------------------------------------------

set(FUZIX_TOOLCHAIN_KIND "gcc")
set(FUZIX_CC_LABEL "arm-gcc")

# Mirrors CROSS_CCOPTS in cpu-armm4/rules.mk (the -I/-c are added by the build
# helper). Kept as a list so each flag is passed as its own argument.
set(CPU_OPT -g -Os -fno-strict-aliasing -fno-builtin -Wall
            -mcpu=cortex-m4 -mtune=cortex-m4 -march=armv7e-m+nofp -mthumb
            -DNSOCKET=4)

# No fcc machine flag / derived linker / libc (gcc link).
set(CPU_MACHINE      "")
set(CPU_LD_TOOL      "")
set(CPU_LIBC_SUBPATH "")

set(CPU_LOWLEVEL "kernel/cpu/armm4/lowlevel-armm4.S")
set(CPU_USERMEM  "kernel/cpu/armm4/usermem_std-armm4.S")

# arm-none-eabi-ld -T <script> --entry=start -> ELF image.
set(LINK_STYLE "arm-elf")
