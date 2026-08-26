# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the Z80 "u" port (Fuzix Compiler Kit, fcc -mz80).
#
# z80u uses the same Fuzix Compiler Kit as the 8080, so this is just an alias
# for the generic fcc toolchain. The CPU-specific linker (ldz80) and C library
# (libz80.a) are derived in CMakeLists.txt from the selected CPU and the
# toolchain prefix.
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-z80u.cmake \
#         -DFUZIX_CPU=z80u -DFUZIX_PLATFORM=z80pack
# ---------------------------------------------------------------------------
include("${CMAKE_CURRENT_LIST_DIR}/toolchain-i8080.cmake")
