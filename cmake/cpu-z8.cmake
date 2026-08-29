# ---------------------------------------------------------------------------
# CPU settings: Zilog Z8 (Fuzix Compiler Kit, fcc -mz8)
# Included by the top-level CMakeLists once FUZIX_CPU == z8.
#
# The Z8 uses the Fuzix Compiler Kit like the 8080/z80, but its linker (ldz8)
# emits the final loadable binary directly, so there is NO pack85 post-link
# step -> LINK_STYLE "fcc-raw" (see cmake/link-image-z8.sh.in). Single
# low-level / usermem pair (no banking variants).
# ---------------------------------------------------------------------------

set(CPU_MACHINE       "-mz8")                        # fcc machine flag
set(CPU_OPT           "-Os")                         # optimisation flag
set(CPU_LD_TOOL       "ldz8")                         # linker binary (in prefix/bin)
set(CPU_LIBC_SUBPATH  "z8/libz8.a")                  # C library under prefix/lib

set(CPU_LOWLEVEL "kernel/cpu/z8/lowlevel-z8.S")
set(CPU_USERMEM  "kernel/cpu/z8/usermem_std-z8.S")

# ldz8 produces the loadable image directly (no pack85).
set(LINK_STYLE "fcc-raw")

# Boot block (if a platform uses one) is assembled with fcc -mz8.
set(CPU_BOOTBLOCK_ASSEMBLE "\"${FUZIX_CC}\" -mz8 -c \"$PLATDIR/bootblock.S\"")
