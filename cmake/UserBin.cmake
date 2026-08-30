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

# Userland programs are wired for the fcc CPUs (i8080, z80u), for armm0
# (arm-none-eabi, PIE ELF via elfexe32.ld) and for i8086 (ia16-elf, MZ/msdos
# image via 8086.ld + libgcc). The remaining gcc CPU (pdp11) links differently
# (its own script) and is not wired yet.
if(NOT USER_KIND STREQUAL "fcc" AND NOT USERCPU STREQUAL "armm0"
   AND NOT USERCPU STREQUAL "8086")
    add_custom_target(bin
        COMMAND ${CMAKE_COMMAND} -E echo
            "bin: userland programs not wired for '${FUZIX_CPU}' (${USER_KIND}) yet"
        VERBATIM)
    return()
endif()

set(APPSDIR      "${CMAKE_SOURCE_DIR}/bin")
set(USER_BIN_DIR "${CMAKE_BINARY_DIR}/userland/bin")
file(MAKE_DIRECTORY "${USER_BIN_DIR}")

# crt0 objects produced by the `lib` target (in USER_LIB_DIR).
set(CRT0_STDIO   "${USER_LIB_DIR}/crt0_${USERCPU}.o")
set(CRT0_NOSTDIO "${USER_LIB_DIR}/crt0nostdio_${USERCPU}.o")

# armm0 (gcc/arm) links PIE ELF binaries with ld + elfexe32.ld + libgcc, per
# Target/rules.armm0. Resolve the libgcc directory from the compiler once.
if(USERCPU STREQUAL "armm0")
    set(USER_CC_LABEL "arm-gcc")
    set(ELFEXE32_LD "${CMAKE_SOURCE_DIR}/lib/elfexe32.ld")
    execute_process(
        COMMAND "${USER_CC}" ${USER_OPT} -print-libgcc-file-name
        OUTPUT_VARIABLE _libgcc_file OUTPUT_STRIP_TRAILING_WHITESPACE)
    get_filename_component(LIBGCC_DIR "${_libgcc_file}" DIRECTORY)
endif()

# i8086 (gcc/ia16) links against libc8086 + libgcc through the msdos/MZ linker
# script 8086.ld, mirroring Target/rules.8086 and lib/link/ld8086. Resolve the
# libgcc directory from the compiler once.
if(USERCPU STREQUAL "8086")
    set(USER_CC_LABEL "ia16-gcc")
    set(LD8086_SCRIPT "${CMAKE_SOURCE_DIR}/lib/link/8086.ld")
    execute_process(
        COMMAND "${USER_CC}" ${USER_OPT} -print-libgcc-file-name
        OUTPUT_VARIABLE _libgcc_file OUTPUT_STRIP_TRAILING_WHITESPACE)
    get_filename_component(LIBGCC_DIR "${_libgcc_file}" DIRECTORY)
endif()

# ---------------------------------------------------------------------------
# 1. Program registry
# ---------------------------------------------------------------------------
# fuzix_program(NAME <n> PACKAGE <pkg> CRT0 <stdio|nostdio>
#               [BIN <binname>]           (installed binary name; default: NAME)
#               [DIR <subdir>]            (default: util)
#               [SOURCES <a.c> ...]       (default: <n>.c)
#               [LIBS <name> ...]         (extra -l<name><usercpu>, e.g. termcap)
#               [DEFINES <MACRO> ...]     (extra -D<MACRO> at compile, e.g. BUILD_FSH)
#               [CPUS <usercpu> ...])     (empty = all CPUs)
# NAME is the unique registry id; BIN is the produced binary. Two programs may
# share a BIN (e.g. util's `ed` and V7's `ed`) - the selection pass keeps the
# first enabled one and shadows the rest, so both can coexist in the registry.
# Records metadata only; nothing is built until the selection pass below.
set_property(GLOBAL PROPERTY FUZIX_PROGRAMS "")
function(fuzix_program)
    cmake_parse_arguments(P "" "NAME;PACKAGE;CRT0;DIR;BIN" "SOURCES;LIBS;CPUS;DEFINES" ${ARGN})
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
    if(NOT DEFINED P_BIN)
        set(P_BIN "${P_NAME}")
    endif()
    set_property(GLOBAL APPEND PROPERTY FUZIX_PROGRAMS "${P_NAME}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_BIN     "${P_BIN}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_PACKAGE "${P_PACKAGE}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_CRT0    "${P_CRT0}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_DIR     "${P_DIR}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_SOURCES "${P_SOURCES}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_LIBS    "${P_LIBS}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_CPUS    "${P_CPUS}")
    set_property(GLOBAL PROPERTY FUZIX_PROG_${P_NAME}_DEFINES "${P_DEFINES}")
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

# A root filesystem needs /init, which lives in the (default-off) coreutils-extra
# package; force it on so `make bin` produces it for the rootfs image.
if(FUZIX_ROOTFS)
    set(_binaries_extra_default "init")
else()
    set(_binaries_extra_default "")
endif()
set(FUZIX_BINARIES_EXTRA   "${_binaries_extra_default}" CACHE STRING "Extra programs to force-enable (;-list of names)")
set(FUZIX_BINARIES_EXCLUDE "" CACHE STRING "Programs to force-disable (;-list of names)")

# ---------------------------------------------------------------------------
# 3. Build helpers
# ---------------------------------------------------------------------------
# Compile one app source (fcc emits <base>.o into an MD5-keyed cwd). The key
# includes the owning program name so that a source shared by several programs
# (e.g. ue.c in ue / ue.fuzix / ue.ansi) gets a distinct object per program
# instead of colliding on one OUTPUT.
function(_userbin_compile outvar prog abs_src incdir defines)
    get_filename_component(_base "${abs_src}" NAME_WE)
    string(MD5 _h "${prog}:${abs_src}")
    set(_wd "${CMAKE_BINARY_DIR}/userland/binobj/${_h}")
    file(MAKE_DIRECTORY "${_wd}")
    set(_obj "${_wd}/${_base}.o")
    set(_dflags "")
    foreach(d ${defines})
        list(APPEND _dflags "-D${d}")
    endforeach()
    if(USER_KIND STREQUAL "gcc")
        # Standard gcc driver: -c -o, no cwd-emit. gcc already predefines
        # __STDC__ (unlike fcc), so it is not injected here.
        add_custom_command(
            OUTPUT  "${_obj}"
            COMMAND "${USER_CC}" ${USER_OPT}
                    -Wno-int-conversion -Wno-implicit-int
                    ${_dflags} ${USER_INCLUDE_FLAGS} "-I${incdir}"
                    -c "${abs_src}" -o "${_obj}"
            DEPENDS "${abs_src}" "${LIBC_A}"
            COMMENT "${USER_CC_LABEL}  ${abs_src}"
            VERBATIM)
    else()
        add_custom_command(
            OUTPUT  "${_obj}"
            COMMAND "${USER_CC}" -X ${USER_CC_MACHINE} -c ${USER_OPT} -D__STDC__
                    ${_dflags} ${USER_INCLUDE_FLAGS} "-I${incdir}" "${abs_src}"
            WORKING_DIRECTORY "${_wd}"
            DEPENDS "${abs_src}" "${LIBC_A}"
            COMMENT "fcc ${USER_CC_MACHINE}  ${abs_src}"
            VERBATIM)
    endif()
    set(${outvar} "${_obj}" PARENT_SCOPE)
endfunction()

# Build one registered program (compile its sources + link) -> app path in out.
function(_userbin_build name outvar)
    get_property(_crt0kind GLOBAL PROPERTY FUZIX_PROG_${name}_CRT0)
    get_property(_dir      GLOBAL PROPERTY FUZIX_PROG_${name}_DIR)
    get_property(_srcs     GLOBAL PROPERTY FUZIX_PROG_${name}_SOURCES)
    get_property(_libs     GLOBAL PROPERTY FUZIX_PROG_${name}_LIBS)
    get_property(_bin      GLOBAL PROPERTY FUZIX_PROG_${name}_BIN)
    get_property(_defs     GLOBAL PROPERTY FUZIX_PROG_${name}_DEFINES)

    set(_objs "")
    foreach(s ${_srcs})
        _userbin_compile(_o "${name}" "${APPSDIR}/${_dir}/${s}" "${APPSDIR}/${_dir}" "${_defs}")
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

    set(_app "${USER_BIN_DIR}/${_bin}")
    if(USERCPU STREQUAL "armm0")
        # PIE ELF link (Target/rules.armm0): ld + crt0 + libc + libgcc + elfexe32.ld.
        add_custom_command(
            OUTPUT  "${_app}"
            COMMAND "${FUZIX_LD}" "${_crt0}" ${_objs}
                    "-L${USER_LIB_DIR}" ${_lflags} -lc${USERCPU}
                    "-L${LIBGCC_DIR}" -lgcc
                    -pie -static -no-dynamic-linker -z max-page-size=4
                    --no-export-dynamic -Bstatic -T "${ELFEXE32_LD}"
                    -o "${_app}"
            DEPENDS ${_objs} "${_crt0}" "${LIBC_A}" "${ELFEXE32_LD}"
            COMMENT "ld(arm)  ${_bin}"
            VERBATIM)
    elseif(USERCPU STREQUAL "8086")
        # MZ/msdos image link (Target/rules.8086 / lib/link/ld8086):
        # ld crt0 objs -lc8086 -lgcc -T 8086.ld -o app.
        add_custom_command(
            OUTPUT  "${_app}"
            COMMAND "${FUZIX_LD}" "${_crt0}" ${_objs}
                    "-L${USER_LIB_DIR}" ${_lflags} -lc${USERCPU}
                    "-L${LIBGCC_DIR}" -lgcc
                    -T "${LD8086_SCRIPT}" -o "${_app}"
            DEPENDS ${_objs} "${_crt0}" "${LIBC_A}" "${LD8086_SCRIPT}"
            COMMENT "ld(8086)  ${_bin}"
            VERBATIM)
    else()
        add_custom_command(
            OUTPUT  "${_app}"
            COMMAND "${USER_CC}" ${USER_CC_MACHINE} -X -s "${_crt0}" ${_objs}
                    "-L${USER_LIB_DIR}" ${_lflags} -lc${USERCPU} -o "${_app}" -M
            DEPENDS ${_objs} "${_crt0}" "${LIBC_A}"
            COMMENT "ld${USERCPU}  ${_bin}"
            VERBATIM)
    endif()
    set(${outvar} "${_app}" PARENT_SCOPE)
endfunction()

# ---------------------------------------------------------------------------
# 4. Selection pass: decide + build the enabled programs
# ---------------------------------------------------------------------------
set(_bin_outputs "")
set(_skipped_cpu "")
set(_shadowed "")
set(_claimed_bins "")     # binary names already produced by an earlier program
# per-package enabled/total counters
foreach(pkg ${_packages})
    set(_pkg_on_${pkg} 0)
    set(_pkg_tot_${pkg} 0)
endforeach()

foreach(name ${_all_progs})
    get_property(_pk   GLOBAL PROPERTY FUZIX_PROG_${name}_PACKAGE)
    get_property(_cpus GLOBAL PROPERTY FUZIX_PROG_${name}_CPUS)
    get_property(_bin  GLOBAL PROPERTY FUZIX_PROG_${name}_BIN)
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
        if(_bin IN_LIST _claimed_bins)
            # Another enabled program already produces this binary (e.g. util's
            # `ed` vs V7's `ed`). Keep the first, shadow this one.
            list(APPEND _shadowed "${_bin}(${_pk})")
        else()
            _userbin_build("${name}" _app)
            list(APPEND _bin_outputs "${_app}")
            list(APPEND _claimed_bins "${_bin}")
            math(EXPR _pkg_on_${_pk} "${_pkg_on_${_pk}} + 1")
        endif()
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
if(_shadowed)
    list(JOIN _shadowed " " _sh)
    message(STATUS "  shadowed (binary already provided): ${_sh}")
endif()
message(STATUS "  total: ${_nbin} built of ${_nreg} registered  -> ${USER_BIN_DIR}")
message(STATUS "  tune with -DFUZIX_PKG_<PKG>=ON/OFF, -DFUZIX_BINARIES_EXTRA/EXCLUDE, or -DFUZIX_CONFIG=<name>")

# ---------------------------------------------------------------------------
# 6. rpipico flash filesystem image (target: flashimage)  [armm0 only]
# ---------------------------------------------------------------------------
# Packs the built armm0 userland into a FUZIX fs -> Dhara FTL -> .uf2 to flash
# at 0x10018000 (alongside the kernel fuzix.uf2 built by the rpipico kernel
# configure). Mirrors platform-rpipico/update-flash.sh. Needs picotool.
if(USERCPU STREQUAL "armm0")
    find_program(PICOTOOL_BIN picotool)
    set(MKFS_BIN   "${CMAKE_BINARY_DIR}/tools/mkfs")
    set(UCP_BIN    "${CMAKE_BINARY_DIR}/tools/ucp")
    set(FSCK_BIN   "${CMAKE_BINARY_DIR}/tools/fsck")
    set(MKFTL_BIN  "${CMAKE_BINARY_DIR}/tools/mkftl")
    set(ETC_DIR    "${CMAKE_SOURCE_DIR}/tools/filesystem-src/etc-files")
    set(FLASH_OUT_DIR "${CMAKE_BINARY_DIR}/images")
    set(FLASH_FSSIZE 2547)
    set(PICO_UF2_FAMILY "rp2040")
    set(PICO_UF2_OFFSET "0x10018000")
    if(PICOTOOL_BIN)
        configure_file("${CMAKE_SOURCE_DIR}/cmake/flashimage-rpipico.sh.in"
                       "${CMAKE_BINARY_DIR}/flashimage-rpipico.sh" @ONLY)
        add_custom_command(
            OUTPUT  "${FLASH_OUT_DIR}/filesystem.uf2"
            COMMAND /bin/sh "${CMAKE_BINARY_DIR}/flashimage-rpipico.sh"
            DEPENDS ${_bin_outputs} "${MKFS_BIN}" "${UCP_BIN}" "${FSCK_BIN}" "${MKFTL_BIN}"
                    "${CMAKE_BINARY_DIR}/flashimage-rpipico.sh"
            COMMENT "flashimage  filesystem.uf2 (armm0 rootfs -> FTL -> uf2)"
            VERBATIM)
        add_custom_target(flashimage DEPENDS "${FLASH_OUT_DIR}/filesystem.uf2")
        add_dependencies(flashimage bin tools)
        message(STATUS "-- Flash image (target: flashimage) --")
        message(STATUS "  picotool        : ${PICOTOOL_BIN}")
        message(STATUS "  output          : ${FLASH_OUT_DIR}/filesystem.uf2 (flash @ ${PICO_UF2_OFFSET})")
    else()
        add_custom_target(flashimage
            COMMAND ${CMAKE_COMMAND} -E echo
                "flashimage: picotool not found on PATH (needed to make the .uf2)"
            VERBATIM)
        message(STATUS "-- Flash image: picotool NOT found (flashimage target will error)")
    endif()
endif()
