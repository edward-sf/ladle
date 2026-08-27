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

### The licence

The repository is public under [PolyForm Noncommercial 1.0.0](../LICENSE), one
licence covering the documents, the code, and the skills alike.

**Licensing is the lever, not visibility.** These are routinely conflated, and
conflating them produces the wrong decision in both directions — either hiding
work that would have cost nothing to show, or publishing under terms that give
away the thing being protected. Being public determines who can *read* Ladle.
The licence determines what they may *do* with it, and those are independent
choices. A public repository under a noncommercial licence is readable by
everyone and commercially usable by nobody but its author, which is exactly the
combination this project wants.

That makes the licence the mechanism the section above depends on. Monetisation
is kept possible by writing down what lies behind the door; a permissive licence
would have quietly given away the room behind it. MIT or Apache would let anyone
ship Ladle commercially, including someone who did none of the work, which is
precisely the optionality *Money* is holding open. The opposite extreme, an
explicit all-rights-reserved notice, reserves no more than PolyForm does and
grants nothing to a reader who wants to run the thing to see whether the work is
any good — it costs portfolio value and buys no protection.

**Nothing about this constrains monetising later.** A noncommercial licence binds
the people who receive the software, not the person who wrote it. As sole author
Ladle can be relicensed going forward at any time, dual-licensed, or sold
outright, and none of that requires the repository to have been private.
Relicensing does not appear as a row in the table above because it costs nothing
at the point it would be needed.

**What is permanent is publication, not the licence.** Anything public stays
public — clones, forks, the network graph, archives, and whatever has already
been scraped. The decision recorded here is therefore *which parts are
permanently public*, not whether to be public for the time being, and a private
repository created later retracts nothing that preceded it. That boundary is
drawn once, in
[`engineering.md`](./engineering.md), and it falls around the labelled corpus
rather than around the application, because the application is reproducible by
anyone with the documents and the corpus is roughly forty hours of one person's
labelling.

The consequence worth naming is that Ladle's authorization model is published in
full: every RLS predicate in [`data.md`](./data.md), and every moderation
threshold and rate limit in [`requirements.md`](./requirements.md). Both are
deliberate. RLS security does not depend on the predicate being secret, and a
published policy that every table must carry one is easier to hold to than a
private one. The moderation limits are safe to publish for a sharper reason:
they are bounded by construction rather than by obscurity, so knowing the daily
cap does not help anyone exceed it. A design whose safety rested on secret
thresholds could not have been published, and would have been worse for it.

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
| **Metered**, above included allowances | Storage, egress, branch hours — a small standing figure now that pull requests touching migrations open one — and the compute of any *second* permanently running project |

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
| Classifier inference | Recipe creates, updates, backfills | Never — see *Where classification runs* |
| Push delivery | Notifications sent | Free at the transport layer |

**Releases 1 and 2 are structurally bounded and Release 3 is not**, and that is
precisely why the gate sits where it does. A household's photos are
viewed by that household: storage grows slowly, egress is trivial, and the whole
thing is a rounding error. The showcase changes the denominator from *members of
one household* to *anyone browsing*, and egress is the one number that scales
with strangers.

### The arithmetic that matters

Illustrative rather than predictive, and the assumptions are stated so they can
be argued with: a well-compressed 4:3 photo at display size is on the order of
150 KB, a thumbnail on the order of 15 KB, a showcase grid shows about six images
per screen, and a browsing session covers perhaps fifty screens.

Against the paid tier's included monthly egress, which is two and a half times
what the free one allowed:

| Grid loads | Image loads per month | Browsing sessions |
| --- | --- | --- |
| Full-size images | ~1,700,000 | **~5,800** |
| Thumbnail derivatives | ~17,000,000 | **~58,000** |

Six thousand browsing sessions a month is a real audience. Fifty-eight thousand
is more reach than a portfolio piece has any use for. **The difference is still
one decision about what a grid loads**, and it is still a factor of ten on the
only cost that scales without limit — the larger allowance moved both rows
without touching the ratio between them, which is the part that was ever the
argument.

What the larger allowance did change is the *character* of the risk. On the old
figures a modestly successful showcase serving full-size images would have found
the wall; on these it takes an implausible amount of traffic to reach it at all
with thumbnails in place. Egress stops being the thing most likely to stop Ladle
working and becomes a boundary condition — which is what the Release 3 gate below
is reconsidered against.

That decision is made in P2, when the recipe editor first stores an image and the
cookbook first renders a grid of them — roughly six months before the showcase
exists and eight before the bill would arrive. It is nearly free to get right
then and expensive to revisit once there are photos in the bucket, because
fixing it later means re-deriving every image already stored.

`NFR-PERF-06` makes it a requirement rather than an intention.

### Where classification runs

This was carried as an open question on the grounds that a model inside an Edge
Function and a hosted inference endpoint differ by orders of magnitude per call,
with `FR-TAG-18` committing to a backfill across every existing recipe. The
framing was the mistake. Orders of magnitude per call only matter when the calls
are numerous, and Ladle has decided not to have many.

Count them. Online classification happens on a recipe create or update, which is
a household writing its own cookbook. A backfill runs on a retraining pass, which
is a deliberate act a few times a year at most, across a corpus the showcase cap
already holds to a few hundred recipes. That is thousands of inferences a year,
not millions. **The expensive shape is only expensive at a scale this project
has decided not to reach** — which is *Growth is not a goal* paying out again, in
the place it was least expected.

So per-call cost is not the selection criterion. What actually separates the
options is whether one adds a **standing monthly charge**, because that is what a
$50 ceiling with two thirds already committed cannot absorb. A hosted endpoint
frequently bills for being available rather than for being used.

The decision follows from that:

- **Online classification runs as a small model inside an Edge Function.** It
  satisfies `FR-TAG-11`, keeps the model swappable without an app release, and
  its cost falls inside the function-invocation line above, which is modest at
  both releases.
- **Backfill runs where retraining already runs** — as a batch on the
  administrator's machine, from the private corpus repository, writing results
  through the administrator's authenticated path. `FR-TAG-11` constrains the
  online path so the model can be replaced without shipping an app; it does not
  require a periodic bulk job to take the same route.

The risk worth naming is accuracy rather than cost. If evaluation at P11 shows
that no model small enough for an Edge Function clears the per-facet bar
`NFR-OPS-04` measures, the fallback is a hosted endpoint — and the number to
price then is its standing charge, not its per-call rate.

### What is deliberately not optimised

Database size, function invocations, and push. Each is small enough that
attention spent on it is attention not spent on the one driver that matters.
Recording this stops a later reader from optimising the wrong thing on the
grounds that optimising is generally good.

## The Release 3 gate

Release 3 is conditional, and the gate sits after Release 2 rather than before it
because the two cost different currencies. Release 2 costs **time** — 120 hours,
roughly 40 of them hand-labelling — and almost no recurring money. It is also the
most technically interesting work in the plan, and it improves the private
cookbook through facet search and recommendation without needing a public surface
at all. Putting it behind a gate would have placed the best part of the portfolio
behind a door that may never open.

**What the gate is conditional on has narrowed.** It was written as a funding
decision, on the reasoning that Release 3 is where money starts. The paid
database tier has already been committed for reasons that have nothing to do with
the showcase — backups and a project that stays awake, both of which Release 1
needs — and its included allowances cover the arithmetic above with room to
spare, provided `NFR-PERF-06` holds. The infrastructure half of the gate is
therefore paid for whether or not the showcase is built. Building it adds no
recurring line to the bill; it consumes headroom that already exists.

**What remains is the half money was never going to buy.** The moderation queue
spends one person's attention, and there is one administrator. That is the scarce
resource the whole moderation design in [`user-experience.md`](./user-experience.md)
is shaped around — automatic suppression, time-based escalation, a queue bounded
by construction — and every one of those measures exists because capacity is not
an available answer. A larger allowance does not read a report.

So the decision to make after Release 2 is still a real one with a real default,
but it is a question about sustained attention rather than about an invoice: is
there an administrator who will work a queue for as long as the showcase is
open? **Not building Release 3 leaves a complete, published, demonstrable
application** — the thing the household uses every day, and the thing being
demonstrated. The showcase adds reach that a portfolio does not need and an
obligation that does not end.

The two conditions are not symmetrical, and it matters which one is binding. A
funding gate can be reopened by deciding to spend more; an attention gate cannot
be reopened by deciding to try harder, which is why the honest form of the
decision is a commitment to keep going rather than a willingness to start.

**The showcase therefore ships capped.** A `Household` holds at most fifty
published recipes at once (`FR-RCP-21`). That question was inherited from when
this gate was about money, and the answer changed when the gate did. As an egress
control a cap is unnecessary — thumbnails put the included allowance far past any
traffic this project expects. As a moderation control it is the missing half: the
report queue is bounded by construction, but nothing bounded the number of things
that can be reported, and every published recipe is a permanent target for the
one person who reads them.

Fifty sits above a full cookbook rather than shaping behaviour. The demo
household is thirty recipes and represents using Ladle well, so an ordinary
household never meets the limit while the pathological case stays bounded. It is
one configured figure rather than a per-household allowance, because a household
record would be a second place to establish something a single setting already
establishes. Pagination depth was the other candidate on the ladder and is
declined: it bounds egress only weakly and moderation not at all, and it degrades
the browsable discovery `FR-RCP-17` requires, which is the showcase's entire
purpose.


## If the ceiling is approached

Approached, not reached. With the spend cap on, reaching it is not an invoice to
respond to — it is the app refusing to serve. The whole ladder has to be climbed
on the way up, which is the work `NFR-OPS-11` exists to make possible, and a rung
taken late is taken during an outage.

A ladder, in order, so that the first response to the measure moving is not a
panic:

1. **Thumbnails and image budgets**, if `NFR-PERF-06` has somehow not already
   settled it.
2. **Caps on the public surface.** The per-household publishing cap is in place
   from Release 3's first day — see *The Release 3 gate* — so this rung tightens
   a figure rather than introducing a mechanism. Pagination depth stays available
   and stays a last resort, because it degrades discovery.
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

Note that the first two rungs cost nothing, and both are taken before the measure
ever moves rather than in response to it — `NFR-PERF-06` settles the first at P2,
and the publishing cap settles the second at P13. That is the whole argument for
deciding them early: with the platform's limit enforced, a showcase shipped
without a cap of Ladle's own would find that the first limit anyone meets is the
platform's, applied to everything at once, during an outage.

## Open questions

None outstanding.
