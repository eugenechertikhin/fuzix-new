# FuzixOS: Because Small Is Beautiful

FUZIX is a fusion of various elements from the assorted UZI forks and branches beaten together into some kind of semi-coherent platform and then extended from V7 to somewhere in the SYS3 to SYS5.x world with bits of POSIX thrown in for good measure. Various learnings and tricks from ELKS and from OMU also got blended in

This is the rework of well-known FuzixOS project.  A CMake-driven build of the [FUZIX](https://github.com/EtchedPixels/FUZIX) kernel where the **target CPU, platform, memory manager, filesystem and device drivers are selected with build flags** instead of per-platform Makefiles.

Per-CPU settings live in `cmake/cpu-<cpu>.cmake`, per-platform link recipes in `cmake/platform-<platform>.cmake`, so more CPUs/platforms can be added later. See [ARCHITECTURE.md](ARCHITECTURE.md) for the full roadmap of all 30 CPU ports and 132 boards, plus deep-dives on the [ZX Spectrum / Z80](docs/ZX.md) and [x86](docs/X86.md) families.

## Layout

```
fuzix-new/
├── CMakeLists.txt                # shared options; includes the cpu/platform fragments
├── cmake/
│   ├── toolchain-i8080.cmake     # generic fcc cross toolchain (also used by i8085/z80u)
│   ├── toolchain-i8085.cmake     # alias of the above for i8085
│   ├── toolchain-8070.cmake      # alias of the above for 8070
│   ├── toolchain-z8.cmake        # alias of the above for z8
│   ├── toolchain-super8.cmake    # alias of the above for super8
│   ├── toolchain-armm4.cmake     # arm-none-eabi gcc toolchain
│   ├── toolchain-z80u.cmake      # alias of the above for z80u
│   ├── toolchain-pdp11.cmake     # pdp11-aout gcc toolchain
│   ├── toolchain-i8086.cmake     # ia16-elf gcc toolchain
│   ├── cpu-i8080.cmake           # i8080: -m8080, ld8080, lib8080.a
│   ├── cpu-i8085.cmake           # i8085: -m8085, ld8080, lib8085.a
│   ├── cpu-8070.cmake            # 8070:  -m8070, ld8070, lib8070.a (no pack85)
│   ├── cpu-z8.cmake              # z8:    -mz8,   ldz8,   libz8.a (no pack85)
│   ├── cpu-super8.cmake          # super8: -msuper8, ldsuper8, libsuper8.a (no pack85)
│   ├── cpu-armm4.cmake           # armm4: arm gcc, cortex-m4, elf32, --entry=start
│   ├── cpu-z80u.cmake            # z80u:  -mz80,  ldz80,  libz80.a, normal|thunked
│   ├── cpu-pdp11.cmake           # pdp11: gcc kind, ld+objcopy, simple MM
│   ├── cpu-i8086.cmake           # i8086: gcc kind, ld -> fuzix.elf, bank8086 MM
│   ├── platform-v8080.cmake      # v8080 link recipe (object order, link flags)
│   ├── platform-z80pack.cmake    # z80pack link recipe
│   ├── platform-rcbus-8080.cmake # rcbus-8080 link recipe
│   ├── platform-rcbus-8085.cmake # rcbus-8085 link recipe
│   ├── platform-rcbus-z8.cmake   # rcbus-z8 link recipe
│   ├── platform-rcbus-8070.cmake # rcbus-8070 link recipe
│   ├── platform-rcbus-super8.cmake # rcbus-super8 link recipe
│   ├── platform-rcbus-80c188.cmake # rcbus-80c188 link recipe (ia16, fuzix.ld)
│   ├── platform-tm4c129x.cmake   # tm4c129x link recipe (arm, fuzix.ld)
│   ├── platform-pdp11.cmake      # pdp11 link recipe (fuzix.ld)
│   ├── platform-ibmpc.cmake      # ibmpc link recipe (fuzix.ld)
│   ├── FuzixBuild.cmake          # compile/link helper functions (fcc + gcc kinds)
│   ├── link-image.sh.in          # fcc: <ld> + pack85 image link (template)
│   ├── link-image-pdp11.sh.in    # gcc: ld -T fuzix.ld + objcopy (template)
│   ├── link-image-8086.sh.in     # gcc: ld -T fuzix.ld -> fuzix.elf (template)
│   ├── link-image-armm4.sh.in    # gcc/arm: ld --entry=start -T -> fuzix.elf
│   ├── link-image-z8.sh.in       # fcc-raw: ldz8/ldsuper8/ld8070 -> fuzix.bin
│   └── diskimage.sh.in           # bootblock + boot.dsk/drivep.dsk (template)
└── kernel/
    ├── core/       # portable kernel: process, vfs, syscalls, tty, swap, mm.c…
    ├── cpu/
    │   ├── i8080/  # 8080 low-level: context switch, usermem, entry (was cpu-8080)
    │   ├── z80u/   # z80u low-level: normal + thunked variants (was cpu-z80u)
    │   ├── pdp11/  # pdp11 low-level (was cpu-pdp11)
    │   └── i8086/  # 8086 low-level: lowlevel/usermem, kernel-8086.def (was cpu-8086)
    ├── mm/         # memory managers (bankfixed, simple, bank8k, flat, …)
    ├── lib/        # asm helpers: 8080fixedbank / z80ufixedbank (bank switching)
    ├── platform/
    │   ├── v8080/      # board: crt0, main, devtty, memory map, config.h
    │   ├── z80pack/    # board: crt0, main, memory map, config.h
    │   ├── rcbus-8080/ # RC2014 8080 SBC: SCSI/IDE/CH375/RTC, loader, config.h
    │   ├── pdp11/      # DEC PDP-11: crt0, fuzix.ld, RK/RX drivers, config.h
    │   └── ibmpc/      # IBM PC: crt0, fuzix.ld, BIOS disk/con/vid, 8259A, config.h
    ├── dev/           # shared drivers: TinyDisk (ide/scsi), ds1302 RTC, ch375…
    ├── dev/z80pack/   # Z80Pack drivers: devfd (floppy), devtty, devlpr, devrtc
    ├── include/       # kernel headers
    └── tools/         # host tools: makeversion, pack85
```

## Toolchain (cross compilation)

There are several **toolchain kinds**. 
- The 8080/Z80 targets use the **Fuzix Compiler Kit** (`fcc`) + **Fuzix Bintools**; 
- The PDP-11 use standard **gcc** cross toolchains `pdp11-aout-gcc` with a linker script flattens with `objcopy`.
- The 8086 use standard **gcc** cross toolchains `ia16-elf-gcc` and links straight to an ELF.

- https://codeberg.org/EtchedPixels/Fuzix-Compiler-Kit
- https://codeberg.org/EtchedPixels/Fuzix-Bintools

For the fcc targets the linker and C library are **derived from the selected CPU** and the toolchain prefix, so a single fcc toolchain file serves both:

| CPU     | Kind | Compiler     | Linker   | Post-link | C library   |
|---------|------|--------------|----------|-----------|-------------|
| `i8080` | fcc  | `fcc -m8080` | `ld8080` | `pack85`  | `lib8080.a` |
| `i8085` | fcc  | `fcc -m8085` | `ld8080` | `pack85`  | `lib8085.a` |
| `8070`  | fcc  | `fcc -m8070` | `ld8070` | (none)    | `lib8070.a` |
| `z8`    | fcc  | `fcc -mz8`   | `ldz8`   | (none)    | `libz8.a`   |
| `super8`| fcc  | `fcc -msuper8` | `ldsuper8` | (none) | `libsuper8.a` |
| `armm4` | gcc  | `arm-none-eabi-gcc` | `arm-none-eabi-ld --entry=start -T fuzix.ld` | (none, ELF image) | (gcc libc) |
| `z80u`  | fcc  | `fcc -mz80`  | `ldz80`  | `pack85`  | `libz80.a`  |
| `pdp11` | gcc  | `pdp11-aout-gcc` | `pdp11-aout-ld -T fuzix.ld` | `objcopy -O binary` | (gcc libc) |
| `i8086` | gcc  | `ia16-elf-gcc`   | `ia16-elf-ld -T fuzix.ld`   | (none, ELF image)   | (gcc libc) |

The PDP-11 tools are expected on `PATH`; point `-DFUZIX_PDP11_PREFIX=<dir>` at them if they live elsewhere. Use `cmake/toolchain-pdp11.cmake` for that target. The 8086 tools work the same way via `cmake/toolchain-i8086.cmake` and `-DFUZIX_IA16_PREFIX=<dir>`.

The toolchain location is fully configurable via `cmake/toolchain-i8080.cmake` (or its `cmake/toolchain-z80u.cmake` alias). The default install prefix is `./toolchain/fcc`; override it as needed:

```sh
# whole prefix
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake \
      -DFUZIX_TOOLCHAIN_PREFIX=$PWD/toolchain/fcc

# or point at the compiler / linker / libc individually
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake \
      -DFUZIX_CC=/path/fcc -DFUZIX_LD=/path/ld8080 -DFUZIX_LIBC=/path/lib8080.a
```

`FUZIX_TOOLCHAIN_PREFIX` may also be set in the environment.

The host tools (`makeversion`, `pack85`) are compiled with the **host** compiler automatically — no configuration needed.

### Building without the real toolchain (fake toolchain)

The repo ships a **stub toolchain** in [`toolchain/fake/`](toolchain/fake/) so you can exercise the *entire* build graph — every compile, the version generation, the link and the real `pack85`/`dd` steps — on a machine that does **not** have the Fuzix Compiler Kit / Bintools installed. This is useful for verifying the CMake wiring, the module selection flags and the `diskimage` target itself.

It is **not** a real compiler:

- `toolchain/fake/bin/fcc` — creates an empty `<basename>.o` per source (no real code is generated); works for both `-m8080` and `-mz80`.
- `toolchain/fake/bin/ld8080`, `toolchain/fake/bin/ldz80` — write a 40 KB zero image plus a `pack85`-compatible symbol map (they do not actually link).
- `toolchain/fake/bin/asz80` — stub assembler used for the z80pack boot block.
- `toolchain/fake/bin/pdp11-aout-{gcc,ld,objcopy,as}` — stubs for the pdp11 gcc flow (build with `-DFUZIX_PDP11_PREFIX=$PWD/toolchain/fake/bin`).
- `toolchain/fake/bin/ia16-elf-{gcc,ld,objcopy}` — stubs for the 8086 gcc flow (build with `-DFUZIX_IA16_PREFIX=$PWD/toolchain/fake/bin`).
- `toolchain/fake/lib/{8080/lib8080.a,z80/libz80.a}` — empty placeholder archives.

Build with it by pointing `FUZIX_TOOLCHAIN_PREFIX` at the fake tree:

```sh
# i8080 kernel image
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake \
      -DFUZIX_TOOLCHAIN_PREFIX=$PWD/toolchain/fake
cmake --build build
# -> build/image/fuzix.bin        (a dummy image, but the pipeline ran for real)

# z80u kernel image
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-z80u.cmake \
      -DFUZIX_CPU=z80u -DFUZIX_PLATFORM=z80pack \
      -DFUZIX_TOOLCHAIN_PREFIX=$PWD/toolchain/fake
cmake --build build

# boot floppy + root disk (either target)
cmake --build build --target diskimage
# -> build/images/boot.dsk, build/images/drivep.dsk
```

The produced `fuzix.bin` / `boot.dsk` are dummies (filled from the stub tools), but the whole build/link/pack/dd pipeline executes exactly as it would with the real toolchain — so command lines, object ordering, generated headers and image geometry are all verified. See [`toolchain/fake/README.md`](toolchain/fake/README.md) for details.

For a real kernel, install the actual toolchain and point `FUZIX_TOOLCHAIN_PREFIX` at it (default `./toolchain/fcc`) instead.

## Build

```sh
# i8080 / v8080  (defaults)
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake
cmake --build build
# -> build/image/fuzix.bin   (packed, loadable kernel image)

# i8085 / rcbus-8085
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8085.cmake \
      -DFUZIX_CPU=i8085 -DFUZIX_PLATFORM=rcbus-8085
cmake --build build

# 8070 / rcbus-8070   (ld8070 emits fuzix.bin directly, no pack85)
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-8070.cmake \
      -DFUZIX_CPU=8070 -DFUZIX_PLATFORM=rcbus-8070
cmake --build build

# z8 / rcbus-z8   (ldz8 emits fuzix.bin directly, no pack85)
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-z8.cmake \
      -DFUZIX_CPU=z8 -DFUZIX_PLATFORM=rcbus-z8
cmake --build build

# super8 / rcbus-super8   (ldsuper8 emits fuzix.bin directly, no pack85)
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-super8.cmake \
      -DFUZIX_CPU=super8 -DFUZIX_PLATFORM=rcbus-super8
cmake --build build

# armm4 / tm4c129x   (ARM Cortex-M4, arm-none-eabi-gcc -> fuzix.elf)
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-armm4.cmake \
      -DFUZIX_CPU=armm4 -DFUZIX_PLATFORM=tm4c129x \
      -DFUZIX_ARM_PREFIX=$PWD/toolchain/arm-none-eabi/bin
cmake --build build

# 80C188 / rcbus-80c188   (ia16 gcc, build-testing only like ibmpc)
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8086.cmake \
      -DFUZIX_CPU=i8086 -DFUZIX_PLATFORM=rcbus-80c188 \
      -DFUZIX_IA16_PREFIX=<ia16-elf bindir>
cmake --build build

# z80u / z80pack
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-z80u.cmake \
      -DFUZIX_CPU=z80u -DFUZIX_PLATFORM=z80pack
cmake --build build

# pdp11 / pdp11  (gcc toolchain: pdp11-aout-gcc on PATH, or -DFUZIX_PDP11_PREFIX=...)
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-pdp11.cmake \
      -DFUZIX_CPU=pdp11 -DFUZIX_PLATFORM=pdp11
cmake --build build

# i8086 / ibmpc  (gcc toolchain: ia16-elf-gcc on PATH, or -DFUZIX_IA16_PREFIX=...)
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8086.cmake \
      -DFUZIX_CPU=i8086 -DFUZIX_PLATFORM=ibmpc
cmake --build build
# -> build/image/fuzix.elf   (core build only: no loader/drivers yet)
```

CMake prints a configuration summary showing exactly which modules were selected (CPU, platform, linker, memory manager, object count, …).

> Notes to MacOS users. System installed (from command-line-tools) yacc and bison won't work. Installation GNU bison required. Can be obtained from ftp://ftp.gnu.org/gnu/bison

### Build flags

| Option                     | Default     | Meaning |
|----------------------------|-------------|----------------------------------------------|
| `FUZIX_CPU`                | `i8080`     | Target CPU: `i8080`, `i8085`, `8070`, `z8`, `super8`, `z80u`, `pdp11`, `i8086` or `armm4` |
| `FUZIX_PLATFORM`           | `v8080`     | Target board: `v8080`, `rcbus-8080`, `rcbus-8085`, `rcbus-8070`, `rcbus-z8`, `rcbus-super8`, `rcbus-80c188`, `tm4c129x`, `pdp11`, `ibmpc`, or any of the 19 `z80u` boards (`z80pack`, `aqplus`, `nascom`, `z80-mbc2`, … — see ARCHITECTURE.md). The right memory manager / multiprocess default is selected per board, so a bare `-DFUZIX_PLATFORM=<b>` just works. |
| `FUZIX_Z80U_MODE`          | `normal`    | z80u low-level: `normal` (common RAM) or `thunked` |
| `FUZIX_MM`                 | `bankfixed` | Memory manager (see below)                   |
| `FUZIX_MEMALLOC`           | `none`      | User allocator: `none` or `malloc`           |
| `FUZIX_MULTIPROCESS`       | `ON`        | Multiple processes resident (`CONFIG_MULTI`) |
| `FUZIX_FS_NATIVE`          | `ON`        | Native inode/superblock filesystem           |
| `FUZIX_BLOCKSIZE`          | `512`       | Block buffer size: `512` or `400`            |
| `FUZIX_EXECFORMAT`         | `16`        | exec loader: `16`, `32`, `elf32`, `none`     |
| `FUZIX_NET`                | `OFF`       | TCP/IP (BSD sockets)                         |
| `FUZIX_LEVEL2`             | `OFF`       | Level-2 features (sessions/job control)      |
| `FUZIX_SELECT`             | `OFF`       | `select()`/`poll()`                          |
| `FUZIX_VT`                 | `OFF`       | Console video / virtual terminals            |
| `FUZIX_AUDIO`              | `OFF`       | Audio layer                                  |
| `FUZIX_INPUT`              | `OFF`       | Input layer                                  |
| `FUZIX_KMOD`               | `OFF`       | Loadable modules                             |
| `FUZIX_DRIVER_TTY`         | `ON`        | v8080 platform console/serial TTY driver     |
| `FUZIX_DRIVER_Z80PACK_FD`  | `ON`        | Z80Pack virtual floppy block driver          |
| `FUZIX_DRIVER_Z80PACK_TTY` | `ON`        | Z80Pack console/serial TTY (z80pack)         |
| `FUZIX_DRIVER_Z80PACK_LPR` | `ON`        | Z80Pack line printer (z80pack)               |
| `FUZIX_DRIVER_Z80PACK_RTC` | `ON`        | Z80Pack real-time clock (z80pack)            |
| `FUZIX_DRIVER_TINYDISK`    | `ON`        | TinyDisk generic block layer (rcbus-8080)    |
| `FUZIX_DRIVER_IDE`         | `ON`        | IDE / PPIDE disk (rcbus-8080)                |
| `FUZIX_DRIVER_SCSI`        | `ON`        | SCSI disk + NCR5380 (rcbus-8080)             |
| `FUZIX_DRIVER_CH375`       | `ON`        | CH375 USB mass storage (rcbus-8080)          |
| `FUZIX_DRIVER_RTC_DS1302`  | `ON`        | DS1302 real-time clock (rcbus-8080)          |
| `FUZIX_DRIVER_JOYSTICK`    | `ON`        | Joystick + core input layer (rcbus-8080)     |

`FUZIX_Z80U_MODE` picks the Z80 low-level variant: `normal` for boards with common RAM (a region mapped in every bank — the usual case, including `z80pack`), `thunked` for boards where the whole 64K switches at once. See [ARCHITECTURE.md](ARCHITECTURE.md#memory-model--banking) for the banking model in general, and [ZX.md](docs/ZX.md) for the ZX Spectrum / Z80 platform specifics (128K memory map, `CODE1..CODE4` banks, DivIDE/DivMMC, the 32K process limit).

### Memory managers (`FUZIX_MM`)

Each choice selects the matching `mm/*.c` source and the corresponding `CONFIG_*` define:

| Value         | Source             | Define               |
|---------------|--------------------|----------------------|
| `bankfixed`   | `mm/bankfixed.c`   | `CONFIG_BANK_FIXED`  |
| `banksplit`   | `mm/banksplit.c`   | `CONFIG_BANK_FIXED`  |
| `simple`      | `mm/simple.c`      | `CONFIG_SWAP_ONLY`   |
| `bank8k`      | `mm/bank8k.c`      | `CONFIG_BANK8`       |
| `bank16k`     | `mm/bank16k.c`     | `CONFIG_BANK16`      |
| `bank16k_low` | `mm/bank16k_low.c` | `CONFIG_BANK16_LOW`  |
| `bank32k`     | `mm/bank32k.c`     | `CONFIG_BANK32`      |
| `bank16kfc`   | `mm/bank16kfc.c`   | `CONFIG_BANK16FC`    |
| `bank8086`    | `mm/bank8086.c`    | `CONFIG_BANK_8086`   |
| `bank65c816`  | `mm/bank65c816.c`  | `CONFIG_BANK_65C816` |
| `flat`        | `mm/flat.c`        | `CONFIG_FLAT`        |
| `flat_small`  | `mm/flat_small.c`  | `CONFIG_FLAT_SMALL`  |
| `unbanked`    | `mm/unbanked.c`    | —                    |

> The default (`bankfixed`) matches both stock boards (`v8080` and `z80pack`), whose hardware memory maps (`MAP_SIZE`, `PROGTOP`, …) are defined in `kernel/platform/<board>/config.h`. Choosing a manager that does not match the board's hardware map will build but is not expected to run — the flag mechanism is there so new boards/CPUs can drive it.

Example — swap manager + networking, no virtual floppy:

```sh
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake \
      -DFUZIX_MM=simple -DFUZIX_NET=ON -DFUZIX_DRIVER_Z80PACK_FD=OFF
```

## Disk images (`diskimage` target)

Beyond the raw `fuzix.bin` kernel image, a `diskimage` target builds the bootable media, mirroring the selected platform's `diskimage` rule:

```sh
cmake --build build --target diskimage
```

The recipe is **platform-specific** (two styles):

### Boot-floppy style (`v8080`, `z80pack`)

Produces, in `FUZIX_IMAGES_DIR` (default `build/images/`):

- **`boot.dsk`** — a 256256-byte boot floppy (77 tracks × 26 sectors × 128 bytes). The boot sector is assembled from the platform's `bootblock.S`, padded to a full disk, and the kernel is written starting at track 58 (byte offset 193024), skipping the kernel's low load-origin bytes:

| Platform  | Boot assembler        | Kernel skip | Link origin |
|-----------|-----------------------|-------------|-------------|
| `v8080`   | `fcc -m8080 -c` + `ld8080 -b` | 256 bytes | `-C 0x0100 -S 0xE800` |
| `z80pack` | `asz80` + `ldz80 -b`  | 136 bytes | `-C 0x0088 -S 0xF400 -X 0xE900` |

- **`drivep.dsk`** — a 512 MB root hard disk. If a root filesystem image is supplied it is written at offset 0; otherwise the disk is left blank (with a warning).

### IDE-loader style (`rcbus-8080`)

Assembles the platform's `loader.S` (linked high at `0xFE00`), then lays out a single **`disk.img`**: loader at sector 0, kernel at sector 1, root filesystem at sector 2048. A partition-table base image and the filesystem live outside this tree — supply them for a bootable image:

| Option | Default | Meaning |
|---|---|---|
| `FUZIX_PARTTAB` | *(empty)* | Partition-table base image (else a blank 40 MB disk) |
| `FUZIX_FILESYS_IMG` | *(empty)* | Root filesystem written at sector 2048 |

Relevant options:

| Option | Default | Meaning |
|---|---|---|
| `FUZIX_IMAGES_DIR` | `build/images` | Output directory for the disk images |
| `FUZIX_FILESYS_IMG` | *(empty)* | Root filesystem image placed at the start of `drivep.dsk` |

```sh
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake \
      -DFUZIX_FILESYS_IMG=/path/to/filesys.img
cmake --build build --target diskimage
```

> The root filesystem image itself is produced by the FUZIX userland tools (not part of this kernel tree). Point `FUZIX_FILESYS_IMG` at one to get a ready-to-run `drivep.dsk`.
