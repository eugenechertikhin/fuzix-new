# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the Zilog Super8 port (Fuzix Compiler Kit,
# fcc -msuper8). Alias of the generic fcc toolchain; the CPU-specific linker
# (ldsuper8) and C library (libsuper8.a) are derived in CMakeLists.txt from the
# selected CPU and the toolchain prefix.
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-super8.cmake \
#         -DFUZIX_CPU=super8 -DFUZIX_PLATFORM=rcbus-super8
# ---------------------------------------------------------------------------
include("${CMAKE_CURRENT_LIST_DIR}/toolchain-i8080.cmake")
