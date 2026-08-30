# ---------------------------------------------------------------------------
# CPU settings: Motorola 6800 (Fuzix Compiler Kit, fcc -m6800)
# Included by the top-level CMakeLists once FUZIX_CPU == 6800.
#
# Like the z8 / 8070, the 6800 linker (ld6800) emits the loadable binary
# directly, so there is NO pack85 step -> LINK_STYLE "fcc-raw" (shared
# link-image-z8.sh.in). The 6800 is big-endian; the userland library build
# passes the endianness flag (see UserLib.cmake _ul_6800_row).
# ---------------------------------------------------------------------------

set(CPU_MACHINE       "-m6800")                      # fcc machine flag
set(CPU_OPT           "-Os")                         # optimisation flag
set(CPU_LD_TOOL       "ld6800")                      # linker binary (in prefix/bin)
set(CPU_LIBC_SUBPATH  "6800/lib6800.a")              # C library under prefix/lib

set(CPU_LOWLEVEL "kernel/cpu/6800/lowlevel-6800.S")
set(CPU_USERMEM  "kernel/cpu/6800/usermem_std-6800.S")

# ld6800 produces the loadable image directly (no pack85).
set(LINK_STYLE "fcc-raw")

# Boot block (if a platform uses one) is assembled with fcc -m6800.
set(CPU_BOOTBLOCK_ASSEMBLE "\"${FUZIX_CC}\" -m6800 -c \"$PLATDIR/bootblock.S\"")
