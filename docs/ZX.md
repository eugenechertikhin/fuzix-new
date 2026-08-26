# FUZIX on ZX Spectrum / Z80 platforms

Deep-dive into how FUZIX ports to **ZX Spectrum-class Z80 machines** (and Z80 banked systems in general). The generic banking model lives in [ARCHITECTURE.md](../ARCHITECTURE.md#memory-model--banking); this file collects the concrete, board-level facts. All file references point at the upstream tree (`../FUZIX/Kernel/…`); none of these boards are ported into `fuzix-new` yet.

These are the **classic `cpu-z80`** (SDCC) ports. The new-compiler [`z80u`](../kernel/cpu/z80u/) port (built with `fcc`) is a separate CPU that reuses the same banking *ideas* but a different toolchain and low-level code.

---

## 1. Toolchain

Classic Z80 boards build with **SDCC**, not the Fuzix Compiler Kit:

| Tool     | Program    | Notes |
|----------|------------|-------|
| Compiler | `sdcc`     | `--std-sdcc99 --no-std-crt0 -mz80 --stack-auto --constseg CONST`, custom `switch.peep` peephole |
| Assembler| `sdasz80`  | `-plosff` |
| Linker   | `sdldz80`  | banking-aware (`bankld`) |
| Objects  | `.rel`     | (vs `.o` for fcc targets) |

The Spectrum ports additionally pass `--external-banker` and split code into several **code segments** (`CODE1..CODE4`) that the linker places in different physical banks — see [`platform-pentagon/rules.mk`](../../FUZIX/Kernel/platform/platform-pentagon/rules.mk).

---

## 2. Memory model

### The Z80 address space on a 128K Spectrum

Four 16K windows; only the top one is switchable:

```
0x0000-0x3FFF   ROM (16K)                 <- DivMMC/DivIDE can page RAM here
0x4000-0x7FFF   RAM bank 5  (screen)      <- FIXED  ┐ common RAM
0x8000-0xBFFF   RAM bank 2                <- FIXED  ┘ (always mapped)
0xC000-0xFFFF   RAM bank 0..7             <- SWITCHED via port 0x7FFD bits 0-2
```

The fixed middle **32K (`0x4000-0xBFFF`) is the common RAM** — interrupt handlers, kernel stack, task-switch and user↔kernel copy code all live there. That makes the Spectrum a **banked (fixed-common)** machine, so FUZIX uses `lowlevel-z80-banked.s` (`BANKED=-banked` in the platform `rules.mk`), **not** the thunked model.

### How the kernel is laid out

The kernel is split into code segments that each occupy the `0xC000-0xFFFF` window in a *different* physical bank. For [pentagon](../../FUZIX/Kernel/platform/platform-pentagon/Makefile):

| Segment  | Window        | Physical bank |
|----------|---------------|---------------|
| common   | `0x4000-0x7FFF` | bank 5 (screen) |
| common   | `0x8000-0xBFFF` | bank 2 |
| `CODE1`  | `0xC000-0xFFFF` | bank 0 |
| `CODE2`  | `0xC000-0xFFFF` | bank 6 |
| `CODE3`  | `0xC000-0xFFFF` | bank 7 (also video) |
| `CODE4`  | `0xC000-0xFFFF` | bank 3 |

Calling from one code bank into another goes through generated `__bank_X_Y` trampolines (exported in [`pentagon.s`](../../FUZIX/Kernel/platform/platform-pentagon/pentagon.s)); the linker's banker inserts the switch.

### User process layout & the 32K limit

```
PROGBASE = PROGLOAD = 0x8000     (code + data start)
PROGTOP  = 0xFD00 (pentagon) / 0xFE00 (zxdiv)   (top; U_DATA copy above)
MAP_SIZE = 0x8000  (32K bankable per process)
```

A process lives in `0x8000-PROGTOP` — roughly **31–32K per process**. This is the well-known "32K per app" limit on Spectrum-class hardware, driven purely by how little of the address space can be banked.

### Bank switching

`switch_bank` writes the RAM-bank number to port **`0x7FFD`**, OR-ing in the 48K-ROM select bit. It stores the target to `current_map` **before** the `out`, so that an interrupt in the window restores the correct bank and the `out` becomes a harmless no-op ([`pentagon.s`](../../FUZIX/Kernel/platform/platform-pentagon/pentagon.s)):

```asm
switch_bank:
        ld (current_map), a     ; store first (interrupt-safe)
        push bc
        ld bc, #0x7ffd
        or #BANK_BITS           ; keep the 48K ROM paged
        out (c), a
        pop bc
        ret
```

`Z80_TYPE` in the platform `kernel.def` selects CPU quirks: `0` = CMOS Z80, `1` = NMOS Z80, `2` = Z180.

### Machines with more than 128K

[`dev/zx/bankbig.c`](../../FUZIX/Kernel/dev/zx/bankbig.c) handles >128K boards (Pentagon 1024, Scorpion, etc.). Each process gets a **pair of 16K banks**: `p_page` for its `0x8000-0xBFFF` page and `p_page2` for the upper page plus the udata stash. To avoid an expensive full swap it **copies the `0x8000-0xBFFF` region in/out** rather than remapping it, so the generic `swap_map` helper isn't used — the addresses are hardcoded for this machine class.

---

## 3. Boot & disk image

Spectrum ports don't use the 8080/z80u `pack85` + raw-floppy flow. Instead (pentagon example):

1. A small **4K loader** (`loader.s`) is assembled with `sdasz80`/`sdldz80`, `makebin` produces a 32K image and the loader block is cut out.
2. The kernel banks are written to six `block*` files (the common banks + the four `CODE*` banks) with `dd`.
3. Everything is packed into a **TR-DOS `.trd` disk** via the `trdify` tool (`BOOT0` = loader, `BLOCK0..5` = kernel banks).
4. `diskimage` builds a 20 MB partitioned disk (`parttab.20M`), lays the filesystem at sector 2048, and prepends an `.hdf` header for emulators.

Other Spectrum boards vary the media (raw CF/IDE image, `.dsk`, cartridge for Timex) but follow the same "loader + banked kernel image + separate root fs" shape.

---

## 4. Device drivers ([`dev/zx/`](../../FUZIX/Kernel/dev/zx/))

### Video & console
- `zxvideo.s` / `video.s` / `video-banked.s` — text console on the Spectrum's attribute-based bitmap screen (screen memory at `CONFIG_GFXBASE 0x4000`, bank 5). Uses the core **VT** layer (`CONFIG_VT`), typically `VT_WIDTH 32 × VT_HEIGHT 24`, fonts `FONT8X8` + `FONT8X8SMALL`, `CONFIG_UNIKEY`.
- On pentagon `CODE3` deliberately overlays the video bank (7) so kernel code and framebuffer share the switched window.

### Keyboard, joystick, mouse
- [`zxkeyboard.c`](../../FUZIX/Kernel/dev/zx/zxkeyboard.c) — scans the 8×5 key matrix, feeds the input layer (`CONFIG_INPUT`, `CONFIG_INPUT_GRABMAX 3`).
- [`devinput.c`](../../FUZIX/Kernel/dev/zx/devinput.c) + `zxuno.c` — joystick (Kempston / Fuller) and **Kempston mouse** as input events (`fuller, kempston, kmouse, kempston_mbmask`).
- `zxtty.c` — tty glue.

### Mass storage — TinyDisk stack (`CONFIG_TD`)
FUZIX drives the disk via the generic TinyDisk/TinyIDE/TinySD layer, with a board-specific back end:

| Driver           | Interface | Boards |
|------------------|-----------|--------|
| `nemoide.c`      | NemoIDE (8-bit IDE/CF) | pentagon, pentagon1024, scorpion |
| `divide.c`       | DivIDE     | zx128, zxdiv, tc2068 (via twister) |
| `zxmmc.c`        | ZXMMC SD   | zx+3 and others |
| `divmmc.c`       | DivMMC SD (ports `0xE7`/`0xEB`) | zxdiv, zxdiv48 |
| `evommc.c`       | ZX Evolution MMC | zxevo |
| `zxuno.c`        | ZX-Uno peripherals | zxuno |

Relevant switches: `CONFIG_TD_IDE`, `CONFIG_TD_SD`, `CONFIG_TINYIDE_8BIT` / `IDE_IS_8BIT`, `CONFIG_TINYIDE_SDCCPIO`, `SD_SPI_BANKED`.

**DivIDE / DivMMC are special**: they can page their own RAM/EPROM over the `0x0000-0x3FFF` ROM ("automap"), which is how the `zxdiv`/`zxdiv48` ports get kernel code into the low 16K that is normally ROM.

---

## 5. Board-by-board specifics

| Board          | IDE / SD           | Distinctive traits |
|----------------|--------------------|--------------------|
| `zx128`        | DivIDE/DivMMC      | 128K + microdrive; obsolete experiment |
| `zxdiv`        | DivIDE/DivMMC      | 128K/+2 grey; RAM-over-ROM automap |
| `zxdiv48`      | extended DivMMC/IDE| 48K machine + expander (experiment) |
| `zx+3`         | ZXMMC + floppy     | +2A/+3; **full-size processes** (proper HDD paging) |
| `pentagon`     | NemoIDE            | Russian 128K clone; maps RAM into low 16K |
| `pentagon1024` | NemoIDE + bankbig  | 1 MB; pair-of-16K-banks model |
| `scorpion`     | NemoIDE            | 256K clone; SMUC not supported |
| `zxuno`        | zxuno / DivMMC     | FPGA; turns **video contention off**, CPU up to 14 MHz |
| `zxevo`        | EvoMMC             | ZX Evolution (early WIP) |
| `zxspectra`    | —                  | Spectra / SpectraNet (WIP) |
| `tc2068`       | DivIDE via twister | Timex; **extended Timex video modes**; cartridge boot |
| `sam`          | AtomLite IDE       | SAM Coupé; unusual **32K banked** model, SAMBus RTC |

Not supported across the family: BetaDisk, original 16-bit AtomIDE (sam), AY-3-8912 sound (tc2068), SMUC (scorpion).

---

## 6. Why this matters for `fuzix-new`

These boards need the classic **SDCC + `sdldz80` banking** pipeline and the `-banked` low-level code — a different toolchain from the two ported targets ([`i8080`](../kernel/cpu/i8080/), [`z80u`](../kernel/cpu/z80u/)), which use the Fuzix Compiler Kit. Bringing a ZX board into `fuzix-new` would mean adding:

1. an SDCC toolchain file (`sdcc`/`sdasz80`/`sdldz80`, `.rel` objects, code segments `CODE1..CODE4`);
2. a banking-aware link/image step (the `.trd` / banked-blocks flow above);
3. the `dev/zx/` driver set and a `cpu-z80` port with the banked low-level.

That is a substantially bigger job than the fcc-based `z80u` port, which is why only the virtual `z80pack` (fcc) board is carried today.
