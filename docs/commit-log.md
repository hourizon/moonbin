# moonbin Commit Log

This document records the purpose and file changes of each effective commit in
the moonbin repository. It is maintained as a project development trace for the
OSC2026 application requirement.

## Commit 1

**Hash:** `f7f9f24`

**Message:** `Initialize MoonBit project structure`

**Purpose:** Initialize a minimal MoonBit package so later work can be developed
as a real project instead of loose notes.

**Changes:**

- Added `.gitignore` for MoonBit build outputs, editor files, and system files.
- Added `README.md` as the GitHub-facing project introduction.
- Added `README.mbt.md` as the MoonBit documentation/example test entry.
- Added `moon.mod` as the module-level MoonBit project configuration.
- Added `moon.pkg` as the package configuration.
- Added `moonbin.mbt` with a minimal public `version()` API.
- Added `moonbin_test.mbt` with a basic version test.

## Commit 2

**Hash:** `8de6ac4`

**Message:** `Add project proposal and planning notes`

**Purpose:** Add the application proposal and early project planning materials
to document the project direction and rationale.

**Changes:**

- Added `moonbin_project_proposal.md` with the project application draft.
- Added `moonbit_moonbin_project_discussion.md` with early discussion notes.

## Commit 3

**Hash:** `f32d3fe`

**Message:** `Remove planning discussion notes`

**Purpose:** Remove the broad discussion document from the public repository and
keep the repository focused on the actual project and application materials.

**Changes:**

- Deleted `moonbit_moonbin_project_discussion.md`.

## Commit 4

**Hash:** `b758968`

**Message:** `Add moonbin binary format specification`

**Purpose:** Define the first version of the moonbin binary format before
implementing the encoder and decoder.

**Changes:**

- Added `docs/format.md`.
- Defined the v1 scope as `BinValue <-> Bytes`.
- Documented the non-goals: no runtime reflection, no schema files, no code
  generation, no protobuf compatibility, and no automatic serialization for
  arbitrary MoonBit structs.
- Defined the `BinValue` data model.
- Defined the general binary layout: `Tag + Payload` and
  `Tag + Length + Value`.
- Defined type tags for Null, Bool, Int, Double, String, Bytes, Array, and
  Object.
- Defined primitive and compound encoding rules.
- Added byte-level examples for Bool, String, Array, and Object.
- Documented decode rules, error model, compatibility rules, and the
  relationship with MoonBit JSON support.

## Commit 5

**Hash:** See `git log` for the final hash of this self-documenting commit.

**Message:** `Add commit history record`

**Purpose:** Add a repository-maintained development trace that records each
effective commit and explains why the commit is meaningful.

**Changes:**

- Added `docs/commit-log.md`.
- Recorded the project initialization commit.
- Recorded the project proposal commit.
- Recorded the cleanup commit that removed the early discussion notes.
- Recorded the binary format specification commit.
- Added a maintenance note for future commit-log updates.

## Maintenance Note

Future effective commits should append a new section to this document with:

- commit hash
- commit message
- purpose
- changed files
- why the commit is meaningful
