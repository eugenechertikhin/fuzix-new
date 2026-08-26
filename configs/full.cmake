# configs/full.cmake - build everything currently in the registry.
#
# Enable all program packages (coreutils, coreutils-extra, editors, shell).
set(FUZIX_PKG_COREUTILS       ON  CACHE BOOL "")
set(FUZIX_PKG_COREUTILS_EXTRA ON  CACHE BOOL "")
set(FUZIX_PKG_EDITORS         ON  CACHE BOOL "")
set(FUZIX_PKG_SHELL           ON  CACHE BOOL "")
