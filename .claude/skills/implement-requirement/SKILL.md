---
name: implement-requirement
description: Implements one numbered requirement from requirements.md test-first, tracing it through the data model and closing with a commit that cites it. Use when asked to build, implement, or write the code for an FR- or NFR- identifier.
---

## Instructions

Take one identifier at a time. If the user named several, do them in order and
commit each separately - a commit that implements two requirements cannot be
reverted to undo one of them.

### 1. Read the requirement, not your memory of it

    grep -n -A4 '\*\*FR-PAN-06\*\*' docs/requirements.md

Take the statement, its verification marker, and any *Given / when / then*
criteria. **The marker decides how you finish**, so read it first:

| Marker | What "done" means |
| --- | --- |
| `test` | An automated test in the app suite. Write it before the code. |
| `ci` | A check in the build pipeline, not a product test. |
| `manual` | No code closes it. Add it to the release checklist and say so. |
| `monitor` | An operational measure. Build the measurement, not a pass/fail. |
| `policy` | A standing commitment. Nothing to implement; do not invent a test. |

A `policy` or `manual` requirement handed to you as "implement this" is worth a
sentence back rather than a test that pretends to cover it.

### 2. Find the shape it acts on

`docs/data.md` holds the tables, their columns, and an **RLS** line for each.
Columns that exist to satisfy a requirement cite its identifier, so:

    grep -n 'FR-PAN-06' docs/data.md docs/user-interface.md

That tells you which table, column, or screen the requirement already has a
design for. Build what is written there. If the requirement needs something the
data model does not have, say so before writing code - the model is the thing
that should change first, and `data.md` and the migration move together.

### 3. Write the test first

`requirements.md` exists to guide test-driven development and 185 of its
requirements are marked `test`. Name the test for the identifier so the link
survives:

    test('FR-PAN-06: grocery list category order follows the household sequence', ...)

Where the requirement carries *Given / when / then* criteria, each becomes a
case. Where it carries none, the statement itself is the test - that absence is
deliberate and means the statement is unambiguous, not that it matters less.

Run it. It must fail for the right reason before you write the implementation.

### 4. Implement

Follow the invariants in `CLAUDE.md` - RLS on every user-owned table, the
`service_role` key never in the bundle, schema in migrations rather than the
dashboard, semantic tokens rather than primitives in components. If a migration
is involved, use the `migration` skill; it lands as its own commit, before this
one.

### 5. Commit

Per the commit conventions in `CLAUDE.md`:

```
Added household grocery category ordering

Requirement: FR-PAN-06
Phase: P4
```

Run `docs/check.sh` first if anything under `docs/` changed.

### If the requirement turns out to be wrong

This happens, and the response is specified. A change that could make a
currently-passing test wrong **retires the identifier and issues a new one**;
wording and clarity edits keep theirs. Never edit a cited requirement's meaning
in place. A new identifier is appended to the end of its area, never inserted,
and it must then be placed in exactly one roadmap phase - `docs/check.sh` fails
until it is.
