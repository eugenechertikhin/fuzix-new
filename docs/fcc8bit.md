# FUZIX on the 8080 / 8085 / Z80 family (Fuzix Compiler Kit)

Deep-dive into the 8-bit CPUs that are **actually ported into `fuzix-new`** and
built with the **Fuzix Compiler Kit (`fcc`)**: the Intel **8080** (`i8080`), the
Intel **8085** (`i8085`), and the new-compiler **Z80** (`z80u`). Together these
carry the large majority of the ported boards.

This is the fcc counterpart to two other docs:

- The **ZX Spectrum** family ([Spectrum.md](Spectrum.md)) is *classic* Z80 built with **SDCC**
  (`sdldz80` banking, `.rel` objects, `dev/zx/` drivers) — a different toolchain,
  and **not ported here** yet.
- The generic banked-Z80 porting model (the `map_kernel`/`map_process` contract,
  common memory, crt0 relocation) is upstream in [Z80banked.md](Z80banked.md); the
  no-common / 32K-split cases are in [Z80Thunked.md](Z80Thunked.md); the
  syscall/register ABI is in [Z80ABI.md](Z80ABI.md).

> Also fcc, but out of scope here: the National **INS8070** (`8070`), Zilog **Z8**
> (`z8`) and **Super8** (`super8`) ports are separate instruction sets with their
> own single boards — recorded in the [ARCHITECTURE.md](../ARCHITECTURE.md)
> Platforms table, no deep-dive yet.

---

## 1. Toolchain

All three CPUs use the **Fuzix Compiler Kit** — one compiler driver (`fcc`) with a
per-CPU machine flag, and the 8080-lineage linkers (`ld8080` for 8080/8085,
`ldz80` for Z80). Objects are the FCK's own `.o` format (not ELF, not SDCC
`.rel`), and the kernel image is finished with the `pack85` packer.

| CPU     | `CPU_MACHINE` | Linker   | libc          | Toolchain file |
|---------|---------------|----------|---------------|----------------|
| `i8080` | `-m8080`      | `ld8080` | `lib8080.a`   | [`toolchain-i8080.cmake`](../cmake/toolchain-i8080.cmake) |
| `i8085` | `-m8085`      | `ld8080` | 8085 libc     | [`toolchain-i8085.cmake`](../cmake/toolchain-i8085.cmake) |
| `z80u`  | `-mz80`       | `ldz80`  | `lib8080.a`*  | [`toolchain-z80u.cmake`](../cmake/toolchain-z80u.cmake) (includes the i8080 one) |

The i8085 is object-compatible with the 8080 flow — same `ld8080` and `pack85`,
only the machine flag and C library differ. `toolchain-z80u.cmake` simply
`include()`s `toolchain-i8080.cmake` and overrides the machine flag/linker, so a
single toolchain family drives all three. Point it at the real FCK with
`-DFUZIX_TOOLCHAIN_PREFIX=$PWD/toolchain/fcc`.

The linkers **parse options before input files** — `-o out` must precede the
objects, or `ld8080`/`ldz80` treat `-o` as an input and fail with
`-o: No such file or directory`. (This is why FCK link/loader steps put `-o`
first; it bit the `rcbus-ide` loader link once.)

---

## 2. Memory model

These are no-MMU machines, so a bigger-than-64K kernel + processes run by **bank
switching**. The default manager is **`bankfixed`** (a fixed common region mapped
in every bank, with a switched window below); the CPU low level comes in a
`normal` and a `thunked` flavour, and `z80u` ships both. The exact model is
chosen per board (an explicit `-DFUZIX_MM` always wins):

| MM (`FUZIX_MM`) | Model            | Ported boards (examples)          |
|-----------------|------------------|-----------------------------------|
| `bankfixed`     | banked, fixed common (default) | v8080, z80pack, most Z80 SBCs |
| `bank16k`       | 4×16K banked     | aqplus, z80retro                  |
| `bank16kfc`     | 4×16K flash-friendly | rcbus-8070 (8070 CPU)         |
| `simple`        | swap-only        | searle, tomssbc, rc2014-tiny, z1013, simple80 |

The **generic** contract these implement — `map_kernel`, `map_process`,
`map_save_kernel`/`map_restore`, `commonmem.s`, `tricks.s`, crt0 relocation — is
documented once, upstream, in [Z80banked.md](Z80banked.md); the no-common and
32K/32K-split variants are in [Z80Thunked.md](Z80Thunked.md). See
[ARCHITECTURE.md](../ARCHITECTURE.md#memory-model--banking) for the
plain/banked/thunked overview across all targets.

---

## 3. CPUs & boards

| CPU     | Boards ported into `fuzix-new` |
|---------|--------------------------------|
| `i8080` | [`v8080`](../kernel/platform/v8080/) (Z80Pack virtual 8080), [`rcbus-8080`](../kernel/platform/rcbus-8080/) (RC2014 8080 SBC) |
| `i8085` | [`rcbus-8085`](../kernel/platform/rcbus-8085/) (RC2014 80C85, 8/56K banking, TMS9918 VDP) |
| `z80u`  | **19 boards** — [`z80pack`](../kernel/platform/z80pack/), [`nascom`](../kernel/platform/nascom/), [`sbcv2`](../kernel/platform/sbcv2/), [`lobo-max80`](../kernel/platform/lobo-max80/), [`rc2014-tiny`](../kernel/platform/rc2014-tiny/), [`z80-mbc2`](../kernel/platform/z80-mbc2/), [`searle`](../kernel/platform/searle/), … (see the ARCHITECTURE.md Platforms table) |

Full per-board status (tested / builds / WIP) lives in the
[ARCHITECTURE.md](../ARCHITECTURE.md) Platforms table.

---

## 4. Boot & disk image

The `diskimage` target packs a bootable image whose shape depends on the board's
`DISKIMAGE_STYLE` (default `bootblock`):

| Style        | Boards            | Shape |
|--------------|-------------------|-------|
| `bootblock`  | v8080, z80pack    | `pack85` kernel + a boot floppy (loader linked high, last 256 B cut) + a root disk |
| `rcbus-ide`  | rcbus-8080, rcbus-8085 | loader linked at `0xFE00` + kernel + a 40 MB partitioned **IDE** disk |
| `none`       | nascom, sbcv2, lobo-max80, … | no in-tree image packaging (dd/loader done elsewhere upstream) |

`bootblock` and `rcbus-ide` optionally take a partition table
(`-DFUZIX_PARTTAB=`) and a populated root filesystem (`-DFUZIX_FILESYS_IMG=`);
without them a blank image is produced. The kernel image itself is `pack85`'d and
linked with the board's `LINK_FLAGS` (load origin `-C`, split/common base `-S`,
etc.).

```
# v8080 (fcc, i8080)
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake \
      -DFUZIX_CPU=i8080 -DFUZIX_PLATFORM=v8080 \
      -DFUZIX_TOOLCHAIN_PREFIX=$PWD/toolchain/fcc
cmake --build build --target fuzix       # image/fuzix.bin
cmake --build build --target diskimage   # boot floppy + root disk
```

---

## 5. How this is wired into `fuzix-new`

1. **Toolchain files** — one per CPU (`toolchain-i8080/i8085/z80u.cmake`), the
   z80u one layered on top of i8080. They set `FUZIX_CC`/`FUZIX_LD` for the real
   FCK; without the toolchain file `FUZIX_CC` is empty and the build dies in the
   userlib syscall-gen step.
2. **CPU fragments** ([`cmake/cpu-<cpu>.cmake`](../cmake/)) — machine flag,
   linker tool, `pack85` image step, low-level source selection.
3. **Platform fragments** ([`cmake/platform-<board>.cmake`](../cmake/)) — object
   link order, `LINK_FLAGS`, `DISKIMAGE_STYLE`.
4. **Shared driver trees** — several boards pull drivers from
   `kernel/dev/z80pack/` (v8080, z80pack) or the nascom-family `kernel/dev/80bus/`
   (nascom). Because a board-specific header can shadow a generic one (e.g.
   `dev/z80pack/devfd.h` also declares `hd_*`, which the generic
   `dev/devfd.h` does not), a board that uses such a tree **prepends** it to the
   include path in its own platform fragment, ahead of the generic `kernel/dev`.

See [ARCHITECTURE.md](../ARCHITECTURE.md) for where these CPUs sit among all
ports, [Spectrum.md](Spectrum.md) for the SDCC Spectrum family, and
[Z80banked.md](Z80banked.md) / [Z80Thunked.md](Z80Thunked.md) for the generic
banked-Z80 model.
