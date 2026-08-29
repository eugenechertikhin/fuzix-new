# ---------------------------------------------------------------------------
# CPU settings: Intel 8085 (Fuzix Compiler Kit, fcc -m8085)
# Included by the top-level CMakeLists once FUZIX_CPU == i8085.
#
# The 8085 is object-compatible with the 8080 flow: same ld8080 linker and
# pack85 image step as i8080, only the machine flag (-m8085) and C library
# (lib8085.a) differ. Like the 8080 it has no banking variants, so there is a
# single low-level / usermem pair.
# ---------------------------------------------------------------------------

set(CPU_MACHINE       "-m8085")                      # fcc machine flag
set(CPU_OPT           "-Os")                         # optimisation flag
set(CPU_LD_TOOL       "ld8080")                      # linker binary (in prefix/bin)
set(CPU_LIBC_SUBPATH  "8085/lib8085.a")              # C library under prefix/lib

set(CPU_LOWLEVEL "kernel/cpu/i8085/lowlevel-8085.S")
set(CPU_USERMEM  "kernel/cpu/i8085/usermem_std-8085.S")

# How the boot sector is assembled (the second half, ld -b, is shared).
# On 8085, as on 8080, the boot block is assembled with fcc itself.
set(CPU_BOOTBLOCK_ASSEMBLE "\"${FUZIX_CC}\" -m8085 -c \"$PLATDIR/bootblock.S\"")
