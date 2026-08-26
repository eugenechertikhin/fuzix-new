# FUZIX Applications — porting status and CPU mapping

A catalog of **all** programs from the upstream `Applications/` tree (not only the ones already ported), flagged with what has been ported into `fuzix-new`, and noting which CPUs each package builds for upstream. The tables are updated as new CPUs/platforms are ported.

> FUZIX userland programs are built **per CPU** (USERCPU), not per specific board: the set of supported CPUs is defined by the presence of `Applications/<pkg>/Makefile.<cpu>`. A board inherits whatever is built for its CPU (and whatever fits in the image).

## Legend

- **Ported:** ✅ builds via the `bin` target in `fuzix-new`; ⬜ not yet.
- **crt0:** `nostdio` = linked with `crt0nostdio` (no stdio), `stdio` = with `crt0`, `+tc` = additionally `libtermcap`, `+curses`/`+rl`/`+m` = curses/readline/libm.

## CPU model

The full set of USERCPU in upstream (**27**), from which the package sets are drawn:

```
6303 6502 65c816 6800 6803 6809 68000 68hc11 8070 8080 8085 8086
armm0 armm4 esp32 esp8266 ez80_z80 ns32k pdp11 r2k riscv32 super8
tms7000 tms9995 wrx6 z8 z80
```

- Most packages build for **"all (−6803)"** — the entire set except `6803`.
- In `fuzix-new` the ported CPUs so far are: **`i8080`(→8080)**, **`z80u`(→z80)**
  (both library and programs build), plus (gcc) configured **`pdp11`**, **`i8086`(→8086)**.
- An entry "`all (−a,b)`" = the full set minus the listed CPUs.

## What is ported now

- **Library** (`lib` target): `libc<cpu>.a` + crt0 + `libm/termcap/readline/curses`
  + `liberror.txt` — for the fcc CPUs (8080, z80). See [ARCHITECTURE.md](ARCHITECTURE.md).
- **Programs** (`bin` target): **31** utilities from `util` + **`sh`** (V7 Bourne shell).
  Marked ✅ in the tables below.

## Configuring the build set

This document is the human-readable mirror of the program **registry** in
[cmake/programs.cmake](cmake/programs.cmake) (`fuzix_program(NAME .. PACKAGE ..
CRT0 .. [CPUS ..])`). What the `bin` target actually builds is selected by:

- **Packages:** `-DFUZIX_PKG_<PACKAGE>=ON/OFF` (`coreutils` and `shell` default
  ON; `coreutils-extra`, `editors` default OFF).
- **Per-program:** `-DFUZIX_BINARIES_EXTRA=name;name` /
  `-DFUZIX_BINARIES_EXCLUDE=name;name`.
- **CPU:** a program whose `CPUS` list excludes the current USERCPU is skipped.
- **Board config file:** `-DFUZIX_CONFIG=<name>` includes
  `configs/<name>.cmake` (ships `default`, `minimal`, `full`), which pre-sets the
  above. An explicit `-D…` on the command line always overrides the config.

`cmake --build <dir> --target bin` then builds only the enabled set; the configure
summary prints an **Optional binaries** section with per-package counts.

---

## util — base utilities and system tools

Package `util`. CPU: **all (−6803)**. Source: `Applications/util/Makefile.common`.

### util — without stdio (crt0nostdio)

| Program | Purpose | crt0 | Ported |
|---|---|---|---|
| `basename` | strip dir/suffix from path | nostdio | ✅ |
| `border` | draw screen border | nostdio | ⬜ |
| `cat` | concatenate files | nostdio | ✅ |
| `chgrp` | change group | nostdio | ⬜ |
| `chmod` | change mode | nostdio | ✅ |
| `chown` | change owner | nostdio | ⬜ |
| `cmp` | compare two files | nostdio | ✅ |
| `date` | print/set date | nostdio | ✅ |
| `dirname` | strip last path component | nostdio | ✅ |
| `false` | exit failure | nostdio | ✅ |
| `groups` | print group memberships | nostdio | ⬜ |
| `head` | first lines of file | nostdio | ✅ |
| `init` | process 1 / system init | nostdio | ⬜ |
| `kill` | send signal | nostdio | ✅ |
| `killall` | kill by name | nostdio | ⬜ |
| `logname` | print login name | nostdio | ⬜ |
| `mkdir` | make directory | nostdio | ✅ |
| `mkfifo` | make FIFO | nostdio | ⬜ |
| `mknod` | make device node | nostdio | ⬜ |
| `pagesize` | print memory page size | nostdio | ⬜ |
| `printenv` | print environment | nostdio | ⬜ |
| `prtroot` | print root device | nostdio | ⬜ |
| `pwd` | print working dir | nostdio | ✅ |
| `reboot` | reboot system | nostdio | ⬜ |
| `rm` | remove files | nostdio | ✅ |
| `rmdir` | remove empty dir | nostdio | ✅ |
| `substroot` | substitute root | nostdio | ⬜ |
| `sum` | checksum (BSD) | nostdio | ⬜ |
| `sync` | flush buffers | nostdio | ✅ |
| `tee` | copy stdin to files | nostdio | ⬜ |
| `telinit` | change init runlevel | nostdio | ⬜ |
| `touch` | update timestamps | nostdio | ✅ |
| `tr` | translate chars | nostdio | ⬜ |
| `true` | exit success | nostdio | ✅ |
| `while1` | loop helper | nostdio | ⬜ |
| `whoami` | print effective user | nostdio | ⬜ |
| `yes` | repeat a string | nostdio | ⬜ |

### util — with stdio (crt0)

| Program | Purpose | crt0 | Ported |
|---|---|---|---|
| `banner` | big text banner | stdio | ⬜ |
| `bd` | binary dump | stdio | ⬜ |
| `blkdiscard` | discard block ranges | stdio | ⬜ |
| `cal` | calendar | stdio | ⬜ |
| `chmem` | set program memory | stdio | ⬜ |
| `cksum` | CRC checksum | stdio | ✅ |
| `cp` | copy files | stdio | ✅ |
| `cu` | call-up / serial dialer | stdio | ⬜ |
| `cut` | cut columns | stdio | ✅ |
| `dd` | convert/copy blocks | stdio | ⬜ |
| `decomp16` | decompress | stdio | ⬜ |
| `df` | free disk space | stdio | ✅ |
| `dosread` | read MS-DOS FS | stdio | ⬜ |
| `du` | disk usage | stdio | ⬜ |
| `echo` | print args | stdio | ✅ |
| `ed` | line editor | stdio | ⬜ |
| `env` | run with env | stdio | ✅ |
| `factor` | factor integers | stdio | ⬜ |
| `fdisk` | partition editor | stdio | ⬜ |
| `fgrep` | fixed-string grep | stdio | ⬜ |
| `free` | free memory | stdio | ⬜ |
| `fsck` | FS check | stdio | ⬜ |
| `fsck-fuzix` | FUZIX FS check | stdio | ⬜ |
| `gpiotool` | GPIO control | stdio | ⬜ |
| `gptparse` | parse GPT | stdio | ⬜ |
| `grep` | pattern search | stdio | ✅ |
| `id` | user/group ids | stdio | ⬜ |
| `kbdrate` | set key repeat | stdio | ⬜ |
| `labelfs` | label filesystem | stdio | ⬜ |
| `ll` | ls -l alias | stdio | ⬜ |
| `ls` | list directory | stdio | ✅ |
| `mail` | simple mail | stdio | ⬜ |
| `man` | manual pager | stdio | ⬜ |
| `manscan` | index man pages | stdio | ⬜ |
| `mkfs` | make filesystem | stdio | ⬜ |
| `mode` | stty-like mode | stdio | ⬜ |
| `more` | pager | stdio | ✅ |
| `mount` | mount FS | stdio | ✅ |
| `nvtool` | NVRAM tool | stdio | ⬜ |
| `od` | octal dump | stdio | ⬜ |
| `passwd` | change password | stdio | ⬜ |
| `ps` | process status | stdio | ⬜ |
| `remount` | remount FS | stdio | ⬜ |
| `rx` | XMODEM receive | stdio | ⬜ |
| `sed` | stream editor | stdio | ⬜ |
| `seq` | number sequence | stdio | ⬜ |
| `setboot` | set boot block | stdio | ⬜ |
| `setdate` | set RTC | stdio | ⬜ |
| `size` | binary section sizes | stdio | ⬜ |
| `sleep` | delay | stdio | ✅ |
| `socktest` | socket test | stdio | ⬜ |
| `sort` | sort lines | stdio | ✅ |
| `ssh` | secure shell client | stdio | ⬜ |
| `stty` | terminal settings | stdio | ⬜ |
| `su` | switch user | stdio | ⬜ |
| `swapon` | enable swap | stdio | ⬜ |
| `sx` | XMODEM send | stdio | ⬜ |
| `tail` | last lines | stdio | ⬜ |
| `tar` | archiver | stdio | ⬜ |
| `termcap` | termcap query | stdio | ⬜ |
| `umount` | unmount FS | stdio | ✅ |
| `uname` | system info | stdio | ✅ |
| `uniq` | unique lines | stdio | ⬜ |
| `uptime` | uptime | stdio | ⬜ |
| `uud` | uudecode | stdio | ⬜ |
| `uue` | uuencode | stdio | ⬜ |
| `wc` | word/line count | stdio | ✅ |
| `which` | find in PATH | stdio | ⬜ |
| `who` | who is logged in | stdio | ⬜ |
| `write` | message a user | stdio | ⬜ |
| `xargs` | build arg lists | stdio | ⬜ |

### util — termcap programs (crt0 + libtermcap)

| Program | Purpose | crt0 | Ported |
|---|---|---|---|
| `fleamacs` | tiny emacs | +tc | ⬜ |
| `less` | pager | +tc | ⬜ |
| `marksman` | editor | +tc | ⬜ |
| `tchelp` | termcap help | +tc | ⬜ |
| `tget` | termcap get | +tc | ⬜ |
| `vile` | vi-like editor | +tc | ⬜ |

### util — miscellaneous

| Program | Purpose | Note | Ported |
|---|---|---|---|
| `fforth` | FORTH interpreter | separate package `fuzix-fforth` | ⬜ |
| `ar` | archiver | separate from `Applications/ar` | ⬜ |
| `bogomips` | CPU speed bench | | ⬜ |
| `cpuinfo` | CPU info | has asm `cpuinfo-<cpu>.s` (per-CPU) | ⬜ |
| `gfxtest` | graphics test | | ⬜ |
| `jstest` | joystick test | | ⬜ |
| `line` | read one line | | ⬜ |
| `seltest` | select() test | | ⬜ |

---

## Shells

| Program | Package | CPU | crt0 | Ported |
|---|---|---|---|---|
| `sh` | `V7/cmd/sh` (fuzix-sh) | all (−6803) | stdio | ✅ |
| `fsh` | `V7/cmd/sh` | all (−6803) | stdio +rl | ⬜ (readline variant) |

---

## V7 — UNIX V7 commands

Package `V7/cmd`. CPU: **all (−6803)**. Source: `Applications/V7/cmd`.

| Program | Purpose | Ported |
|---|---|---|
| `ac` | login accounting | ⬜ |
| `accton` | enable process accounting | ⬜ |
| `at` | schedule a job | ⬜ |
| `atrun` | run at-jobs | ⬜ |
| `clear` | clear screen | ⬜ |
| `col` | filter reverse line feeds | ⬜ |
| `comm` | compare sorted files | ⬜ |
| `cpio` | copy in/out archive | ⬜ |
| `cron` | job scheduler daemon | ⬜ |
| `crypt` | encrypt/decrypt | ⬜ |
| `dc` | desk calculator | ⬜ |
| `dd` | convert/copy | ⬜ |
| `deroff` | strip nroff/troff | ⬜ |
| `diff` | file diff | ⬜ |
| `diff3` | 3-way diff | ⬜ |
| `diffh` | diff helper | ⬜ |
| `ed` | line editor | ⬜ |
| `join` | relational join | ⬜ |
| `look` | dictionary lookup | ⬜ |
| `ls` | list directory (V7) | ⬜ |
| `makekey` | encryption key gen | ⬜ |
| `mesg` | allow/deny messages | ⬜ |
| `newgrp` | change group id | ⬜ |
| `pg` | pager | ⬜ |
| `pr` | paginate for printing | ⬜ |
| `ptx` | permuted index | ⬜ |
| `rev` | reverse lines | ⬜ |
| `sort` | sort (V7) | ⬜ |
| `split` | split file | ⬜ |
| `su` | switch user (V7) | ⬜ |
| `sum` | checksum (V7) | ⬜ |
| `test` | condition eval | ⬜ |
| `time` | time a command | ⬜ |
| `tsort` | topological sort | ⬜ |
| `tty` | print tty name | ⬜ |
| `wall` | write to all | ⬜ |

---

## Editors

| Program | Package | CPU | Purpose | Ported |
|---|---|---|---|---|
| `ed` | `util` / `V7/cmd` | all (−6803) | line editor | ⬜ |
| `levee`, `levee-ansi`, `levee-termcap`, `levee-vt52` | `levee` | all (−6803) | vi-like editor | ⬜ |
| `ue` | `ue` | all (−6803,r2k) | micro-emacs | ⬜ |
| `vile` | `util` | all (−6803) | vi-like (+termcap) | ⬜ |
| `marksman` | `util` | all (−6803) | editor (+termcap) | ⬜ |
| `fleamacs` | `util` | all (−6803) | tiny emacs (+termcap) | ⬜ |
| `less` | `util` | all (−6803) | pager (+termcap) | ⬜ |

---

## Games

| Package | Programs | CPU | Ported |
|---|---|---|---|
| `games` | adventure (`adv01`…`adv14`, `advint`), `startrek`, `zork` (`z1`…`z8`), `fweep`, `myst01`…`myst11`, `sok`, `hamurabi`, `fortune`, `cowsay`, `dopewars`, `l9x`, `ppt`, `qrun`, `taylormade` | all (−6803) | ⬜ |
| `games/2048` | `2048` | per build.mk (usually all −6803) | ⬜ |
| `V7/games` | `arithmetic`, `backgammon`, `fish`, `hangman`, `quiz`, `wump` | all (−6803) | ⬜ |
| `cursesgames` | `invaders`, `yuk` | all (−6803) | ⬜ |
| `cave` | adventure game | all (−6803) | ⬜ |
| `rpilot-1.4.2` | `pilot`, `rpilot` | ez80_z80 | ⬜ |

---

## Languages and development tools

| Package | Programs | CPU | Ported |
|---|---|---|---|
| `CC` | Fuzix Compiler Kit (C compiler) | all (−ez80_z80,riscv32) | ⬜ |
| `cpp` | `cpp` (preprocessor) | all (−ez80_z80,riscv32) | ⬜ |
| `assembler` | `as`, `ld`, `nm`, `osize`, `dumprelocs` | all (−ez80_z80,riscv32) | ⬜ |
| `ar` | `ar` (archiver) | all (−6303,ez80_z80,riscv32) | ⬜ |
| `BCPL` | `bcpl`, `icint`, `icintv` | 6809, z80 | ⬜ |
| `TCL` | `picol` (mini-Tcl) | 6809, ez80_z80, z80 | ⬜ |
| `basic` | BASIC interpreter | per build.mk (usually all −6803) | ⬜ |
| `v7yacc` | yacc | per build.mk (usually all −6803) | ⬜ |
| `dasm09` | `dasm09` (6809 disassembler) | 6809 | ⬜ |
| `MWC/cmd` | `ac`, `almanac`, `at`, `calendar`, `col`, `deroff`, `du`, `expr`, `find`, `m4`, `make`, `pr`, `tar`, `test`, `units` | all (−6803) | ⬜ |

---

## System, networking, disks, emulation

| Package | Programs | CPU | Ported |
|---|---|---|---|
| `netd` | `netd-*`, `ifconfig`, `ping`, `telnet`, `httpd`, `htget`, `dig`, `echoping`, `ntpdate`, `tinyirc` | all (−6803) | ⬜ |
| `dw` | `dw`, `dwdate`, `dwgetty`, `dwterm` (DriveWire) | all (−6803,r2k,wrx6) | ⬜ |
| `cpm` | `runcpm` (CP/M emulator) | all (−6803) | ⬜ |
| `cpmfs` | CP/M FS access | all (−6803) | ⬜ |
| `cpnet` | CP/NET | all (−6803) | ⬜ |
| `emulators` | emulators | all (−6803) | ⬜ |
| `flashrom` | `flashrom` | all (−6803) | ⬜ |
| `fview` | `fview` (FS viewer) | 6809 | ⬜ |
| `db` | debugger | subset (6303 6502 65c816 6800 68000 6809 68hc11 8070 8080 8085 8086 armm0 ns32k super8 tms7000 wrx6 z8 z80) | ⬜ |
| `plato` | PLATO terminal | all (−6803) | ⬜ |
| `man2` | man system | per build.mk (usually all −6803) | ⬜ |

---

## Other packages

`Applications/` also contains helper directories without standalone user programs
or with a specialized purpose: `cpp`, `dw`, etc. are already accounted for above.
Packages are added here as they are ported.

> CPU data was extracted from the presence of `Applications/<pkg>/Makefile.<cpu>`
> in upstream (snapshot as of this file's creation date). Packages built via
> `build.mk` without a per-CPU Makefile are marked "per build.mk".
