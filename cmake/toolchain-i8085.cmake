# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the Intel 8085 port (Fuzix Compiler Kit, fcc -m8085).
#
# i8085 uses the same Fuzix Compiler Kit as the 8080, so this is just an alias
# for the generic fcc toolchain. The CPU-specific linker (ld8080) and C library
# (lib8085.a) are derived in CMakeLists.txt from the selected CPU and the
# toolchain prefix.
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8085.cmake \
#         -DFUZIX_CPU=i8085 -DFUZIX_PLATFORM=rcbus-8085
# ---------------------------------------------------------------------------
include("${CMAKE_CURRENT_LIST_DIR}/toolchain-i8080.cmake")
