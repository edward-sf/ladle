---
name: roadmap.md
description: This file outlines the development roadmap for the Rootloom application.
---
# Roadmap

This file sequences the work. It is the only place release scope is recorded:
[`requirements.md`](./requirements.md) deliberately carries no release markers, so
that re-planning happens here and the two cannot drift.

Every one of the 213 requirements is assigned to exactly one phase below. That is
checkable rather than asserted — a requirement belonging to no phase, or to two,
is a defect in this document.

## How to read this

Phases run in dependency order. Each states what must be true to **begin** it and
what must be true to call it **done**, and lists the requirements it delivers.

Dates are derived, not chosen. They come from three inputs and nothing else:

| Input | Value |
| --- | --- |
| Start | 25 August 2026 |
| Sustained capacity | 20 hours per week |
| Planned break | 21 December 2026 – 4 January 2027 |

If capacity changes, every date after that point moves proportionally; the hour
estimates are the real content and the dates are arithmetic over them. **There is
no buffer built in.** A date is the earliest the phase can finish given a clean
run, which is what makes them useful to be held to and what makes a slipped one
worth noticing rather than absorbing.

## Three releases, the last one conditional

**Release 1 is the private cookbook, with something already in it** — everything
a household does for itself. Households, calendar, cookbook, pantry, grocery,
nutrition, search within your own recipes, and a curated library to start from so
that a new user's first action is not authoring a recipe from nothing. **This is the portfolio artifact**, and it is published to the
Play Store rather than demonstrated from a build: shipping is itself part of what
is being demonstrated, and a listed app is a credential an internal-track link is
not. It goes to one store rather than two. The Apple Developer Program is an
annual charge and iOS waits for Release 2, where it is taken up together with the
commercialisation question and with the parallel sign-in providers that cannot be
built without it.

**Release 2 is tagging and discovery** — the classifier, facet search, and
recommendation. All of it improves a private cookbook, and none of it needs a
public surface to be worth having. It is also where iOS arrives, so Release 2 is
the first version listed on both stores, and where sign-in stops being a password
alone.

**Release 3 is the showcase** — publishing, copying, attribution, and moderation.
**It is conditional on there being sustained moderation capacity for it**, and it
may not happen. Features beyond Release 2 are listed as planned rather than
promised.

The gate sits between Releases 2 and 3 rather than before both, because the two
cost different currencies. Release 2 costs time — 120 hours, roughly 40 of them
hand-labelling — and almost no recurring money. Release 3 is where the costs
start that do not stop: public photos scale with strangers browsing rather than
with anything under control, and the moderation queue spends the scarcer resource
still, which is one person's attention. Putting the gate before both would place
the most technically interesting work behind a door that may never open.

The gate was originally written as a funding decision. It is not one any more:
the paid database tier is committed for Release 1's sake, and its allowances
cover a thumbnailed showcase with room to spare, so building Release 3 adds no
recurring line to the bill. What is left is the obligation to work a queue for as
long as the showcase is open — see [`operating-model.md`](./operating-model.md),
where the reasoning and the ladder that follows from it are recorded.

This supersedes an earlier two-release split. The reasoning that produced it
still holds — the classifier gate, the corpus licence, and the moderation queue
are all consequences of a public corpus, and none is load-bearing for a household
cooking its own food, which is why none of them sits on Release 1's critical
path. What changed is that a standing obligation, rather than sequence, now
separates the showcase from everything else.

Dates past Release 1 assume the work continues without pause. A gap at the gate
moves Release 3 by the length of the gap; nothing about the arithmetic accounts
for a decision taking time.

| Phase | Hours | Starts | Ends |
| --- | --- | --- | --- |
| P0 · Foundations | 82 | 25 Aug 2026 | 22 Sep 2026 |
| P1 · Ingredient catalog | 61 | 22 Sep 2026 | 13 Oct 2026 |
| P2 · Cookbook and recipes | 70 | 13 Oct 2026 | 6 Nov 2026 |
| P3 · Calendar, meals and cooking | 60 | 6 Nov 2026 | 27 Nov 2026 |
| P4 · Pantry and grocery | 45 | 27 Nov 2026 | 12 Dec 2026 |
| P5 · Household collaboration | 60 | 12 Dec 2026 | 16 Jan 2027 |
| P6 · Dietary and allergy | 43 | 16 Jan 2027 | 31 Jan 2027 |
| P7 · Nutrition | 46 | 31 Jan 2027 | 16 Feb 2027 |
| P8 · Cookbook search | 20 | 16 Feb 2027 | 23 Feb 2027 |
| P9 · Curated library | 46 | 23 Feb 2027 | 11 Mar 2027 |
| P10 · Profile, preferences, notifications, accessibility | 74 | 11 Mar 2027 | 5 Apr 2027 |
| P11 · Release 1 hardening and Play submission | 48 | 5 Apr 2027 | **21 Apr 2027** |
| P12 · Taxonomy and classifier | 135 | 21 Apr 2027 | 7 Jun 2027 |
| P13 · iOS launch and parallel-provider auth | 72 | 7 Jun 2027 | 2 Jul 2027 |
| P14 · Release 2 hardening and submission | 28 | 2 Jul 2027 | **11 Jul 2027** |
| P15 · Opening publishing, and moderation | 58 | 11 Jul 2027 | 31 Jul 2027 |
| P16 · Release 3 hardening and submission | 25 | 31 Jul 2027 | **8 Aug 2027** |

973 hours; 48.65 working weeks plus the holiday. The last 83 of those hours
are conditional.

---

## Release 1 — the private cookbook

### P0 · Foundations
**82h · 25 Aug – 22 Sep 2026**

Supabase local stack, the production project and scripted preview branching,
the migration chain, CI, EAS profiles, auth and session persistence, the typed
client with TanStack Query and MMKV persistence, NativeWind with the token
layers, the contrast check, and the navigation shell.

**Begins when** nothing — this is the first phase.
**Done when** `supabase db reset` builds from empty, CI replays migrations and
runs the suite, a preview branch provisions from the chain and is destroyed by
script, all three EAS profiles build, a user can sign up and return to a
persisted session, a breached password is refused at signup, a build below the
published minimum version refuses to run, and the contrast check runs green
against the default theme.

Delivers `FR-ACCT-01`, `FR-ACCT-02`, `FR-ACCT-06`–`FR-ACCT-08`, `FR-PREF-07`,
`NFR-SEC-01`–`NFR-SEC-05`, `NFR-SEC-08`, `NFR-SEC-09`, `NFR-OFF-01`–`NFR-OFF-05`,
`NFR-DATA-01`, `NFR-DATA-04`–`NFR-DATA-06`, `NFR-DATA-09`–`NFR-DATA-13`,
`NFR-OPS-01`,
`NFR-OPS-06`, `NFR-OPS-08`–`NFR-OPS-10`, `NFR-OPS-12`, `NFR-OPS-13`,
`NFR-OPS-15`,
`NFR-A11Y-02`.

### P1 · Ingredient catalog
**61h · 22 Sep – 13 Oct 2026**

Schema and seed content: categories, ingredients, synonyms, nutrition per 100g,
and the allergen tag facet. Roughly a third of this is code and the rest is
content work. Curation runs through import and export scripts rather than a
user interface — a spreadsheet round-trip is the right tool for bulk one-time
work, and it defers the administrator tool proper to the phase that needs one.

**The Application Administrator arrives here**, not with the moderation queue.
This is the first phase that writes to a curated table, and the only sanctioned
way to write one is a `security definer` function checking membership of
`app_administrators` — so the table, its bootstrap row, and the functions the
import scripts call are six of these hours. The alternative was `service_role`,
which is precisely the key those functions exist to avoid distributing, and it
would have left the catalog's first several thousand rows as the only writes in
the system attributable to nobody. P12's labelling tool and P15's moderation
queue both inherit the table rather than introducing it.

**Begins when** P0 is done.
**Done when** the catalog holds enough ingredients to write real recipes against,
every one carries a category and a nutrition estimate, allergen tags are curated
and approved, and synonym search returns the right entry.

USDA FoodData Central is public domain, which makes it the obvious nutrition
source and sidesteps the licence question entirely here — unlike the recipe
corpus in P12, where the same question is unresolved.

Delivers `FR-ING-01`, `FR-ING-02`, `FR-ING-04`–`FR-ING-07`, `FR-TAG-01`,
`FR-TAG-02`, `NFR-DATA-07`, `NFR-SEC-15`.

### P2 · Cookbook and recipes
**70h · 13 Oct – 6 Nov 2026**

The silent household, recipes, versions, ingredient lines with reconciliation,
collections, the viewer, and the editor. The editor is the hardest screen in the
release and most of this estimate.

**Begins when** P1 is done — the editor cannot offer catalog matches without a
catalog.
**Done when** a recipe with a title alone saves, a dismissed editor leaves a
recoverable draft, an unreconciled ingredient persists as typed and can be matched
later, and a recipe sits in several collections without duplication.

Delivers `FR-HH-01`, `FR-HH-02`, `FR-RCP-01`–`FR-RCP-05`, `FR-RCP-07`,
`FR-RCP-08`, `FR-RCP-16`, `FR-RCP-20`, `FR-ING-03`, `FR-ING-08`, `FR-JRN-01`,
`NFR-DATA-03`, `NFR-PERF-03`, `NFR-PERF-06`.

### P3 · Calendar, meals and cooking
**60h · 6 Nov – 27 Nov 2026**

Meals with the generated start time, week and month views, participants and
servings held apart, the cooked state, and the cooking view.

**Begins when** P2 is done.
**Done when** a block is drawn from preparation start to serving time, servings
seed from participants and diverge on edit, marking cooked records every
participant as having eaten, and the cooking view holds a multi-recipe meal in
one scroll with the screen awake.

Delivers `FR-MEAL-01`–`FR-MEAL-15`, `FR-JRN-03`, `FR-JRN-05`, `NFR-PERF-01`,
`NFR-A11Y-05`.

### P4 · Pantry and grocery
**45h · 27 Nov – 12 Dec 2026**

Grocery items with per-contribution provenance, the pantry, check-off, and
household category ordering.

**Begins when** P3 is done — there are no contributions without meals.
**Done when** deleting one of two meals needing garlic leaves garlic on the list,
a hand-added item survives every meal deletion, check-off stocks the pantry
without a dialog, and the whole list works through a loss of signal.

Delivers `FR-PAN-01`–`FR-PAN-13`, `FR-JRN-04`, `NFR-DATA-02`, `NFR-OFF-06`,
`NFR-PERF-02`, `NFR-A11Y-01`.

### P5 · Household collaboration
**60h · 12 Dec 2026 – 16 Jan 2027**

Members and roles, the single-owner index, invitations through a `security
definer` accept, requests and approvals, dissolution with its grace period, and
Realtime on the shared tables.

**Begins when** P4 is done — approvals need something to approve.
**Done when** a second member cannot create a second owner, an invitee lands in a
household already showing its planned week, a denied request reaches its
requester with a reason, and a dissolved household is recoverable within its
window.

This phase spans the holiday break; the dates already account for it.

Delivers `FR-HH-03`–`FR-HH-17`, `FR-HH-19`–`FR-HH-24`, `FR-ACCT-04`,
`FR-JRN-02`, `NFR-SEC-06`.

### P6 · Dietary and allergy
**43h · 16 Jan – 31 Jan 2027**

Allergy and dietary profiles, derivation from curated ingredient tags, and the
warning and incomplete-check treatments everywhere a recipe appears.

**Begins when** P5 is done — conflicts between participants need participants.
**Done when** an allergen match warns wherever a recipe is shown, a cashew
allergy does not warn on almond, and a recipe holding one unreconciled ingredient
reports its check as incomplete rather than clean.

Delivers `FR-DIET-01`–`FR-DIET-12`, `FR-RCP-13`, `FR-TAG-06`, `FR-TAG-07`,
`NFR-SEC-11` — the health-data consent gate, which must exist before the first
allergy is stored.

### P7 · Nutrition
**46h · 31 Jan – 16 Feb 2027**

Demographics, Mifflin-St Jeor targets with overrides, the tracked six, and the
Today rings.

**Begins when** P6 is done.
**Done when** targets compute and a manual override survives recomputation, a
user who declines every demographic question can still use the app, and no ring
changes colour on reaching or exceeding a target.

Delivers `FR-NUT-01`–`FR-NUT-19`, `NFR-SEC-07`.

### P8 · Cookbook search
**20h · 16 Feb – 23 Feb 2027**

Search across the household's own recipes by title, ingredient, and tag. The
scope control is not built here — there is only one scope until the showcase
exists.

**Begins when** P7 is done.
**Done when** a search for an ingredient returns recipes using it, including by
synonym, within the 500ms target.

Delivers `FR-TAG-30`, `FR-TAG-32`, `NFR-PERF-05`.

### P9 · Curated library
**46h · 23 Feb – 11 Mar 2027**

Public-readable recipes, the browsable library, and copying into your own
cookbook. This is the showcase surface, built here rather than in Release 3, and
it ships with exactly one household able to publish into it.

**That is the whole of the curation mechanism.** No second surface, no separate
content type, no flag on a recipe. The administrator's own household authors
recipes through the app — the demo household work that used to sit in the
hardening phase — and publishes them through an administrator script, the same
pattern P1 already uses for bulk catalog curation. It is a curated library
because one household is the only one that has been given a way to publish yet.
The user-facing publish control, and the confirmation that states what a
household is about to expose, wait for Release 3.

Copy semantics are complete here rather than half-built: snapshot, attribution,
and the notice when an original changes. The library is precisely where upstream
edits happen — one author correcting recipes other households already cook from —
and the version history this needs has been paid for since P2. Building half of it
now would mean changing copy behaviour in Release 3 under recipes people already
hold.

**The library ships photoless**, which is why Release 1's photo egress stays what
[`operating-model.md`](./operating-model.md) says it is: a household's photos
viewed by that household. A photoless recipe is first-class by design and
[`user-interface.md`](./user-interface.md) already accepts an uneven grid rather
than placeholder imagery, so this costs a design allowance that was granted
years before it was needed. It also removes the licence question entirely, which
is the trap that has already caught the training corpus and the demo
photographs.

Browse only, no search. Thirty recipes do not need it, and searching across two
scopes at once is a question that belongs with the showcase, where it bites.

Eight of the hours are the **demo household** — thirty recipes entered by hand
through the app, moved here from the hardening phase because a library with
nothing in it is not a library. One household covers both jobs: its photoless
recipes are what the library publishes, and the ones carrying photographs stay
private, which demonstrates the published and private states side by side rather
than asserting that both work. The photographs are therefore still only ever seen
inside the household that owns them, and the licence question they carry is the
one [`engineering.md`](./engineering.md) already describes rather than a wider
one.

**Begins when** P8 is done **and** the demo photograph licence question is
answered.
**Done when** a new user with an empty cookbook can browse the library,
copy a recipe, and plan it without authoring anything; an edit to a published
original surfaces on its copies without altering them; and the library is
non-empty in production.

Delivers `FR-RCP-06`, `FR-RCP-09`–`FR-RCP-12`, `FR-RCP-14`, `FR-RCP-15`,
`FR-RCP-17`, `FR-RCP-19`, `FR-RCP-21`, `FR-RCP-22`, `FR-HH-18`, `FR-ACCT-03`,
`FR-ACCT-05`, `FR-JRN-06`, `FR-JRN-07`, `NFR-OPS-11`.

### P10 · Profile, preferences, notifications, accessibility
**74h · 11 Mar – 5 Apr 2027**

Public profile, per-user preferences, reminders and expiry warnings, the optional
second factor, and the accessibility pass across everything built so far.
Notifications carry their own schema and delivery path — device tokens,
per-category silences, delivery history, a scheduling sweep, and a push
dispatcher — which is what moved this phase from 45 hours to 60. The second
factor added the remaining 14. It sits here rather than in P0 because enrolment,
recovery codes and removal are settings-screen work; the sign-in path gains only
a challenge that nobody meets until they have enrolled.

**Begins when** P8 is done — the accessibility pass wants the screens finished.
**Done when** units change display without touching stored quantities, timezone
moves the day boundary, every notification category switches off independently,
a user who enrolled a factor is challenged for it and a user who did not is not,
and every `manual` accessibility requirement has been walked through.

Delivers `FR-PROF-01`–`FR-PROF-03`, `FR-PREF-01`–`FR-PREF-06`, `FR-ACCT-09`–
`FR-ACCT-16`, `FR-NOTIF-06`,
`FR-NOTIF-01`–`FR-NOTIF-05`, `NFR-SEC-10`, `NFR-A11Y-03`, `NFR-A11Y-04`,
`NFR-A11Y-06`–`NFR-A11Y-08`.

### P11 · Release 1 hardening and Play submission
**48h · 5 Apr – 21 Apr 2027**

Closed-track beta, performance measured against the reference devices, the Play
listing, **the app icon and mark** — the design phase deferred in
[`user-interface.md`](./user-interface.md), which becomes blocking here because a
build cannot reach a tester without an icon. The demo household is no longer part
of this phase: it moved to P9, where the library it stocks is built.

Ten hours came off this phase when Release 1 stopped going to two stores. What
replaced them costs no hours and constrains the phase more than the hours do. **A
personal Play Console account created after November 2023 cannot reach production
until a closed test has run twelve testers, continuously opted in, for fourteen
days.** That is elapsed time rather than work, and at 48 hours this phase spans
about seventeen days, so the window fits inside it — but only if the build reaches
the closed track on the first day. Two things follow. The icon stops being
something this phase contains and becomes the first thing it does. And the
testers are recruited before the phase opens, in numbers above twelve, because
the requirement is twelve *continuously* enrolled: one person uninstalling drops
the count, and the fourteen days are not satisfied until twelve have been in
place for fourteen unbroken ones.

The eight hours of content work left with the demo household, and so did the
argument for naming them: entering thirty recipes by hand is the last honest
acceptance test of the recipe editor, and that test now happens two phases
earlier, where a finding about the editor is more actionable rather than less.

**Begins when** P10 is done **and** at least twelve testers have committed to the
closed track. That second criterion is the corpus licence question in miniature
and carries the same logic: it can be resolved at any time before this phase, and
resolving it early is free insurance against a fourteen-day clock that cannot
start.
**Done when** a build is in Play's review queue, every P95 latency target
has been measured rather than assumed, both privacy policies are published and
linked, and the `manual` release checklist has been worked through once end to
end.

Delivers `NFR-SEC-12` and `NFR-OPS-07` — the consumer health data privacy
policy and the breach response procedure, both of which are submission-time
obligations rather than product features. Everything else here verifies what the
previous ten phases built.

---

## Release 2 — tagging and discovery

### P12 · Taxonomy and classifier
**135h · 21 Apr – 7 Jun 2027**

The full tag vocabulary, corpus licence verification, corpus assembly,
hand-labelling, training, evaluation, and the activation and backfill machinery.
The corpus and its training pipeline move into the separate private repository
described in [`engineering.md`](./engineering.md) at the start of this phase,
which is the first point at which there is anything to put in it.
Includes building the administrator tool that the labelling runs through — the
~40 hours below is a rate that assumes one, and labelling 1,250 recipes through
Supabase Studio would cost considerably more and produce worse labels.

**Begins when** the corpus licence question is answered. This is the phase's real
entry criterion and it can be resolved at any time before then — it does not need
Release 1 to be finished, and resolving it early is free insurance against
discovering the corpus is unusable after the labelling is done.

**Done when** every corpus entry names its source and that source's licence,
per-facet floors are set from the evaluation curve rather than guessed, a trained
model names the corpus revision behind it, dormant tags are searchable and
manually applicable, an author's removal survives a retraining pass, and a
backfill applies newly active tags retroactively.

The ~40 hours of hand-labelling inside this estimate is content work at a fixed
rate and does not compress with practice. It is the largest single uninterrupted
task in the plan.

Delivers `FR-TAG-03`–`FR-TAG-05`, `FR-TAG-09`–`FR-TAG-29`, `FR-TAG-33`,
`NFR-PERF-04`, `NFR-OPS-03`–`NFR-OPS-05`, `NFR-OPS-14`.

### P13 · iOS launch and parallel-provider auth
**72h · 7 Jun – 2 Jul 2027**

The Apple Developer Program, the first iOS build to reach a device, and the
sign-in methods that were waiting for an Apple team to exist: a third-party
provider on both platforms, a second provider alongside it collecting no more
than a name and a withholdable email address, and passkeys. `rootloom.app` begins
serving the two domain association files passkeys depend on, which is the first
time anything in this project is web-facing at all.

The hours are enrolment and credentials 6, the iOS build and TestFlight 10, the
two providers 14, passkeys 24, the association files and their hosting 6, an
iOS-only interface and accessibility pass 8, and 4 to re-measure the P95 latency
targets on the iPhone that joins the reference hardware here — the harness exists
from P11, so this is a second run rather than a second harness. The second provider is an App Store
rule (`FR-ACCT-18`) before it is a preference, which is why it is a requirement
rather than something for the submission to discover.

**Passkeys carry the widest uncertainty in this document, and their 24 hours are
its least trustworthy number.** Supabase shipped them to beta in May 2026 and
still documents them as experimental. More awkwardly, the documented client
support is JavaScript, Swift and Dart, and none of those is React Native —
`supabase-js` drives a browser API this runtime does not have, so the work is
wiring a native module to Supabase's WebAuthn endpoints with no reference
implementation to follow. **The fallback is to ship this phase without them**:
third-party sign-in and the optional second factor from P10 each stand alone,
`FR-ACCT-19` and `NFR-SEC-13` move to a later phase, and nothing else here
depends on either. That is the same shape as the classifier's accuracy risk — a
named alternative chosen when the phase opens, rather than a discovery made
halfway through it.

**Begins when** P12 is done **and** the Apple Developer Program enrolment has
completed. That second criterion is not a formality: enrolment takes as long as
it takes, and it is the one item in this phase that working harder does not
shorten.
**Done when** an iOS build has run on a device, a user can sign in by each
offered method and remove any but their last, both association files resolve over
HTTPS from the relying-party domain, and every P95 latency target has been
re-measured on the iPhone that joins the reference hardware here.

Delivers `FR-ACCT-17`–`FR-ACCT-20`, `NFR-SEC-13`, and `NFR-SEC-14`.

### P14 · Release 2 hardening and submission
**28h · 2 Jul – 11 Jul 2027**

Regression across the tagging surfaces, submission, and review. Play is an update
and is light, because the listing, the icon and both privacy policies already
exist. iOS is not: it is a first submission, with its own listing, its own
screenshots, its own App Privacy questionnaire and the review latitude that
attaches to a first-time app. The eight hours over the original estimate are
that, and they are the part of this plan most likely to be wrong, because a first
submission is where the store gets to disagree with assumptions nobody has tested
yet.

**Begins when** P13 is done.
**Done when** a build is on both stores' review queues and the `manual`
checklist has been walked for anything tagging touched.

Delivers no new requirements.

---

## Release 3 — opening the showcase

**Conditional on moderation capacity.** The showcase *surface* already exists —
P9 built the public library, the browsable entry points and the copy machinery,
and Releases 1 and 2 ship with them. What is conditional is opening publishing to
every household, and the moderation the moment they can. That is a narrower
release than the one this section used to describe, and deliberately so: the gate
now holds back exactly the thing the gate is about. Everything below happens only
if there is an administrator committed to working a report queue for as long as
the showcase stays open — see [`operating-model.md`](./operating-model.md), where the gate's
narrowing from money to attention is recorded, and where the escalation ladder
makes clear that not building this is a real option rather than a failure.
Release 1 remains the portfolio artifact whether or not any of it is built, and
Release 2 remains the last unconditional phase.

### P15 · Opening publishing, and moderation
**58h · 11 Jul – 31 Jul 2027**

The publish control in the recipe editor and the confirmation that states what a
household is about to expose; reports with automatic
suppression; the escalation sweep; rate limits; and the search scope control. The
moderation queue is a section added to the administrator tool built in P12, not a
new surface.

Forty-four hours left this phase — forty to P9 with the public surface, and the
administrator table to P1, which needed it first. What remains is the half that
needs a person rather than a screen. That is the right shape for a conditional phase: if
the capacity decision goes the other way, what is lost is user publishing, not
the ability of anyone to find a recipe they did not write.

**Begins when** P14 is done **and** the capacity decision has been made.
**Done when** a household other than the administrator's can publish and
unpublish, a reported dietary claim suppresses on filing, an unreviewed urgent
report withdraws its recipe from the showcase by itself, and no volume of reports
removes anything.

Delivers `FR-RCP-18`, `FR-MOD-01`–`FR-MOD-15`, `FR-TAG-08`, `FR-TAG-31`,
`NFR-OPS-02`.

### P16 · Release 3 hardening and submission
**25h · 31 Jul – 8 Aug 2027**

Beta, moderation dry-run against seeded reports, and submission.

**Begins when** P15 is done.
**Done when** the escalation sweep has been observed firing on a real unattended
report, and a build is submitted.

Delivers no new requirements.

---

## Beyond Release 3

Not scoped, not estimated, and not dated. Recorded so that the ideas are held
somewhere deliberate rather than resurfacing from a scratchpad, and so that
decisions taken in Release 1 and 2 can avoid foreclosing them.

**Taste profiles and the recommendation pipeline.** The intended direction for
Release 3 and beyond. Recommendation through Release 2 is deliberately thin —
`FR-TAG-22` weights what the `Pantry` already stocks and `FR-TAG-23` requires
every suggestion to state its reason, and that is the whole of it. What comes
after is maturation on two fronts: a per-`User` and per-`Household` taste
profile built from what a household actually cooks, repeats, and abandons, and
the services and pipelines that turn it into suggestions worth reading.

Two things about it are already settled by decisions taken earlier. The signal is
revealed preference rather than stated — Rootloom records who cooked what and when,
which is better evidence than anything a person would fill in on a form, and it
accrues from the first release without anyone building for it. And whatever it
grows into, `FR-TAG-23` holds: a recommendation states its reason, because an
unexplained ranked list is not something a person can act on. A taste profile
that cannot explain itself is not shippable here regardless of how well it ranks.

The household axis is the interesting half and the harder one. A household is
several people with different preferences eating the same dinner, so a household
taste profile is not the average of its members and cannot be built as one.

**Save-for-later on the showcase.** A Release 3 question, deliberately left open
until the showcase is being designed rather than settled now. At present the only
way to keep a showcase `Recipe` is to copy it (`FR-RCP-09`), which creates a
recipe the household owns, in the shared `Cookbook`, visible to everyone — there
is no lightweight "maybe" state, so every flicker of interest costs a permanent
addition to a cookbook other people read. Whether that friction is worth a
mechanism is a judgement best made against a real showcase. If it is built, it is
personal rather than household-scoped, which is what distinguishes it from a
collection.

## What could move this

- **The corpus licence.** Unresolved, and the only open question that can
  invalidate work already done rather than merely delay work not yet started.
  Answer it before P12 begins, and ideally before Release 1 ships.
- **Catalog seeding (P1) and labelling (P12) are content, not code.** Together
  they are roughly 65 hours that no amount of tooling or familiarity speeds up.
  They are also the two phases most likely to be underestimated, because they feel
  like data entry until you are doing them.
- **The editor (P2) and the calendar (P3)** are the two hardest screens. If any
  code phase overruns, it will be one of these.
- **No buffer exists.** At 20 hours a week, a fortnight lost to illness, travel, or
  a demanding stretch at work moves every subsequent date by two weeks. That is
  not a failure of the plan; it is the plan telling the truth about what happened.
- **The dietitian review is not scheduled**, deliberately. It triggers on a claim
  rather than a date: before Rootloom says anything about health outside the app, and
  before any nutrition figure stops being labelled as convention or overridable.
