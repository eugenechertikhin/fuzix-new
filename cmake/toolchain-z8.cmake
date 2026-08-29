# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the Zilog Z8 port (Fuzix Compiler Kit, fcc -mz8).
#
# z8 uses the same Fuzix Compiler Kit as the 8080, so this is just an alias
# for the generic fcc toolchain. The CPU-specific linker (ldz8) and C library
# (libz8.a) are derived in CMakeLists.txt from the selected CPU and the
# toolchain prefix.
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-z8.cmake \
#         -DFUZIX_CPU=z8 -DFUZIX_PLATFORM=rcbus-z8
# ---------------------------------------------------------------------------
include("${CMAKE_CURRENT_LIST_DIR}/toolchain-i8080.cmake")
