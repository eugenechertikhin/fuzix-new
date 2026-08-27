# ===========================================================================
# Root filesystem image (target: rootfs).
#
# Drives tools/filesystem-src/build-filesystem.py (a single Python script that
# replaced the old build-filesystem / build-mini-filesystem / build.mk /
# populatefs.awk tooling) to assemble a FUZIX root filesystem from the
# fuzix-*.pkg package files, using the host-built mkfs/ucp/fsck.
#
# Not part of ALL. Requires the `tools` binaries; enable with -DFUZIX_ROOTFS=ON.
# When enabled and no explicit FUZIX_FILESYS_IMG was given, the generated image
# becomes the root filesystem written into the disk image by `diskimage`.
#
# NOTE: the in-tree fuzix-basefs.pkg references userland files (init, libc's
# liberror.txt) that do not exist in this kernel-only tree, so a stock build
# will fail until those are provided or a pkg limited to present files is used
# (point FUZIX_ROOTFS_PKG at it).
# ===========================================================================

option(FUZIX_ROOTFS "Build a root filesystem image (target: rootfs)" OFF)

set(FUZIX_ROOTFS_PKG "" CACHE STRING
    "Package to force-enable when building the root fs (build-filesystem.py -p)")
set(FUZIX_ROOTFS_ISIZE "256" CACHE STRING "Root fs inode-table size (mkfs isize)")
set(FUZIX_ROOTFS_BSIZE "65535" CACHE STRING "Root fs block count (mkfs fsize)")
option(FUZIX_ROOTFS_BIG_ENDIAN "Byte-swizzle the fs image (big-endian targets)" OFF)

set(FSSRC     "${TOOLSRC}/filesystem-src")
set(ROOTFS_PY "${FSSRC}/build-filesystem.py")
set(ROOTFS_DIR "${CMAKE_BINARY_DIR}/rootfs")
set(ROOTFS_IMG "${ROOTFS_DIR}/rootfs.img")
file(MAKE_DIRECTORY "${ROOTFS_DIR}")

find_program(PYTHON3 NAMES python3 python)

# Where `make lib` / `make bin` drop their outputs. Package `f` sources that are
# build artifacts (liberror.txt from the C library, /init and other binaries)
# are found here by build-filesystem.py's --search, so the packages can name
# them by the port's layout (lib/libs/..., bin/...) instead of a build path.
set(_userland_lib_dir "${CMAKE_BINARY_DIR}/userland/lib")
set(_userland_bin_dir "${CMAKE_BINARY_DIR}/userland/bin")

# Script arguments assembled from the options above.
set(_rootfs_args
    --version "${FUZIX_VERSION}"
    -f "${ROOTFS_IMG}"
    -g "${FUZIX_ROOTFS_ISIZE}" "${FUZIX_ROOTFS_BSIZE}"
    --mkfs "${TOOLOUT}/mkfs"
    --ucp  "${TOOLOUT}/ucp"
    --fsck "${TOOLOUT}/fsck"
    --search "."
    --search "${_userland_lib_dir}"
    --search "${_userland_bin_dir}")
if(FUZIX_ROOTFS_PKG)
    list(APPEND _rootfs_args -p "${FUZIX_ROOTFS_PKG}")
endif()
if(FUZIX_ROOTFS_BIG_ENDIAN)
    list(APPEND _rootfs_args -x)
endif()

# Rebuild when the script, any package file or any staged file changes.
file(GLOB _rootfs_deps
    "${FSSRC}/build-filesystem.py"
    "${FSSRC}/fuzix-*.pkg"
    "${FSSRC}/etc-files/*"
    "${FSSRC}/templates/*")

if(PYTHON3)
    add_custom_command(
        OUTPUT  "${ROOTFS_IMG}"
        COMMAND "${PYTHON3}" "${ROOTFS_PY}" ${_rootfs_args}
        WORKING_DIRECTORY "${FSSRC}"
        DEPENDS "${TOOLOUT}/mkfs" "${TOOLOUT}/ucp" "${TOOLOUT}/fsck"
                ${_rootfs_deps}
        COMMENT "build-filesystem.py -> rootfs.img"
        VERBATIM)
    add_custom_target(rootfs DEPENDS "${ROOTFS_IMG}")
else()
    add_custom_target(rootfs
        COMMAND ${CMAKE_COMMAND} -E echo
                "rootfs: python3 not found; cannot build the filesystem image"
        VERBATIM)
endif()

# When enabled, feed the generated image to `diskimage` unless the user pinned
# their own FUZIX_FILESYS_IMG. (FUZIX_FILESYS_IMG here is a plain variable that
# shadows the cache entry for the later configure_file in the diskimage step.)
if(FUZIX_ROOTFS AND NOT FUZIX_FILESYS_IMG)
    set(FUZIX_FILESYS_IMG "${ROOTFS_IMG}")
    set(FUZIX_ROOTFS_FEEDS_DISKIMAGE ON)
endif()
