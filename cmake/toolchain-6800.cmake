# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the Motorola 6800 port (Fuzix Compiler Kit, fcc -m6800).
#
# 6800 uses the same Fuzix Compiler Kit as the 8080, so this is just an alias
# for the generic fcc toolchain. The CPU-specific linker (ld6800) and C library
# (lib6800.a) are derived in CMakeLists.txt from the selected CPU and the
# toolchain prefix.
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-6800.cmake \
#         -DFUZIX_CPU=6800 -DFUZIX_PLATFORM=rcbus-6800
# ---------------------------------------------------------------------------
include("${CMAKE_CURRENT_LIST_DIR}/toolchain-i8080.cmake")
