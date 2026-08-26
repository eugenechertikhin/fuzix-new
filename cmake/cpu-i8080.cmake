# ---------------------------------------------------------------------------
# CPU settings: Intel 8080 (Fuzix Compiler Kit)
# Included by the top-level CMakeLists once FUZIX_CPU == i8080.
# All paths are relative to the source tree root unless noted.
# ---------------------------------------------------------------------------

set(CPU_MACHINE       "-m8080")                      # fcc machine flag
set(CPU_OPT           "-Os")                         # optimisation flag
set(CPU_LD_TOOL       "ld8080")                      # linker binary (in prefix/bin)
set(CPU_LIBC_SUBPATH  "8080/lib8080.a")              # C library under prefix/lib

# Low level (context switch / user<->kernel copy). The 8080 has no banking
# variants, so there is a single pair.
set(CPU_LOWLEVEL "kernel/cpu/i8080/lowlevel-8080.S")
set(CPU_USERMEM  "kernel/cpu/i8080/usermem_std-8080.S")

# How the boot sector is assembled (the second half, ld -b, is shared).
# On 8080 the boot block is assembled with fcc itself.
set(CPU_BOOTBLOCK_ASSEMBLE "\"${FUZIX_CC}\" -m8080 -c \"$PLATDIR/bootblock.S\"")
