# rootloom

Rootloom is a cross-platform mobile application, providing seamless meal planning, nutrition tracking, and pantry management features. Written with React Native, deployed on Expo Application Services, and backed by Supabase Auth/Postgres, Rootloom brings modern solutions to a timeless problem.

## Status

**Planning.** This repository currently holds design documentation, a licence,
and the checking script — there is no application code, no `package.json`, and
no build or test tooling yet. The documents below are complete and internally
consistent, and the roadmap sequences the work that follows from them.

Three releases: the private cookbook, then tagging and discovery, then the public
showcase. Release 1 is the portfolio artifact and lists on Google Play; iOS follows at
Release 2, with the Apple Developer Program bought then rather than a year early.
Release 3 is conditional on there being sustained moderation capacity for it and
may not happen; features beyond Release 2 are listed as planned rather than
promised.

| | Scope | Earliest |
| --- | --- | --- |
| **Release 1** | Everything a household does for itself — cookbook, calendar, pantry, grocery, nutrition | 6 Apr 2027 |
| **Release 2** | The tag classifier, facet search, recommendation — and iOS, with third-party sign-in and passkeys | 24 Jun 2027 |
| **Release 3** | Publishing, copying, and moderation — *conditional on moderation capacity* | 6 Aug 2027 |

Those dates are derived rather than chosen: they fall out of a start date, a
sustained 20h/week, and a planned holiday break applied to per-phase hour
estimates. They carry no buffer and are meant to be the earliest each phase can
finish on a clean run.

## The documents

Each one owns a distinct kind of fact. Where a fact could live in two of them, it
belongs in the one named here and the other references it.

| File | Owns |
| --- | --- |
| [`docs/user-experience.md`](docs/user-experience.md) | Audiences, features, user stories, and end-to-end journeys. Behaviour only. |
| [`docs/data.md`](docs/data.md) | Data tier technology, environment partitioning, and the data model. |
| [`docs/taxonomy.md`](docs/taxonomy.md) | The curated vocabularies — the faceted tag set and the retail ingredient categories. |
| [`docs/user-interface.md`](docs/user-interface.md) | UI tooling, brand identity, layout, and theming. |
| [`docs/requirements.md`](docs/requirements.md) | The numbered, testable requirements that drive development. |
| [`docs/roadmap.md`](docs/roadmap.md) | Sequencing and delivery planning. |
| [`docs/engineering.md`](docs/engineering.md) | Repository structure, testing strategy, CI, and observability. |
| [`docs/privacy.md`](docs/privacy.md) | What personal data Rootloom holds, retention and deletion, and the store disclosures. |
| [`docs/operating-model.md`](docs/operating-model.md) | What Rootloom is for, whether it takes money, and what it costs to run. |

[`CLAUDE.md`](CLAUDE.md) records the product decisions behind all of it, each
with its reasoning and what it costs, so that revisiting one is a deliberate act
rather than a rediscovery.

## How the documents fit together

Requirements are the spine. Each carries a stable identifier (`FR-<AREA>-<NN>` or
`NFR-<ATTRIBUTE>-<NN>`) and a verification marker saying how it is checked —
`test`, `ci`, `manual`, `monitor`, or `policy`. The point of the marker is that a
commitment which cannot be an automated test is visibly not one, rather than
quietly assumed to be covered.

Those identifiers are cited by the data model, the interface spec, and the
roadmap, which is what lets three claims be checked mechanically rather than
asserted:

- every requirement appears in exactly one roadmap phase
- every identifier cited outside `requirements.md` actually exists
- the set of `manual` requirements *is* the release checklist

## Checking the documents

```
docs/check.sh          # all structural checks
docs/check.sh -q       # failures and summary only
```

Eleven deterministic checks — link resolution, identifier sequencing,
verification markers, citation resolution, roadmap placement, area mapping,
emphasis balance, hard-wrap conformance, mermaid fences, schedule re-derivation,
and criterion vocabulary. It exits non-zero on any failure and is the gate for
a commit touching `docs/`.

What it deliberately cannot check is whether a requirement genuinely covers the
intent it claims to. That match is semantic, and `user-experience.md` carries no
identifiers by design — the audit is a reading task, run through the
`coverage-audit` skill in [`.claude/skills/`](.claude/skills/).

To list the release checklist:

```
grep -oE '\*\*(FR|NFR)-[A-Z0-9]+-[0-9]+\*\* `manual`' docs/requirements.md
```

## Planned commands

None of these run yet; they are the intended workflow, described in
[`docs/data.md`](docs/data.md).

```
supabase start                    # full local stack in Docker
supabase db reset                 # drop, replay every migration, apply seed.sql
supabase migration new <name>     # scaffold a timestamped SQL migration
supabase branches create <name>   # provision a preview branch from the chain
supabase branches list            # what is running, and for how long
supabase branches delete <name>   # destroy it when the candidate ships
supabase gen types typescript     # regenerate client types from the live schema
supabase functions deploy         # deploy Edge Functions
```

## Licence

[PolyForm Noncommercial 1.0.0](LICENSE). Read it, run it, change it, share it —
for any noncommercial purpose. Commercial rights are reserved.

The choice follows from what this repository is for. Rootloom is a portfolio and
craft project, and the documents are as much the artifact as the code will be, so
being readable is most of the point. Reserving the commercial side costs a reader
nothing and keeps a door open that would be expensive to reopen later.

One boundary is planned and does not exist yet: the classifier's labelled corpus
and training pipeline will live in a separate private repository from P11, for
reasons set out in
[`docs/engineering.md`](docs/engineering.md#the-corpus-repository). Everything
that runs on a phone or in the database is here.

## Security

Reporting is described in [`SECURITY.md`](SECURITY.md). There is nothing
deployed yet, so the useful reports right now are about the design rather than a
running system.

## Contributing

Commit conventions, cadence, and branching are in
[`CLAUDE.md`](CLAUDE.md#commit-conventions). In short: a past-tense subject
naming the artifact, a body explaining why, and a `Requirement:` trailer citing
every identifier the commit touches.
