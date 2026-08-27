--- name: taxonomy.md description: This file defines Rootloom's curated
vocabularies - the faceted `Tag` set applied to recipes and ingredients, and the
retail `IngredientCategory` set that orders a grocery list. ---
# Taxonomy

Rootloom's search, recommendation, allergy checking, and grocery ordering all
rest on two curated vocabularies. This file defines them.

Both are **closed**: Rootloom authors every term, and neither households nor the
classifier may coin a new one. That constraint is what makes the surfaces built
on top of them reliable - search, recommendation, and incompatibility rules can
only be trusted when "weeknight", "week-night", and "quick" cannot become three
unrelated concepts. The cost is curation, and it is paid deliberately.

This file is the vocabulary. How it is stored belongs to
[`data.md`](./data.md); how it is applied belongs to
[`user-experience.md`](./user-experience.md).

## Tags

A `Tag` belongs to exactly one **facet**. The facet is what makes a tag more
than a label: a safety rule can be written against the allergen facet without
naming individual allergens, and search can offer "filter by cuisine" without
knowing which terms happen to be cuisines.

The facet list itself is closed. Adding a facet is a schema change and a
deliberate act; adding a tag within an existing facet is curation.

| Facet | Asserts | Applied to | Assigned by |
| --- | --- | --- | --- |
| `allergen` | This is present | Ingredients, and recipes by derivation | Administrators, assisted |
| `dietary` | This recipe complies | Recipes | Derivation, or the author |
| `course` | This is the kind of dish | Recipes | The classifier |
| `cuisine` | This is the tradition | Recipes | The classifier |
| `method` | This is how it is cooked | Recipes | The classifier |
| `season` | This is when it is best | Recipes | The classifier |
| `effort` | This is what it costs to make | Recipes | The classifier |

Only the bottom five facets are decided by a model. Everything that carries a
safety claim or a promise of compliance is either curated by a person or
derived deterministically, which is what keeps the classifier's accuracy bar a
question about search quality rather than about trust.

### Polarity: presence versus compliance

The `allergen` and `dietary` facets look similar and mean opposite things, and
conflating them is the most likely source of a dangerous bug in this system.

- An **allergen tag asserts presence**. `allergen:peanut` means the thing
  contains peanut.
- A **dietary tag asserts compliance**. `dietary:vegan` means the recipe
  satisfies the rules of that framework.

So `dietary:gluten-free` and the absence of `allergen:gluten` are not the same
claim, and neither implies the other. Compliance is a positive assertion made
after evaluating a whole recipe; absence is merely the state of not having been
tagged, which is also what an untagged ingredient looks like. Nothing may treat
the absence of an allergen tag as evidence of safety.

### Derivation requires a fully reconciled recipe

Deriving a dietary tag from ingredient tags depends on every ingredient in the
recipe being a curated catalog entry, because only then does an absent allergen
tag mean the allergen is absent rather than unreviewed.

A cook may write a recipe using an ingredient the catalog does not yet hold, and
that recipe is legitimate. But until every one of its ingredients is reconciled
with the catalog, it carries no derived dietary tag at all, and its allergy
check reports as **incomplete** rather than as clean. An unreviewed ingredient
and a verified-safe one look identical, and only one of them is.

### Active and dormant tags

Every tag the classifier decides carries a state, and that state is a property
of the training data rather than of the term itself.

A tag is **active** once the corpus holds its floor of labelled examples, and
the classifier may then apply it. Below that floor the tag is **dormant**: it
exists in the vocabulary, it can be searched, and an author may apply it by
hand, but the classifier never emits it. A model guessing at a term it has
barely seen produces confident nonsense, and a wrong `cuisine:oaxacan` is worse
than an absent one.

The floor is **per facet, and measured rather than chosen**. Facets differ in
how much evidence they need: `season` has five coarse terms, while `cuisine` has
94 with fine distinctions between neighbours. Each facet's floor is set where
its accuracy curve stops improving with more data.

That is circular on its face - the floor comes from evaluation, and evaluation
needs labelled data the floor is meant to scope - and it resolves by tranches.
A first tranche is labelled at a working figure of fifty examples per tag, the
curve is fitted from it, per-facet floors are set where each curve flattens, and
facets that fall short are topped up. Fifty is a scoping device for budgeting the
first tranche, not a commitment to a number.

Dormancy is a state of assignment, not of existence. A dormant tag filters and
searches exactly like an active one; there are simply fewer recipes carrying it,
which is honest rather than broken. It is also an internal state, surfaced to
administrators and not to the people using the app - nobody writing a recipe needs
know which terms the model has learned yet.

The long tail therefore fills itself from use. An author who applies
`cuisine:eritrean` by hand has produced exactly the labelled example that tag
needs, corrections are durable so the label survives, and the backfill that
follows a retraining pass activates the tag retroactively across every recipe
that should carry it.

This is what lets the full vocabulary ship on day one without the corpus having
to cover all of it first. It applies to every classifier-decided facet, not only
to cuisine, though cuisine is where it will be felt.

A tag that stays dormant is reviewed at each retraining pass, never retired on a
timer. That is the moment activation states are recalculated anyway and the
evidence is freshest, so the review attaches to an event that already exists
rather than to a calendar someone has to remember - with the consequence that
the retraining schedule is also the vocabulary's review schedule. An Application
Administrator may
seed a dormant tag by sourcing examples, keep it because it is real food that
has simply not appeared yet, or retire it through the migration described under
Curation. Automatic retirement is specifically rejected: dormancy
correlates with exactly the cuisines an openly licensed corpus already
under-represents, so a rule that deleted long-dormant terms would quietly erase
the food this vocabulary was expanded to include.

### `allergen`

Ingredient-level allergen tags are the base that recipe-level allergy checking
joins against. They are curated by hand - assisted by suggestion tooling, but
never assigned by inference - because this is the one facet carrying a safety
claim.

The set covers the regulated major allergens of both the US and the EU, plus
the common non-regulatory sensitivities people actually filter on.

| Tag | Notes |
| --- | --- |
| `allergen:dairy` | Milk and milk derivatives |
| `allergen:egg` | |
| `allergen:fish` | Finned fish |
| `allergen:crustacean` | Prawn, crab, lobster |
| `allergen:mollusc` | Clam, mussel, squid, octopus |
| `allergen:tree-nut` | Carries a sub-tag per nut where it matters |
| `allergen:peanut` | A legume, tagged separately because the allergy is |
| `allergen:sesame` | |
| `allergen:soy` | |
| `allergen:wheat` | |
| `allergen:gluten` | Broader than wheat: barley, rye, spelt |
| `allergen:celery` | EU-regulated |
| `allergen:mustard` | EU-regulated |
| `allergen:lupin` | EU-regulated |
| `allergen:sulphite` | EU-regulated; common in dried fruit and wine |
| `allergen:nightshade` | Tomato, potato, aubergine, pepper, chilli |
| `allergen:allium` | Garlic, onion, leek, shallot, chive |
| `allergen:corn` | |
| `allergen:coconut` | Classified as a tree nut in the US, not in the EU |
| `allergen:yeast` | |

`allergen:tree-nut` is a group, and a tree nut ingredient carries both the group
tag and its specific one - almond, walnut, cashew, pistachio, hazelnut, pecan,
macadamia, brazil - so that someone allergic to cashews alone is not made to
avoid every nut.

### `dietary`

A recipe carries a dietary tag when it satisfies that framework's rules
completely. These drive ranking rather than blocking: a household observing a
framework sees compliant recipes first, not exclusively.

Dietary tags are never assigned by the classifier. A compliance claim that a
model guessed is a promise Rootloom cannot keep, and almost all of these can be
worked out exactly.

**Derived from ingredient tags.** `dietary:vegan`, `dietary:vegetarian`,
`dietary:pescatarian`, `dietary:dairy-free`, `dietary:gluten-free`.

**Derived from computed nutrition.** Each of these is a numeric test against the
figures Rootloom already computes for a recipe. Where a nutrition-claim
regulation defines the term, Rootloom adopts its figure rather than inventing
one, so that a tag means what the packaging in someone's hand means.

| Tag | Threshold | Basis |
| --- | --- | --- |
| `dietary:low-sodium` | 140 mg sodium or less per serving | FDA nutrient content claim rules |
| `dietary:high-protein` | 20% or more of energy from protein | EU Regulation 1924/2006; the FDA's 20% of Daily Value agrees |
| `dietary:low-carb` | 26% or less of energy from carbohydrate | Convention - no regulator defines this term |
| `dietary:keto` | 10% or less of energy from carbohydrate | Convention - no regulator defines this term |

Three caveats attach to that table.

**US and EU claims use different bases** - the US expresses them per serving,
the EU per 100g - and Rootloom computes per serving, so it follows the
per-serving form wherever the two diverge.

**The citations are for traceability, not authority.** Claim regulations are
amended, so the figures should be checked against current text before they ship.

**Two of the four rest on convention and say so.** No regulator defines keto or
low-carb, so Rootloom chose those figures itself, and the app labels them as
convention where they are used rather than presenting all four as equivalent.
Professional review of these thresholds - and of the target equation, which is
the larger claim - is deliberately deferred past the first release. What ends
the deferral is the claim rather than the calendar: review is required before
Rootloom says anything about health outside the app, in marketing, store copy,
or any comparative or outcome claim, and before these figures stop being
labelled as convention or stop being overridable. The deferral is affordable
exactly as long as Rootloom claims nothing more for them than that they are
common convention.

**Declared by the author, never inferred.** `dietary:kosher`, `dietary:halal`,
`dietary:paleo`, `dietary:whole-food`, `dietary:low-fodmap`. Kosher and halal
depend on sourcing, certification, and preparation rather than on which
ingredients appear in a list, and the others rest on contested definitions.
These are surfaced as the author's claim, attributed to them, and never
presented as something Rootloom verified.

Frameworks combine rather than compete: a recipe may be both `dietary:kosher`
and `dietary:vegetarian`, and a `User` may observe both.

### `course`

A `Meal` is deliberately agnostic about whether a `Recipe` is a drink, a side,
or a main - course lives on the recipe, for search and for incompatibility
advice, not on the meal.

`course:breakfast`, `course:brunch`, `course:lunch`, `course:dinner`,
`course:appetizer`, `course:main`, `course:side`, `course:salad`,
`course:soup`, `course:bread`, `course:dessert`, `course:snack`,
`course:drink`, `course:cocktail`, `course:sauce`, `course:condiment`,
`course:preserve`, `course:base`

### `cuisine`

The most culturally loaded facet, and the one most likely to be got wrong by
being too coarse.

Cuisine tags are hierarchical, and a recipe carries every level that applies -
a Sichuan braise is tagged `cuisine:chinese` and `cuisine:sichuan` both. This
mirrors the group-and-specific pattern used for tree nuts, and it means a search
for a broad tradition finds its regional cooking without any query expansion.

A region is added **only where the cooking genuinely differs** - different
staples, different techniques, a difference a cook would notice. Uniform depth
is not a goal: some traditions warrant several regions, others are a single
term, and inventing sub-regions nobody cooks by would make the vocabulary worse
rather than more precise.

| Parent | Regions |
| --- | --- |
| `cuisine:chinese` | `sichuan`, `cantonese`, `hunan`, `shanghainese`, `dongbei` |
| `cuisine:indian` | `north-indian`, `south-indian`, `bengali`, `gujarati`, `goan` |
| `cuisine:italian` | `northern-italian`, `roman`, `neapolitan`, `sicilian` |
| `cuisine:spanish` | `basque`, `catalan`, `andalusian` |
| `cuisine:french` | `provencal`, `alsatian` |
| `cuisine:mexican` | `oaxacan`, `yucatecan`, `northern-mexican` |
| `cuisine:american` | `southern-us`, `cajun-creole`, `new-england`, `tex-mex`, `californian` |
| `cuisine:middle-eastern` | `levantine`, `persian`, `iraqi` |
| `cuisine:north-african` | `moroccan`, `tunisian`, `egyptian` |
| `cuisine:west-african` | `nigerian`, `senegalese`, `ghanaian` |
| `cuisine:east-african` | `ethiopian`, `eritrean`, `somali` |
| `cuisine:southeast-asian` | `thai`, `vietnamese`, `malaysian`, `indonesian`, `filipino`, `singaporean` |
| `cuisine:caribbean` | `jamaican`, `cuban`, `trinidadian`, `puerto-rican` |
| `cuisine:south-american` | `peruvian`, `brazilian`, `argentine`, `colombian` |
| `cuisine:eastern-european` | `polish`, `hungarian`, `russian`, `ukrainian`, `czech` |
| `cuisine:jewish` | `ashkenazi`, `sephardi`, `mizrahi` |
| `cuisine:nordic` | `swedish`, `danish`, `norwegian`, `finnish`, `icelandic` |

Traditions carrying no regional split are applied alone: `cuisine:japanese`,
`cuisine:korean`, `cuisine:turkish`, `cuisine:greek`, `cuisine:portuguese`,
`cuisine:german`, `cuisine:british`, `cuisine:irish`, `cuisine:south-african`,
`cuisine:pakistani`, `cuisine:sri-lankan`. A term moves out of this list when
someone makes the case that its regions cook differently enough to matter, which
is a curation decision recorded with its reasoning.

A recipe may carry more than one unrelated tradition, which is the honest way to
tag food that came from somewhere and was cooked somewhere else.

**The set above is the launch vocabulary and it grows on evidence.** A region is
added when there is a concrete case for it - recipes that do not sit properly in
any existing term, or a request from someone who cooks that food - and the case
is recorded alongside the addition. Rootloom does not go looking for regions to
add, because the cuisine facet is the largest part of the vocabulary and every
term added to it enlarges the corpus that has to be labelled before the
classifier can be trained.

### `method`

`method:bake`, `method:roast`, `method:grill`, `method:broil`, `method:fry`,
`method:deep-fry`, `method:stir-fry`, `method:saute`, `method:braise`,
`method:stew`, `method:steam`, `method:poach`, `method:boil`,
`method:slow-cook`, `method:pressure-cook`, `method:sous-vide`,
`method:air-fry`, `method:smoke`, `method:cure`, `method:ferment`,
`method:pickle`, `method:no-cook`, `method:one-pot`, `method:sheet-pan`

### `season`

`season:spring`, `season:summer`, `season:autumn`, `season:winter`,
`season:year-round`

Seasonality is hemispheric. The tag names the season, and the client resolves
it against the household's locale, so a `season:summer` recipe surfaces in
December in Sydney and in July in Toronto.

### `effort`

What a recipe costs the cook in time and attention, which is the axis a
weeknight meal plan is actually built along.

`effort:quick`, `effort:weeknight`, `effort:make-ahead`, `effort:batch-cook`,
`effort:freezer-friendly`, `effort:hands-off`, `effort:project`,
`effort:beginner`, `effort:cook-with-kids`

## Incompatibility

Incompatibility rules are expressed as pairs of tags that make an odd meal when
they appear together in one `Meal` - two `course:dessert` recipes, or a
`cuisine:japanese` main beside a `cuisine:mexican` side.

Every such rule is **advisory**. Rootloom can say two recipes make an unusual
meal; it never prevents the cook from disagreeing, because the cook is
frequently right and the rule is a generalization.

## Ingredient categories

Every `Ingredient` belongs to exactly one `IngredientCategory`. Unlike tags,
this is a single-valued classification, and it exists to do one job: order a
`GroceryList` so that a shopper walks the shop once.

The category is therefore a **retail** axis, not a botanical or dietary one.
Groupings along any other axis are tags. The test is simple: a grouping that
would not help someone find something in a supermarket does not belong here.

| Category | Contains |
| --- | --- |
| `produce` | Fresh fruit and vegetables |
| `herbs-fresh` | Fresh herbs, usually shelved with produce but bought separately |
| `meat` | Beef, pork, lamb, game |
| `poultry` | Chicken, turkey, duck |
| `seafood` | Fish and shellfish, fresh and frozen |
| `dairy-and-eggs` | Milk, cheese, butter, yoghurt, eggs |
| `refrigerated` | Chilled prepared goods, doughs, fresh pasta, tofu |
| `frozen` | Everything from the freezer aisle |
| `bakery` | Bread, rolls, pastries |
| `dry-goods` | Pasta, rice, grains, pulses, flour, sugar |
| `baking` | Leaveners, chocolate, extracts, decorating supplies |
| `canned-and-jarred` | Tinned tomatoes, beans, fish, preserves |
| `condiments-and-sauces` | Ketchup, soy, vinegar-based sauces, dressings |
| `oils-and-vinegars` | Cooking oils, vinegars |
| `spices-and-seasonings` | Dried herbs, ground spices, salt, stock cubes |
| `beverages` | Non-alcoholic drinks |
| `alcohol` | Wine, beer, spirits, including cooking wine |
| `snacks` | Crisps, biscuits, confectionery |
| `international` | Aisles shops group by origin rather than by kind |

### Ordering is a household setting

The category set is **global**: an ingredient's category never depends on where
its household shops, which keeps the catalog single-valued and keeps a public
recipe meaningful in every market.

What varies is the **order**, and it varies by shop rather than by country. A
`Household` therefore holds its own ordered sequence of these categories, seeded
from a shipped default and rearranged by dragging. British shops tend to open on
produce and end on frozen; American shops commonly run the perimeter; the shop
at the end of any particular road does whatever it does. Letting a household
state its own order solves the problem at the granularity it actually occurs,
and needs no locale tables curated or inferred from a country code.

The ordering belongs to the household rather than to each member, because the
`GroceryList` is one shared artifact and whoever shops is walking one shop.

## Curation

- **The classifier assigns the five discovery facets only** - course, cuisine,
  method, season, effort - and is constrained to this vocabulary, unable to coin
  a term. Its worst failure is a poor search result, which is what makes a
  recall-favouring accuracy bar defensible.
- **Allergen and dietary tags never come from the classifier.** Allergen tags
  are curated on ingredients; dietary tags are derived from those tags or from
  computed nutrition, or else declared by the author and attributed to them.
- **Ingredient tags are curated by people**, with suggestion tooling proposing
  terms when an ingredient enters the catalog and an Application Administrator
  approving them
  before it is published. Inference never has the last word on an allergen tag.
- **An author's correction to their own recipe is durable.** A later
  classification pass may add tags, but it never restores one a person removed.
- **Retiring a term is a migration, not a deletion.** Recipes carrying a retired
  tag are remapped in the same change that removes it, so no recipe is left
  pointing at a term that no longer exists.
- **Adding a term has a labelling cost.** The classifier needs a floor of
  examples for every tag it decides, so the corpus is sized by the vocabulary
  rather than by how many recipes exist. Roughly two thirds of the classifier's
  terms are cuisines, which makes that facet the one whose growth is felt most
  directly in the schedule.
- **The corpus draws only on public-domain and permissively licensed sources.**
  That text skews old and Anglophone, so the terms hardest to reach a floor for
  are the long-tail cuisines this vocabulary exists to honour. The tags that
  cannot reach their floor ship dormant rather than being cut or written to
  order, and activate as use supplies the examples. Coverage should still be
  sampled per tag before labelling begins, so that what will be dormant at
  launch is known in advance rather than discovered at evaluation.
