#!/usr/bin/env python3
"""
configure.py - interactive CMake configuration generator for fuzix-new.

A console/CLI menu (questionary) that walks you through the build options
declared in CMakeLists.txt (CPU, platform, board config, memory manager,
filesystem, kernel subsystems, device drivers, disk-image paths) and emits the
matching `cmake -S . -B <build> -D...` command. It can print, copy, save, or
run it directly.

Design notes
------------
* Options are parsed live from CMakeLists.txt, so new `option()` /
  `set(... CACHE ...)` entries show up automatically without touching this file.
* Only values you actually change from the CMake default are emitted as -D
  flags, so the command stays minimal and computed defaults (memory manager,
  multiprocess, ...) are left for CMake to resolve per platform.
* CPU/platform/config come from globbing cmake/ and configs/, so the choice
  lists never fall behind the tree. The only thing not machine-readable is which
  platform belongs to which CPU; that lives in PLATFORM_CPU below (with a
  fallback so an unmapped new port still appears).

Requires: python3, `pip install questionary`
Usage:    ./configure.py         (from the repo root)
"""

import os
import re
import shlex
import subprocess
import sys
from pathlib import Path

try:
    import questionary
    from questionary import Choice
except ImportError:
    sys.exit(
        "This tool needs the 'questionary' package.\n"
        "  install it with:  pip install questionary\n"
    )

ROOT = Path(__file__).resolve().parent
CMAKELISTS = ROOT / "CMakeLists.txt"

# ---------------------------------------------------------------------------
# platform -> CPU grouping (the one relationship not encoded in the CMake tree).
# Keep in sync when porting a new board; unmapped platform-*.cmake files still
# appear in the menu (flagged) so nothing silently disappears.
# ---------------------------------------------------------------------------
PLATFORM_CPU = {
    "i8080": ["v8080", "rcbus-8080"],
    "z80u": [
        "z80pack", "aqplus", "challengeriii", "lobo-max80", "nascom",
        "nano-z80", "rc2014-tiny", "rcbus-tp128", "sbcv2", "sbc2g", "sc720",
        "z80membership", "z1013", "zrc", "z80all", "z80-mbc2", "z80retro",
        "searle", "tomssbc", "simple80",
    ],
    "pdp11": ["pdp11"],
    "i8086": ["ibmpc"],
}


# ---------------------------------------------------------------------------
# Parse CMakeLists.txt for cache options.
# ---------------------------------------------------------------------------
class Opt:
    """A single build option pulled from CMakeLists.txt."""

    def __init__(self, name, kind, default, doc="", choices=None):
        self.name = name          # e.g. FUZIX_MM
        self.kind = kind          # "bool" | "choice" | "string" | "path"
        self.default = default    # literal default, or None if computed (${...})
        self.doc = doc
        self.choices = choices or []


def parse_cmake_options(text):
    opts = {}

    # option(NAME "doc" VALUE)
    for m in re.finditer(r'option\(\s*(\w+)\s+"([^"]*)"\s+(\S+?)\s*\)', text):
        name, doc, val = m.group(1), m.group(2), m.group(3)
        if val in ("ON", "OFF"):
            default = (val == "ON")
        else:
            default = None  # computed default (${_mp_default} etc.)
        opts[name] = Opt(name, "bool", default, doc)

    # set(NAME "default" CACHE <TYPE> "doc")
    set_re = re.compile(
        r'set\(\s*(\w+)\s+("(?:[^"\\]|\\.)*"|\S+)\s+CACHE\s+'
        r'(STRING|BOOL|PATH|FILEPATH)\s+"([^"]*)"',
        re.MULTILINE,
    )
    for m in set_re.finditer(text):
        name, raw_default, ctype, doc = m.groups()
        default = raw_default.strip('"')
        if default.startswith("${") or "${" in default:
            default = None  # computed
        kind = {"STRING": "string", "BOOL": "bool",
                "PATH": "path", "FILEPATH": "path"}[ctype]
        if kind == "bool":
            default = (default == "ON") if default is not None else None
        opts[name] = Opt(name, kind, default, doc)

    # set_property(CACHE NAME PROPERTY STRINGS a b c ...)  -> turns into a choice.
    # The value list may span multiple lines and contain comments.
    prop_re = re.compile(
        r'set_property\(\s*CACHE\s+(\w+)\s+PROPERTY\s+STRINGS(.*?)\)',
        re.DOTALL,
    )
    for m in prop_re.finditer(text):
        name, body = m.group(1), m.group(2)
        # strip inline comments, collapse whitespace, drop ${...} expansions
        body = re.sub(r"#[^\n]*", " ", body)
        toks = [t for t in body.split() if not t.startswith("${")]
        if name in opts and toks:
            opts[name].kind = "choice"
            opts[name].choices = toks
    return opts


def glob_names(directory, pattern, prefix):
    """cmake/cpu-*.cmake -> ['i8080', ...] (strip prefix + .cmake)."""
    out = []
    for p in sorted((ROOT / directory).glob(pattern)):
        stem = p.name[:-len(".cmake")] if p.name.endswith(".cmake") else p.name
        if stem.startswith(prefix):
            out.append(stem[len(prefix):])
    return out


# ---------------------------------------------------------------------------
# Interactive flow.
# ---------------------------------------------------------------------------
def ask(fn, *a, **kw):
    """Wrap a questionary prompt; treat Ctrl-C / ESC as 'abort'."""
    res = fn(*a, **kw).ask()
    if res is None:
        print("\nAborted.")
        sys.exit(1)
    return res


def platforms_for_cpu(cpu, all_platforms):
    mapped = PLATFORM_CPU.get(cpu, [])
    known = {p for lst in PLATFORM_CPU.values() for p in lst}
    unmapped = [p for p in all_platforms if p not in known]
    choices = [Choice(p, value=p) for p in mapped if p in all_platforms]
    for p in unmapped:  # new ports not yet in PLATFORM_CPU
        choices.append(Choice(f"{p}  (unmapped port)", value=p))
    return choices or [Choice(p, value=p) for p in all_platforms]


def choice_prompt(opt):
    label = f"{opt.name}  ({opt.doc})" if opt.doc else opt.name
    choices = []
    for c in opt.choices:
        tag = "  [default]" if c == opt.default else ""
        choices.append(Choice(f"{c}{tag}", value=c))
    default_val = opt.default if opt.default in opt.choices else opt.choices[0]
    return ask(questionary.select, label, choices=choices, default=default_val)


def main():
    if not CMAKELISTS.exists():
        sys.exit(f"CMakeLists.txt not found next to {__file__}. Run from repo root.")

    text = CMAKELISTS.read_text()
    opts = parse_cmake_options(text)

    cpus = glob_names("cmake", "cpu-*.cmake", "cpu-")
    platforms = glob_names("cmake", "platform-*.cmake", "platform-")
    configs = glob_names("configs", "*.cmake", "")

    print("\n  fuzix-new  ::  interactive CMake configurator\n")

    flags = {}   # -D NAME=VALUE  (only what differs from CMake defaults)

    # 1. CPU -> toolchain file
    cpu = ask(questionary.select, "Target CPU:",
              choices=[Choice(c, value=c) for c in cpus])
    toolchain = ROOT / "cmake" / f"toolchain-{cpu}.cmake"
    flags["FUZIX_CPU"] = cpu

    # 2. Platform (filtered by CPU)
    platform = ask(questionary.select, f"Target platform (CPU={cpu}):",
                   choices=platforms_for_cpu(cpu, platforms))
    flags["FUZIX_PLATFORM"] = platform

    # 3. Board config
    default_cfg = "default" if "default" in configs else configs[0]
    config = ask(questionary.select, "Board config (configs/<name>.cmake):",
                 choices=[Choice(c, value=c) for c in configs],
                 default=default_cfg)
    if config != "default":
        flags["FUZIX_CONFIG"] = config

    # 4. Build directory
    build_dir = ask(questionary.text, "Build directory:",
                    default=f"build-{cpu}-{platform}")

    # 5. Advanced options?
    if questionary.confirm(
        "Customise advanced options (memory manager, filesystem, subsystems, "
        "drivers, image paths)?  [No -> use per-platform defaults]",
        default=False,
    ).ask():
        advanced_menu(opts, flags)

    # 6. Assemble and act.
    cmd = build_command(build_dir, toolchain, flags)
    finish(cmd, build_dir)


# Options handled explicitly by the primary flow; hide them from advanced menu.
PRIMARY = {"FUZIX_CPU", "FUZIX_PLATFORM", "FUZIX_CONFIG"}


def advanced_menu(opts, flags):
    # Bucket the remaining options into readable groups.
    groups = {
        "Memory manager": ["FUZIX_MM", "FUZIX_MEMALLOC", "FUZIX_MULTIPROCESS"],
        "Filesystem / exec": ["FUZIX_FS_NATIVE", "FUZIX_BLOCKSIZE", "FUZIX_EXECFORMAT"],
    }
    placed = set(PRIMARY)
    for names in groups.values():
        placed.update(names)

    subsystems = [n for n in opts if n.startswith("FUZIX_")
                  and opts[n].kind == "bool" and n not in placed
                  and not n.startswith("FUZIX_DRIVER_")]
    drivers = [n for n in opts if n.startswith("FUZIX_DRIVER_")]
    paths = [n for n in opts if opts[n].kind in ("string", "path")
             and n not in placed and n not in ("FUZIX_VERSION", "FUZIX_SUBVERSION")]

    while True:
        section = ask(questionary.select, "Advanced section (Done to finish):",
                      choices=[
                          Choice("Memory manager", value="Memory manager"),
                          Choice("Filesystem / exec", value="Filesystem / exec"),
                          Choice("Kernel subsystems (net, vt, select, ...)", value="subsys"),
                          Choice("Device drivers", value="drivers"),
                          Choice("Image / paths", value="paths"),
                          Choice("── Done ──", value="done"),
                      ])
        if section == "done":
            return
        if section in groups:
            for name in groups[section]:
                if name in opts:
                    edit_scalar(opts[name], flags)
        elif section == "subsys":
            edit_bool_set(opts, subsystems, flags, "Enable kernel subsystems:")
        elif section == "drivers":
            edit_bool_set(opts, drivers, flags, "Enable device drivers:")
        elif section == "paths":
            for name in paths:
                edit_path(opts[name], flags)


def edit_scalar(opt, flags):
    if opt.kind == "choice":
        val = choice_prompt(opt)
        set_if_changed(flags, opt, val)
    elif opt.kind == "bool":
        cur = opt.default if opt.default is not None else False
        val = questionary.confirm(f"{opt.name}  ({opt.doc})", default=bool(cur)).ask()
        if val is not None:
            set_if_changed(flags, opt, "ON" if val else "OFF",
                           bool_default=opt.default)
    else:
        edit_path(opt, flags)


def edit_path(opt, flags):
    default = opt.default or ""
    val = questionary.text(f"{opt.name}  ({opt.doc})", default=default).ask()
    if val is None:
        return
    val = val.strip()
    if val and val != default:
        flags[opt.name] = val


def edit_bool_set(opts, names, flags, title):
    if not names:
        return
    choices = []
    for n in names:
        o = opts[n]
        checked = bool(o.default) if o.default is not None else False
        # reflect any prior override
        if n in flags:
            checked = flags[n] == "ON"
        choices.append(Choice(f"{n[len('FUZIX_'):]}  ({o.doc})",
                              value=n, checked=checked))
    selected = questionary.checkbox(title, choices=choices).ask()
    if selected is None:
        return
    sel = set(selected)
    for n in names:
        want_on = n in sel
        default_on = bool(opts[n].default) if opts[n].default is not None else False
        if want_on != default_on:
            flags[n] = "ON" if want_on else "OFF"
        else:
            flags.pop(n, None)  # back to default -> don't emit


def set_if_changed(flags, opt, value, bool_default=None):
    ref = bool_default if bool_default is not None else opt.default
    if opt.kind == "bool":
        ref = "ON" if ref else "OFF" if ref is not None else None
    if ref is None or str(value) != str(ref):
        flags[opt.name] = value
    else:
        flags.pop(opt.name, None)


# ---------------------------------------------------------------------------
# Command assembly + final action.
# ---------------------------------------------------------------------------
def build_command(build_dir, toolchain, flags):
    parts = ["cmake", "-S", ".", "-B", shlex.quote(build_dir),
             f"-DCMAKE_TOOLCHAIN_FILE={_rel(toolchain)}"]
    for name in sorted(flags):
        parts.append(f"-D{name}={shlex.quote(str(flags[name]))}")
    return parts


def _rel(p):
    try:
        return str(Path(p).relative_to(ROOT))
    except ValueError:
        return str(p)


def finish(cmd, build_dir):
    pretty = " \\\n    ".join(_group(cmd))
    print("\n" + "=" * 70)
    print("Generated configure command:\n")
    print("  " + pretty)
    print("=" * 70 + "\n")

    action = ask(questionary.select, "What now?", choices=[
        Choice("Run it now (cmake configure)", value="run"),
        Choice("Run configure + build", value="build"),
        Choice("Save to configure.sh", value="save"),
        Choice("Just print (done)", value="print"),
    ])

    line = " ".join(cmd)
    if action == "print":
        return
    if action == "save":
        out = ROOT / "configure.sh"
        out.write_text("#!/bin/sh\nset -e\n" + line + "\n")
        out.chmod(0o755)
        print(f"Wrote {out}")
        return
    print(f"\n$ {line}\n")
    rc = subprocess.call(cmd, cwd=ROOT)
    if rc != 0:
        sys.exit(f"cmake configure failed (exit {rc})")
    if action == "build":
        bcmd = ["cmake", "--build", build_dir]
        print(f"\n$ {' '.join(bcmd)}\n")
        sys.exit(subprocess.call(bcmd, cwd=ROOT))


def _group(cmd):
    """Group tokens so -S . and -B dir stay on their intro line, one -D per line."""
    out, i = [], 0
    lead = []
    while i < len(cmd) and not cmd[i].startswith("-D"):
        lead.append(cmd[i])
        i += 1
    out.append(" ".join(lead))
    out.extend(cmd[i:])
    return out


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nAborted.")
        sys.exit(1)
