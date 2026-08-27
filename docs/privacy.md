--- name: privacy.md description: This file records what personal data Rootloom
collects, why, who can read it, how long it is kept, and what deletion does -
the internal source from which the public privacy policy and the app store
disclosures are written. ---
# Privacy

Rootloom collects health data. That single fact is why this document exists
separately from the others: the demographic inputs to the nutrition target
equation are a category that regulators, app stores, and users all treat
differently from a shopping list, and the handling has to be deliberate rather
than inherited from how the rest of the data is treated.

## What this document is for

It is the internal record, and it has three consumers.

The **public privacy policy** is written from it rather than independently, so
that the policy cannot describe a system Rootloom does not have. The **app store
disclosures** — Google's Data Safety form at Release 1, and Apple's App Privacy
questionnaire when iOS arrives at Release 2 — ask questions this inventory is
built to answer. And **design review** uses it
to notice when a new field quietly enlarges what Rootloom holds.

It is not itself the public policy and it is not legal advice. Nobody involved
in writing it is a lawyer, and the obligation to have it reviewed by one
triggers on an act rather than a date: **before the policy is published, and
before the first store submission.** That is the same shape as the deferred
dietitian review — the exposure is created by publishing, so publishing is what
ends the deferral.

## Jurisdiction

**Release 1 lists in the United States only.** Store availability is a setting
rather than a fact, and it is the single biggest determinant of how many regimes
this document has to satisfy. Listing narrowly first is the cheap lever a solo
developer has, and opening a market later is a decision that reopens this
section rather than an inheritance from the default.

Three things follow, and one of them is unusual.

**Washington's My Health My Data Act is the binding constraint**, and it binds
because the developer is in Washington rather than because of where users are.
It is unusual in three ways that matter here. It carries no revenue or
user-count threshold, so it applies on day one with zero users — where the
comprehensive state privacy laws, California's included, only bite above
thresholds Rootloom will not approach for years. It carries a private right of
action, so the exposure is any user with a grievance rather than a regulator who
has to be provoked into acting. And it requires a **consumer health data privacy
policy as a separate, distinctly linked document**, with opt-in consent taken
before the data is collected and separately from any other consent.

Whether the nutrition demographics fall inside its definition of consumer health
data is a question for review. Recorded allergies almost certainly do. Rootloom
therefore treats both as in scope rather than waiting for the answer, since the
design cost of doing so is a consent screen and the cost of being wrong the
other way is a private action.

MHMDA also grants a right to confirm whether consumer health data is being
collected and to access it, alongside the rights to withdraw consent and to
delete. `FR-ACCT-09` satisfies that as a subset of something larger: the export
covers everything a user can read rather than their health data alone, because
the narrow version would answer a question nobody asked while omitting the
cookbook, which is the thing people are actually afraid of losing. The right to
know which third parties data is shared with is answered by the processor table
below, which is short because Rootloom shares with none of them for any purpose
beyond running the service.

**HIPAA does not apply.** It reaches healthcare providers, health plans, and
clearinghouses, and Rootloom is none of them. This is recorded because the
instinct on seeing health data is to reach for HIPAA, and doing so would produce
a policy describing obligations Rootloom does not have while missing the ones it
does.

**The FTC Health Breach Notification Rule does apply**, having been extended to
health apps outside HIPAA, along with the general prohibition on deceptive
practices — which is the mechanism by which a privacy policy that misdescribes
the app becomes a federal matter rather than an embarrassment.

### Children

Accounts require a stated date of birth and are not created under 13
(`FR-ACCT-08`). Anyone younger exists only as a person in a household, recorded
by the adult who looks after them, carrying a name, allergies, and dietary tags
and nothing else (`FR-DIET-12`).

That is what makes COPPA tractable rather than expensive. Its trigger is an
operator collecting personal information **from** a child online, and Rootloom
does not: there is no child-facing account, no child-entered field, and no
interface a child is expected to use. What exists is a guardian recording that
someone at their table cannot eat peanuts.

It also means the most protected person in the system is the one Rootloom holds
least about. No date of birth, no body measurements, no nutrition ledger for a
child — not as a compliance posture but because headcount and allergy checking
never needed them.

Nutrition tracking is separately gated at 18 (`FR-NUT-19`), which is a product
decision with a health dimension rather than a legal one: the target equation
was validated on adults, and nothing here has professional review behind it.

### What a second market would cost

Recorded now so that the decision is priced when it is made rather than
discovered afterwards. The EU and EEA are the expensive step: GDPR treats health
data as special category requiring explicit consent, an Article 27
representative established in the Union is a recurring paid obligation for a
developer with no EU presence, and the showcase would fall within the DSA's
notice-and-action rules. Rootloom's moderation design already sits close to the
last of those, which is a fortunate accident of having designed it carefully
rather than a plan.

The English-speaking markets — the UK, Canada, Australia, New Zealand — are
cheaper than the EU and not free, adding three regimes and their own consent and
access rules.

None of this is legal advice, and privacy law in this area has been moving
quickly. The specifics above are the starting point for a review, not the
conclusion of one.

## Standing commitments

These are already requirements, and they constrain everything below. They are
listed here because a privacy document that restates them loosely, in different
words, creates a second version that can drift from the first.

| Commitment | Requirement |
| --- | --- |
| Demographic health data is readable only by the user it belongs to | `FR-NUT-05`, `NFR-SEC-07` |
| Health data is deletable without deleting the account | `FR-NUT-06` |
| No feature outside Nutrition Tracking requires a demographic input | `FR-NUT-07` |
| The sex input is distinct from pronouns and display identity | `FR-NUT-08` |
| Publishing is the only action that exposes household data | `FR-ACCT-05` |
| Account deletion resolves every household the user owns | `FR-ACCT-04` |
| Attribution degrades rather than persisting or erasing content | `FR-RCP-19` |
| The public/private boundary is stated where data is entered | `FR-PROF-02` |
| Private storage objects are served only by short-lived signed URL | `NFR-SEC-08` |
| Production data is never copied into another environment | `NFR-DATA-06` |
| Health data is stored only after a separate, explicit opt-in | `NFR-SEC-11` |
| The consumer health data policy is a distinct, separately linked document | `NFR-SEC-12` |
| A breach response procedure exists before production holds user data | `NFR-OPS-07` |
| A user may export every record they can read, from within the app | `FR-ACCT-09`, `FR-ACCT-10` |

## The inventory

Grouped by how sensitive the data is rather than by which table holds it. The
tables themselves, and their RLS predicates, are in [`data.md`](./data.md).

### Health data

The most sensitive category, and the only one that would be called health data
by a regulator.

| Data | Purpose | Readable by | On account deletion |
| --- | --- | --- | --- |
| Date of birth, height, weight, sex, activity level, goal | Computing nutrition targets, and nothing else | The user alone, with no household exception | Deleted |
| Recorded allergies | Excluding recipes from recommendation, warning where they appear | The user; the fact of a conflict is visible to their household | Deleted |
| Dietary frameworks observed | Ranking recommendations | The user; visible to their household | Deleted |
| A household person's name, allergies, and dietary tags | Headcount, and checking a recipe against everyone at the table | The household | Retained by the household; not the deleting user's to remove |
| Per-participant `ate` state and the nutrition ledger derived from it | The user's own daily figures | The user alone | Deleted |

Every demographic column is nullable, and a row of all nulls is a user who
declined the questions. That is a supported state rather than an incomplete one,
which means **a user who does not want Rootloom to hold health data simply does
not give it any**, and the rest of the app works unchanged.

Allergies sit in this category deliberately. An allergy is health information
even though Rootloom uses it for filtering rather than for advice, and the fact
that a household can see a conflict warning does not make the underlying record
theirs to read.

### Identity and account

| Data | Purpose | Readable by | On account deletion |
| --- | --- | --- | --- |
| Email address and authentication credentials | Signing in | Held by Supabase Auth | Deleted |
| Display name, avatar, about-me, pronouns | Identifying a person to their household and on published recipes | Any signed-in user | Deleted; attribution degrades to a placeholder |
| Account timestamps and active flag | Operating the account | The user alone | Deleted |
| Preferences — theme, units, language, timezone | Rendering the app as the user asked | The user alone | Deleted |
| Push notification tokens, one per device | Delivering notifications | The user alone | Deleted; also deleted on sign-out |
| Notification silences and delivery history | Honouring what a user switched off, and not repeating a warning | The user alone | Deleted |

Display identity is readable by any signed-in user rather than only by a
household, because a published recipe carries its author's name and picture.
That is the consequence of publishing being a public act, and `FR-PROF-02`
requires it to be stated where the data is entered rather than discovered later.

### Household and content

| Data | Purpose | Readable by | On account deletion |
| --- | --- | --- | --- |
| Household membership and role | Authorization | Household members | Ownership transfers or the household dissolves |
| Recipes, collections, and version history | The product | The household; the showcase if published | Retained by the household; copies keep content and lose the name |
| Meals, participants, serving counts | Planning and nutrition attribution | Household members | Retained by the household |
| Pantry contents and grocery list | The product | Household members | Retained by the household |
| Reports raised, and their outcome | Moderation | The reporter sees their own; administrators see the queue | Retained, dissociated from the reporter |

This is the category where deletion is least intuitive, because most of it does
not belong to the person deleting their account. A household's calendar is the
household's, and one member leaving does not entitle them to remove it.
`FR-ACCT-04` resolves the ownership question before deletion is confirmed rather
than leaving it undefined.

### Operational

Reports on moderation queue age, labelling throughput, and classifier accuracy
are measured over data the system already holds and produce aggregate figures.
They are not a separate collection and are not per-user.

## Deletion

Four distinct operations, deliberately kept distinct, because collapsing them
would make one of them do something a user did not ask for.

**Deleting health data alone** (`FR-NUT-06`) removes the demographic row and the
derived targets, leaving the account and everything else intact. This is the
escape hatch for someone who tried nutrition tracking and would rather Rootloom
did not hold the inputs. It is also the withdrawal-of-consent path that
`NFR-SEC-11` implies — together with `FR-NUT-04`, which dismisses the feature so
that nothing further is collected, withdrawal is expressed as two existing
capabilities rather than a third mechanism that would need its own screen.

**Leaving a household** removes membership. An owner must transfer ownership
first (`FR-HH-10`), so no exit orphans data.

**Dissolving a household** (`FR-HH-17`–`FR-HH-20`) is destructive, itemised
before confirmation, and recoverable for a stated period. Published recipes are
unpublished. Copies other households took are snapshots and are untouched.

**Deleting the account** removes the person's own data and resolves every
household they own. What it does not do is erase them from other people's
cookbooks — a copied recipe keeps its content and loses the name, showing a
placeholder that identifies nobody (`FR-RCP-19`).

That last point is the one most worth being able to explain, because it looks
like a failure to erase and is not. Two things are being balanced: erasure must
not preserve an identifier for someone who asked to be forgotten, and it must
not rewrite a recipe sitting in someone else's cookbook that they have been
cooking from for a year. Degrading the attribution satisfies both — the person
is no longer identified, and the copier still does not appear to have written
what they copied.

### Retention

| What | Kept for | Why that long |
| --- | --- | --- |
| A deleted account's rows | Not at all — removed on confirmation (`FR-ACCT-11`) | The itemised confirmation is the protection against accident; a grace period would mean "deleted" did not mean deleted |
| A dissolved `Household` | 30 days (`FR-HH-19`) | The person confirming may be mid-argument rather than post-decision, so the window has to outlast the argument |
| Resolved reports | 12 months (`FR-MOD-14`) | Long enough to see repeat behaviour and to stand behind a ruling, short enough not to become an archive |
| Notification delivery history | 90 days (`FR-NOTIF-06`) | It exists only to avoid sending the same warning twice, and its foreign keys already cascade it away with its subject |
| Backups | 7 days (`NFR-DATA-13`) | Operational recovery. This is the honest caveat on every deletion claim above |

Deletion is immediate everywhere except the two places where something has to be
recoverable, and both of those are recoverable because the destruction reaches
beyond the person who asked for it.

**The backup line is the one most policies leave out.** Nothing that runs on real
infrastructure can claim data is gone the instant a row is dropped, because the
backup taken an hour earlier still holds it. Saying seven days is less impressive
than saying "immediately" and is the only version that is true.

Seven is the managed tier's retention rather than a figure Rootloom chose, which
is worth saying plainly: the window is short because that is what the platform
does, not because a shorter one was bought. It replaces an earlier claim of 30
days that was retired for being inaccurate rather than merely generous, and the
correction moves in the direction that favours the reader.

These figures are initial targets in the sense `requirements.md` means it — they
exist to be measured against and revised, not defended. None of them is set by a
regulator.


## Processors

Everyone who processes personal data on Rootloom's behalf, which the policy has
to name.

| Processor | Holds | Note |
| --- | --- | --- |
| Supabase | Everything — database, authentication, storage, functions | The whole data tier, per [`data.md`](./data.md) |
| Expo / EAS | Build and update infrastructure | No user data at rest |
| Google, and Apple from Release 2 | Store distribution and push notification transport | Also the recipients of the disclosure forms |
| Breached-password lookup | Nothing | See below |
| Crash reporting | Stack traces and device model, scrubbed of health data | See below |

`FR-ACCT-06` refuses passwords known to have appeared in a public breach corpus.
This sounds like sending a password to a third party and is not: the standard
implementation hashes the password locally and sends only a five-character
prefix of the hash, receiving back every matching suffix to compare on the
device. **The password, and any identifier of the account, never leave.** Worth
recording precisely, because a reader of the policy will reasonably assume the
worse version.

### Crash reporting

Rootloom collects crash and error reports from production builds
(`NFR-OPS-08`), because a solo developer shipping to devices they do not own
otherwise learns about failures from store reviews. Store-provided crash
reporting was not enough on its own: it captures native crashes, and in React
Native most failures are JavaScript errors that never reach the native layer.

The payload is constrained by requirement rather than by configuration. No
demographic input, allergy, or other health data appears in a report
(`NFR-OPS-09`), and no screenshot, session replay, or network request body is
captured at all (`NFR-OPS-10`). Both are tested rather than trusted to a
settings page, because the default configuration of every crash reporter is
generous and the drift is silent.

That constraint is what keeps this out of the consent question. A payload
containing no health data is not a disclosure of consumer health data, so
nothing has to be asked for — which is a better position than a consent dialog,
since asking implies the payload might contain something worth worrying about.


## Store disclosures

Both stores ask what is collected, whether it is linked to identity, and whether
it is used for tracking. Rootloom's answers are unusually simple in one respect:
**nothing is collected for advertising, nothing is shared with data brokers, and
there is no cross-app or cross-site tracking.** No third-party analytics or
advertising SDK is planned, which is what makes the tracking answer a flat no
rather than a qualified one.

The disclosures that do apply are health and fitness data, contact information,
user content, and identifiers. Each maps to a row in the inventory above. Apple
additionally treats health data as a category requiring the purpose to be stated,
which `FR-NUT-08` already forces the app itself to do at the point of collection;
that obligation arrives with iOS at Release 2 and is recorded now because the
answer is already known and will not have to be worked out under submission
pressure.

An age rating and the handling of under-age users is an open question below, and
it is a store-blocking one rather than a policy nicety.

## What is deliberately not collected

Recorded because an absence is a decision and should be visible as one.

No location. No contacts. No advertising identifiers. No analytics of any kind.
Crash reporting is not analytics: it carries no behavioural events, records
nothing about what a person did, and is scoped by `NFR-OPS-09` and `NFR-OPS-10`.
No micronutrients — excluded from the product for reasons of data quality rather
than privacy, but the effect is that Rootloom holds less. No free-text health
information: the demographic inputs are enumerated fields and a date, so there
is nowhere for someone to type a diagnosis.

## Open questions

None outstanding. Every question this document opened has been answered and
written into the requirements; what remains is the legal review recorded at the
top, which is triggered by publication rather than by anything left undecided.

