# ===========================================================================
# programs.cmake - FUZIX userland program registry (data for UserBin.cmake).
#
# One fuzix_program() per program. Packages group them for the FUZIX_PKG_*
# switches; PROGRAMS.md is the human-readable mirror. Generated from
# Applications/util/Makefile.common + V7/cmd/sh; grow deliberately.
#   coreutils        - curated default-on core set
#   coreutils-extra  - the rest of util/ single-file commands (opt-in)
#   editors          - termcap-based editors/pagers from util/ (opt-in)
#   util-misc        - diagnostics / test tools from util/ (opt-in)
#   fforth           - the FORTH interpreter (opt-in)
#   shell            - the V7 Bourne shell
#
# bogomips (util-misc) now builds on the 8080 fcc userland via a portable C
# delay loop; other CPUs still rely on its SDCC/gcc inline-asm variants.
# ===========================================================================

# --- coreutils (curated, default ON) ---
fuzix_program(NAME basename  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME cat  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME chmod  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME cmp  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME date  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME dirname  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME false  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME head  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME kill  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME mkdir  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME pwd  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME rm  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME rmdir  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME sync  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME touch  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME true  PACKAGE coreutils  CRT0 nostdio)
fuzix_program(NAME cksum  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME cp  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME cut  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME df  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME echo  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME env  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME grep  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME ls  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME more  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME mount  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME sleep  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME sort  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME umount  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME uname  PACKAGE coreutils  CRT0 stdio)
fuzix_program(NAME wc  PACKAGE coreutils  CRT0 stdio)

# --- coreutils-extra (rest of util/, default OFF) ---
fuzix_program(NAME border  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME chgrp  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME chown  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME groups  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME init  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME killall  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME logname  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME mkfifo  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME mknod  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME pagesize  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME printenv  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME prtroot  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME reboot  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME substroot  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME sum  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME tee  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME telinit  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME tr  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME while1  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME whoami  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME yes  PACKAGE coreutils-extra  CRT0 nostdio)
fuzix_program(NAME banner  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME bd  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME blkdiscard  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME cal  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME chmem  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME cu  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME dd  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME decomp16  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME dosread  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME du  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME ed  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME factor  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME fdisk  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME fgrep  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME free  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME fsck  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME fsck-fuzix  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME gpiotool  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME gptparse  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME id  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME kbdrate  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME labelfs  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME ll  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME mail  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME man  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME manscan  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME mkfs  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME mode  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME nvtool  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME od  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME passwd  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME ps  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME remount  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME rx  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME sed  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME seq  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME setboot  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME setdate  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME size  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME ssh  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME socktest  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME stty  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME su  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME swapon  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME sx  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME tar  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME tail  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME termcap  PACKAGE coreutils-extra  CRT0 stdio  LIBS termcap)
fuzix_program(NAME uniq  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME uptime  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME uud  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME uue  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME which  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME who  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME write  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME xargs  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME ar  PACKAGE coreutils-extra  CRT0 stdio)
fuzix_program(NAME line  PACKAGE coreutils-extra  CRT0 stdio)

# --- editors (termcap; default OFF) ---
fuzix_program(NAME fleamacs  PACKAGE editors  CRT0 stdio  LIBS termcap)
fuzix_program(NAME less  PACKAGE editors  CRT0 stdio  LIBS termcap)
fuzix_program(NAME tget  PACKAGE editors  CRT0 stdio  LIBS termcap)
fuzix_program(NAME tchelp  PACKAGE editors  CRT0 stdio  LIBS termcap)
fuzix_program(NAME marksman  PACKAGE editors  CRT0 stdio  LIBS termcap)
fuzix_program(NAME vile  PACKAGE editors  CRT0 stdio  LIBS termcap)

# --- util-misc (diagnostics/tests; default OFF) ---
fuzix_program(NAME seltest  PACKAGE util-misc  CRT0 stdio)
fuzix_program(NAME jstest  PACKAGE util-misc  CRT0 stdio)
# gfxtest pokes real Z80 graphics-card I/O ports.  It uses the FCK
# __builtin_out/__builtin_in intrinsics, which only the z80 backend inlines to
# OUT/IN (the 8080 backend calls a nonexistent runtime helper) -> CPUS z80.
fuzix_program(NAME gfxtest  PACKAGE util-misc  CRT0 stdio  CPUS z80)
fuzix_program(NAME bogomips  PACKAGE util-misc  CRT0 stdio)
# cpuinfo needs a per-CPU asm helper; only CPUs that ship one can build it.
# Pick the helper for this USERCPU and register cpuinfo once (or not at all).
set(_cpuinfo_asm "")
if(USERCPU STREQUAL "8080")
    set(_cpuinfo_asm cpuinfo-8080.s)
elseif(USERCPU STREQUAL "z80")
    set(_cpuinfo_asm cpuinfo-z80.S)
endif()
if(_cpuinfo_asm)
    fuzix_program(NAME cpuinfo PACKAGE util-misc CRT0 stdio
                  SOURCES cpuinfo.c ${_cpuinfo_asm})
endif()

# --- fforth ---
fuzix_program(NAME fforth  PACKAGE fforth  CRT0 stdio)

# ==== Wave 1: program collections (games / V7 / curses games) ====
# --- games (opt-in; all link libtermcap) ---
fuzix_program(NAME advint  PACKAGE games  CRT0 nostdio  DIR games  LIBS termcap)
fuzix_program(NAME fortune  PACKAGE games  CRT0 nostdio  DIR games  LIBS termcap)
fuzix_program(NAME qrun  PACKAGE games  CRT0 nostdio  DIR games  LIBS termcap)
fuzix_program(NAME z1  PACKAGE games  CRT0 nostdio  DIR games  LIBS termcap)
fuzix_program(NAME z2  PACKAGE games  CRT0 nostdio  DIR games  LIBS termcap)
fuzix_program(NAME z3  PACKAGE games  CRT0 nostdio  DIR games  LIBS termcap)
fuzix_program(NAME z4  PACKAGE games  CRT0 nostdio  DIR games  LIBS termcap)
fuzix_program(NAME z5  PACKAGE games  CRT0 nostdio  DIR games  LIBS termcap)
fuzix_program(NAME z8  PACKAGE games  CRT0 nostdio  DIR games  LIBS termcap)
fuzix_program(NAME l9x  PACKAGE games  CRT0 nostdio  DIR games  LIBS termcap)
fuzix_program(NAME adv01  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv02  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv03  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv04  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv05  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv06  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv07  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv08  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv09  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv10  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv11  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv12  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv13  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv14a  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME adv14b  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst01  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst02  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst03  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst04  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst05  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst06  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst07  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst08  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst09  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst10  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME myst11  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap  DEFINES CONFIG_IO_CUSS)
fuzix_program(NAME startrek  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap)
fuzix_program(NAME hamurabi  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap)
fuzix_program(NAME cowsay  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap)
fuzix_program(NAME taylormade  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap)
fuzix_program(NAME dopewars  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap)
fuzix_program(NAME ppt  PACKAGE games  CRT0 stdio  DIR games  LIBS termcap)

# --- v7 (UNIX V7 commands; opt-in; dd/ed/sum/su come from util) ---
fuzix_program(NAME ac  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME col  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME dc  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME diff  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME makekey  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME ptx  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME wall  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME accton  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME comm  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME diffh  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME mesg  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME rev  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME test  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME at  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME cron  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME deroff  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME join  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME newgrp  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME split  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME time  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME atrun  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME crypt  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME diff3  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME look  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME pr  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME tsort  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME pg  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME tty  PACKAGE v7  CRT0 stdio  DIR v7)
fuzix_program(NAME clear  PACKAGE v7  CRT0 stdio  DIR v7  LIBS termcap)

# --- v7games (opt-in) ---
fuzix_program(NAME arithmetic  PACKAGE v7games  CRT0 stdio  DIR v7games)
fuzix_program(NAME backgammon  PACKAGE v7games  CRT0 stdio  DIR v7games)
fuzix_program(NAME fish  PACKAGE v7games  CRT0 stdio  DIR v7games)
fuzix_program(NAME wump  PACKAGE v7games  CRT0 stdio  DIR v7games)

# --- cursesgames (opt-in; link libcurses + libtermcap) ---
fuzix_program(NAME invaders  PACKAGE cursesgames  CRT0 stdio  DIR cursesgames  LIBS curses termcap)
fuzix_program(NAME yuk  PACKAGE cursesgames  CRT0 stdio  DIR cursesgames  LIBS curses termcap)

# --- games-2048 (opt-in) ---
fuzix_program(NAME 2048  PACKAGE games-2048  CRT0 stdio  DIR g2048
    LIBS termcap  SOURCES board.c draw.c main.c)

# ==== Wave 2 (partial): single-exe tools / interpreters ====
# --- lang (interpreters; opt-in) ---
fuzix_program(NAME picol  PACKAGE lang  CRT0 stdio  DIR tcl)
# --- tools (misc single-exe tools; opt-in) ---
fuzix_program(NAME flashrom  PACKAGE tools  CRT0 stdio  DIR flashrom)
fuzix_program(NAME dasm09  PACKAGE tools  CRT0 stdio  DIR dasm09  CPUS 6809)
fuzix_program(NAME fview  PACKAGE tools  CRT0 stdio  DIR fview  CPUS 6809)

# ==== Wave 2 (multi-file single/multi-exe) ====
# cpp preprocessor (lang)
fuzix_program(NAME cpp  PACKAGE lang  CRT0 stdio  DIR cpp
    SOURCES cpp.c hash.c main.c token1.c token2.c)
# cave adventure -> exe 'advent' (games)
fuzix_program(NAME advent  PACKAGE games  CRT0 stdio  DIR cave
    SOURCES advent.c adventdb.c database.c english.c itverb.c lib.c saveadv.c turn.c verb.c global.c)
# CP/NET client (net)
fuzix_program(NAME cpnet  PACKAGE net  CRT0 stdio  DIR cpnet
    SOURCES cpmutl.c cpnet12.c main.c netio.c sio.c)
# ue micro-emacs: 3 terminal variants sharing ue.c (editors)
fuzix_program(NAME ue  PACKAGE editors  CRT0 stdio  DIR ue  LIBS termcap
    SOURCES ue.c term.c)
fuzix_program(NAME ue.fuzix  PACKAGE editors  CRT0 nostdio  DIR ue
    SOURCES ue.c term-fuzix.c)
fuzix_program(NAME ue.ansi  PACKAGE editors  CRT0 nostdio  DIR ue
    SOURCES ue.c term-ansi.c)

# V7 originals of names also provided by util (shadowed by util's by default;
# a V7-flavoured board disables coreutils-extra or excludes the util one).
fuzix_program(NAME dd-v7  BIN dd  PACKAGE v7  CRT0 stdio  DIR v7  SOURCES dd.c)
fuzix_program(NAME ed-v7  BIN ed  PACKAGE v7  CRT0 stdio  DIR v7  SOURCES ed.c)
fuzix_program(NAME su-v7  BIN su  PACKAGE v7  CRT0 stdio  DIR v7  SOURCES su.c)
fuzix_program(NAME sum-v7  BIN sum  PACKAGE v7  CRT0 stdio  DIR v7  SOURCES sum.c)

# V7 cpio (unique to V7) + ls/sort (shadowed by util's by default). Upstream's
# V7 Makefile omits these; we offer them for a full V7 userland.
fuzix_program(NAME cpio  PACKAGE v7  CRT0 stdio  DIR v7  SOURCES cpio.c)
fuzix_program(NAME ls-v7  BIN ls  PACKAGE v7  CRT0 stdio  DIR v7  SOURCES ls.c)
fuzix_program(NAME sort-v7  BIN sort  PACKAGE v7  CRT0 stdio  DIR v7  SOURCES sort.c)

# levee "Captain Video" - a vi clone (David L Parsons). fcc Makefile builds two
# terminal variants via -DANSI/-DVT52; no extra libs.
fuzix_program(NAME levee-ansi  PACKAGE editors  CRT0 stdio  DIR levee
    DEFINES VT52=0 ANSI=1
    SOURCES beep.c blockio.c display.c doscall.c editcor.c exec.c find.c flexcall.c gemcall.c globals.c insert.c main.c misc.c modify.c move.c rmxcall.c ucsd.c undo.c unixcall.c wildargs.c)
fuzix_program(NAME levee-vt52  PACKAGE editors  CRT0 stdio  DIR levee
    DEFINES VT52=1 ANSI=0
    SOURCES beep.c blockio.c display.c doscall.c editcor.c exec.c find.c flexcall.c gemcall.c globals.c insert.c main.c misc.c modify.c move.c rmxcall.c ucsd.c undo.c unixcall.c wildargs.c)

# ==== MWC (Mark Williams / Coherent utilities); opt-in ====
# find/expr: parser .c generated from find.y/expr.y by GNU bison (checked in).
fuzix_program(NAME find  PACKAGE mwc  CRT0 stdio  DIR mwc)
fuzix_program(NAME expr  PACKAGE mwc  CRT0 stdio  DIR mwc)
fuzix_program(NAME almanac  PACKAGE mwc  CRT0 stdio  DIR mwc)
fuzix_program(NAME calendar  PACKAGE mwc  CRT0 stdio  DIR mwc)
fuzix_program(NAME m4  PACKAGE mwc  CRT0 stdio  DIR mwc)
fuzix_program(NAME make  PACKAGE mwc  CRT0 stdio  DIR mwc)
fuzix_program(NAME moo  PACKAGE mwc  CRT0 stdio  DIR mwc)
fuzix_program(NAME ttt  PACKAGE mwc  CRT0 stdio  DIR mwc)
fuzix_program(NAME units  PACKAGE mwc  CRT0 stdio  DIR mwc)
fuzix_program(NAME ac-mwc  BIN ac  PACKAGE mwc  CRT0 stdio  DIR mwc  SOURCES ac.c)
fuzix_program(NAME at-mwc  BIN at  PACKAGE mwc  CRT0 stdio  DIR mwc  SOURCES at.c)
fuzix_program(NAME col-mwc  BIN col  PACKAGE mwc  CRT0 stdio  DIR mwc  SOURCES col.c)
fuzix_program(NAME cron-mwc  BIN cron  PACKAGE mwc  CRT0 stdio  DIR mwc  SOURCES cron.c)
fuzix_program(NAME deroff-mwc  BIN deroff  PACKAGE mwc  CRT0 stdio  DIR mwc  SOURCES deroff.c)
fuzix_program(NAME du-mwc  BIN du  PACKAGE mwc  CRT0 stdio  DIR mwc  SOURCES du.c)
fuzix_program(NAME ed-mwc  BIN ed  PACKAGE mwc  CRT0 stdio  DIR mwc  SOURCES ed.c)
fuzix_program(NAME pr-mwc  BIN pr  PACKAGE mwc  CRT0 stdio  DIR mwc  SOURCES pr.c)
fuzix_program(NAME tar-mwc  BIN tar  PACKAGE mwc  CRT0 stdio  DIR mwc  SOURCES tar.c)
fuzix_program(NAME test-mwc  BIN test  PACKAGE mwc  CRT0 stdio  DIR mwc  SOURCES test.c)

# ==== dev toolchain: ar (BSD), assembler (Fuzix Compiler Kit), CC ====
fuzix_program(NAME ar-full  BIN ar  PACKAGE dev  CRT0 stdio  DIR ar
    SOURCES append.c ar.c archive.c contents.c delete.c extract.c misc.c move.c print.c replace.c strmode.c)
fuzix_program(NAME ld  PACKAGE dev  CRT0 stdio  DIR asm  SOURCES ld.c)
fuzix_program(NAME nm  PACKAGE dev  CRT0 stdio  DIR asm  SOURCES nm.c)
fuzix_program(NAME osize  PACKAGE dev  CRT0 stdio  DIR asm  SOURCES osize.c)
fuzix_program(NAME dumprelocs  PACKAGE dev  CRT0 stdio  DIR asm  SOURCES dumprelocs.c)
# as needs a per-CPU target define (8080-family uses the 8085 table)
set(_as_target "")
if(USERCPU STREQUAL "8080")
    set(_as_target TARGET_8085)
elseif(USERCPU STREQUAL "z80")
    set(_as_target TARGET_Z80)
endif()
if(_as_target)
    fuzix_program(NAME as  PACKAGE dev  CRT0 stdio  DIR asm  DEFINES ${_as_target}
        SOURCES as0.c as2.c as3.c as4.c)
endif()
# CC passes are target-agnostic; the cc driver (ccfuzix.c) is 8080-family only.
fuzix_program(NAME cc0  PACKAGE dev  CRT0 stdio  DIR cc  SOURCES frontend.c)
fuzix_program(NAME cc1  PACKAGE dev  CRT0 stdio  DIR cc
    SOURCES body.c declaration.c enum.c error.c expression.c header.c idxdata.c initializer.c label.c lex.c main.c primary.c stackframe.c storage.c struct.c switch.c symbol.c tree.c type.c type_iterator.c)
fuzix_program(NAME cc2  PACKAGE dev  CRT0 stdio  DIR cc  SOURCES backend.c)
fuzix_program(NAME copt  PACKAGE dev  CRT0 stdio  DIR cc  SOURCES copt.c)
if(USERCPU STREQUAL "8080")
    fuzix_program(NAME cc  PACKAGE dev  CRT0 stdio  DIR cc  DEFINES CPU_8080  SOURCES ccfuzix.c)
endif()

# ==== cpmfs: read/write CP/M floppy images + CP/M-like shell (-> exe 'cpm') ====
# Helge Skrivervik's cpm, ANSIfied by Alan Cox.  Plain C, one exe from 20 .c
# (gensktab.c is the runtime skew-table builder gen_sktab(), NOT a host
# generator).  Upstream only ships a real Makefile for a few CPUs; builds fine
# on the fcc CPUs.  cpm.hlp/cpm.1 are runtime/doc data, not build inputs.
fuzix_program(NAME cpm  PACKAGE cpmfs  CRT0 stdio  DIR cpmfs
    SOURCES bitmap.c blockio.c cclose.c ccreat.c cfillbuf.c cflsbuf.c cmdhdl.c
            copen.c copy.c cpm.c delete.c dirhdl.c extent.c ffc.c gensktab.c
            hexdmp.c interact.c physio.c pip.c rename.c)

# ==== net/comms: dw (DriveWire), plato terminal ====
fuzix_program(NAME dw  PACKAGE net  CRT0 stdio  DIR dw  SOURCES dw.c)
fuzix_program(NAME dwgetty  PACKAGE net  CRT0 stdio  DIR dw  SOURCES dwgetty.c)
fuzix_program(NAME dwterm  PACKAGE net  CRT0 stdio  DIR dw  SOURCES dwterm.c)
fuzix_program(NAME dwdate  PACKAGE net  CRT0 stdio  DIR dw  SOURCES dwdate.c)
fuzix_program(NAME plato  PACKAGE net  CRT0 stdio  DIR plato  LIBS m
    SOURCES io_base.c keyboard_base.c plato.c protocol.c screen_base.c terminal.c touch_base.c tgi_ascii.c fuzix/font.c fuzix/io.c fuzix/keyboard.c fuzix/scale.c fuzix/screen.c fuzix/splash.c fuzix/terminal_char_load.c fuzix/touch.c)

# ==== BCPL: INTCODE interpreter kit (Martin Richards' BCPL) ====
# The pkg installs two INTCODE interpreters: icint and the paged-memory variant
# icintv.  Upstream builds icintv from icintv.c/blibv.c, which are just
# `#define PAGEDMEM` + `#include "icint.c"/"blib.c"` wrappers -- but the Fuzix
# Compiler Kit fcc miscompiles an `#include` of a .c file (emits an empty
# object), so we build icintv straight from icint.c/blib.c with DEFINES PAGEDMEM
# instead (per-program object dirs keep it distinct from icint).  Pure portable
# C, so no CPUS filter.  The bcpl "compiler" is a /bin/sh wrapper (rootfs data,
# not a binary) and the .b/.i sources are /usr/src/BCPL data -- both via the pkg.
fuzix_program(NAME icint  PACKAGE lang  CRT0 stdio  DIR bcpl
    SOURCES icint.c blib.c)
fuzix_program(NAME icintv  PACKAGE lang  CRT0 stdio  DIR bcpl  DEFINES PAGEDMEM
    SOURCES icint.c blib.c)

# --- shell ---
fuzix_program(NAME sh PACKAGE shell CRT0 stdio DIR sh
    SOURCES args.c blok.c builtin.c cmd.c ctype.c error.c expand.c fault.c io.c
            macro.c main.c msg.c name.c print.c service.c setbrk.c stak.c string.c
            word.c xec.c glob.c)

# fsh: readline-enabled variant of sh (same sources, -DBUILD_FSH + libreadline).
fuzix_program(NAME fsh PACKAGE shell CRT0 stdio DIR sh
    LIBS readline  DEFINES BUILD_FSH
    SOURCES args.c blok.c builtin.c cmd.c ctype.c error.c expand.c fault.c io.c
            macro.c main.c msg.c name.c print.c service.c setbrk.c stak.c string.c
            word.c xec.c glob.c)

