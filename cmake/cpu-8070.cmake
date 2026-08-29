# ---------------------------------------------------------------------------
# CPU settings: National Semiconductor INS8070 (Fuzix Compiler Kit, fcc -m8070)
# Included by the top-level CMakeLists once FUZIX_CPU == 8070.
#
# Like the z8, the 8070 linker (ld8070) emits the loadable binary directly, so
# there is NO pack85 step -> LINK_STYLE "fcc-raw" (see link-image-z8.sh.in,
# shared by both raw-ld fcc targets). Single low-level / usermem pair.
# ---------------------------------------------------------------------------

set(CPU_MACHINE       "-m8070")                      # fcc machine flag
set(CPU_OPT           "-Os")                         # optimisation flag
set(CPU_LD_TOOL       "ld8070")                       # linker binary (in prefix/bin)
set(CPU_LIBC_SUBPATH  "8070/lib8070.a")              # C library under prefix/lib

set(CPU_LOWLEVEL "kernel/cpu/8070/lowlevel-8070.S")
set(CPU_USERMEM  "kernel/cpu/8070/usermem_std-8070.S")

# ld8070 produces the loadable image directly (no pack85).
set(LINK_STYLE "fcc-raw")

# Boot block (if a platform uses one) is assembled with fcc -m8070.
set(CPU_BOOTBLOCK_ASSEMBLE "\"${FUZIX_CC}\" -m8070 -c \"$PLATDIR/bootblock.S\"")
