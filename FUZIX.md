# Upstream FUZIX baseline

This project (`fuzix-new`) is a CMake-based rework derived from the upstream
FUZIX tree at `../FUZIX`. This file pins the exact upstream revision the current
port was based on, so future migrations / re-syncs can diff cleanly against a
known point instead of guessing.

## Pinned revision

| Field            | Value                                                                 |
|------------------|-----------------------------------------------------------------------|
| Commit           | `bd684c795f27ddd0f6ad43fff0bbea3370979a28`                            |
| Describe         | `0.5rc1-639-gbd684c795`                                                |
| Date             | 2026-09-27 13:54:55 +0100                                             |
| Subject          | riz180: get it all back working nicely, sort SD, add back Wiznet support |
| Branch           | `master`                                                              |
| Remote           | `origin` → https://codeberg.org/EtchedPixels/FUZIX.git                |
| Nearest tag      | `v0.5rc1`                                                             |

## Notes

- The commit above is **clean** — the 86 files `git status` shows as "modified"
  are **not** real changes. Upstream FUZIX tracks both `crt0.S` and `crt0.s`
  (and commonmem, sdcard, ds1302_6809, …) at **case-colliding paths** — 86
  groups / 172 files. On macOS's case-insensitive filesystem the two variants of
  each pair can't coexist on disk, so one is missing from the worktree and the
  other shows as perpetually "modified". These must **never** be committed
  (doing so would overwrite one case-variant with the other's bytes). Migration
  diffs against the pinned commit are therefore accurate as-is.
- The `.S` blob is always the true source; the `.s` is accidentally-committed
  cpp/preprocessor output. For a faithful full checkout, clone onto a
  case-sensitive APFS volume.
- To fetch and inspect newer upstream work:
  ```sh
  cd ../FUZIX
  git fetch origin
  git log bd684c795f27ddd0f6ad43fff0bbea3370979a28..origin/master --oneline
  ```
- When migrating to a newer upstream revision, update the table above with the
  new pinned commit once the port has been re-synced and verified.
