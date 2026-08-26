---
name: engineering.md
description: This file describes the repository structure, code conventions, testing strategy, continuous integration, and observability for the Ladle application.
---
# Engineering

This document covers how the code is laid out, how it is tested, what runs in
CI, and how the operational measures are taken. It is the counterpart to the
product documents: they say what Ladle does and why, this says how the work of
building it is organised.

It deliberately does not restate two things it would otherwise duplicate.
[`data.md`](./data.md) owns the data tier, the environment partitioning, and the
promotion of migrations from local through staging to production; this document
describes the CI jobs that carry that promotion out, not the promotion itself.
[`user-interface.md`](./user-interface.md) owns the UI tooling and the token
layers.

Nothing here is running yet. Ladle is at the planning stage, and this document
is a set of decisions to build against rather than a description of something
that exists.

## Repository structure

One application, not a monorepo. There is exactly one consumer of this code and
no shared library with a second one, so a workspace tool would be indirection
bought against a need that has not arrived. If an administrative surface ends up
separate from the mobile app — see the open question at the end — that is the
change that would justify revisiting it.

```
app/                    Expo Router routes; the file tree is the navigation
  (tabs)/               Today, Plan, Cookbook, Shop
  _layout.tsx
components/
  ui/                   React Native Reusables, vendored and edited
  <feature>/            components belonging to one feature
lib/
  supabase/             client construction, generated database types
  queries/              TanStack Query hooks, one module per feature
  theme/                the token layers
  format/               rounding, units, dates - shared pure functions
supabase/
  migrations/           timestamped SQL; the only source of schema
  functions/            Edge Functions (Deno)
  tests/                pgTAP tests for constraints and triggers
  seed.sql
tests/
  rls/                  policy tests, one file per table
  helpers/              fixture users, household factories
e2e/                    Maestro flows, one per user experience path
docs/
.claude/skills/
```

Two of these carry a rule rather than a convention.

`supabase/migrations/` is the only place schema is defined. Supabase Studio is
for inspection; a change made there exists in one environment and no other.

`components/ui/` holds vendored code. React Native Reusables is copy-in rather
than installed-from, so those files are ours to edit and are reviewed like any
other source. They are not a dependency that can be upgraded, and they should
not be treated as untouchable because they arrived from elsewhere.

Component tests sit beside their component as `Component.test.tsx`. Tests that
are not about a single module — policy tests, journeys — live in the trees above,
because they belong to a requirement rather than to a file.

## Code conventions

TypeScript in `strict` mode, with `any` disallowed rather than discouraged. The
database types are generated from the live schema and committed
(`NFR-DATA-05`), which only pays off if the compiler is actually able to reject
what no longer matches.

Imports resolve through a single `@/` path alias to the repository root. Relative
paths that climb more than one level are the signal that something is in the
wrong place.

ESLint and Prettier run in CI and are not negotiated in review. Formatting
arguments consume attention that this project, with one developer, does not have
spare.

Naming follows the register of whatever it touches. Database identifiers are
`snake_case` because that is what [`data.md`](./data.md) specifies and what
PostgREST returns; TypeScript is `camelCase`; components are `PascalCase`. The
translation happens at the query layer in `lib/queries/`, in one place, rather
than opportunistically wherever a row is read.

## Testing

187 requirements carry a `test` marker. That number is only meaningful if a
test can be traced to the requirement it discharges, so the tests are organised
by what they prove rather than by what they touch.

### The layers

| Layer | Proves | Runs against |
| --- | --- | --- |
| Unit | Pure logic — rounding, unit conversion, date boundaries, derivation rules | Nothing external |
| Component | A screen or control renders and behaves as specified | React Native Testing Library |
| Policy | A user can read exactly the rows they should and no others | Real Postgres, real JWTs |
| Integration | A query layer hook reads and writes what it claims | Local Supabase stack |
| Journey | An end-to-end path completes | A built app, on a simulator |

The layers are not equally weighted. Most requirements are discharged at the
unit and integration layers. The policy layer is small in volume and carries the
most risk. The journey layer is deliberately thin.

### Policy tests are the ones that matter

`NFR-SEC-01` requires row-level security on every user-owned table, in the same
migration that creates it, and [`data.md`](./data.md) states the consequence
plainly: a table without RLS is a data breach. But a policy that exists is not a
policy that is correct. The failure that actually costs something is a predicate
that is present, syntactically valid, and wrong — and nothing about writing it
reveals that.

So the test that matters is not "does this table have RLS enabled" but "can user
A read user B's rows". That cannot be mocked and cannot be unit tested. It needs
a real database, real policies, and at least two real authenticated users.

Policy tests are written in TypeScript against the local Supabase stack, using
`supabase-js` clients signed in as fixture users. That choice is deliberate over
testing the predicates in SQL alone: the client path is PostgREST plus a JWT
plus a policy, and testing the policy in isolation proves the middle of three
things. A test that signs in and selects is testing what the application
actually does.

`supabase/tests/` holds pgTAP tests as well, for the things SQL expresses better
than TypeScript can — check constraints, generated columns, triggers, and the
partial unique index that enforces one owner per household. Those are assertions
about the database's own integrity rather than about who can see what.

Every table gets a policy test, and this is enforced rather than encouraged. CI
fails a migration that creates a table for which `tests/rls/` holds no
corresponding file. The invariant is stated as absolute in `CLAUDE.md`, so it
should be checkable rather than remembered — the same reasoning that put
requirement placement into `check.sh`.

Each policy test covers four cases at minimum: the owner reads their own row,
a member of the same household reads what their role permits, a member of a
different household reads nothing, and an unauthenticated request reads nothing.
Where a table has a `security definer` path across a user boundary — invitation
acceptance, administrator action on a report — that path gets its own case,
because it is the deliberate exception and therefore the most likely place for
an accidental one.

### The journey tests are already written

`FR-JRN-01` through `FR-JRN-06` state the six user experience paths as
end-to-end claims, with acceptance criteria attached. They are the end-to-end
suite; there is no separate exercise of deciding what to cover. One Maestro flow
per requirement, named for it, and no more than that — end-to-end tests are slow
and brittle in proportion to how many there are, and six paths that each cross
every feature is already good coverage of the joins.

Maestro over Detox: YAML flows, no native build step of its own, and it works
against an EAS build.

### A test names its requirement

A test that discharges a requirement carries its identifier as the first thing
in the test name:

```ts
test('FR-PAN-06: category order follows the household sequence', ...)
```

Where the requirement has *Given / when / then* criteria, each becomes a case.
Where it has none, the statement is the test — that absence is deliberate and
means the statement is unambiguous.

This is what makes the register auditable in the direction that matters. Once
there is a test suite, `check.sh` gains a check that every `test`-marked
requirement is cited by at least one test, and a requirement with no test
becomes a build failure rather than an assumption. Until then the naming
convention is doing that job on trust.

### What is not tested, and why that is written down

A requirement marked `manual`, `monitor`, or `policy` has no automated test by
definition, and inventing one for it is worse than leaving it — a test that
asserts something adjacent to the real commitment reports green while the
commitment goes unmet. The markers exist so that the gap is visible rather than
papered over. The `manual` set is the release checklist; the `policy` set is
kept honest by review.

## Continuous integration

GitHub Actions. Every job below runs on a pull request; the deployment jobs run
only on `main`.

| Job | Does | Discharges |
| --- | --- | --- |
| `docs` | Runs `docs/check.sh` | — |
| `lint` | ESLint, Prettier, `tsc --noEmit` | — |
| `types` | Regenerates database types, fails on any diff | `NFR-DATA-05` |
| `schema` | `supabase db reset` from empty, then pgTAP | `NFR-DATA-04` |
| `rls` | Policy tests; fails on a table with no test file | `NFR-SEC-01` |
| `test` | Unit, component, and integration suites | the `test` set |
| `secrets` | Scans bundle and repository for the `service_role` key | `NFR-SEC-02`, `NFR-SEC-03` |
| `contrast` | Token contrast pairs, per theme, per mode | `NFR-A11Y-02` |
| `journey` | Maestro flows against an EAS build | `FR-JRN-01`–`FR-JRN-06` |

`FR-TAG-21` — retiring a tag remaps every recipe carrying it within the same
migration — is checked by the `schema` job, since the remap and the retirement
are the same migration and a reset proves they run together.

`NFR-OPS-06` requires explicit human approval before a migration reaches
production. That is not a job but a protected GitHub Environment gating the
production step, which is why it cannot be satisfied by a check that a script
could be persuaded to skip. The promotion path itself is described in
[`data.md`](./data.md).

The `journey` job is the slow one and runs on pull requests into `main` rather
than on every push, because a suite that takes long enough to be avoided is a
suite that gets avoided.

## Observability

Four requirements are marked `monitor`, meaning they are watched over time
rather than passed at a point. Each needs somewhere the measurement is actually
taken, or the marker is decoration.

| Requirement | Measures | Taken from |
| --- | --- | --- |
| `FR-MOD-09` | Turnaround per report tier against its target | `reports`, by tier |
| `NFR-OPS-02` | Age of the oldest unresolved report, per tier | `reports` |
| `NFR-OPS-03` | Labelling throughput against unmet tag floors and the release date | `tags.example_count` against per-facet floors |
| `NFR-OPS-04` | Classifier accuracy per facet against a held-out set | the evaluation run |

These are reports, not a dashboard. The audience is one person, and a dashboard
nobody has a reason to open measures nothing. Each is a query against data the
system already holds, surfaced two ways: on an administrator screen, and as a
scheduled digest that arrives whether or not anyone went looking.

The digest is the important half. `NFR-OPS-02` exists because the queue's
failure mode is an administrator who is away, and a measure that requires
someone to check it fails in exactly that case. This is the same reasoning that
put automatic escalation behind `FR-MOD-10`: the system should behave correctly
when nobody is watching, because that is when it matters that there is one
administrator.

Before launch the measure that carries the deadline is `NFR-OPS-03`; afterwards
it is `NFR-OPS-02`. They do not overlap, which is what makes a single reader
viable.

## Open questions

- **Where the administrator's moderation surface lives.** The queue is worked by
  an Application Administrator, who holds no household role and needs a view no
  household member should have. Whether that is a screen inside the mobile app
  gated on `app_administrators`, or a separate minimal web surface, is undecided.
  It affects repository structure, so it is worth settling before P12 rather than
  during it. It does not block P0.
- **Crash and error reporting has no requirement behind it.** Nothing in
  `requirements.md` commits to knowing when the app fails in someone's hands,
  which is an absence rather than a decision. If it is wanted, it belongs in
  `NFR-OPS` with a requirement stating what is collected — Ladle holds health
  data, so a reporting tool's default payload is a privacy question rather than
  a configuration detail.
- **Seed data for a realistic local database.** `supabase db reset` applies
  `seed.sql`, and what that contains determines whether local development
  exercises anything resembling a real household. Related to the ingredient
  catalog seeding in P1, and worth deciding alongside it.
