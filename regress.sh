#!/bin/bash
# regress.sh - build every z80u platform with the real fcc toolchain.
#
# Configures + builds each board into an in-tree build-<platform> directory
# (kept, not deleted) and reports the resulting fuzix.bin size or FAIL.
# Run from anywhere; paths are derived from this script's location.
#
#   ./regress.sh
#
# Requires the Fuzix Compiler Kit under ./toolchain/fcc (override by editing
# TOOLPREFIX below or setting FUZIX_TOOLCHAIN_PREFIX in the environment).
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLPREFIX="${FUZIX_TOOLCHAIN_PREFIX:-$ROOT/toolchain/fcc}"
cd "$ROOT"

# Boards whose low-level layer has no common RAM (thunked variant).
THUNKED=" searle tomssbc simple80 "

build_one() {
  local plat="$1" extra="$2" tag="$3"
  local bdir="$ROOT/build-${plat}${tag}"
  local mode=""
  case "$THUNKED" in *" $plat "*) mode="-DFUZIX_Z80U_MODE=thunked";; esac
  {
    cmake -B "$bdir" -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-z80u.cmake \
      -DFUZIX_CPU=z80u -DFUZIX_PLATFORM="$plat" $mode $extra \
      -DFUZIX_TOOLCHAIN_PREFIX="$TOOLPREFIX" >/dev/null 2>&1 \
    && cmake --build "$bdir" >/dev/null 2>&1
  }
  if [ -f "$bdir/image/fuzix.bin" ]; then
    printf "OK   %-16s%-8s %8d bytes\n" "$plat" "$tag" "$(stat -f%z "$bdir/image/fuzix.bin")"
  else
    printf "FAIL %-16s%-8s (see %s)\n" "$plat" "$tag" "$bdir"
  fi
}
export -f build_one
export ROOT TOOLPREFIX THUNKED

# All 19 z80u boards.
ALL="aqplus challengeriii lobo-max80 nascom nano-z80 rc2014-tiny rcbus-tp128 \
sbcv2 sbc2g sc720 z80membership z1013 zrc z80all z80-mbc2 z80retro \
searle tomssbc simple80"

echo "===== net-off default builds (all 19) ====="
printf '%s\n' $ALL | xargs -P4 -I{} bash -c 'build_one "$@"' _ {} "" "" | sort

echo
echo "===== net-ON builds (FUZIX_NET-gated boards) ====="
for p in rcbus-tp128 sbcv2 zrc; do build_one "$p" "-DFUZIX_NET=ON" "-net"; done
