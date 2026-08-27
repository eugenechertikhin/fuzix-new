#!/usr/bin/env python3
# Portable GNU-format `ar` for building the Fuzix Compiler Kit on hosts whose
# system ar cannot archive foreign object formats.
#
# Apple's /usr/bin/ar (and llvm-ar) refuse to add anything that is not a Mach-O
# object, so they silently drop the custom-format fcc/ld target objects and
# leave every lib<cpu>.a empty. This stand-in writes a real GNU-format archive
# of whatever members it is handed, which the fcc linkers (ld<cpu>) read back.
#
# It implements the forms the kit uses: r/c/q (+ modifiers) to build/append and
# t to list. Archive members are pre-ordered by lorder<cpu>|tsort, so no symbol
# index is emitted (the single-pass fcc linkers rely on member order, not on a
# ranlib index). On a host with GNU ar this shim is unnecessary but harmless.
import sys, os

args = sys.argv[1:]
if not args:
    sys.exit("ar: no operation")
op = args[0].lstrip('-')
mods = set(op)

def pad(b):
    return b + (b'\n' if len(b) % 2 else b'')

def read_members(path):
    """Yield (name, data) for each member of an existing archive, or nothing."""
    try:
        with open(path, 'rb') as f:
            blob = f.read()
    except OSError:
        return
    if blob[:8] != b'!<arch>\n':
        return
    i = 8
    while i + 60 <= len(blob):
        hdr = blob[i:i + 60]
        name = hdr[0:16].decode('latin-1').rstrip()
        if name.endswith('/'):
            name = name[:-1]
        size = int(hdr[48:58].decode('latin-1').strip() or '0')
        i += 60
        data = blob[i:i + size]
        i += size + (size & 1)
        yield name, data

def write_archive(path, members):
    with open(path, 'wb') as out:
        out.write(b'!<arch>\n')
        for name, data in members:
            nm = name if len(name) <= 15 else name[:15]
            out.write(("%-16s%-12d%-6d%-6d%-8o%-10d`\n"
                       % (nm + '/', 0, 0, 0, 0o644, len(data))).encode('latin-1'))
            out.write(pad(data))

if not (mods <= set('rcqstuvTloab') and mods & set('rcqst')):
    sys.exit("ar: unsupported operation '%s'" % args[0])

archive = args[1]

# List members and exit.
if 't' in mods:
    for name, _ in read_members(archive):
        print(name)
    sys.exit(0)

# q (quick append) and c (create) append every member verbatim, keeping
# duplicate basenames (the 8080/z80 libs pull _10.o from several subdirs). Only
# r (replace) deduplicates by name. The kit removes the archive before a fresh
# build, so a bare qc/cr effectively starts empty.
members = list(read_members(archive)) if 'r' in mods else []
dedup = 'r' in mods

for m in args[2:]:
    try:
        with open(m, 'rb') as f:
            data = f.read()
    except OSError as e:
        sys.exit("ar: %s" % e)
    name = os.path.basename(m)
    if dedup:
        for idx, (n, _) in enumerate(members):
            if n == name:
                members[idx] = (name, data)
                break
        else:
            members.append((name, data))
    else:
        members.append((name, data))

write_archive(archive, members)
