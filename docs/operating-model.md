---
name: operating-model.md
description: This file records what Ladle is for, whether it needs to pay for itself, what it costs to run, and which design decisions those answers constrain.
---
# Operating model

Every other document here describes what Ladle does. This one records why it is
being built, what it may cost, and where those two facts constrain a decision
somebody would otherwise make on technical grounds alone.

It exists because the absence of it was reaching into documents already written.
Whether Ladle takes money determines whether [`privacy.md`](./privacy.md) holds a
payment processor and a store disclosure; whether it wants scale determines
whether the showcase is a feature or a liability; and the cost of a photo
determines a choice made in the recipe editor eight months before the invoice
arrives.

## What Ladle is for

**A portfolio and craft project.** The point is building it well and having built
it. Users are welcome and are not the measure of success — the quality of the
thing, including the quality of these documents, is itself the output.

That is a lighter statement than it sounds, and it settles arguments that would
otherwise be hard.

**Growth is not a goal, so anything that limits growth is nearly free.** A
showcase that exists, works, and holds a few hundred recipes demonstrates exactly
the same craft as one holding a hundred thousand, and costs a fraction of it.
Where a commercial product would resist a cap on its public surface, Ladle loses
almost nothing by having one. This is the single most useful consequence of the
answer, and most of the decisions below fall out of it.

**Release 1 is the artifact.** It is what gets demonstrated, and it is published
to both stores rather than shown from a build — shipping is part of what is being
demonstrated, and a listed app is a credential a TestFlight link is not. Release 2
adds the classifier and is unconditional. Everything beyond it is *listed as
planned rather than promised*, which is a normal and honest thing for a portfolio
piece to say.

**Done is a real state.** There is no obligation to keep adding and no metric that
punishes stopping.

**The documentation is part of the artifact**, which is why a coverage audit and
a schedule that re-derives itself are worth the hours they cost rather than being
overhead on the real work.

## Money

**Free at every release, with monetisation possible later.** Nothing is
built for it now: no payment processor, no purchase flow, no paywall, no billing
data. [`privacy.md`](./privacy.md) is accurate as written precisely because none
of that exists.

Keeping that door open costs nothing today provided what lies behind it is
written down, so that opening it later is a known quantity rather than a
discovery. Monetisation would add, at minimum:

| Change | Where it lands |
| --- | --- |
| A payment processor | A new row in the processor table, and a store disclosure |
| Billing and purchase records | A new category in the data inventory, with its own retention |
| Purchase, restore, and receipt flows | New surfaces in a finished feature set |
| Store billing rules and review requirements | Scope in P10, which is already estimated |
| A free-tier boundary | A product decision touching almost every feature |

The last is the expensive one, and it is expensive in design rather than in code.
Deciding which of a household's five major features degrade without payment is a
question the current documents deliberately do not answer, and answering it late
means answering it against a feature set that was designed without it.

## The ceiling

**Under $50 a month, absorbed personally.**

**No vendor prices are stated here on purpose.** They move, and a figure asserted
confidently in a planning document is a figure that quietly misleads a year
later. What is stable is the *shape* of the spending, which is what the rest of
this section is about. Confirm the numbers when P0 provisions anything.

That shape changed when the database organisation moved to its paid tier, and
the change is worth recording because it went in the direction nobody expects an
upgrade to go.

| | What sits here |
| --- | --- |
| **Committed**, whatever the usage | The Apple Developer Program annually, the one-off Google Play registration, a domain to serve the privacy policies from, and now the database subscription — which includes enough compute credit for exactly one project |
| **Metered**, above included allowances | Storage, egress, branch hours, and the compute of any *second* permanently running project |

**The ceiling used to be mostly headroom and is now mostly rent.** The committed
row accounts for something close to two thirds of it before a single person uses
the app. That one fact drives two decisions recorded elsewhere: the environment
topology in [`data.md`](./data.md) keeps one permanent hosted project rather than
two, because a second always-on database is a metered compute line that would
push the committed share past three quarters, and the spend cap below stays on.

What the paid tier bought in exchange is not headroom but *floor*: backups exist
at all where the free tier took none, and projects no longer sleep when they go a
week without traffic. Both were latent defects in documents already written —
`NFR-DATA-13` replaces a retired requirement that had promised a backup window
the account could not have delivered.

### The cap stays on

The platform's spend cap refuses usage past the included allowances rather than
billing for it, and it is left enabled. That turns $50 from a promise to watch
the invoice into a property of the account — the same move as bounding the
moderation queue by construction rather than by goodwill.

The cost of that choice should be stated plainly rather than discovered: **past
an allowance the app stops serving, it does not start costing more.** The failure
mode is an outage rather than a bill. For a free project with no revenue that is
the right direction — an unexpected invoice for an app nobody pays for is the
worse of the two, and there is no user whose money is being taken in exchange for
availability.

It does create an obligation, though. A ceiling enforced by the platform fails
without warning unless something is watching the approach to it, and the ladder
below is only useful if it is climbed *before* the wall rather than after. That
is `NFR-OPS-11`, and it is the same argument that put a scheduled digest behind
`NFR-OPS-02`: a measure nobody has a reason to open measures nothing.

## Cost drivers

| Driver | Scales with | Bites at |
| --- | --- | --- |
| Database rows | Households and their content | Never, realistically — this is text |
| Photo **storage** | Recipes that carry a photo | Release 3, slowly |
| Photo **egress** | People *browsing*, not people storing | Release 3, quickly |
| Edge Function invocations | Notification sweeps, classification | Modest at both releases |
| Classifier inference | Recipe creates, updates, backfills | Release 2, depends on hosting |
| Push delivery | Notifications sent | Free at the transport layer |

**Releases 1 and 2 are structurally bounded and Release 3 is not**, and that is
precisely why the funding gate sits where it does. A household's photos are
viewed by that household: storage grows slowly, egress is trivial, and the whole
thing is a rounding error. The showcase changes the denominator from *members of
one household* to *anyone browsing*, and egress is the one number that scales
with strangers.

### The arithmetic that matters

Illustrative rather than predictive, and the assumptions are stated so they can
be argued with: a well-compressed 4:3 photo at display size is on the order of
150 KB, a thumbnail on the order of 15 KB, a showcase grid shows about six images
per screen, and a browsing session covers perhaps fifty screens.

Against a 100 GB monthly egress allowance:

| Grid loads | Image loads per month | Browsing sessions |
| --- | --- | --- |
| Full-size images | ~700,000 | **~2,300** |
| Thumbnail derivatives | ~7,000,000 | **~23,000** |

Two thousand browsing sessions a month is not a lot. Twenty-three thousand is a
respectable small product. **The difference is one decision about what a grid
loads**, and it is a factor of ten on the only cost that scales without limit.

That decision is made in P2, when the recipe editor first stores an image and the
cookbook first renders a grid of them — roughly six months before the showcase
exists and eight before the bill would arrive. It is nearly free to get right
then and expensive to revisit once there are photos in the bucket, because
fixing it later means re-deriving every image already stored.

`NFR-PERF-06` makes it a requirement rather than an intention.

### What is deliberately not optimised

Database size, function invocations, and push. Each is small enough that
attention spent on it is attention not spent on the one driver that matters.
Recording this stops a later reader from optimising the wrong thing on the
grounds that optimising is generally good.

## The Release 3 gate

Release 3 is conditional on funding being allocated for it, and the gate sits
after Release 2 rather than before it because the two cost different currencies.

Release 2 costs **time** — 120 hours, roughly 40 of them hand-labelling — and
almost no recurring money. It is also the most technically interesting work in
the plan, and it improves the private cookbook through facet search and
recommendation without needing a public surface at all. Putting it behind a
funding gate would have placed the best part of the portfolio behind a door that
may never open.

Release 3 is where money starts. Public photos are the only cost that scales with
strangers browsing, and the moderation queue spends the other scarce resource,
which is one person's attention.

So the decision to make after Release 2 is a real one with a real default. **Not
building Release 3 leaves a complete, published, demonstrable application** — the
thing the household uses every day, and the thing being demonstrated. The
showcase adds reach that a portfolio does not need and a bill that scales with
people who are not evaluating the work.


## If the ceiling is approached

Approached, not reached. With the spend cap on, reaching it is not an invoice to
respond to — it is the app refusing to serve. The whole ladder has to be climbed
on the way up, which is the work `NFR-OPS-11` exists to make possible, and a rung
taken late is taken during an outage.

A ladder, in order, so that the first response to the measure moving is not a
panic:

1. **Thumbnails and image budgets**, if `NFR-PERF-06` has somehow not already
   settled it.
2. **Caps on the public surface** — published recipes per household, or showcase
   pagination depth. Nearly free here, for the reason in *What Ladle is for*.
3. **A CDN or transform layer**, if egress is genuinely the binding constraint
   and the content warrants it.
4. **Monetisation**, opening the door described above with its costs already
   known.
5. **Closing the showcase**, leaving Release 1 intact. Ladle without a public
   surface is still the thing the household uses every day, and this is a real
   option rather than a failure — which is worth knowing before anyone treats
   step 4 as forced.

The ladder is ordered by cost to the project, not by cost to the invoice. A cap
is cheaper than a payment processor, and the craft is demonstrated either way.

Note that the first two rungs cost nothing and need no decision — which is the
argument for taking them before the measure ever moves rather than in response to
it. Step 2 is the *Whether Release 3 should launch with a cap already in place*
question below, and the spend cap sharpens it: shipping without one means the
first enforcement of a limit is the platform's, applied to everything at once,
rather than Ladle's, applied to the surface that chose it.

## Open questions

- **Classifier inference hosting is unpriced.** `FR-TAG-11` puts classification
  server-side, and whether that is a small model inside an Edge Function or a
  hosted inference endpoint is a difference of orders of magnitude per call —
  with `FR-TAG-18` committing to backfills across every existing recipe, which is
  the expensive shape. Belongs with the classifier engineering plan that P11
  already needs.
- **Whether Release 3 should launch with a cap already in place** rather than
  waiting to need one. Cheap to add before there is content, awkward afterwards.
  The spend cap has sharpened this rather than settled it: with the platform's
  limit enforced, shipping without a cap of Ladle's own means the first limit
  anyone meets is applied to everything at once, by the platform, during an
  outage. That is an argument for step 2 of the ladder rather than a decision, and
  it stays open because the figure — recipes per household, or pagination depth —
  is a product judgement nobody has made yet.
- **Classifier inference is the one cost the paid tier did not absorb.** Worth
  naming next to the question above, because the arithmetic in this document now
  concerns a driver with room to spare while the unpriced one sits at Release 2,
  before the gate, with no allowance covering it at all.
