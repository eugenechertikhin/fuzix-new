# ---------------------------------------------------------------------------
# CPU settings: Zilog Super8 (Fuzix Compiler Kit, fcc -msuper8)
# Included by the top-level CMakeLists once FUZIX_CPU == super8.
#
# Z8-derived core. Like the z8/8070, ldsuper8 emits the loadable binary
# directly -> LINK_STYLE "fcc-raw" (no pack85; see link-image-z8.sh.in).
# Single low-level / usermem pair.
# ---------------------------------------------------------------------------

set(CPU_MACHINE       "-msuper8")                    # fcc machine flag
set(CPU_OPT           "-Os")                         # optimisation flag
set(CPU_LD_TOOL       "ldsuper8")                    # linker binary (in prefix/bin)
set(CPU_LIBC_SUBPATH  "super8/libsuper8.a")          # C library under prefix/lib

set(CPU_LOWLEVEL "kernel/cpu/super8/lowlevel-super8.S")
set(CPU_USERMEM  "kernel/cpu/super8/usermem_std-super8.S")

# ldsuper8 produces the loadable image directly (no pack85).
set(LINK_STYLE "fcc-raw")

# Boot block (if a platform uses one) is assembled with fcc -msuper8.
set(CPU_BOOTBLOCK_ASSEMBLE "\"${FUZIX_CC}\" -msuper8 -c \"$PLATDIR/bootblock.S\"")
