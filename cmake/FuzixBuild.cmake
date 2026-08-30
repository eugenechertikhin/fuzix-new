# ---------------------------------------------------------------------------
# FuzixBuild.cmake - compile/link helpers for the Fuzix cross toolchain.
#
# fcc/ld8080 are freestanding cross tools with a non-standard CLI, so instead
# of fighting CMake's built-in C language rules we drive them through custom
# commands. The *configuration* (which sources, which -D defines, which
# include dirs) is still fully controlled by the CMake options in the top
# level CMakeLists.txt - that is where the "build flags select the modules"
# behaviour lives.
#
# Expected variables (set by the caller before using these functions):
#   FUZIX_CC             - path to fcc
#   FUZIX_CC_MACHINE     - machine flag, e.g. -m8080
#   FUZIX_OBJ_DIR        - directory that receives the .o files
#   FUZIX_INCLUDE_FLAGS  - list of -I... flags
#   FUZIX_DEFS           - list of -D... flags
# ---------------------------------------------------------------------------

# fuzix_compile(<source> [EXTRA <flags...>])
#
# Registers a custom command that compiles one source (C or .S) into
# ${FUZIX_OBJ_DIR}/<basename>.o and appends that object to the global,
# order-preserving property FUZIX_OBJECTS.
function(fuzix_compile src)
    cmake_parse_arguments(ARG "" "" "EXTRA" ${ARGN})

    get_filename_component(_abs  "${src}" ABSOLUTE)
    get_filename_component(_base "${src}" NAME_WE)

    # fcc emits <basename>.o into the working directory. Different sources can
    # share a basename (e.g. core/devinput.c and platform/*/devinput.c), so give
    # each source its own working dir keyed by a hash of its absolute path.
    string(MD5 _h "${_abs}")
    set(_wd "${FUZIX_OBJ_DIR}/${_h}")
    file(MAKE_DIRECTORY "${_wd}")
    set(_obj "${_wd}/${_base}.o")

    if(FUZIX_TOOLCHAIN_KIND STREQUAL "gcc")
        # Standard gcc-style driver: writes to -o directly.
        add_custom_command(
            OUTPUT  "${_obj}"
            COMMAND "${FUZIX_CC}" ${FUZIX_CC_OPT}
                    ${FUZIX_INCLUDE_FLAGS} ${FUZIX_DEFS} ${ARG_EXTRA}
                    -c "${_abs}" -o "${_obj}"
            DEPENDS "${_abs}" ${FUZIX_EXTRA_DEPENDS}
            COMMENT "${FUZIX_CC_LABEL}  ${src}"
            VERBATIM)
    elseif(FUZIX_TOOLCHAIN_KIND STREQUAL "sdcc")
        # SDCC (classic Z80 path): .s assembles with sdasz80, .c compiles with
        # sdcc.  Both emit a relocatable .rel object (kept under the .o name so
        # the shared FUZIX_OBJECTS accumulator/link path is unchanged).  Segment
        # placement (--codeseg CODE2 / --constseg DISCARD / ...) is passed per
        # source through EXTRA, transcribing the upstream top-Makefile segment
        # source lists.
        get_filename_component(_ext "${_abs}" EXT)
        if(_ext STREQUAL ".s" OR _ext STREQUAL ".asm")
            add_custom_command(
                OUTPUT  "${_obj}"
                COMMAND "${FUZIX_AS}" ${FUZIX_ASOPTS} ${FUZIX_ASINCLUDES}
                        -o "${_obj}" "${_abs}"
                DEPENDS "${_abs}" ${FUZIX_EXTRA_DEPENDS}
                COMMENT "sdasz80  ${src}"
                VERBATIM)
        else()
            add_custom_command(
                OUTPUT  "${_obj}"
                COMMAND "${FUZIX_CC}" ${FUZIX_SDCC_OPTS}
                        ${FUZIX_INCLUDE_FLAGS} ${FUZIX_DEFS} ${ARG_EXTRA}
                        -o "${_obj}" "${_abs}"
                DEPENDS "${_abs}" ${FUZIX_EXTRA_DEPENDS}
                COMMENT "sdcc ${FUZIX_CC_MACHINE}  ${src}"
                VERBATIM)
        endif()
    else()
        # Fuzix Compiler Kit (fcc): emits <basename>.o into the working dir.
        add_custom_command(
            OUTPUT  "${_obj}"
            COMMAND "${FUZIX_CC}" -X ${FUZIX_CC_MACHINE} -c ${FUZIX_CC_OPT}
                    ${FUZIX_INCLUDE_FLAGS} ${FUZIX_DEFS} ${ARG_EXTRA} "${_abs}"
            WORKING_DIRECTORY "${_wd}"
            DEPENDS "${_abs}" ${FUZIX_EXTRA_DEPENDS}
            COMMENT "fcc ${FUZIX_CC_MACHINE}  ${src}"
            VERBATIM)
    endif()

    set_property(GLOBAL APPEND PROPERTY FUZIX_OBJECTS "${_obj}")
endfunction()

# fuzix_report_module(<enabled> <label> <detail>)
# Pretty configuration summary line.
function(fuzix_report_module enabled label detail)
    if(enabled)
        message(STATUS "  [x] ${label}: ${detail}")
    else()
        message(STATUS "  [ ] ${label}: (disabled)")
    endif()
endfunction()
