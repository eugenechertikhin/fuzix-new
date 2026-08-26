# ---------------------------------------------------------------------------
# CPU settings: Z80 "u" port (Fuzix Compiler Kit, fcc -mz80)
# Included by the top-level CMakeLists once FUZIX_CPU == z80u.
#
# This is the new-compiler Z80 target: unlike the classic cpu-z80 (which uses
# SDCC), z80u builds with the same Fuzix Compiler Kit as the 8080, so it fits
# the same fcc/ldz80/pack85 pipeline.
# ---------------------------------------------------------------------------

set(CPU_MACHINE       "-mz80")                       # fcc machine flag
set(CPU_OPT           "-O")                          # optimisation flag
set(CPU_LD_TOOL       "ldz80")                       # linker binary (in prefix/bin)
set(CPU_LIBC_SUBPATH  "z80/libz80.a")                # C library under prefix/lib

# Low level has a "normal" (common RAM) and a "thunked" (no common RAM) variant.
set(FUZIX_Z80U_MODE "normal" CACHE STRING "Z80U low-level variant: normal|thunked")
set_property(CACHE FUZIX_Z80U_MODE PROPERTY STRINGS normal thunked)
if(FUZIX_Z80U_MODE STREQUAL "thunked")
    set(CPU_LOWLEVEL "kernel/cpu/z80u/lowlevel-z80u-thunked.S")
    set(CPU_USERMEM  "kernel/cpu/z80u/usermem_std-z80u-thunked.S")
else()
    set(CPU_LOWLEVEL "kernel/cpu/z80u/lowlevel-z80u.S")
    set(CPU_USERMEM  "kernel/cpu/z80u/usermem_std-z80u.S")
endif()

# On z80u the boot sector is assembled with the standalone asz80 assembler.
set(CPU_BOOTBLOCK_ASSEMBLE
    "\"${FUZIX_TOOLCHAIN_PREFIX}/bin/asz80\" \"$PLATDIR/bootblock.S\" -o bootblock.o")
