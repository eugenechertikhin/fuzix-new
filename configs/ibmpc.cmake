# configs/ibmpc.cmake - maximal userland for the IBM PC (i8086 / ia16-elf).
#
# Enables every program package (like configs/full.cmake), then drops the few
# programs that cannot be produced for this target:
#   * cc1 / cc2  - the Fuzix Compiler Kit code generator + backend. They pull in
#                  the per-target gen_*/target_* codegen objects (built specially,
#                  not part of the app link), so they fail to link with libc alone.
#
# Everything else in the registry that is not CPU-filtered out (gfxtest, dasm09,
# fview are 6809/8-bit only and auto-skip) builds with ia16-elf-gcc 6.3.0.
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8086.cmake \
#         -DFUZIX_CPU=i8086 -DFUZIX_PLATFORM=ibmpc -DFUZIX_CONFIG=ibmpc \
#         -DFUZIX_IA16_PREFIX=$PWD/toolchain/ia16-elf-gcc/bin
#   cmake --build build --target bin

set(FUZIX_PKG_COREUTILS       ON CACHE BOOL "")
set(FUZIX_PKG_COREUTILS_EXTRA ON CACHE BOOL "")
set(FUZIX_PKG_EDITORS         ON CACHE BOOL "")
set(FUZIX_PKG_UTIL_MISC       ON CACHE BOOL "")
set(FUZIX_PKG_FFORTH          ON CACHE BOOL "")
set(FUZIX_PKG_SHELL           ON CACHE BOOL "")
set(FUZIX_PKG_GAMES           ON CACHE BOOL "")
set(FUZIX_PKG_V7              ON CACHE BOOL "")
set(FUZIX_PKG_V7GAMES         ON CACHE BOOL "")
set(FUZIX_PKG_CURSESGAMES     ON CACHE BOOL "")
set(FUZIX_PKG_GAMES_2048      ON CACHE BOOL "")
set(FUZIX_PKG_LANG            ON CACHE BOOL "")
set(FUZIX_PKG_TOOLS           ON CACHE BOOL "")
set(FUZIX_PKG_NET             ON CACHE BOOL "")
set(FUZIX_PKG_MWC             ON CACHE BOOL "")
set(FUZIX_PKG_DEV             ON CACHE BOOL "")
set(FUZIX_PKG_CPMFS           ON CACHE BOOL "")

# Compiler backend components that cannot link standalone on i8086.
set(FUZIX_BINARIES_EXCLUDE "cc1;cc2" CACHE STRING "")
