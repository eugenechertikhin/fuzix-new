# ===========================================================================
# UserLib.cmake - build the FUZIX userland C library for the selected CPU.
#
# Defines the `lib` target (NOT part of ALL). It mirrors the upstream
# Library/libs build: compile the libc sources, generate + assemble the syscall
# stubs, archive libc<usercpu>.a, build the crt0 objects and liberror.txt, and
# (optionally) the extra libraries libm / libtermcap / libreadline / libcurses.
#
# The userland toolchain is deliberately separate from the kernel one: its own
# include tree (lib/include[/<usercpu>]), its own crt0/libc, and - for the fcc
# CPUs - the ld<cpu> wrapper (a full fcc relocatable link). See cmake data in
# cmake/userland-srcs-<usercpu>.cmake for the transcribed source lists.
#
# Must be kept in step for every new port: add a USERCPU mapping row below and
# a cmake/userland-srcs-<usercpu>.cmake data file.
# ===========================================================================

# ---------------------------------------------------------------------------
# 1. FUZIX_CPU -> userland (USERCPU) mapping.
#    kind  : fcc | gcc   machine: fcc -m flag (empty for gcc)
#    opt   : optimisation/arch flags used to build the library
#    lerr  : flag passed to the host `liberror` tool (endianness/format)
# ---------------------------------------------------------------------------
#                    usercpu  kind  machine     opt              lerr
set(_ul_i8080_row    "8080"   fcc   "-m8080"    "-Os"            "")
set(_ul_z80u_row     "z80"    fcc   "-mz80"     "-O"             "")
set(_ul_pdp11_row    "pdp11"  gcc   ""          "-Os"            "-X")
set(_ul_i8086_row    "8086"   gcc   ""          "-march=i8086 -Os" "-X")
set(_ul_armm0_row    "armm0"  gcc   ""          "-std=c99 -mcpu=Cortex-M0plus -ffunction-sections -fdata-sections -fno-strict-aliasing -fomit-frame-pointer -fno-builtin -Os" "-X")

if(NOT DEFINED _ul_${FUZIX_CPU}_row)
    # Userland not wired for this CPU yet: provide a `lib` target that explains.
    add_custom_target(lib
        COMMAND ${CMAKE_COMMAND} -E echo
            "lib: userland C library not wired for FUZIX_CPU='${FUZIX_CPU}' yet (add a row to cmake/UserLib.cmake + cmake/userland-srcs-<usercpu>.cmake)"
        VERBATIM)
    return()
endif()

list(GET _ul_${FUZIX_CPU}_row 0 USERCPU)
list(GET _ul_${FUZIX_CPU}_row 1 USER_KIND)
list(GET _ul_${FUZIX_CPU}_row 2 USER_CC_MACHINE)
list(GET _ul_${FUZIX_CPU}_row 3 USER_OPT)
list(GET _ul_${FUZIX_CPU}_row 4 USER_LIBERROR_FLAG)
separate_arguments(USER_OPT UNIX_COMMAND "${USER_OPT}")

set(USER_CC "${FUZIX_CC}")                       # same driver as the kernel build

# Archiver: gcc targets need their cross ar. For the fcc targets a GNU-style
# host `ar` works on the custom-format objects, but Apple's /usr/bin/ar refuses
# to archive anything that is not a Mach-O object (it silently drops the members
# and leaves an empty library), so on macOS fall back to the bundled portable
# GNU-format archiver. Override with -DUSER_AR=... for a real GNU ar.
if(USER_KIND STREQUAL "gcc")
    # Rewrite ONLY the tool basename (ia16-elf-gcc -> ia16-elf-ar), not the whole
    # path: the install dir usually also contains "gcc" (…/toolchain/ia16-elf-gcc/
    # bin/…), and a blanket REPLACE would mangle it to a nonexistent
    # …/ia16-elf-ar/bin/ia16-elf-ar.
    get_filename_component(_cc_dir  "${FUZIX_CC}" DIRECTORY)
    get_filename_component(_cc_name "${FUZIX_CC}" NAME)
    string(REPLACE "gcc" "ar" _ar_name "${_cc_name}")
    if(_cc_dir)
        set(_derived_ar "${_cc_dir}/${_ar_name}")
    else()
        set(_derived_ar "${_ar_name}")
    endif()
    set(USER_AR "${_derived_ar}" CACHE FILEPATH "Userland archiver")
elseif(CMAKE_HOST_APPLE)
    set(USER_AR "${CMAKE_SOURCE_DIR}/cmake/portable-ar.py"
        CACHE FILEPATH "Userland archiver")
else()
    set(USER_AR "ar" CACHE FILEPATH "Userland archiver")
endif()

# Optional extra libraries (libm / termcap / readline / curses).
option(FUZIX_LIB_EXTRAS "Build the extra userland libraries (m/termcap/readline/curses)" ON)

# ---------------------------------------------------------------------------
# 2. Paths + source lists
# ---------------------------------------------------------------------------
set(LIBDIR  "${CMAKE_SOURCE_DIR}/lib")
set(LIBS    "${LIBDIR}/libs")
set(LIBINC  "${LIBDIR}/include")
set(USER_OUT     "${CMAKE_BINARY_DIR}/userland")
set(USER_OBJ_DIR "${USER_OUT}/obj")
set(USER_LIB_DIR "${USER_OUT}/lib")              # final libc<cpu>.a, crt0*.o, liberror.txt
set(USER_GEN     "${USER_OUT}/gen")              # copied kernel headers (sys/*)
file(MAKE_DIRECTORY "${USER_OBJ_DIR}" "${USER_LIB_DIR}" "${USER_GEN}/sys")

include("${CMAKE_SOURCE_DIR}/cmake/userland-srcs-${USERCPU}.cmake")

# Kernel headers the library pulls in as <sys/...> (userstructs.h, drivewire.h).
set(_krn_hdrs userstructs.h drivewire.h)
set(_krn_hdr_out "")
foreach(h ${_krn_hdrs})
    add_custom_command(
        OUTPUT  "${USER_GEN}/sys/${h}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${KDIR}/include/${h}" "${USER_GEN}/sys/${h}"
        DEPENDS "${KDIR}/include/${h}"
        COMMENT "userland  sys/${h}"
        VERBATIM)
    list(APPEND _krn_hdr_out "${USER_GEN}/sys/${h}")
endforeach()

set(USER_INCLUDE_FLAGS
    -I${USER_GEN}
    -I${LIBINC}
    -I${LIBINC}/${USERCPU})

# ---------------------------------------------------------------------------
# 3. Per-source compile helper (accumulates objects into a GLOBAL property).
#    Mirrors fuzix_compile: fcc emits <base>.o into the cwd (the fake fcc
#    ignores -o), so give every source its own MD5-keyed working dir.
# ---------------------------------------------------------------------------
function(userlib_compile prop src)
    get_filename_component(_abs "${LIBS}/${src}" ABSOLUTE)
    get_filename_component(_base "${src}" NAME_WE)
    string(MD5 _h "${_abs}")
    set(_wd "${USER_OBJ_DIR}/${_h}")
    file(MAKE_DIRECTORY "${_wd}")
    set(_obj "${_wd}/${_base}.o")

    if(USER_KIND STREQUAL "gcc")
        add_custom_command(
            OUTPUT  "${_obj}"
            COMMAND "${USER_CC}" ${USER_OPT} ${USER_INCLUDE_FLAGS}
                    -c "${_abs}" -o "${_obj}"
            DEPENDS "${_abs}" ${_krn_hdr_out}
            COMMENT "cc  lib/libs/${src}"
            VERBATIM)
    else()
        add_custom_command(
            OUTPUT  "${_obj}"
            COMMAND "${USER_CC}" -X ${USER_CC_MACHINE} -c ${USER_OPT}
                    ${USER_INCLUDE_FLAGS} "${_abs}"
            WORKING_DIRECTORY "${_wd}"
            DEPENDS "${_abs}" ${_krn_hdr_out}
            COMMENT "fcc ${USER_CC_MACHINE}  lib/libs/${src}"
            VERBATIM)
    endif()
    set_property(GLOBAL APPEND PROPERTY ${prop} "${_obj}")
endfunction()

# ---------------------------------------------------------------------------
# 4. libc: compile the static sources, then generate + archive.
# ---------------------------------------------------------------------------
set_property(GLOBAL PROPERTY USERLIB_LIBC_OBJS "")
foreach(s ${USERLIB_SRC_C} ${USERLIB_SRC_HARD} ${USERLIB_SRC_ASM})
    userlib_compile(USERLIB_LIBC_OBJS "${s}")
endforeach()
get_property(_libc_static GLOBAL PROPERTY USERLIB_LIBC_OBJS)

# 4a. syscall stubs (dynamic file set -> driven by a configured script).
set(SYSCALL_GEN     "${CMAKE_BINARY_DIR}/tools/syscall_${USERCPU}")
set(SYSCALL_WORK    "${USER_OUT}/syscall")
set(SYSCALL_OBJ_DIR "${SYSCALL_WORK}/obj")
set(SYSCALL_LIST    "${SYSCALL_WORK}/syscall-objs.txt")
file(MAKE_DIRECTORY "${SYSCALL_WORK}")

add_custom_command(
    OUTPUT  "${SYSCALL_GEN}"
    COMMAND "${HOSTCC}" -O2 "-I${KDIR}/include"
            -o "${SYSCALL_GEN}" "${LIBDIR}/tools/syscall_${USERCPU}.c"
    DEPENDS "${LIBDIR}/tools/syscall_${USERCPU}.c" "${KDIR}/include/syscall_name.h"
    COMMENT "host cc  lib/tools/syscall_${USERCPU}"
    VERBATIM)

set(LIBS_DIR "${LIBS}")
# USER_OPT is a CMake list; flatten to a space-separated string for the shell
# template (a raw @USER_OPT@ would substitute as one semicolon-joined argument).
string(REPLACE ";" " " USER_OPT_STR "${USER_OPT}")
configure_file("${CMAKE_SOURCE_DIR}/cmake/userlib-syscalls.sh.in"
               "${CMAKE_BINARY_DIR}/userlib-syscalls-${USERCPU}.sh" @ONLY)
add_custom_command(
    OUTPUT  "${SYSCALL_LIST}"
    COMMAND /bin/sh "${CMAKE_BINARY_DIR}/userlib-syscalls-${USERCPU}.sh"
    DEPENDS "${SYSCALL_GEN}"
            "${CMAKE_BINARY_DIR}/userlib-syscalls-${USERCPU}.sh"
    COMMENT "gen  userland syscall stubs (${USERCPU})"
    VERBATIM)

# 4b. archive libc<usercpu>.a from static objects + syscall objects.
set(LIBC_A "${USER_LIB_DIR}/libc${USERCPU}.a")
# Directory holding the cross tools (lorder<cpu>/nm<cpu>) for member ordering.
get_filename_component(TOOLBIN "${USER_CC}" DIRECTORY)
configure_file("${CMAKE_SOURCE_DIR}/cmake/userlib-archive.sh.in"
               "${CMAKE_BINARY_DIR}/userlib-archive.sh" @ONLY)
add_custom_command(
    OUTPUT  "${LIBC_A}"
    COMMAND /bin/sh "${CMAKE_BINARY_DIR}/userlib-archive.sh"
            "${LIBC_A}" "${SYSCALL_LIST}" ${_libc_static}
    DEPENDS ${_libc_static} "${SYSCALL_LIST}"
            "${CMAKE_BINARY_DIR}/userlib-archive.sh"
    COMMENT "ar  libc${USERCPU}.a"
    VERBATIM)

# ---------------------------------------------------------------------------
# 5. crt0 objects (crt0_<cpu>.o, crt0nostdio_<cpu>.o) live directly in lib dir.
# ---------------------------------------------------------------------------
set(_crt0_out "")
foreach(c ${USERLIB_SRC_CRT0})
    get_filename_component(_cbase "${c}" NAME_WE)
    set(_cobj "${USER_LIB_DIR}/${_cbase}.o")
    if(USER_KIND STREQUAL "gcc")
        add_custom_command(
            OUTPUT  "${_cobj}"
            COMMAND "${USER_CC}" ${USER_OPT} -c "${LIBS}/${c}" -o "${_cobj}"
            DEPENDS "${LIBS}/${c}"
            COMMENT "cc  ${c}"
            VERBATIM)
    else()
        add_custom_command(
            OUTPUT  "${_cobj}"
            COMMAND "${USER_CC}" -X ${USER_CC_MACHINE} -c "${LIBS}/${c}"
            WORKING_DIRECTORY "${USER_LIB_DIR}"
            DEPENDS "${LIBS}/${c}"
            COMMENT "fcc ${USER_CC_MACHINE}  ${c}"
            VERBATIM)
    endif()
    list(APPEND _crt0_out "${_cobj}")
endforeach()

# ---------------------------------------------------------------------------
# 6. liberror.txt (host tool)
# ---------------------------------------------------------------------------
set(LIBERROR_BIN "${CMAKE_BINARY_DIR}/tools/liberror")
set(LIBERROR_TXT "${USER_LIB_DIR}/liberror.txt")
add_custom_command(
    OUTPUT  "${LIBERROR_BIN}"
    COMMAND "${HOSTCC}" -O2 "-I${KDIR}/include"
            -o "${LIBERROR_BIN}" "${LIBDIR}/tools/liberror.c"
    DEPENDS "${LIBDIR}/tools/liberror.c"
    COMMENT "host cc  lib/tools/liberror"
    VERBATIM)
add_custom_command(
    OUTPUT  "${LIBERROR_TXT}"
    COMMAND "${LIBERROR_BIN}" ${USER_LIBERROR_FLAG} > "${LIBERROR_TXT}"
    DEPENDS "${LIBERROR_BIN}"
    COMMENT "gen  liberror.txt"
    VERBATIM)

set(_lib_outputs "${LIBC_A}" ${_crt0_out} "${LIBERROR_TXT}")

# ---------------------------------------------------------------------------
# 7. Optional extra libraries: libm, libtermcap, libreadline, libcurses.
# ---------------------------------------------------------------------------
function(userlib_archive_lib libname srcs prop)
    set_property(GLOBAL PROPERTY ${prop} "")
    foreach(s ${srcs})
        userlib_compile(${prop} "${s}")
    endforeach()
    get_property(_objs GLOBAL PROPERTY ${prop})
    set(_out "${USER_LIB_DIR}/lib${libname}${USERCPU}.a")
    add_custom_command(
        OUTPUT  "${_out}"
        COMMAND /bin/sh "${CMAKE_BINARY_DIR}/userlib-archive.sh"
                "${_out}" "" ${_objs}
        DEPENDS ${_objs} "${CMAKE_BINARY_DIR}/userlib-archive.sh"
        COMMENT "ar  lib${libname}${USERCPU}.a"
        VERBATIM)
    set(${libname}_A "${_out}" PARENT_SCOPE)
endfunction()

if(FUZIX_LIB_EXTRAS)
    userlib_archive_lib(m        "${USERLIB_SRC_LM}"   USERLIB_M_OBJS)
    userlib_archive_lib(termcap  "${USERLIB_SRC_CT}"   USERLIB_CT_OBJS)
    userlib_archive_lib(readline "${USERLIB_SRC_RL}"   USERLIB_RL_OBJS)
    userlib_archive_lib(curses   "${USERLIB_SRC_CURS}" USERLIB_CURS_OBJS)
    list(APPEND _lib_outputs "${m_A}" "${termcap_A}" "${readline_A}" "${curses_A}")
endif()

# ---------------------------------------------------------------------------
# 8. The `lib` target.
# ---------------------------------------------------------------------------
add_custom_target(lib DEPENDS ${_lib_outputs})

message(STATUS "-- Userland C library (target: lib) --")
message(STATUS "  USERCPU / kind  : ${USERCPU} / ${USER_KIND}")
message(STATUS "  compiler / ar   : ${USER_CC} ${USER_CC_MACHINE} / ${USER_AR}")
list(LENGTH USERLIB_SRC_C _nlibc)
message(STATUS "  libc sources    : ${_nlibc} C (+ asm) -> ${LIBC_A}")
message(STATUS "  extra libs      : ${FUZIX_LIB_EXTRAS} (m/termcap/readline/curses)")
message(STATUS "  output dir      : ${USER_LIB_DIR}")
