---
name: phase-audit
description: Audits whether a roadmap phase can actually build and test what it was given - that every requirement, table, and surface it depends on arrives no later than it does. Use after re-sequencing the roadmap, before planning a phase, or when a phase's scope changes.
---

## Current shape
!`grep -E '^\| P[0-9]+ · ' docs/roadmap.md | awk -F'|' '{printf "%-52s %5s h\n", $2, $3}'`

!`bash docs/check.sh | sed -n '/entity first appears/,/phase-audit skill/p'`

## Why this is a skill and not a script

`docs/check.sh` already proves every requirement sits in exactly one phase. What
it cannot prove is that the phase it sits in can build it, and that gap has now
produced four defects in three separate reviews:

| Found | Was |
| --- | --- |
| `FR-JRN-01` | In P2, with a criterion requiring the showcase from P9 |
| `FR-HH-18` | In P5, unpublishing recipes that nothing could publish until P9 |
| `NFR-PERF-03` | In P1, measuring a keystroke in a phase that builds no interface |
| `app_administrators` | Needed by P1's catalog curation, scheduled in P15 |

The obvious mechanical check - flag a requirement naming an entity that arrives
later - was tried and is too noisy to gate on. `NFR-OFF-01` names `Calendar`,
`Pantry`, `GroceryList` and `Cookbook` in P0 and is correct to: it is a standing
rule about the cache layer that applies as each of them arrives. `FR-JRN-01`
names `Invitation` in P2 in order to assert that one never appears. A negative
claim and a premature dependency are indistinguishable to a regular expression.

**And the worst of the four was not a requirement at all.** `app_administrators`
is a table; tables carry no phase, so no amount of requirement-to-phase analysis
would have reached it. It was found by reading a phase and asking what it needed.

## Instructions

Audit one phase at a time. If the user named a phase, audit only that one.
Otherwise walk them in order, and say how many you covered.

For each phase:

1. Read it whole - the description, **Begins when**, **Done when**, and
   **Delivers**. The description is where the work actually is; the delivers
   list is only what it discharges.
2. For each requirement it delivers, ask the operative question: **at the end of
   this phase, could its test run?** Name what the test needs - a table, a
   screen, a role, another requirement's behaviour - rather than judging by feel.
3. For each thing named, find where it arrives. Requirements are in the delivers
   lists. Tables are in [`data.md`](../../../docs/data.md) and carry no phase, so
   infer it from the phase that first writes them. Screens are in
   [`user-interface.md`](../../../docs/user-interface.md), likewise.
4. Now the reverse direction, which is the one that found the worst defect. List
   what this phase **writes** - tables, seed content, curated rows - and for each,
   check that the mechanism permitting the write exists by now. A curated table
   whose only sanctioned writer is a `security definer` function needs that
   function, and the table behind it, in this phase or earlier.
5. Check the entry criteria are real. **Begins when** should name every
   dependency the phase actually has, including the ones that are not phases -
   an answered licence question, a recruited tester pool, a completed enrolment.

Report a table of requirement to what it needs to where that arrives, then the
requirements that cannot be built where they sit, then anything the phase writes
without a sanctioned path to write it.

State how many requirements you walked, so the reader can check it against the
delivers list.

## Distinguishing a defect from a standing rule

Three things look like violations and are not. Say so explicitly rather than
staying silent, so a later run does not re-report them:

- **A standing rule that applies as subjects arrive.** `NFR-OFF-01` in P0.
  Correct where it sits, because the cache is built once.
- **A negative claim.** A requirement naming a thing in order to assert its
  absence needs the thing not to exist.
- **A shell that precedes its content.** Navigation, an empty state, a tab.

The test that separates them: could the phase's own **Done when** be honestly
signed off with the requirement's test passing? A standing rule passes against
what exists so far. A misplaced requirement cannot pass at all.

## Fixing what is found

Only if the user asks. Moving a requirement between phases is an edit to
[`roadmap.md`](../../../docs/roadmap.md) alone - never to `requirements.md`,
which records no release scope, and never a new identifier, because the claim has
not moved. Re-run `docs/check.sh` afterwards: it re-derives every date from the
hours, so a phase gaining or losing work is caught immediately.

Where the fix is work rather than resequencing, it changes the phase's hours and
therefore every date after it. Say so with the new dates rather than leaving them
to be discovered.
