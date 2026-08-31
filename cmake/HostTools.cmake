# ===========================================================================
# Host-side standalone utilities (the old Kernel/../Standalone tree).
#
# These are ordinary programs built with the *host* compiler (HOSTCC), not the
# cross toolchain. They manipulate FUZIX filesystem images and binaries on the
# build machine:
#
#   mkfs / mkfs400     create an empty FUZIX filesystem image (512 / 400 blk)
#   mkfs_fat           create an empty FAT12/FAT16 image (self-contained)
#   fsck / fsck400     check/repair a filesystem image
#   fsck_fat           check/repair a FAT12/FAT16 image (self-contained)
#   ucp                "UZI copy" - populate an image with files from the host
#   chmem              patch the memory-size header of a binary
#   sethint            set hint bytes in a binary
#   size               print section sizes
#   elf2aout           ELF -> a.out converter
#   mkftl              build a Dhara FTL image (only if kernel/lib/dhara exists)
#
# Sources live in tools/. Built on demand via the aggregate `tools` target
# (not part of ALL); each binary lands in ${CMAKE_BINARY_DIR}/tools/.
# ===========================================================================

set(TOOLSRC "${CMAKE_SOURCE_DIR}/tools")
set(TOOLOUT "${CMAKE_BINARY_DIR}/tools")
file(MAKE_DIRECTORY "${TOOLOUT}")

# Mirrors the original Standalone/Makefile CCOPTS.
set(HOST_TOOL_CFLAGS
    -O2 -g -Wall -pedantic
    -Wno-char-subscripts -Wno-deprecated-declarations)

set(FUZIX_HOST_TOOLS "")   # collected binaries -> the `tools` target

# fuzix_host_tool(<name> SOURCES <src>... [INCLUDES <dir>...])
#   Compile+link one host utility from tools/ sources into TOOLOUT/<name>.
function(fuzix_host_tool name)
    cmake_parse_arguments(HT "" "" "SOURCES;INCLUDES" ${ARGN})

    set(_abs_srcs "")
    foreach(_s ${HT_SOURCES})
        if(IS_ABSOLUTE "${_s}")
            list(APPEND _abs_srcs "${_s}")
        else()
            list(APPEND _abs_srcs "${TOOLSRC}/${_s}")
        endif()
    endforeach()

    set(_inc_flags "")
    foreach(_i ${HT_INCLUDES})
        list(APPEND _inc_flags "-I${_i}")
    endforeach()

    add_custom_command(
        OUTPUT  "${TOOLOUT}/${name}"
        COMMAND "${HOSTCC}" ${HOST_TOOL_CFLAGS} ${_inc_flags}
                -o "${TOOLOUT}/${name}" ${_abs_srcs}
        DEPENDS ${_abs_srcs}
        COMMENT "host cc  tools/${name}"
        VERBATIM)

    set(FUZIX_HOST_TOOLS ${FUZIX_HOST_TOOLS} "${TOOLOUT}/${name}" PARENT_SCOPE)
endfunction()

fuzix_host_tool(mkfs     SOURCES mkfs.c    util.c)
fuzix_host_tool(mkfs400  SOURCES mkfs400.c util400.c)
fuzix_host_tool(mkfs_fat SOURCES mkfs_fat.c)
fuzix_host_tool(fsck     SOURCES fsck.c    util.c)
fuzix_host_tool(fsck_fat SOURCES fsck_fat.c)
fuzix_host_tool(fsck400  SOURCES fsck400.c util400.c)
fuzix_host_tool(ucp      SOURCES ucp.c     util.c)
fuzix_host_tool(chmem    SOURCES chmem.c)
fuzix_host_tool(sethint  SOURCES sethint.c)
fuzix_host_tool(size     SOURCES size.c)
fuzix_host_tool(elf2aout SOURCES elf2aout.c)

# mkftl pulls in the kernel's Dhara flash-translation library; only offer it if
# that source is present in this tree.
set(_dhara "${KDIR}/lib/dhara")
if(EXISTS "${_dhara}/journal.c")
    fuzix_host_tool(mkftl
        SOURCES mkftl.c
                "${_dhara}/journal.c" "${_dhara}/error.c" "${_dhara}/map.c"
        INCLUDES "${_dhara}")
else()
    message(STATUS "Host tools: skipping mkftl (kernel/lib/dhara not present)")
endif()

add_custom_target(tools DEPENDS ${FUZIX_HOST_TOOLS})
