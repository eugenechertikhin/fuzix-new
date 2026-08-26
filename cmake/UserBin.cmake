# ===========================================================================
# UserBin.cmake - build the FUZIX userland programs (`bin` target).
#
# Programs are declared in a data-style REGISTRY (fuzix_program) with metadata
# (package, crt0 kind, source dir, sources, extra libs, supported CPUs). Which
# programs actually get built is then decided by:
#   * per-package switches  FUZIX_PKG_<PACKAGE>   (option, default per package)
#   * per-program overrides  FUZIX_BINARIES_EXTRA / FUZIX_BINARIES_EXCLUDE (lists)
#   * the target CPU: a program whose CPUS list is set and does not contain the
#     current USERCPU is skipped automatically.
#
# A board picks its set through a config file (-DFUZIX_CONFIG=<name> ->
# configs/<name>.cmake, included early by CMakeLists.txt) which just pre-sets the
# FUZIX_PKG_* / FUZIX_BINARIES_* cache variables. PROGRAMS.md is the human-
# readable mirror of this registry.
#
# Each app is compiled with fcc and linked with a crt0 object + libc<usercpu>.a
# via the ld<cpu> recipe (`fcc -m<cpu> -X -s <objs> -L<lib> [-l<lib><cpu>...]
# -lc<cpu> -o app -M`), mirroring util/Makefile.common and V7/cmd/sh.
#
# Depends on the `lib` target (crt0 + libc). Sources live under bin/ (util/, sh/).
# Relies on variables from UserLib.cmake: USERCPU, USER_KIND, USER_CC,
# USER_CC_MACHINE, USER_OPT, USER_INCLUDE_FLAGS, USER_LIB_DIR, LIBC_A.
# ===========================================================================

# Userland programs currently only wired for the fcc CPUs (i8080, z80u). The
# gcc CPUs (pdp11, i8086) link differently (libgcc, -T script) - TODO.
if(NOT USER_KIND STREQUAL "fcc")
    add_custom_target(bin
        COMMAND ${CMAKE_COMMAND} -E echo
            "bin: userland programs not wired for '${FUZIX_CPU}' (${USER_KIND}) yet - only the fcc CPUs are supported so far"
        VERBATIM)
    return()
endif()

set(APPSDIR      "${CMAKE_SOURCE_DIR}/bin")
set(USER_BIN_DIR "${CMAKE_BINARY_DIR}/userland/bin")
file(MAKE_DIRECTORY "${USER_BIN_DIR}")

# crt0 objects produced by the `lib` target (in USER_LIB_DIR).
set(CRT0_STDIO   "${USER_LIB_DIR}/crt0_${USERCPU}.o")
set(CRT0_NOSTDIO "${USER_LIB_DIR}/crt0nostdio_${USERCPU}.o")

# ---------------------------------------------------------------------------
# 1. Program registry
# ---------------------------------------------------------------------------
# fuzix_program(NAME <n> PACKAGE <pkg> CRT0 <stdio|nostdio>
#               [DIR <subdir>]            (default: util)
#               [SOURCES <a.c> ...]       (default: <n>.c)
#               [LIBS <name> ...]         (extra -l<name><usercpu>, e.g. termcap)
#               [CPUS <usercpu> ...])     (empty = all CPUs)
# Records metadata only; nothing is built until the selection pass below.
set_property(GLOBAL PROPERTY FUZIX_PROGRAMS "")
function(fuzix_program)
    cmake_parse_arguments(P "" "NAME;PACKAGE;CRT0;DIR" "SOURCES;LIBS;CPUS" ${ARGN})
    # NOTE: use DEFINED, not truthiness - program names like `false`/`true`
    # would read as boolean values in a plain if().
    if(NOT DEFINED P_NAME OR NOT DEFINED P_PACKAGE OR NOT DEFINED P_CRT0)
        message(FATAL_ERROR "fuzix_program: NAME, PACKAGE and CRT0 are required")
    endif()
    if(NOT DEFINED P_DIR)
        set(P_DIR "util")
    endif()
    if(NOT DEFINED P_SOURCES)
        set(P_SOURCES "${P_NAME}.c")
    endif()
    set_property(GLOBAL APPEND PROPERTY FUZIX_PROGRAMS "${P_NAME}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_PACKAGE "${P_PACKAGE}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_CRT0    "${P_CRT0}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_DIR     "${P_DIR}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_SOURCES "${P_SOURCES}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_LIBS    "${P_LIBS}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_CPUS    "${P_CPUS}")
endfunction()

# Map a package name to its FUZIX_PKG_* option variable (UPPER, '-' -> '_').
function(_pkg_optvar pkg outvar)
    string(TOUPPER "${pkg}" _u)
    string(REPLACE "-" "_" _u "${_u}")
    set(${outvar} "FUZIX_PKG_${_u}" PARENT_SCOPE)
endfunction()

include("${CMAKE_SOURCE_DIR}/cmake/programs.cmake")

# ---------------------------------------------------------------------------
# 2. Package switches + per-program overrides
# ---------------------------------------------------------------------------
# Packages that are ON unless a config/CLI turns them off. Everything else
# defaults OFF (opt-in). A config file (FUZIX_CONFIG) or -D... overrides these;
# options are non-FORCE so an earlier config/CLI value always wins.
set(FUZIX_PKG_DEFAULT_ON coreutils shell)

get_property(_all_progs GLOBAL PROPERTY FUZIX_PROGRAMS)
set(_packages "")
foreach(p ${_all_progs})
    get_property(_pk GLOBAL PROPERTY FUZIX_PROG_${p}_PACKAGE)
    list(APPEND _packages "${_pk}")
endforeach()
list(REMOVE_DUPLICATES _packages)
list(SORT _packages)

foreach(pkg ${_packages})
    _pkg_optvar("${pkg}" _ov)
    if(pkg IN_LIST FUZIX_PKG_DEFAULT_ON)
        set(_def ON)
    else()
        set(_def OFF)
    endif()
    option(${_ov} "Build the '${pkg}' program package" ${_def})
endforeach()

set(FUZIX_BINARIES_EXTRA   "" CACHE STRING "Extra programs to force-enable (;-list of names)")
set(FUZIX_BINARIES_EXCLUDE "" CACHE STRING "Programs to force-disable (;-list of names)")

# ---------------------------------------------------------------------------
# 3. Build helpers
# ---------------------------------------------------------------------------
# Compile one app source (fcc emits <base>.o into an MD5-keyed cwd).
function(_userbin_compile outvar abs_src incdir)
    get_filename_component(_base "${abs_src}" NAME_WE)
    string(MD5 _h "${abs_src}")
    set(_wd "${CMAKE_BINARY_DIR}/userland/binobj/${_h}")
    file(MAKE_DIRECTORY "${_wd}")
    set(_obj "${_wd}/${_base}.o")
    add_custom_command(
        OUTPUT  "${_obj}"
        COMMAND "${USER_CC}" -X ${USER_CC_MACHINE} -c ${USER_OPT} -D__STDC__
                ${USER_INCLUDE_FLAGS} "-I${incdir}" "${abs_src}"
        WORKING_DIRECTORY "${_wd}"
        DEPENDS "${abs_src}" "${LIBC_A}"
        COMMENT "fcc ${USER_CC_MACHINE}  ${abs_src}"
        VERBATIM)
    set(${outvar} "${_obj}" PARENT_SCOPE)
endfunction()

# Build one registered program (compile its sources + link) -> app path in out.
function(_userbin_build name outvar)
    get_property(_crt0kind GLOBAL PROPERTY FUZIX_PROG_${name}_CRT0)
    get_property(_dir      GLOBAL PROPERTY FUZIX_PROG_${name}_DIR)
    get_property(_srcs     GLOBAL PROPERTY FUZIX_PROG_${name}_SOURCES)
    get_property(_libs     GLOBAL PROPERTY FUZIX_PROG_${name}_LIBS)

    set(_objs "")
    foreach(s ${_srcs})
        _userbin_compile(_o "${APPSDIR}/${_dir}/${s}" "${APPSDIR}/${_dir}")
        list(APPEND _objs "${_o}")
    endforeach()

    if(_crt0kind STREQUAL "nostdio")
        set(_crt0 "${CRT0_NOSTDIO}")
    else()
        set(_crt0 "${CRT0_STDIO}")
    endif()

    set(_lflags "")
    foreach(l ${_libs})
        list(APPEND _lflags "-l${l}${USERCPU}")
    endforeach()

    set(_app "${USER_BIN_DIR}/${name}")
    add_custom_command(
        OUTPUT  "${_app}"
        COMMAND "${USER_CC}" ${USER_CC_MACHINE} -X -s "${_crt0}" ${_objs}
                -L"${USER_LIB_DIR}" ${_lflags} -lc${USERCPU} -o "${_app}" -M
        DEPENDS ${_objs} "${_crt0}" "${LIBC_A}"
        COMMENT "ld${USERCPU}  ${name}"
        VERBATIM)
    set(${outvar} "${_app}" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# 4. Selection pass: decide + build the enabled programs
# ---------------------------------------------------------------------------
set(_bin_outputs "")
set(_skipped_cpu "")
# per-package enabled/total counters
foreach(pkg ${_packages})
    set(_pkg_on_${pkg} 0)
    set(_pkg_tot_${pkg} 0)
endforeach()

foreach(name ${_all_progs})
    get_property(_pk   GLOBAL PROPERTY FUZIX_PROG_${name}_PACKAGE)
    get_property(_cpus GLOBAL PROPERTY FUZIX_PROG_${name}_CPUS)
    math(EXPR _pkg_tot_${_pk} "${_pkg_tot_${_pk}} + 1")

    _pkg_optvar("${_pk}" _ov)
    set(_on ${${_ov}})
    if(name IN_LIST FUZIX_BINARIES_EXTRA)
        set(_on ON)
    endif()
    if(name IN_LIST FUZIX_BINARIES_EXCLUDE)
        set(_on OFF)
    endif()

    # CPU constraint
    set(_cpu_ok TRUE)
    if(_cpus AND NOT (USERCPU IN_LIST _cpus))
        set(_cpu_ok FALSE)
    endif()

    if(_on AND _cpu_ok)
        _userbin_build("${name}" _app)
        list(APPEND _bin_outputs "${_app}")
        math(EXPR _pkg_on_${_pk} "${_pkg_on_${_pk}} + 1")
    elseif(_on AND NOT _cpu_ok)
        list(APPEND _skipped_cpu "${name}")
    endif()
endforeach()

# ---------------------------------------------------------------------------
# 5. The `bin` target + summary
# ---------------------------------------------------------------------------
add_custom_target(bin DEPENDS ${_bin_outputs})
add_dependencies(bin lib)     # crt0 + libc must exist first

list(LENGTH _bin_outputs _nbin)
list(LENGTH _all_progs   _nreg)
message(STATUS "-- Optional binaries (target: bin) --")
foreach(pkg ${_packages})
    _pkg_optvar("${pkg}" _ov)
    if(${${_ov}})
        message(STATUS "  [x] ${pkg}: ${_pkg_on_${pkg}}/${_pkg_tot_${pkg}} enabled")
    else()
        message(STATUS "  [ ] ${pkg}: (disabled, ${_pkg_tot_${pkg}} available)")
    endif()
endforeach()
if(_skipped_cpu)
    list(JOIN _skipped_cpu " " _sc)
    message(STATUS "  skipped (CPU ${USERCPU} unsupported): ${_sc}")
endif()
message(STATUS "  total: ${_nbin} built of ${_nreg} registered  -> ${USER_BIN_DIR}")
message(STATUS "  tune with -DFUZIX_PKG_<PKG>=ON/OFF, -DFUZIX_BINARIES_EXTRA/EXCLUDE, or -DFUZIX_CONFIG=<name>")
