# configs/default.cmake - default board program set.
#
# Included early by CMakeLists.txt when -DFUZIX_CONFIG is unset or =default.
# Leave the package defaults as-is (coreutils + shell ON, the rest opt-in).
# Values are set with `set(... CACHE ... )` WITHOUT force, so a -D... on the
# command line always wins over this file.
#
# Nothing to override for the default set.
