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
# A few boards have no common RAM (the whole 64K switches at once) and need the
# "thunked" low-level variant. Default the mode per board so a bare
# -DFUZIX_PLATFORM=<b> picks the right one; an explicit -DFUZIX_Z80U_MODE wins.
if(FUZIX_PLATFORM MATCHES "^(searle|tomssbc|simple80)$")
    set(_z80u_mode_default "thunked")
else()
    set(_z80u_mode_default "normal")
endif()
set(FUZIX_Z80U_MODE "${_z80u_mode_default}" CACHE STRING "Z80U low-level variant: normal|thunked")
set_property(CACHE FUZIX_Z80U_MODE PROPERTY STRINGS normal thunked)
if(FUZIX_Z80U_MODE STREQUAL "thunked")
    set(CPU_LOWLEVEL "kernel/cpu/z80u/lowlevel-z80u-thunked.S")
    set(CPU_USERMEM  "kernel/cpu/z80u/usermem_std-z80u-thunked.S")
else()
    set(CPU_LOWLEVEL "kernel/cpu/z80u/lowlevel-z80u.S")
    set(CPU_USERMEM  "kernel/cpu/z80u/usermem_std-z80u.S")
endif()

# On z80u the boot sector is assembled with the standalone asz80 assembler,
# whose usage is `as [-o object.o] source.s` - the -o option must come BEFORE
# the source file, otherwise asz80 prints usage and fails.
set(CPU_BOOTBLOCK_ASSEMBLE
    "\"${FUZIX_TOOLCHAIN_PREFIX}/bin/asz80\" -o bootblock.o \"$PLATDIR/bootblock.S\"")
