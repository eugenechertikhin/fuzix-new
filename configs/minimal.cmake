# configs/minimal.cmake - smallest useful userland: shell + a handful of tools.
#
# Turn the curated coreutils package OFF and hand-pick a few via _EXTRA.
set(FUZIX_PKG_COREUTILS       OFF               CACHE BOOL   "")
set(FUZIX_PKG_SHELL           ON                CACHE BOOL   "")
set(FUZIX_BINARIES_EXTRA      "cat;ls;rm;echo;pwd;mkdir" CACHE STRING "")
