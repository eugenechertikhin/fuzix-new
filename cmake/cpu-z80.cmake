# ---------------------------------------------------------------------------
# CPU settings: classic Z80 port (SDCC + sdasz80 + sdldz80)
# Included by the top-level CMakeLists once FUZIX_CPU == z80.
#
# This is the original SDCC Z80 target (distinct from z80u, which uses the
# Fuzix Compiler Kit). It introduces a third toolchain kind, "sdcc":
#   - C  : sdcc -c --std-sdcc99 --no-std-crt0 -mz80 ... (writes a .rel object)
#   - asm: sdasz80 -plosff (resolves .include via -I, writes a .rel object)
#   - link: sdldz80 with a generated .lnk command file -> Intel HEX -> binary
#
# SDCC places code/data in named areas (_CODE, CODE2, _COMMONMEM, VIDEO,
# FONT, DISCARD, CONST, ...). Per-source --codeseg / --constseg overrides are
# passed through fuzix_compile(... EXTRA ...) from the platform fragment,
# transcribing the upstream top-level Makefile segment source lists.
# ---------------------------------------------------------------------------

set(FUZIX_TOOLCHAIN_KIND "sdcc")

set(CPU_MACHINE  "-mz80")     # sdcc machine flag (used in build comments)
set(CPU_OPT      "")          # all opt flags folded into FUZIX_SDCC_OPTS below
set(CPU_LD_TOOL  "sdldz80")   # banking-aware SDCC linker
set(CPU_LOWLEVEL "kernel/cpu/z80/lowlevel-z80.s")

# Assembler / linker binaries derived from the toolchain prefix.
set(FUZIX_AS "${FUZIX_TOOLCHAIN_PREFIX}/bin/sdasz80"
    CACHE FILEPATH "SDCC Z80 assembler")
if(NOT DEFINED FUZIX_LD OR FUZIX_LD STREQUAL "")
    set(FUZIX_LD "${FUZIX_TOOLCHAIN_PREFIX}/bin/${CPU_LD_TOOL}")
endif()

# SDCC Z80 runtime library (z80.lib) directory, for sdldz80's -k/-l.
set(CPU_LIB_DIR "${FUZIX_TOOLCHAIN_PREFIX}/share/sdcc/lib/z80")
set(CPU_LIB_NAME "z80")
set(FUZIX_LIBC "${CPU_LIB_DIR}/z80.lib")   # for the configuration summary

# Base sdcc compile options (matches cpu-z80/rules.mk). --constseg CONST is the
# default; individual sources may override the code/const segment via EXTRA.
set(FUZIX_SDCC_OPTS
    -c --std-sdcc99 --no-std-crt0 -mz80
    --max-allocs-per-node 30000 --opt-code-size --stack-auto
    --constseg CONST
    --peep-file "${CMAKE_SOURCE_DIR}/kernel/cpu/z80/switch.peep")

# sdasz80 options + include path so .include "kernel.def" / "kernel-z80.def" /
# "std-commonmem.s" / "z80fixedbank.s" / "vdp1.s" / "z80sio.s" all resolve
# (paths were flattened to plain filenames on import).
set(FUZIX_ASOPTS -plosff)
# sdasz80 needs the joined -I<dir> form (a space-separated "-I dir" is parsed as
# an option after a filename -> "Options come first" error).
set(FUZIX_ASINCLUDES
    "-I${CMAKE_SOURCE_DIR}/kernel/platform/${FUZIX_PLATFORM}"
    "-I${CMAKE_SOURCE_DIR}/kernel/cpu/z80"
    "-I${CMAKE_SOURCE_DIR}/kernel/dev"
    "-I${CMAKE_SOURCE_DIR}/kernel/lib")

# The classic Z80 image is produced from Intel HEX by sdldz80, then packed to a
# flat binary (see cmake/link-image-sdcc.sh.in).
set(LINK_STYLE "sdcc-ihx")
