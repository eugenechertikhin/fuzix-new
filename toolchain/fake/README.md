# Fake i8080 toolchain (for testing the build only)

This is **not** a real compiler. `fcc` and `ld8080` here are stubs that let you
exercise the whole CMake build graph — every compile, the version generation,
the link and the real `pack85` packing step — on a machine that does **not**
have the Fuzix Compiler Kit / Bintools installed.

- `bin/fcc`    — creates an empty `<basename>.o` for each source (no real code).
- `bin/ld8080` — writes a 40K zero `fuzix.raw` + a `pack85`-compatible map.
- `lib/8080/lib8080.a` — empty placeholder archive.

## Usage

```sh
cd ../..            # fuzix-new root
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-i8080.cmake \
      -DFUZIX_TOOLCHAIN_PREFIX=$PWD/toolchain/fake
cmake --build build
# -> build/image/fuzix.bin  (a dummy image, but the pipeline ran for real)
```

For a real kernel build, install the real toolchain and point `FUZIX_TOOLCHAIN_PREFIX` at it (default `./toolchain/fcc`) instead.
