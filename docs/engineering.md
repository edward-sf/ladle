--- name: engineering.md description: This file describes the repository
structure, code conventions, testing strategy, continuous integration, and
observability for the Rootloom application. ---
# Engineering

This document covers how the code is laid out, how it is tested, what runs in
CI, and how the operational measures are taken. It is the counterpart to the
product documents: they say what Rootloom does and why, this says how the work
of building it is organised.

It deliberately does not restate two things it would otherwise duplicate.
[`data.md`](./data.md) owns the data tier, the environment partitioning, and the
promotion of migrations from local through a preview branch to production; this
document describes the CI jobs that carry that promotion out, not the promotion
itself.
[`user-interface.md`](./user-interface.md) owns the UI tooling and the token
layers.

Nothing here is running yet. Rootloom is at the planning stage, and this
document is a set of decisions to build against rather than a description of
something that exists.

## Repository structure

One application and one internal tool, not a monorepo. There is exactly one
consumer of the application code and no shared library, so a workspace tool would
be indirection bought against a need that has not arrived.

That repository is **public**, under a noncommercial source-available licence, and
it holds everything below including the planning documents — which are part of
what is being demonstrated rather than support material for it. A second, private
repository arrives at P11 and holds the classifier corpus. Why that boundary
exists, and why it is the only one, is in *The corpus repository* below.

The internal tool is the Application Administrator's surface, and it is
deliberately not part of the app. It is **local-only** — run on the
administrator's own machine, against the database as their own authenticated
user, never publicly deployed — which is what keeps it a directory with a build
rather than a second product. It shares no packages with the app; anything it
needs, it has its own copy of.

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
admin/                  the Application Administrator's tool - local only
  catalog/              ingredient curation and approval
  labelling/            the corpus labelling surface
  moderation/           the report queue
scripts/                branch provisioning and teardown; import and export
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

### The administrator tool

The Application Administrator has work in three phases, and only the last of them
is moderation. P1 curates the ingredient catalog, P11 labels roughly 1,250
recipes across 150 tags, and P14 works the report queue. The first is bulk
one-time work and runs through `scripts/` and a spreadsheet; the other two need
an interface.

**It is separate from the app because the work is desk work.** Labelling a
thousand recipes and curating thousands of ingredients is keyboard-and-wide-screen
work with bulk operations, and the application is deliberately phone-first, one
column, portrait — a scope decision resting on claims about a phone in a hand.
Admin tooling in that form factor fights the design rather than reusing it. It
also keeps admin code out of every user's bundle.

**It is local-only.** It has no public deployment, no hosting cost, and no
sign-up. That is what makes a second surface cheap enough to be the right answer
rather than an indulgence.

**It acts through `security definer` functions, exactly as the app would.** Not
`service_role`, and not Supabase Studio. `CLAUDE.md` records that administrator
actions run through those functions so that each stays attributable to a person,
and Studio bypasses precisely that — which makes Studio fine for looking and
wrong for ruling.

It grows one section per phase rather than arriving whole, and the scaffold is
built in P11 with the labelling surface that first needs it.

### The corpus repository

The labelled corpus and the training pipeline live in a second, private
repository created at P11. It is the only boundary of its kind in the project,
and the case for it does not rest on privacy.

**It would earn a repository even if everything were public.** The toolchain is
different — training and evaluation are not React Native. The cadence is
different: the model is retrained on its own schedule, and `FR-TAG-11` puts
classification server-side precisely so it can be swapped without an app release.
The trained weights are large binaries that version control handles badly - the
corpus text is not, and the boundary was never about size. And the inputs carry
licence terms that need their own provenance records, which is a filing
obligation the application repository has no reason to take on. A boundary
justified only by secrecy erodes, because every individual exception to it looks
harmless; this one stands on grounds that do not depend on who is looking.

**It is not a service.** The private repository produces an artifact on a slow
cadence and nothing calls it at request time — it is closer to a compiler than
to a component of the running system. Rootloom has no application tier to
decompose: the client queries PostgREST directly and RLS is the authorization
model, so any process holding elevated rights and re-implementing authorization
would create a second one, and the policy tests in `tests/rls/` would then prove
only half of what they claim to. The runtime topology does not change when the
second repository appears.

**The seam is narrow and the vocabulary is the contract.** Recipe text goes to
inference and facet tags come back, drawn from the closed vocabulary in
[`taxonomy.md`](./taxonomy.md), which stays canonical in the public repository.
An Edge Function makes the call; the app never talks to inference directly.

**Dormancy is filtered at serving time, not trained in.** A dormant tag is one
below its per-facet floor, and the model must never emit one. That rule is
enforced in the Edge Function against the activation state the database already
holds, rather than by training a model that knows which tags are dormant. Two
reasons: activation is retroactive, so a tag qualifying must take effect without
a retraining pass, and the state belongs to the same table the labelling
throughput measure reads. A model that encoded dormancy would make every
activation a training job.

**Requirement identifiers stay global.** The register in
[`requirements.md`](./requirements.md) is not split — the private repository
implements requirements it does not own, and a commit there cites `FR-TAG-11` the
same way a commit here would. This is what keeps `git log --grep` meaningful
across the boundary, and it is why the split costs the traceability convention
nothing.

**The corpus is files, not rows.** One file per recipe, plus a manifest carrying
the source each was drawn from, the licence that source carries, and when it was
retrieved (`FR-TAG-33`). It is a few megabytes of text, so the question was never
storage; it was which properties the store gives away for free.

Three of them decide it. Training pins to a revision, so every model traces to
the exact corpus that produced it (`NFR-OPS-14`) - the same reproducibility
`NFR-DATA-04` demands of the schema, applied to the other input that determines
what ships. The licence obligation in `FR-TAG-25` is a filing obligation, and a
misread licence has to become a reviewable deletion with history rather than an
`UPDATE` nobody sees. And a label correction is a judgement worth reading, which
a diff shows and a row does not.

Against that, a database would buy ad-hoc querying the labelling surface does
not need at this size - it loads the corpus and indexes it in memory - and would
cost either a second database to run or, if it went in the Rootloom schema, a
table under RLS, in the migration chain, and owed a policy test, for data no
user will ever read.

**One thing crosses from the corpus to the product, and it is a number.** Per-tag
example counts and per-facet floors are published into `tags.example_count` and
`tag_facet_floors`, where `tags.is_active` is generated from them
(`FR-TAG-15`). Dormancy is therefore derived from the corpus without the corpus
being reachable from the application at all.

**The labelling surface stays in `admin/labelling/`** and reads the corpus from a
configured path rather than moving to the private repository with it. It is
local-only, so a sibling checkout is unremarkable, and it already holds the
authenticated path to production that publishing those counts needs. Labelling
itself needs no session: it edits files.

**Backfill runs here; online classification does not.** A retraining pass
reclassifies every existing recipe (`FR-TAG-18`) and activates whatever has
reached its floor (`FR-TAG-19`), and both run as a batch from this repository on
the administrator's machine, writing through the administrator's authenticated
path. Classifying a recipe as it is saved is the other half and runs in an Edge
Function (`FR-TAG-11`), so the model can be replaced without shipping an app.
[`operating-model.md`](./operating-model.md) records why the split falls there,
and it is a cost argument rather than an architectural one.

**It is created at P11, not before.** There is no corpus yet, and an empty
repository is the same indirection the top of this section already declined.


## Toolchain

A pin nobody can name is not a pin. [`data.md`](./data.md) lists version pinning
as the first mitigation for local/hosted drift; this is where the versions
actually live.

| What | Version | Where the pin lives |
| --- | --- | --- |
| Expo SDK | 57 | the `expo` dependency in `package.json` |
| React Native | 0.86 | implied by the SDK, never set independently |
| Node | 22.13 or later | `.nvmrc`, `engines`, and the CI setup step |
| Supabase CLI | 2.116.0 | a devDependency, so CI and local run the same binary |
| TypeScript | whatever the SDK 57 template ships | recorded here once P0 instantiates it |
| Package manager | npm | the lockfile is committed |
| Python | 3.12 | the CI workflow; `check.sh` needs it and nothing else does |

**React Native is not a choice.** It follows the Expo SDK, and the row above
states what SDK 57 implies rather than a second decision. Upgrading it on its own
is one of the more reliable ways to break an Expo project.

TypeScript is left unpinned until P0 rather than guessed at. The current release
is a major version ahead of what the SDK 57 template is likely to target, and
recording a number here that the template then contradicts would be worse than
recording none.

### One SDK for all of Release 1

Expo ships roughly three SDKs a year and React Native six, so one or two SDKs
will land between P0 and submission. They are deliberately skipped. Upgrades
happen at phase boundaries, never inside one, and Release 1 runs start to finish
on SDK 57.

The reason is the schedule rather than caution. It carries no buffer, so an
upgrade dropped into a phase is unestimated work in a plan with nowhere to absorb
it. And P10 measures every P95 latency target on reference devices rather than
assuming it — a measurement worth taking on the toolchain that ships, not on one
the next SDK has since replaced.

**The stores are the one thing that can override this.** Apple and Google both
raise the platform requirements a submitted build has to meet, on their schedule
rather than Rootloom's, and an SDK upgrade is usually how an Expo app meets
them. No date is stated here because it moves; the point is that it is checked
before P10 plans its work rather than discovered in a rejection notice.
`NFR-OPS-15` keeps the pins honest in the meantime, because a pin that only
exists in prose drifts the first time somebody's machine disagrees with it.

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

## Data for development, testing, and demonstration

Three different needs that look like one, and conflating them produces data that
serves none of them well.

**`seed.sql` is for local development, and it should be ugly.** Its job is to
make every screen reachable and every awkward path exercisable without twenty
minutes of clicking: a photoless recipe, an ingredient not yet reconciled with
the catalog, a household of four including a child with no account and a
recorded allergy, a meal whose participants have conflicting dietary
requirements, an empty pantry beside a full grocery list. Attractive data hides
exactly the states that need looking at. All of it is synthetic, per the
invariant that no production data ever flows the other way.

**Tests build their own fixtures and do not read `seed.sql`.** A test asserting
on three recipes becomes a test that fails when somebody adds a fourth to the
seed for unrelated reasons, and the failure will look like a regression. Fixtures
are constructed by the test that needs them, in the state it needs, and torn
down after. The seed's stability is then a convenience rather than a contract.

**Demo content is a real account, populated by hand, in production.** Release 1
is the portfolio artifact and an empty cookbook demonstrates nothing, so there
has to be a household that looks like a household using Rootloom well. That is
not a seeding exercise — `NFR-DATA-06` says production is never seeded and it
stays true, because entering thirty recipes through the app is *using* the app
rather than loading a fixture into it.

Doing it by hand is deliberate and has a second payoff: it is the last honest
acceptance test before submission. If entering thirty recipes is tedious, that is
a finding about the recipe editor rather than a chore to push through, and P10 is
the last phase where the finding is still actionable.

**Demo photographs need a licence, and this is the corpus trap in miniature.**
Thirty recipes with photographs means thirty photographs from somewhere. Either
the author took them, or they are openly licensed and their terms were confirmed
first. This is the same failure mode the training corpus carries — discovering a
licence problem after the work is done — arriving eight months earlier and on
Release 1's critical path rather than Release 3's. It is scoped explicitly in
P10, with its own entry criterion, on the same reasoning that gates P11 on the
corpus licence: the question is answerable long before the phase, and answering
it late is answering it after the work is done.


## Continuous integration

GitHub Actions. Every job below runs on a pull request; the deployment jobs run
only on `main`.

**Only `docs` exists today**, because it is the only one that can run against a
repository holding no application code. The rest arrive in the phase that builds
what they check, and each becomes a required status check on `main` at that
point rather than in advance. That ordering is not fussiness: a required check
with no workflow to report it does not fail, it waits indefinitely, and a branch
protected by seven of them is a branch nothing can merge into.

| Job | Does | Discharges |
| --- | --- | --- |
| `docs` | Runs `docs/check.sh` | — |
| `toolchain` | Asserts the running versions match the pins | `NFR-OPS-15` |
| `lint` | ESLint, Prettier, `tsc --noEmit` | — |
| `types` | Regenerates database types, fails on any diff | `NFR-DATA-05` |
| `schema` | `supabase db reset` from empty, then pgTAP | `NFR-DATA-04` |
| `rls` | Policy tests; fails on a table with no test file | `NFR-SEC-01` |
| `test` | Unit, component, and integration suites | the `test` set |
| `secrets` | Scans bundle and repository for the `service_role` key | `NFR-SEC-02`, `NFR-SEC-03` |
| `contrast` | Token contrast pairs, per theme, per mode | `NFR-A11Y-02` |
| `journey` | Maestro flows against an EAS build | `FR-JRN-01`–`FR-JRN-06` |

**Supabase Preview** also reports on a pull request, and is not one of these
jobs. It is the Supabase GitHub integration rather than a workflow: it opens a
hosted branch for a pull request that touches `supabase/`, applies the migration
chain to it, and destroys it when the pull request closes. It is deliberately not
a required status check, because it reports nothing at all on the many pull
requests that touch no migration, and a branch protection rule waiting on a check
that will never arrive is the failure this file already describes once.

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

## Client and schema compatibility

**You cannot force anybody to update a mobile app.** A binary installed today
will still be running in six months, issuing the queries it was compiled with,
against whatever schema production has by then. `NFR-DATA-05` generates and
commits types so a schema change breaks the build — but that protects the build,
not the copy of the app already on somebody's phone.

Expo narrows this usefully. A JavaScript-only change ships over the air without a
store round trip, so most clients converge within days rather than months. It
does not close the gap: a device that is offline, or a user who has disabled
updates, still runs old code against a new database, and a change touching native
modules needs a store release regardless.

So the schema moves under three rules.

**Expand and contract, never mutate.** A destructive change is two migrations
separated by time. Add the new column, backfill it, write to both, and only drop
the old one once nothing in circulation reads it. Renames are the same shape —
there is no such thing as a rename that an old client survives.

**A minimum supported version, published by the server and enforced on launch.**
This is the only mechanism that actually retires an old client, and without it
the contract step above has no defensible moment. Below the minimum the app shows
a blocking prompt to update and does nothing else (`NFR-DATA-10`). It exists to
be used rarely; a project that reaches for it often has a different problem.

**Contract only once the minimum supported version postdates the expand.** That
makes the rule mechanical rather than a judgement each time: a column may be
dropped when the oldest client that could still run never read it.

`NFR-DATA-09` puts the guard in CI rather than in memory. A migration containing
a drop or a rename fails the build unless it carries an explicit annotation
recording that no supported client references what it removes — which turns
"I'm fairly sure nothing uses this" into a sentence somebody had to write down.

Two client-side disciplines follow from the same problem:

- **Enum values are additive, and the client tolerates ones it does not know**
  (`NFR-DATA-11`). An exhaustive switch over a server-supplied enum is a crash
  waiting for the next migration. Decode with a fallback and render the unknown
  case as unremarkable rather than as an error.
- **Edge Function request and response shapes are additive too.** They are called
  by clients as old as any query is, and they carry no generated types to break
  the build.


## Observability

Six requirements are marked `monitor`, meaning they are watched over time
rather than passed at a point. Each needs somewhere the measurement is actually
taken, or the marker is decoration.

| Requirement | Measures | Taken from |
| --- | --- | --- |
| `FR-MOD-09` | Turnaround per report tier against its target | `reports`, by tier |
| `NFR-OPS-02` | Age of the oldest unresolved report, per tier | `reports` |
| `NFR-OPS-03` | Labelling throughput against unmet tag floors and the release date | `tags.example_count` against per-facet floors |
| `NFR-OPS-04` | Classifier accuracy per facet against a held-out set | the evaluation run |
| `NFR-OPS-11` | Metered usage against the included allowance | the platform's usage API |
| `NFR-OPS-13` | Preview branches in existence, and their age | `supabase branches list` |

These are reports, not a dashboard. The audience is one person, and a dashboard
nobody has a reason to open measures nothing. Each is a query against data the
system already holds — `NFR-OPS-11` excepted, which is the one measure whose
source is outside the database — surfaced two ways: on an administrator screen,
and as a scheduled digest that arrives whether or not anyone went looking.

`NFR-OPS-11` earns the digest for the same reason `NFR-OPS-02` does, and more
sharply. The spend cap in [`operating-model.md`](./operating-model.md) is left
on, so exceeding an allowance stops the app rather than raising the bill, and an
enforced ceiling with nothing watching the approach to it fails silently and
completely. The measure has to arrive unprompted because the moment it matters is
the moment nobody thought to look.

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

None outstanding.

