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

**Done is a real state.** Release 2 completes the thing that was designed. There
is no obligation to keep adding, and no metric that punishes stopping.

**The documentation is part of the artifact**, which is why a coverage audit and
a schedule that re-derives itself are worth the hours they cost rather than being
overhead on the real work.

## Money

**Free at Release 1 and Release 2, with monetisation possible later.** Nothing is
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

Roughly $10 of that is fixed and has nothing to do with usage — the Apple
Developer Program annually, the one-off Google Play registration, a domain to
serve the privacy policies from. The remainder covers a managed database tier and
whatever storage and egress sit above its included allowances.

**No vendor prices are stated here on purpose.** They move, and a figure asserted
confidently in a planning document is a figure that quietly misleads a year
later. What is stable is the *shape* of the spending, which is what the rest of
this section is about. Confirm the numbers when P0 provisions anything.

## Cost drivers

| Driver | Scales with | Bites at |
| --- | --- | --- |
| Database rows | Households and their content | Never, realistically — this is text |
| Photo **storage** | Recipes that carry a photo | Release 2, slowly |
| Photo **egress** | People *browsing*, not people storing | Release 2, quickly |
| Edge Function invocations | Notification sweeps, classification | Modest at both releases |
| Classifier inference | Recipe creates and updates, plus backfills | Release 2, depends on hosting |
| Push delivery | Notifications sent | Free at the transport layer |

**Release 1 is structurally bounded and Release 2 is not**, and the split is
exactly the release boundary. A household's photos are viewed by that household:
storage grows slowly, egress is trivial, and the whole thing is a rounding error.
The showcase changes the denominator from *members of one household* to *anyone
browsing*, and egress is the one number that scales with strangers.

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

## If the ceiling is reached

A ladder, in order, so that the first response to an invoice is not a panic:

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

## Open questions

- **Classifier inference hosting is unpriced.** `FR-TAG-11` puts classification
  server-side, and whether that is a small model inside an Edge Function or a
  hosted inference endpoint is a difference of orders of magnitude per call —
  with `FR-TAG-18` committing to backfills across every existing recipe, which is
  the expensive shape. Belongs with the classifier engineering plan that P11
  already needs.
- **Whether Release 2 should launch with a cap already in place** rather than
  waiting to need one. Cheap to add before there is content, awkward afterwards.
