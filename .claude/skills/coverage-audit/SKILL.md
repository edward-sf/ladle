---
name: coverage-audit
description: Audits that every intent bullet in user-experience.md is covered by a numbered requirement in requirements.md. Use after editing either document, or when asked whether requirements coverage is complete.
---

## Current tallies
!`awk '/^#### /{f=substr($0,6)} /^##### Requirements/{r=1;next} /^##### /{r=0} r&&/^- /{c[f]++} END{for(k in c) printf "%-32s %s\n", k, c[k]}' docs/user-experience.md | sort`

!`grep -o '\*\*\(FR\|NFR\)-[A-Z0-9]*-[0-9]*\*\*' docs/requirements.md | tr -d '*' | sed 's/-[0-9]*$//' | sort | uniq -c`

## Why this is a skill and not a script

`user-experience.md` deliberately carries no requirement identifiers, so nothing
automated can detect drift between the two registers. The match is semantic and
has to be made by reading. The first time this audit was actually run it found
**thirteen** missing requirements; a glance at the same documents beforehand had
claimed coverage was complete and named two.

Assume you will find more than you expect. Do not report coverage you have not
enumerated.

## Instructions

Audit one functional area at a time. If the user named a feature or an area,
audit only that one. Otherwise walk every area in the mapping table under
`## Conventions` in `docs/requirements.md`.

For each area:

1. Extract the intent bullets for its feature. Each feature in
   `docs/user-experience.md` has an `##### Requirements` block beneath it; the
   `JRN` area maps to `## User Experience Paths` instead.

       awk '/^#### Recipes and Cookbooks/{f=1;next} /^#### /{f=0} f&&/^##### Requirements/{r=1;next} f&&/^##### /{r=0} r&&/^- /' docs/user-experience.md

2. Read that area's requirements in `docs/requirements.md`.
3. For every bullet, name the requirement ID or IDs that make it testable. The
   relation is many-to-many: one bullet often needs several requirements, and one
   requirement can serve several bullets.
4. Note the reverse direction too. A requirement with no corresponding intent
   bullet is a defect in one of the two documents - either the feature outran its
   description, or the requirement outran its feature. Say which you think it is.

Report a table of bullet to identifiers, then the uncovered bullets, then the
orphaned requirements. State how many bullets you walked, so the reader can check
it against the tally above.

## Writing the missing requirements

Only if the user asks. Follow the conventions in `docs/requirements.md` exactly:

- **Append to the end of the area.** Never insert, never renumber, never reuse a
  retired number.
- **One requirement, one claim.** A statement needing "and" to join two
  independent claims is two requirements.
- Give every one a verification marker - `test`, `ci`, `manual`, `monitor`, or
  `policy`. A commitment that cannot be an automated test must be visibly not one.
- Add *Given / when / then* criteria only where the statement alone does not
  determine the test.
- Never record release scope here. That lives in `docs/roadmap.md`.

A new requirement is unplaced until it appears in exactly one roadmap phase.
Adding one obliges an edit to `docs/roadmap.md` and a re-run of the placement
check.
