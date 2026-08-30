#!/bin/bash
# regress.sh - build every platform found in the source tree.
#
# The list of platforms (and each one's CPU) is discovered from the tree on
# every run - it is NOT hardcoded - by scanning cmake/platform-*.cmake for the
# "CPU: <cpu>" tag in each file's header. For each platform we pick the right
# cross compiler:
#
#   * the toolchain kind, compiler binary and prefix variable are read from the
#     matching cmake/toolchain-<cpu>.cmake fragment (fcc vs gcc);
#   * the compiler is searched for on $PATH, then in the in-tree real toolchains
#     (toolchain/*/bin, excluding toolchain/fake), then finally the fake stub
#     toolchain (toolchain/fake) is used so the whole build graph can still run;
#   * rpipico (armm0) is special: it builds through the Pico SDK with no
#     toolchain file, auto-finding toolchain/pico-sdk + toolchain/arm-none-eabi.
#
# A bare -DFUZIX_CPU/-DFUZIX_PLATFORM build is used: the memory manager, the
# z80u thunked/normal low-level variant and multiprocess default are all
# auto-selected per board by the CMake tree, so no extra flags are needed.
#
# Usage:
#   ./regress.sh                 # kernel only, every platform (default)
#   ./regress.sh searle ibmpc    # kernel only, just the named platforms
#   ./regress.sh all             # kernel + userland (lib, bin) + disk/flash image
#   ./regress.sh all z80pack     # the `all` build for just the named platforms
#
# Default mode prints one line per board: platform, CPU, the compiler actually
# used (with real/fake tag) and the kernel compile status. In `all` mode extra
# columns report the userland library (lib), programs (bin) and image targets;
# "-" means the target is not wired for that CPU/board (source-tree fact, not a
# failure), "skip" means it was skipped because the kernel build failed.
#
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

BUILD_ALL=0

# --------------------------------------------------------------------------
# Source-tree queries
# --------------------------------------------------------------------------

# cpu_of_platform <platform>  ->  echoes the CPU parsed from the header comment.
cpu_of_platform() {
    grep -oiE 'CPU:[[:space:]]*[A-Za-z0-9]+' "cmake/platform-$1.cmake" 2>/dev/null \
        | head -1 | sed -E 's/CPU:[[:space:]]*//I'
}

# toolchain_kind <cpu>  ->  "gcc" or "fcc" (the fcc kit is the default / absence
# of a gcc marker). Follows nothing: the alias fragments (z80u, z8, ...) include
# toolchain-i8080.cmake which is also fcc, so grepping the top file is enough.
toolchain_kind() {
    if grep -q 'FUZIX_TOOLCHAIN_KIND "gcc"' "cmake/toolchain-$1.cmake" 2>/dev/null; then
        echo gcc
    else
        echo fcc
    fi
}

# compiler_binary <cpu> <kind>  ->  basename of the compiler driver.
compiler_binary() {
    local cpu="$1" kind="$2"
    if [ "$kind" = fcc ]; then
        echo fcc
        return
    fi
    # gcc: pull the quoted FUZIX_CC value, drop ${...} expansions, take basename.
    grep -oE 'set\(FUZIX_CC[^)]*' "cmake/toolchain-$cpu.cmake" \
        | grep -oE '"[^"]+"' | head -1 | tr -d '"' \
        | sed -E 's/\$\{[^}]*\}//g' | sed -E 's#.*/##'
}

# prefix_var <cpu> <kind>  ->  the -D variable that points at the toolchain.
prefix_var() {
    local cpu="$1" kind="$2"
    if [ "$kind" = fcc ]; then
        echo FUZIX_TOOLCHAIN_PREFIX
        return
    fi
    grep -oE 'FUZIX_[A-Z0-9]+_PREFIX' "cmake/toolchain-$cpu.cmake" \
        | grep -v TOOLCHAIN_PREFIX | head -1
}

# lib_wired <cpu>  ->  true if the userland C library is wired for this CPU
# (a _ul_<cpu>_row mapping exists in cmake/UserLib.cmake).
lib_wired() {
    grep -qE "_ul_$1_row" cmake/UserLib.cmake 2>/dev/null
}

# bin_wired <cpu>  ->  true if userland programs are wired: fcc CPUs, or armm0.
# (UserBin.cmake gates on USER_KIND==fcc OR USERCPU==armm0; both are read from
#  the same _ul_<cpu>_row: field 0 = USERCPU, field 1 = kind.)
bin_wired() {
    local row usercpu kind
    row="$(grep -oE "_ul_$1_row[^)]*" cmake/UserLib.cmake 2>/dev/null)"
    [ -n "$row" ] || return 1
    usercpu="$(printf '%s' "$row" | grep -oE '"[^"]*"' | head -1 | tr -d '"')"
    kind="$(printf '%s' "$row" | sed -E 's/.*_row[[:space:]]+"[^"]*"[[:space:]]+([a-z]+).*/\1/')"
    [ "$kind" = fcc ] || [ "$usercpu" = armm0 ]
}

# image_target <platform>  ->  echoes the image target name for the board, or
# nothing if the board has no image packaging. rpipico -> flashimage; boards
# whose fragment sets DISKIMAGE_STYLE=none have none; everything else uses the
# default bootblock/rcbus-ide diskimage.
image_target() {
    local plat="$1" style
    [ "$plat" = rpipico ] && { echo flashimage; return; }
    style="$(grep -oE 'set\(DISKIMAGE_STYLE[^)]*' "cmake/platform-$plat.cmake" 2>/dev/null \
             | head -1 | sed -E 's/set\(DISKIMAGE_STYLE//; s/[)"]//g' | xargs)"
    [ "$style" = none ] && return
    echo diskimage
}

# --------------------------------------------------------------------------
# Output helpers
# --------------------------------------------------------------------------
clearline() { [ -t 1 ] && printf '\r\033[K'; }

# Default (kernel-only) 4-column row.
row() { clearline; printf '%-16s %-8s %-26s %s\n' "$1" "$2" "$3" "$4"; }

# `all`-mode 7-column row: platform cpu compiler kernel lib bin image.
row_all() {
    clearline
    printf '%-16s %-8s %-26s %-7s %-7s %-7s %s\n' "$1" "$2" "$3" "$4" "$5" "$6" "$7"
}

# progress <platform> <cpu> <compiler>  ->  live "building..." marker, TTY only.
progress() {
    [ -t 1 ] && printf '%-16s %-8s %-26s %s\r' "$1" "$2" "$3" "building..."
}

# --------------------------------------------------------------------------
# Compiler location
# --------------------------------------------------------------------------

# locate_compiler <binary>  ->  echoes the full path to the first match, in the
# order PATH, in-tree real toolchains, fake stubs. Empty if nothing found.
locate_compiler() {
    local bin="$1" p
    if p="$(command -v "$bin" 2>/dev/null)"; then echo "$p"; return; fi
    for p in toolchain/*/bin/"$bin"; do
        case "$p" in toolchain/fake/bin/*) continue;; esac
        [ -x "$p" ] && { echo "$ROOT/$p"; return; }
    done
    p="toolchain/fake/bin/$bin"
    [ -x "$p" ] && { echo "$ROOT/$p"; return; }
}

# build_target <bdir> <target> <log>  ->  echoes OK / FAIL for one make target.
build_target() {
    if cmake --build "$1" --target "$2" >>"$3" 2>&1; then echo OK; else echo FAIL; fi
}

# --------------------------------------------------------------------------
# rpipico (armm0): Pico SDK kernel, plus a separate userland-only build for the
# lib/bin/flashimage targets (the SDK kernel build wires no userland).
# --------------------------------------------------------------------------
build_rpipico() {
    local plat="$1" cpu="$2" comp="arm-none-eabi-gcc (real)"
    local bdir="$ROOT/build-$plat" log="$ROOT/build-$plat.log"
    local kernel lib bin image udir ulog armdir

    if [ -z "$(locate_compiler arm-none-eabi-gcc)" ]; then
        if [ "$BUILD_ALL" = 1 ]; then
            row_all "$plat" "$cpu" "arm-none-eabi-gcc" "SKIP" "-" "-" "-"
        else
            row "$plat" "$cpu" "arm-none-eabi-gcc" "SKIP (no arm gcc)"
        fi
        return
    fi

    progress "$plat" "$cpu" "$comp"
    rm -rf "$bdir"
    if cmake -B "$bdir" -DFUZIX_CPU="$cpu" -DFUZIX_PLATFORM="$plat" >"$log" 2>&1 \
       && cmake --build "$bdir" >>"$log" 2>&1; then
        kernel=OK
    else
        kernel=FAIL
    fi

    if [ "$BUILD_ALL" != 1 ]; then
        [ "$kernel" = OK ] && row "$plat" "$cpu" "$comp" "OK" \
                           || row "$plat" "$cpu" "$comp" "FAIL  (see $(basename "$log"))"
        return
    fi

    # Userland-only configure (lib/bin/flashimage) in a sibling build dir.
    udir="$ROOT/build-$plat-user"; ulog="$ROOT/build-$plat-user.log"
    armdir="$(dirname "$(locate_compiler arm-none-eabi-gcc)")"
    rm -rf "$udir"
    if cmake -B "$udir" -DFUZIX_CPU="$cpu" -DFUZIX_PLATFORM="$plat" \
            -DFUZIX_USERLAND_ONLY=ON \
            -DCMAKE_TOOLCHAIN_FILE="cmake/toolchain-armm0.cmake" \
            -DFUZIX_ARM_PREFIX="$armdir" >"$ulog" 2>&1; then
        lib="$(build_target "$udir" lib "$ulog")"
        bin="$(build_target "$udir" bin "$ulog")"
        image="$(build_target "$udir" flashimage "$ulog")"
    else
        lib=FAIL; bin=FAIL; image=FAIL
    fi
    row_all "$plat" "$cpu" "$comp" "$kernel" "$lib" "$bin" "$image"
}

# --------------------------------------------------------------------------
# Build a single platform.
# --------------------------------------------------------------------------
build_one() {
    local plat="$1"
    local cpu bdir log kind bin cc var prefix realtag comp
    local kernel lib bin_st image imgtgt
    bdir="$ROOT/build-$plat"; log="$ROOT/build-$plat.log"

    cpu="$(cpu_of_platform "$plat")"
    if [ -z "$cpu" ]; then
        if [ "$BUILD_ALL" = 1 ]; then
            row_all "$plat" "?" "-" "SKIP" "-" "-" "-"
        else
            row "$plat" "?" "-" "SKIP (no CPU tag)"
        fi
        return
    fi

    if [ "$plat" = rpipico ]; then
        build_rpipico "$plat" "$cpu"
        return
    fi

    kind="$(toolchain_kind "$cpu")"
    bin="$(compiler_binary "$cpu" "$kind")"
    var="$(prefix_var "$cpu" "$kind")"
    cc="$(locate_compiler "$bin")"

    if [ -z "$cc" ]; then
        if [ "$BUILD_ALL" = 1 ]; then
            row_all "$plat" "$cpu" "$bin" "SKIP" "-" "-" "-"
        else
            row "$plat" "$cpu" "$bin" "SKIP (compiler not found)"
        fi
        return
    fi

    # real vs fake, and the prefix to hand cmake:
    #   fcc  -> prefix is the install ROOT   (compiler lives at <root>/bin/<bin>)
    #   gcc  -> prefix is the bin DIRECTORY  (compiler lives at <dir>/<bin>)
    case "$cc" in *"/toolchain/fake/"*) realtag=fake;; *) realtag=real;; esac
    if [ "$kind" = fcc ]; then
        prefix="$(dirname "$(dirname "$cc")")"
    else
        prefix="$(dirname "$cc")"
    fi
    comp="$bin ($realtag)"

    progress "$plat" "$cpu" "$comp"
    rm -rf "$bdir"
    if ! cmake -B "$bdir" \
            -DCMAKE_TOOLCHAIN_FILE="cmake/toolchain-$cpu.cmake" \
            -DFUZIX_CPU="$cpu" -DFUZIX_PLATFORM="$plat" \
            -D"$var=$prefix" >"$log" 2>&1; then
        # Configure failed: nothing else can build.
        if [ "$BUILD_ALL" = 1 ]; then
            row_all "$plat" "$cpu" "$comp" "FAIL" "skip" "skip" "skip"
        else
            row "$plat" "$cpu" "$comp" "FAIL  (see $(basename "$log"))"
        fi
        return
    fi

    if cmake --build "$bdir" >>"$log" 2>&1; then kernel=OK; else kernel=FAIL; fi

    if [ "$BUILD_ALL" != 1 ]; then
        [ "$kernel" = OK ] && row "$plat" "$cpu" "$comp" "OK" \
                           || row "$plat" "$cpu" "$comp" "FAIL  (see $(basename "$log"))"
        return
    fi

    # lib / bin are independent of the kernel image; the image target needs it.
    if lib_wired "$cpu"; then lib="$(build_target "$bdir" lib "$log")"; else lib="-"; fi
    if bin_wired "$cpu"; then bin_st="$(build_target "$bdir" bin "$log")"; else bin_st="-"; fi
    imgtgt="$(image_target "$plat")"
    if [ -z "$imgtgt" ]; then
        image="-"
    elif [ "$kernel" != OK ]; then
        image="skip"
    else
        image="$(build_target "$bdir" "$imgtgt" "$log")"
    fi
    row_all "$plat" "$cpu" "$comp" "$kernel" "$lib" "$bin_st" "$image"
}

# --------------------------------------------------------------------------
# Parse args: an optional leading `all`, then an optional platform filter.
# --------------------------------------------------------------------------
if [ "${1:-}" = all ]; then
    BUILD_ALL=1
    shift
fi

if [ "$#" -gt 0 ]; then
    PLATFORMS="$*"
else
    PLATFORMS="$(for f in cmake/platform-*.cmake; do
                     basename "$f" .cmake | sed 's/^platform-//'
                 done | sort)"
fi

if [ "$BUILD_ALL" = 1 ]; then
    row_all "PLATFORM" "CPU" "COMPILER" "KERNEL" "LIB" "BIN" "IMAGE"
    row_all "--------" "---" "--------" "------" "---" "---" "-----"
else
    row "PLATFORM" "CPU" "COMPILER" "STATUS"
    row "--------" "---" "--------" "------"
fi

for p in $PLATFORMS; do
    build_one "$p"
done
