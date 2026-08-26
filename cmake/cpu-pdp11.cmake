# ---------------------------------------------------------------------------
# CPU settings: PDP-11 (pdp11-aout GCC)
# Included by the top-level CMakeLists once FUZIX_CPU == pdp11.
#
# This is a gcc-kind toolchain: compilation uses the standard `gcc -c -o`
# form, and linking uses `ld -T <script>` + objcopy instead of pack85.
# ---------------------------------------------------------------------------

set(FUZIX_TOOLCHAIN_KIND "gcc")

# Full gcc flag set (was CROSS_CCOPTS in cpu-pdp11/rules.mk).
set(CPU_OPT "-Os;-fno-strict-aliasing;-fomit-frame-pointer;-fno-builtin;-Wall")
set(FUZIX_CC_LABEL "pdp11-gcc")

# No machine flag / linker binary / libc archive to derive (gcc link).
set(CPU_MACHINE      "")
set(CPU_LD_TOOL      "")
set(CPU_LIBC_SUBPATH "")

# Low level (context switch / user<->kernel copy).
set(CPU_LOWLEVEL "kernel/cpu/pdp11/lowlevel-pdp11.S")
set(CPU_USERMEM  "kernel/cpu/pdp11/usermem_std-pdp11.S")

# Link via linker-script + objcopy rather than pack85.
set(LINK_STYLE "ld-objcopy")
