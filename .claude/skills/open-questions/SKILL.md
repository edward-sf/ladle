---
name: open-questions
description: Audits a planning document for decisions that are still open, puts them to the author, and propagates the answers across every document they touch. Use when asked to address Open Questions or to review a doc for gaps before building it out.
---

## The documents
!`ls -1 docs/*.md && echo "---" && wc -l CLAUDE.md docs/*.md`

## Instructions

Work on the document the user named. Read it, read `CLAUDE.md`, and read whatever
it cross-references, because most answers land in more than one file.

### 1. Audit

Find decisions the document depends on but has not made. A genuine gap is one that
would change what gets built or lets two documents disagree - not a wording
preference, not a section that is merely short.

**Verify rather than assert.** Anything checkable, check by running something.
Counts, identifier sequences, whether a cited requirement exists, whether a link
resolves, whether a contrast ratio passes. Claims made from memory here have been
wrong more often than they have been right, and each one was found later by a
command that took a few seconds to write.

### 2. Surface before asking

State what you found in prose first - the concerns, the conflicts between
documents, anything you think is a defect. The author may redirect, or answer
half of it outright, and neither is possible once the questions are already on
screen.

### 3. Ask

Use `AskUserQuestion`. Put the recommended option first and mark it
`(Recommended)`. Give each option its **cost**, not just its benefit - the
decisions in `CLAUDE.md` that have held up are the ones recorded with what they
rule out. Expect to be overruled; several of the load-bearing choices here were
made against the recommendation.

### 4. Propagate

An answer is rarely confined to the document being edited. Before reporting
finished, check each one that could be affected:

| If the answer touches | Then check |
| --- | --- |
| behaviour or a feature | `docs/user-experience.md`, then `docs/requirements.md` |
| an entity, field, or relationship | `docs/data.md` |
| a tag, facet, or threshold | `docs/taxonomy.md` |
| a screen, token, or interaction | `docs/user-interface.md` |
| anything with a new requirement | `docs/roadmap.md` - it must land in exactly one phase |
| the reasoning behind the choice | `CLAUDE.md`, Product decisions |

Respect each file's conventions: `data.md`, `taxonomy.md` and
`user-interface.md` hard-wrap at roughly 80 columns; `user-experience.md` and
`requirements.md` do not. Role and state names inside an italic feature
description are written plain - nested emphasis terminates the span early and
breaks rendering.

### 5. Record the reasoning, not just the choice

Add the decision to **Product decisions** in `CLAUDE.md`: what was chosen, why,
and what it costs or forecloses. The point is that revisiting one later is a
deliberate act rather than a rediscovery.

If the answer changed intent prose to match a decision rather than the other way
round, say so explicitly in your report. That direction is sometimes right and
always worth the author seeing.

### 6. Re-verify and close

Re-run whatever the change could have broken. Delete the Open Questions section
when it empties rather than leaving an empty heading, and update any reference to
it elsewhere.
