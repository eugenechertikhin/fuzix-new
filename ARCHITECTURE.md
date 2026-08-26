# Supported CPUs / platforms

FUZIX supports **30 CPU ports** in total. This `fuzix-new` CMake tree currently ports **four** of them — the Intel **8080** (`i8080`, boards [`v8080`](kernel/platform/v8080/), [`rcbus-8080`](kernel/platform/rcbus-8080/)) and the new-compiler **Z80** (`z80u`, board [`z80pack`](kernel/platform/z80pack/)), both built with the Fuzix Compiler Kit (`fcc`), plus the **PDP-11** (`pdp11`, board [`pdp11`](kernel/platform/pdp11/)) and the Intel **8086** (`i8086`, board [`ibmpc`](kernel/platform/ibmpc/)), both built with a standard gcc cross toolchain (`pdp11-aout-gcc` / `ia16-elf-gcc`). The remaining 26 are recorded here as the porting roadmap.

All CPU ports live under [`kernel/cpu/`](kernel/cpu/), one directory per CPU. The links below point at those local directories — [`i8080`](kernel/cpu/i8080/), [`z80u`](kernel/cpu/z80u/), [`pdp11`](kernel/cpu/pdp11/) and [`i8086`](kernel/cpu/i8086/) exist today; the rest will be created as each port lands.

Legend: ✅ ported into `fuzix-new` · ⬜ planned (directory to be created).

---

# CPUs

## Intel 8080 family

| CPU                                   | Directory                                      | Status   |
|---------------------------------------|------------------------------------------------|----------|
| 8080 (`i8080`)                        | [`kernel/cpu/i8080/`](kernel/cpu/i8080/)       | ✅ ported |
| 8085 (`i8085`)                        | [`kernel/cpu/i8085/`](kernel/cpu/i8085/)       | ⬜        |
| 8086 (`i8086`, 16-bit)                | [`kernel/cpu/i8086/`](kernel/cpu/i8086/)       | ✅ ported |

## Zilog Z80 family

| CPU                                   | Directory                                      | Status   |
|---------------------------------------|------------------------------------------------|----------|
| Z80                                   | [`kernel/cpu/z80/`](kernel/cpu/z80/)           | ⬜        |
| Z80U (new-compiler / thunked variant) | [`kernel/cpu/z80u/`](kernel/cpu/z80u/)         | ✅ ported |
| Z180                                  | [`kernel/cpu/z180/`](kernel/cpu/z180/)         | ⬜        |
| Z280                                  | [`kernel/cpu/z280/`](kernel/cpu/z280/)         | ⬜        |
| eZ80 (Z80 mode)                       | [`kernel/cpu/ez80_z80/`](kernel/cpu/ez80_z80/) | ⬜        |
| Rabbit 2000/3000 (Z80-derived)        | [`kernel/cpu/r2k/`](kernel/cpu/r2k/)           | ⬜        |

## Zilog Z8 family

| CPU                                   | Directory                                      | Status   |
|---------------------------------------|------------------------------------------------|----------|
| Z8                                    | [`kernel/cpu/z8/`](kernel/cpu/z8/)             | ⬜        |
| Super8 (Z8-derived)                   | [`kernel/cpu/super8/`](kernel/cpu/super8/)     | ⬜        |

## Motorola 6800 family

| CPU                                   | Directory                                      | Status   |
|---------------------------------------|------------------------------------------------|----------|
| 6800                                  | [`kernel/cpu/6800/`](kernel/cpu/6800/)         | ⬜        |
| 68HC11                                | [`kernel/cpu/68hc11/`](kernel/cpu/68hc11/)     | ⬜        |
| 6809                                  | [`kernel/cpu/6809/`](kernel/cpu/6809/)         | ⬜        |

## Motorola 68000 family

| CPU                                   | Directory                                      | Status   |
|---------------------------------------|------------------------------------------------|----------|
| 68000                                 | [`kernel/cpu/68000/`](kernel/cpu/68000/)       | ⬜        |

## ARM

| CPU                                   | Directory                                      | Status   |
|---------------------------------------|------------------------------------------------|----------|
| ARM Cortex-M0 (e.g. RP2040 / Pico)    | [`kernel/cpu/armm0/`](kernel/cpu/armm0/)       | ⬜        |
| ARM Cortex-M4 (e.g. TM4C)             | [`kernel/cpu/armm4/`](kernel/cpu/armm4/)       | ⬜        |

## Xtensa (Espressif)

| CPU                                   | Directory                                      | Status   |
|---------------------------------------|------------------------------------------------|----------|
| ESP8266                               | [`kernel/cpu/esp8266/`](kernel/cpu/esp8266/)   | ⬜        |
| ESP32                                 | [`kernel/cpu/esp32/`](kernel/cpu/esp32/)       | ⬜        |

## DEC / National / other minis and 32-bit

| CPU                                   | Directory                                      | Status   |
|---------------------------------------|------------------------------------------------|----------|
| PDP-11                                | [`kernel/cpu/pdp11/`](kernel/cpu/pdp11/)       | ✅ ported |
| NS32000 (ns32k)                       | [`kernel/cpu/ns32k/`](kernel/cpu/ns32k/)       | ⬜        |
| INS8070 (National Semiconductor)      | [`kernel/cpu/8070/`](kernel/cpu/8070/)         | ⬜        |
| RISC-V 32                             | [`kernel/cpu/riscv32/`](kernel/cpu/riscv32/)   | ⬜        |

---

## Summary

| Family                 | CPUs                                 | Count  |
|------------------------|--------------------------------------|--------|
| Intel 8080             | i8080 ✅, i8085, i8086 ✅            | 3      |
| Zilog Z80              | z80, z80u ✅, z180, z280, ez80_z80, r2k | 6      |
| Zilog Z8               | z8, super8                           | 2      |
| Motorola 6800          | 6800, 68hc11, 6809                   | 5      |
| Motorola 68000         | 68000                                | 1      |
| ARM                    | armm0, armm4                         | 2      |
| Xtensa                 | esp8266, esp32                       | 2      |
| DEC / National / other | pdp11 ✅, ns32k, 8070, riscv32       | 4      |

# Compilers / toolchains

Which cross-compiler a port uses is determined by its **CPU** (`Kernel/cpu-<cpu>/rules.mk` in the old repo), not by the board. Summary of the compilers in play across all CPUs:

| Compiler / toolchain                      | CPUs                               |
|-------------------------------------------|------------------------------------|
| Fuzix Compiler Kit (`fcc`)                | 8080, 8085, z8, super8, 6800, 8070 |
| Fuzix Compiler Kit (`fcc -mz80`)          | z80u                               |
| ia16 GCC (8086)                           | 8086                               |
| SDCC (`sdcc`/`sdasz80`/`sdldz80`)         | z80                                |
| SDCC (`sdcc -mz180`)                      | z180                               |
| SDCC (WIP)                                | z280                               |
| SDCC (`sdcc`/`sdasz80`)                   | ez80_z80                           |
| SDCC (`sdcc`/`sdasrab`)                   | r2k                                |
| 68HC11 GCC 3.4.6                          | 68hc11                             |
| m6809 GCC + lwtools                       | 6809                               |
| m68k GCC                                  | 68000                              |
| ARM GCC (Pi Pico SDK)                     | armm0                              |
| ARM GCC (`arm-none-eabi-gcc`)             | armm4                              |
| Xtensa GCC (`xtensa-lx106`)               | esp8266                            |
| Xtensa GCC (ESP32)                        | esp32                              |
| PDP-11 GCC                                | pdp11                              |
| NS32k GCC                                 | ns32k                              |
| RISC-V GCC (`riscv-*-elf-gcc`)            | riscv32                            |

> **fcc** = Fuzix Compiler Kit;
> **sdcc** = SDCC. The 8-bit Intel / eZ80-new / 6800 / Z8 / Super8 targets use `fcc`; the classic Z80 / Z180 / eZ80 / Rabbit targets use `sdcc`;

# Memory model & banking

Most FUZIX targets have no MMU, so a Z80/8080-class kernel runs bigger-than-64K systems by **bank switching**. The CPU low-level layer comes in three flavours (`cpu-z80` has all three; `cpu-z80u` ships `normal` + `thunked`), selected by the platform:

| Model | Common RAM? | When to use |
|-------|-------------|-------------|
| **plain / single**  | n/a (one 64K space) | No banking at all — the whole OS + one process fit in 64K |
| **banked (fixed)**  | yes — a region mapped in *every* bank | Part of the address space is fixed and always visible; the rest is a switched window |
| **thunked**         | **no** — the entire 64K switches | No fixed region exists, so bank switches must go through tiny trampolines ("thunks") |

"Common RAM" is memory that stays mapped no matter which bank is selected. The interrupt handlers, kernel stack, task-switch code and the user↔kernel copy routines must live there. If it exists you use **banked**; if the whole 64K flips at once you need **thunked** trampolines to survive the switch.

## Banking across FUZIX targets

The plain / banked / thunked choice — and the exact memory map — **varies by machine**. Banking is a cross-cutting concern for almost every target, not just the Spectrum:

| Memory manager (`FUZIX_MM`)     | Model          | Boards (examples)                    | Common RAM / notes |
|---------------------------------|----------------|--------------------------------------|--------------------|
| `bankfixed`                     | banked (fixed) | v8080, z80pack, most Z80/CP-M SBCs   | fixed common at top, banks below |
| `bank8k` / `bank16k` / `bank32k`| banked (fixed) | MSX, TRS80, various Z80               | different window size |
| *(Spectrum banked)*             | banked (fixed) | pentagon, scorpion, zxdiv, zx128     | fixed middle 32K + `0xC000` window |
| `flat`                          | plain / flat   | 68000, ESP, ARM, PDP-11              | one flat address space, no banking; fork copies |
| `simple`                        | swap-only      | tiny 8-bit boards                    | one process in RAM, swap to disk |
| *(thunked low-level)*           | thunked        | boards with no fixed region          | trampolines survive the switch |

Two families have enough board-specific detail to live in their own  documents:
 - **[ZX.md](docs/ZX.md)** — ZX Spectrum / Z80: 128K memory map, `CODE1..CODE4` code banks, port `0x7FFD` switching, DivIDE/DivMMC automap, TinyDisk stack, the 32K-per-process limit.
 - **[X86.md](docs/X86.md)** — Intel x86 (8086 / 80C188 / PC): segmented real-mode model, the `bank8086` 4K-page manager, EMM/XMS, BIOS drivers.

# Platforms

| Platform         | CPU      | Compiler        | Status       | Note                                               |
|------------------|----------|-----------------|--------------|----------------------------------------------------|
| **rcbus-8080** ✅ | 8080     | fcc             | tested       | RCBus with 8080 CPU card                           |
| **v8080** ✅      | 8080     | fcc             | tested       | 8080 development on Z80Pack                        |
| rcbus-8085       | 8085     | fcc             | tested       | RCBus with 80C85, 8/56K banking                    |
| rcbus-8070       | 8070     | fcc             | WIP          | RCBus with INS8070 CPU                             |
| rcbus-6800       | 6800     | fcc             | WIP          | RCBus with 6800 CPU                                |
| rcbus-z8         | z8       | fcc             | early WIP    | RCBus with Zilog Z8                                |
| rcbus-super8     | super8   | fcc             | WIP          | RCBus with Zilog Super8                            |
| aqplus           | z80u     | fcc (-mz80)     | WIP          | Mattel Aquarius+ (Z80)                             |
| challengeriii    | z80u     | fcc (-mz80)     | test pending | OSI Challenger III                                 |
| lobo-max80       | z80u     | fcc (-mz80)     | tested       | LOBO MAX-80 (TRS80-class Z80)                      |
| nascom           | z80u     | fcc (-mz80)     | tested       | Nascom 2/3, page-mode RAM, CF on PIO               |
| rc2014-tiny      | z80u     | fcc (-mz80)     | tested       | RC2014 paged ROM, Fuzix in ROM                     |
| rcbus-tp128      | z80u     | fcc (-mz80)     | tested       | RCBus TP128 (Z80U)                                 |
| sbc2g            | z80u     | fcc (-mz80)     | tested       | Another banked Z80 system                          |
| sbcv2            | z80u     | fcc (-mz80)     | tested       | RBC/N8VEM SBC v2                                   |
| sc720            | z80u     | fcc (-mz80)     | tested       | Small Computer Central SC720                       |
| searle           | z80u     | fcc (-mz80)     | tested       | Grant Searle Z80 (modified ROM + timer)            |
| simple80         | z80u     | fcc (-mz80)     | tested       | Bill Shen's Simple80 (bugfix + timer)              |
| tomssbc          | z80u     | fcc (-mz80)     | tested       | Tom's SBC running in RAM                           |
| z1013            | z80u     | fcc (-mz80)     | tested       | East German system (Robotron Z1013)                |
| z80-mbc2         | z80u     | fcc (-mz80)     | tested       | Z80-MBC2, ATMega as I/O                            |
| z80all           | z80u     | fcc (-mz80)     | tested       | Plasmo z80all system                               |
| z80membership    | z80u     | fcc (-mz80)     | tested       | Z80 Membership Card                                |
| **z80pack** ✅    | z80u     | fcc (-mz80)     | tested       | Z80Pack virtual Z80 platform                       |
| z80retro         | z80u     | fcc (-mz80)     | test pending | Peter Wilson's Z80Retro                            |
| zrc              | z80u     | fcc (-mz80)     | tested       | Bill Shen's ZRC platform                           |
| 2063             | z80      | sdcc            | tested       | John Winans Z80 Retro system                       |
| adam             | z80      | sdcc            | WIP          | Coleco Adam (Z80)                                  |
| amprolb          | z80      | sdcc            | tested       | The legendary Ampro Littleboard                    |
| c128-z80         | z80      | sdcc            | WIP          | Commodore 128 Z80 side                             |
| cpc6128          | z80      | sdcc            | builds       | Amstrad CPC6128                                    |
| cpcsme           | z80      | sdcc            | builds       | Amstrad CPC with 512K memory expansion             |
| cpm22            | z80      | sdcc            | exp          | S.100/CP-M setups; BIOS + Z80 customisations       |
| cromemco         | z80      | sdcc            | tested       | Cromemco with banked memory                        |
| easy-z80         | z80      | sdcc            | tested       | Easy-Z80 RC2014-compatible system                  |
| gemini           | z80      | sdcc            | early WIP    | Gemini Galaxy Z80 CP/M                             |
| genie-eg64       | z80      | sdcc            | tested       | Video Genie with banked memory expander            |
| genieiis         | z80      | sdcc            | early WIP    | EACA Genie IIs                                     |
| jeeretro         | z80      | sdcc            | builds       | JeeRetro Z80                                       |
| kc87             | z80      | sdcc            | tested       | East German system (Robotron KC87)                 |
| linc80           | z80      | sdcc            | tested       | LiNC80 Z80 retrobrew SBC                           |
| micro80          | z80      | sdcc            | tested       | Bill Shen's micro80 design                         |
| msx1             | z80      | sdcc            | tested       | MSX1 as a cartridge                                |
| msx2             | z80      | sdcc            | tested       | MSX2 128K+ with MegaFlashROM+SD                    |
| mtx              | z80      | sdcc            | test pending | Memotech MTX512 with SDX or SD (or MEMU)           |
| nc100            | z80      | sdcc            | tested       | Amstrad NC100 (or emulator)                        |
| nc200            | z80      | sdcc            | tested       | Amstrad NC200 (or emulator)                        |
| pcw8256          | z80      | sdcc            | tested       | Amstrad PCW series                                 |
| pentagon         | z80      | sdcc            | tested       | Pentagon (Spectrum near-clone), 128K, NemoIDE      |
| pentagon1024     | z80      | sdcc            | tested       | Pentagon 1MB                                       |
| px4plus          | z80      | sdcc            | early WIP    | Epson PX-4+ (Z80)                                  |
| rc2014           | z80      | sdcc            | tested       | RC2014 with 512K RAM/ROM and RTC                   |
| rcbus-sbc64      | z80      | sdcc            | tested       | RCBus Z80SBC64 128K + RTC                          |
| sam              | z80      | sdcc            | tested       | SAM Coupe (Spectrum-ish, 32K banked)               |
| sc108            | z80      | sdcc            | tested       | Small Computer Central SC108/SC114                 |
| scorpion         | z80      | sdcc            | tested       | Scorpion 256K (Spectrum clone), NemoIDE            |
| smallz80         | z80      | sdcc            | tested       | Stack180 SmallZ80 system                           |
| socz80           | z80      | sdcc            | test pending | Will Sowerbutt's FPGA SocZ80                       |
| tc2068           | z80      | sdcc            | tested       | Timex TC2068/TS2068 + DivIDE/DivMMC                |
| tomssbc-rom      | z80      | sdcc            | tested       | Tom's SBC, 4x16K banked ROM kernel                 |
| trs80            | z80      | sdcc            | tested       | TRS80 Model 4/4D/4P, 128K RAM                      |
| trs80m1          | z80      | sdcc            | tested       | TRS80 Model I/III with a banker                    |
| ubee             | z80      | sdcc            | tested       | Microbee                                           |
| vz200            | z80      | sdcc            | tested       | VZ200 with SD card / memory                        |
| z80-bios         | z80      | sdcc            | exp          | Z80 BIOS experiment                                |
| zeta-v2          | z80      | sdcc            | WIP          | Zeta v2 retrobrew SBC                              |
| zx+3             | z80      | sdcc            | tested       | ZX Spectrum +2A/+3                                 |
| zx128            | z80      | sdcc            | exp          | ZX Spectrum 128K + microdrive (obsolete exp)       |
| zxdiv            | z80      | sdcc            | test pending | ZX Spectrum 128K + DivIDE/DivMMC                   |
| zxdiv48          | z80      | sdcc            | exp          | ZX Spectrum 48K + ext DivMMC/IDE                   |
| zxevo            | z80      | sdcc            | early WIP    | ZX Evolution                                       |
| zxspectra        | z80      | sdcc            | WIP          | ZX Spectrum Spectra/SpectraNet                     |
| zxuno            | z80      | sdcc            | tested       | ZX-Uno FPGA system                                 |
| dyno             | z180     | sdcc (-mz180)   | tested       | Z180 platform using RomWBW                         |
| n8               | z180     | sdcc (-mz180)   | tested       | Retrobrew N8 home computer                         |
| p112             | z180     | sdcc (-mz180)   | builds       | DX Designs P112 (Z180)                             |
| rbc-mark4        | z180     | sdcc (-mz180)   | tested       | Retrobrew Mark 4 Z180 system                       |
| rcbus-z180       | z180     | sdcc (-mz180)   | tested       | RCBus Z180 in Z180 mode (incl. SC126)              |
| rhyophyre        | z180     | sdcc (-mz180)   | tested       | Rhyophyre Z180/NEC7220 graphics                    |
| riz180           | z180     | sdcc (-mz180)   | tested       | RIZ180 128K Z180 (Fuzix in ROM)                    |
| sc111            | z180     | sdcc (-mz180)   | tested       | Small Computer Central SC111 (Z180)                |
| scrumpel         | z180     | sdcc (-mz180)   | builds       | Scrumpel Z180 system                               |
| yaz180           | z180     | sdcc (-mz180)   | builds       | Yet another Z180 system                            |
| z180itx          | z180     | sdcc (-mz180)   | tested       | Z180ITX prototype                                  |
| ezretro          | ez80_z80 | sdcc            | builds       | eZ80-based retro board                             |
| jackrabbit       | r2k      | sdcc (rabbit)   | exp          | Rabbit 2000 board                                  |
| rabbit2000       | r2k      | sdcc (rabbit)   | WIP          | Rabbit 2000 SBC (merge w/ jackrabbit)              |
| z280rc           | z280     | sdcc (WIP)      | WIP          | Z280 RC board                                      |
| appleiie         | 6502     | cc65            | exp          | Apple IIe (6502) — long-term                       |
| pz1              | 6502     | cc65            | tested       | PZ1 6502 console                                   |
| rcbus-6502       | 6502     | cc65            | tested       | RCBus with 65C02/65C816, VIA, 512K                 |
| rcbus-65c816     | 65c816   | cc65c816        | WIP          | RCBus with 65C816                                  |
| v65c816          | 65c816   | cc65c816        | WIP          | Virtual 65C816 (emulator)                          |
| v65c816-big      | 65c816   | cc65c816        | WIP          | Virtual 65C816, large model                        |
| rcbus-6303       | 6303     | CC6303          | tested       | RCBus with 6303/6803 CPU card                      |
| 68knano          | 68000    | m68k GCC        | tested       | Small retrobrew 68000 platform with IDE disk       |
| atarist          | 68000    | m68k GCC        | early WIP    | Atari ST (68000)                                   |
| mb020            | 68000    | m68k GCC        | tested       | 68020 single board                                 |
| p90mb            | 68000    | m68k GCC        | tested       | Plasmo P90MB 68000 SBC                             |
| pico68k          | 68000    | m68k GCC        | tested       | Tiny 68K: 6522/6850 + 128K RAM                     |
| rbc-minim68k     | 68000    | m68k GCC        | tested       | Retrobrew Mini 68K system                          |
| rcbus-68008      | 68000    | m68k GCC        | tested       | RCBus with 68008, PPIDE, flat 512/512K             |
| rosco-r2         | 68000    | m68k GCC        | builds       | rosco_m68k r2 (68000)                              |
| sbc08k           | 68000    | m68k GCC        | tested       | 68008/68k SBC                                      |
| tiny68k          | 68000    | m68k GCC        | tested       | Bill Shen's Tiny68K / T68KRC                       |
| coco2            | 6809     | m6809 GCC       | tested       | Tandy COCO2 (6809), 64K                            |
| coco2cart        | 6809     | m6809 GCC       | tested       | Tandy COCO2/Dragon 64K + IDE/SDC + cartridge flash |
| coco3            | 6809     | m6809 GCC       | tested       | Tandy COCO3 512K (or MAME)                         |
| dragon-mooh      | 6809     | m6809 GCC       | tested       | Dragon 32/64 with Mooh 512K card (or xroar)        |
| dragon-nx32      | 6809     | m6809 GCC       | tested       | Dragon 32/64 with Spinx 512K card (or xroar)       |
| mo6              | 6809     | m6809 GCC       | WIP          | Thomson MO6 (6809)                                 |
| multicomp09      | 6809     | m6809 GCC       | builds       | Extended Multicomp 6809                            |
| rcbus-6809       | 6809     | m6809 GCC       | tested       | RCBus with 6809 CPU card                           |
| to8              | 6809     | m6809 GCC       | test pending | Thomson TO8/TO9+                                   |
| to9              | 6809     | m6809 GCC       | WIP          | Thomson TO9 (6809)                                 |
| mini11           | 68hc11   | 68HC11 GCC      | tested       | Mini11 68HC11A SBC                                 |
| minim8           | 68hc11   | 68HC11 GCC      | WIP          | Minimal 68HC11 SBC                                 |
| rcbus-68hc11     | 68hc11   | 68HC11 GCC      | tested       | RCBus with 68HC11 CPU                              |
| **ibmpc** ✅     | 8086     | ia16 GCC        | build-test   | IBM PC / clones (8086); core build only, no loader |
| rcbus-80c188     | 8086     | ia16 GCC        | early WIP    | RCBus with 80C188                                  |
| rpipico          | armm0    | ARM GCC (Pico)  | builds       | Raspberry Pi Pico                                  |
| tm4c129x         | armm4    | ARM GCC         | test pending | TI Tiva C Series boards                            |
| esp8266          | esp8266  | Xtensa GCC      | test pending | ESP8266 module with added SD card                  |
| esp32            | esp32    | Xtensa GCC      | early WIP    | Espressif ESP32                                    |
| rcbus-ns32k      | ns32k    | NS32k GCC       | tested       | RCBus with NS32K CPU                               |
| **pdp11** ✅      | pdp11    | PDP-11 GCC      | WIP          | DEC PDP-11 (compiler still WIP)                    |
| vrisc32          | riscv32  | RISC-V GCC      | exp          | Virtual RISC-V 32                                  |
| geneve           | tms9995  | cc9995          | early WIP    | Geneve 9640 (TMS9995)                              |
| rcbus-tms9995    | tms9995  | cc9995          | WIP          | RCBus with TMS9995                                 |
| msp430fr5969     | msp430x  | MSP430 GCC      | exp          | TI MSP430FR5969                                    |
| centurion        | wrx6     | Centurion (exp) | early WIP    | Warrex Centurion CPU6 mini                         |

**Status legend**

| Status         | Meaning |
|----------------|---------|
| `exp`          | early sketches / experiment — barely anything works yet |
| `early WIP`    | early stage, much still missing |
| `WIP`          | actively worked on, partially functional |
| `builds`       | Builds — compiles, but untested |
| `test pending` | Builds, test pending — compiles, tests not yet run |
| `tested`       | Builds, passes basic tests — compiles and passes basic tests (working) |

> Statuses are taken from the old repo's [`STATUS.md`](../FUZIX/STATUS.md) (dated 2024-07-04); a few boards not listed there are marked as best-effort.

**CPU vs platform.** A `kernel/cpu/<name>` port is the processor-level layer (context switch, syscall/IRQ entry, user↔kernel memory copy). Concrete machines/boards live under [`kernel/platform/`](kernel/platform/) and each binds to one CPU. This tree currently carries five platforms across four CPUs: [`v8080`](kernel/platform/v8080/) (Z80Pack virtual 8080) and [`rcbus-8080`](kernel/platform/rcbus-8080/) (RC2014-bus 8080 SBC) bound to [`i8080`](kernel/cpu/i8080/), [`z80pack`](kernel/platform/z80pack/) (Z80Pack virtual Z80) bound to [`z80u`](kernel/cpu/z80u/), [`pdp11`](kernel/platform/pdp11/) (DEC PDP-11, swap-only) bound to [`pdp11`](kernel/cpu/pdp11/), and [`ibmpc`](kernel/platform/ibmpc/) (IBM PC / clones, 8086 4K-page banking) bound to [`i8086`](kernel/cpu/i8086/).
