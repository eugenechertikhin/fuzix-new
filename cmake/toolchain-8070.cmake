# ---------------------------------------------------------------------------
# FUZIX cross toolchain for the INS8070 port (Fuzix Compiler Kit, fcc -m8070).
#
# 8070 uses the same Fuzix Compiler Kit as the 8080, so this is just an alias
# for the generic fcc toolchain. The CPU-specific linker (ld8070) and C library
# (lib8070.a) are derived in CMakeLists.txt from the selected CPU and the
# toolchain prefix.
#
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-8070.cmake \
#         -DFUZIX_CPU=8070 -DFUZIX_PLATFORM=rcbus-8070
# ---------------------------------------------------------------------------
include("${CMAKE_CURRENT_LIST_DIR}/toolchain-i8080.cmake")
