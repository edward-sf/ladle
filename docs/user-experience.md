---
name: user-experience.md
description: This file describes the target audience(s), major and minor features, and intended user experience paths for the Ladle application.
---
# User Experience

## Who is this for?

The primary audience for Ladle is the **household cook**, providing them tools to plan meals on their household calendar, manage their household membership and cookbook, and keep their household pantry stocked. This work requires regular, often unseen mental labor that could be reduced by the more integrated tooling that Ladle provides.

Another audience for Ladle is the **nutrient tracker** - the health-conscious person who wants to understand what they're consuming and whether they are hitting their health goals. Meal planning is more than deciding what to cook; it's a strategy for health and diet. Ladle's `Today` tab provides an overview of the current day's planned meals and how that plan satisfies their recommended daily values.

A third audience for Ladle is the **recipe collector** who wants to create, share, and discover recipes.

These audiences are not separate users. The same person is usually all three at different moments of the same week, which is the argument for one application rather than three. Ladle's job is to let each of those moments happen without dragging the other two along.

## Features

Features are sorted by the role they play in the product rather than by the order they will be built - sequencing belongs to [`roadmap.md`](./roadmap.md). A **major feature** is a pillar: something a person would name as their reason for using Ladle. A **minor feature** is supporting capability that serves one or more pillars and would mostly be noticed by its absence.

This document describes behavior. Entities are named (`Household`, `Meal`, `Recipe`) but never specified - fields, keys, and relationships live in [`data.md`](./data.md). Requirements here are stated as intent; the numbered, testable requirements that drive development live in [`requirements.md`](./requirements.md) and trace back to the features below.

### Major Features

#### Households

*A `Household` is Ladle's unit of collaboration. Every `Calendar`, `Cookbook`, `Pantry`, and `GroceryList` belongs to exactly one `Household`, and a `User` may belong to several - a home, a partner's home, a shared apartment. Within a `Household`, an Owner holds full control, Admins share day-to-day management, and Members participate by request.*

##### Requirements
- A `Household` is created silently at signup with the new user as its Owner. Someone cooking alone must be able to plan, shop, and cook without ever meeting an approval queue, an invitation flow, or a permissions screen.
- The role vocabulary stays unrendered until a second person joins, and nothing about the underlying model changes when they do. The machinery was always there, only unshown, so gaining a housemate is never a migration.
- Joining should cost one tap on an invitation. Understanding the difference between an *Admin* and a *Member* is not a prerequisite to eating dinner.
- Roles must be legible from the household screen. A *Member* who cannot add a meal directly should understand why before they try, not after they are refused.
- A denial must never be silent. When a request is declined, the person who made it is told, and ideally told why.
- No exit orphans data. Ownership can be transferred, and a departing *Owner* is required to transfer it before leaving.
- Dissolving a household is a destructive act and is treated as one. What will be destroyed is listed before it happens, published recipes are withdrawn from the showcase, and the household stays recoverable for a period afterwards - because the person confirming it may be in the middle of an argument rather than at the end of a decision. Copies other households already took are snapshots and are untouched.

##### User Stories
1. *As a person cooking only for myself*, I want to plan my week without setting up or thinking about a household, so that the app matches the size of my problem.
2. *As a household cook*, I want to invite my partner so they can see what is planned this week without having to ask me.
3. *As an Owner*, I want to promote someone I trust to *Admin* so that I am not the only person who can approve a grocery request while I am at work.
4. *As a Member*, I want to suggest Thursday's dinner so that I can contribute to the plan without being responsible for it.
5. *As an Owner*, I want to hand the household to someone else before I move out, so that the calendar and cookbook survive my departure.

#### Meal Planning

*Each `Household` has one meal plan `Calendar` with week and month views. A `Meal` sits on it the way an event sits on a Google or Outlook calendar: the cook sets a serving time, and the block is drawn to start at $ServingTime - (PrepTime + CookTime)$ so that the calendar shows when work begins rather than when food arrives. A `Meal` holds one or more `Recipe`s and is agnostic about whether any of them is a drink, a side, or a main. It carries a serving count, which governs how much food is shopped for, and a participant list, which records whose plates and whose nutrition ledgers it lands on.*

##### Requirements
- The calendar must answer two questions at a glance: what am I cooking tonight, and when do I need to start? The second is the one paper calendars cannot answer, and it is the reason blocks are sized by preparation rather than by service.
- Adding a meal must take fewer taps than writing it on the fridge. If it does not, people will keep using the fridge.
- Plans change constantly. Moving, shortening, or deleting a meal must ripple through the `GroceryList` without asking the cook to clean up after it.
- Week view is the working surface and the default. Month view is for orientation and for spotting the weeks that are already full.
- Servings and participants are separate numbers that usually agree. The participant headcount seeds the serving count, and the cook can raise it without removing anyone from the table, because cooking double for the week's lunches is a plan rather than a mistake.
- The serving count drives grocery quantities; the participant list drives whose nutrition the meal counts toward. Keeping them distinct is what lets leftovers, guests, and batch cooking work without special cases.
- A meal planned is not a meal cooked. The calendar must distinguish intention from history without nagging about the difference.
- Cooked and eaten are two different facts and are recorded separately. Cooking is something the household did, and it is what draws down the pantry; eating is something a particular person did, and it is what counts toward their day. They agree almost always, which is why marking a meal cooked records everyone at the table as having eaten it - and the household fact must never quietly assert the personal one, because the person who had toast instead is exactly who nutrition tracking is for.

##### User Stories
1. *As a household cook*, I want to see the whole week at once so that I can spot the night I will be too busy to cook before it arrives.
2. *As a household cook*, I want the calendar to tell me when to start cooking so that dinner is ready when everyone is home rather than an hour after.
3. *As a household cook*, I want to drag Thursday's meal to Saturday when plans change, and have the shopping adjust itself.
4. *As a household cook*, I want to build a meal out of several recipes - a main, a side, and something to drink - and treat it as one thing on the calendar.
5. *As a household cook*, I want to mark that only two of us are home on Tuesday so that I am not shopping for four.
6. *As a household cook*, I want to cook six servings for the four of us on Sunday so that there are lunches on Monday.
7. *As a Member*, I want to propose a meal for a night I will be home so that the plan reflects what the household actually wants.

#### Recipes and Cookbooks

*A `Household` keeps one `Cookbook` holding all of its `Recipe`s. Organization within it comes from collections, which are saved views rather than containers, so a recipe can sit in several at once without being copied or moved. The creator of a `Recipe` is its default Author, and further Authors may be added to share write access. A `Recipe` is Private by default - visible only within its `Household` - or Public, which lists it in Ladle's app-wide showcase where any user can find it and copy it into their own cookbook.*

##### Requirements
- Recipe entry must be forgiving. A recipe with no photo, three steps, and "a knob of butter" is a legitimate recipe and must be saveable as one. Drafts persist; nothing is lost because a field was left empty. A recipe without a photo is shown without one rather than behind a generated stand-in, because a cookbook of handwritten family recipes is mostly photoless and a grid of identical placeholders reads as a failed load.
- *Private* is the default and publishing is a deliberate act, described plainly enough that no one publishes their home address in a story about their kitchen.
- Copying a public recipe produces a recipe the copying household owns outright and may edit freely, taken as a snapshot at the moment of copying. Attribution to the original author survives the copy.
- When an author later edits a published recipe, every copy of it surfaces a quiet notice that the original has changed, showing what changed and offering the choice to take it or leave it. Nothing is ever applied without that household accepting it: an author's correction must not rewrite someone else's dinner while they are cooking it.
- An author who deletes their account leaves the recipes they published in other people's cookbooks, because those copies are snapshots the copying household owns. What goes is their name: attribution degrades to a placeholder identifying nobody. Erasure should not rewrite someone else's cookbook, and it should not let a copier appear to have written what they copied.
- Recipes belong to the cookbook and collections are views over it. Removing a recipe from a collection never deletes it, and no recipe is ever filed in the wrong place, because it can be filed in every place it belongs.
- A published recipe carrying a claim Ladle cannot verify - kosher, halal, and the frameworks resting on contested definitions - shows that claim as the author's, under their name. Any reader can report one they believe is wrong. While it waits for review the claim is suppressed and the recipe stays published, because a suppressed claim costs its author a label while a wrong one left standing costs a household its observance.
- There is deliberately no verification badge. A badge would imply a check Ladle does not perform and cannot perform, and the households most likely to rely on one are the households least able to afford its being wrong.
- The showcase must be browsable by someone with no idea what they want to cook. Discovery is the entry point for the recipe collector, not search.
- Recipes that conflict with a household member's allergies must be visibly marked wherever they appear, including in the showcase.

##### User Stories
1. *As a recipe collector*, I want to browse the showcase when I have no plan, so that I can find something worth cooking this week.
2. *As a recipe collector*, I want to copy a public recipe into my cookbook and adjust the seasoning to my taste, without my changes touching the original.
3. *As a recipe collector*, I want to be told when an author fixes a recipe I copied, see exactly what they changed, and decide for myself whether to take it.
4. *As a recipe collector*, I want a recipe to sit in both "Weeknights" and "Grandma's" without my keeping two copies of it.
5. *As a recipe collector*, I want to publish a recipe I am proud of so that other people can cook it.
6. *As a household cook*, I want to enter my grandmother's handwritten recipe exactly as she wrote it, imprecision included.
7. *As an Author*, I want to add the person I cook with as a second author so that either of us can fix the recipe after we find the mistake.
8. *As a household cook*, I want to see immediately that a recipe contains an ingredient someone here is allergic to.
9. *As a household cook who keeps kosher*, I want to know whether a recipe's kosher label is Ladle's finding or the author's word, so that I can judge how much to lean on it.
10. *As a recipe collector*, I want to report a published recipe whose dietary claim is wrong, and have someone act on it.

#### Pantry and Grocery

*Each `Household` has one `Pantry` - an inventory of `Ingredient`s on hand - and one `GroceryList` of `Ingredient`s to buy. The two are linked: adding a `Meal` to the `Calendar` populates the `GroceryList` with what that meal needs, and items acquired from the `GroceryList` flow into the `Pantry`. Owners and Admins manage both directly; Members request additions for approval.*

##### Requirements
- The list must build itself from the week's plan. A cook who plans meals in Ladle and still writes a separate shopping list has been given a second chore rather than relief from the first.
- Removing a meal removes only what that meal contributed. An ingredient that was added by hand, or that a second meal still needs, stays on the list. Getting this wrong deletes groceries people needed, so it is the sharpest correctness constraint in this feature.
- Quantities follow each meal's serving count rather than its participant headcount, so a meal cooked deliberately large is shopped for at the size it will actually be cooked.
- The list must be usable one-handed, in a shop, with a basket in the other hand: large targets, no confirmation dialogs, and grouping by `IngredientCategory`, which is a retail taxonomy for precisely this reason. The list is ordered by where things sit in a shop, not by which recipe asked for them, and the sequence those groups appear in is the household's own, seeded from a shipped default and rearranged by dragging, because what varies is the shop rather than the country.
- Checking items off at the till should be what stocks the pantry. Anything more than that will not happen.
- A pantry nobody updates is worse than no pantry. The inventory has to stay useful when it is only approximately right, and it must never block planning on being accurate.
- Before shopping, the list should say what the household already has, so that the third jar of paprika is a choice rather than an accident.

##### User Stories
1. *As a household cook*, I want the week's shopping list to assemble itself from the meals I planned, so that planning and shopping are one task.
2. *As a household cook*, I want the list grouped by aisle and ordered the way my shop is actually laid out, so that I walk it once.
3. *As a household cook*, I want to check items off as I put them in the basket and find them in my pantry when I get home.
4. *As a household cook*, I want to cancel Wednesday's meal and have exactly its ingredients leave the list - and nothing else.
5. *As a household cook*, I want to know I already have paprika before I buy more.
6. *As a Member*, I want to ask for oat milk to be added so that I do not have to catch the shopper in the hallway.

#### Nutrition Tracking

*The `Today` tab shows the current day's planned meals and what they contribute against the user's recommended daily values. Targets are computed from the demographic profile - date of birth, height, weight, sex, and activity level - against a stated goal, and every one of them can be overridden by hand. Ladle tracks energy, protein, carbohydrate, fat, fibre, and sodium. The figures are derived from the `IngredientNutrition` estimates attached to the generic `Ingredient` catalog, aggregated up through recipes and meals, and apportioned across the participants named on each meal.*

##### Requirements
- Targets are computed with a standard published equation - Mifflin-St Jeor for the basal rate, scaled by an activity factor and adjusted toward the user's goal - so that someone who does not know their own numbers is given usable ones immediately. Every computed value is overridable and the feature as a whole is dismissible: nutrition is one audience's reason for being here and another's distraction.
- The demographic inputs are health data and are handled as such. They are private to the user, never visible to other household members, never required by any other part of Ladle, and deletable without deleting the account.
- The sex input the equation requires is a separate field from pronouns and from display identity. It is asked once, in the nutrition context, with its purpose stated. Conflating the two would be bad arithmetic and a worse experience.
- Ladle is not a clinical tool. Targets are presented as general estimates; the app makes no health claims and gives no medical advice.
- Where a figure rests on convention rather than on regulation, the app says so where the figure is used, not in a policy document nobody opens. Low sodium and high protein follow published nutrition-claim rules; keto and low-carb follow common convention, because no regulator defines them, and a user reading either deserves to know which they are looking at. Professional review of these figures is deferred, and what ends the deferral is the claim rather than the calendar: it is required before Ladle says anything about health outside the app, and before any of these figures stops being labelled as convention or stops being overridable.
- The tracked set stops at energy, macronutrients, fibre, and sodium: the figures people commonly hold targets for, each reliably present in food data, and few enough that `Today` stays a glance rather than a table. Micronutrients are excluded deliberately, because generic catalog estimates for them are far weaker than for macros and would be presented with a confidence the data cannot support.
- Numbers are estimates and must read as estimates. A generic catalog cannot know the fat content of the specific chicken in someone's fridge, and a figure carried to a tenth of a gram invites a trust the data cannot support. Figures are rounded to steps coarse enough that the rounding itself conveys the uncertainty, and no nutrition figure carries a decimal place.
- The value of the `Today` tab is that it looks forward. Telling someone their plan is short on protein while there is still time to add something is worth more than telling them afterwards.
- Planned and eaten are different states, and the difference must be one tap to record and never a demand. Eaten belongs to the person, not to the meal: a participant can say they did not eat what the household cooked, and only their own day changes when they do.
- The tone is neutral throughout. Ladle reports; it does not congratulate, warn, or judge. Health features are unusually easy to make shaming, and a meal planner that makes people feel bad about dinner will not be opened.

##### User Stories
1. *As a nutrient tracker*, I want to see today's plan measured against my targets so that I can adjust before I cook rather than regret afterwards.
2. *As a nutrient tracker*, I want to know a day is light on protein while there is still time to add something to it.
3. *As a nutrient tracker*, I want to confirm what I actually ate, including the meal I replaced with toast.
4. *As a nutrient tracker*, I want targets worked out for me from what I tell Ladle about myself, so that I do not have to arrive knowing them.
5. *As a nutrient tracker*, I want to overwrite any target Ladle calculated when I disagree with it, and have my figure stick.
6. *As a user who finds those questions intrusive*, I want to decline every one of them and still use the rest of Ladle.
7. *As a household cook who does not track nutrition*, I want none of this in my way.

### Minor Features

#### Ingredient Catalog

*Ladle maintains an app-wide catalog of generic `Ingredient`s used by recipes, pantries, and grocery lists. Each carries an `IngredientNutrition` estimate and belongs to exactly one `IngredientCategory` - a retail taxonomy of produce, dairy, meat, tinned goods, dry goods and the like, whose job is to order a grocery list the way a shop is laid out. Groupings along any other axis, whether botanical like nightshades or dietary like animal products, are `Tag`s rather than categories, because an ingredient sits in exactly one shop aisle but in many of everything else. Both vocabularies are defined in [`taxonomy.md`](./taxonomy.md). The catalog is what makes the pillars interoperate: it is the reason a recipe's ingredient can be matched against a pantry's stock and totalled into a day's nutrition.*

##### Requirements
- Searching for an ingredient must tolerate the words people actually use - "spring onion" and "scallion" must reach the same entry.
- The catalog is curated rather than user-editable, so that a household's private spelling does not fragment everyone else's matching.
- A missing ingredient must not be a dead end. A cook can record what they mean, use it in their recipe, and have it reconciled with the catalog later.
- Category is the shop's axis, not the botanist's. A grouping that would not help someone find something in a supermarket belongs in the tag vocabulary instead.
- The category set is global and an ingredient's category never depends on where its household shops, which is what keeps the catalog single-valued and a published recipe meaningful in every market. What varies is the order the categories are walked in, and that belongs to the `Household` rather than to the ingredient or to a locale, because the thing it has to match is one particular shop.
- Ingredient tags are curated by people. Suggestion tooling proposes terms when an ingredient enters the catalog and an Application Administrator approves them before it is published, because these tags are the base that recipe-level allergy checking joins against and inference must never have the last word on one.

##### User Stories
1. *As a household cook*, I want to find the ingredient I mean on the first search, whatever I happen to call it.
2. *As a household cook*, I want to write a recipe containing something the catalog has never heard of, and still have the rest of the recipe work.

#### Dietary and Allergy Profiles

*A `User` records allergies as individual `Ingredient`s ("garlic") or as `Tag`s covering a whole group ("nightshades", "tree nuts", "shellfish"), and may observe one or more `DietaryModel`s - frameworks of rules such as Vegan, Keto, Kosher, or High Protein, which combine.*

##### Requirements
- Allergies are a safety feature, not a preference. They are enforced absolutely in recommendation and surfaced as a warning everywhere a recipe is displayed, never quietly filtered in a way that could be mistaken for absence.
- Dietary models are preferences and shape ranking rather than blocking. Models combine, so someone can be both Kosher and vegetarian without the app choosing one.
- A compliance claim is either derived or attributed, never inferred. Where Ladle can work a framework out from ingredients or nutrition it does so; where it cannot - kosher and halal turn on sourcing, certification, and preparation rather than on an ingredient list - the claim is the author's, shown as theirs, and a household observing that framework is told which kind of claim it is looking at. On a published recipe an attributed claim can be reported and reviewed, which is the only recourse Ladle offers and is offered honestly as such.
- A household plans for everyone at the table. Where the members of a meal conflict, the conflict is shown rather than resolved automatically.
- Allergen groups are tags rather than categories, so a single ingredient can carry every group it belongs to. A group that no tag expresses is an allergy Ladle cannot protect anyone from, which leaves the allergen facet with the least room for gaps of anything in the product.
- Group and specific tags coexist. A cashew carries both the tree-nut group and its own term, so that someone allergic to cashews alone is not made to avoid every nut in the catalog.
- An allergen tag asserts presence; a dietary tag asserts compliance. They are opposite claims and neither implies the other, so the absence of an allergen tag is never treated as evidence of safety - an untagged ingredient and a verified-safe one look identical, and only one of them is.

##### User Stories
1. *As a household cook*, I want a guest's allergy to be visible on every recipe I consider for the meal they are attending.
2. *As a user*, I want to observe two dietary frameworks at once without the app treating that as a contradiction.

#### Profile and Identity

*A `User` has a public face - display name, profile picture, an optional "about me" - and private demographic data used for nutrition targets and never shown to others.*

##### Requirements
- The line between public and private must be stated on the screen where the data is entered, not buried in a policy document.
- Pronouns are optional, self-selected, and used wherever the app refers to a person in the third person.
- A profile with nothing but a display name is complete. Nothing beyond that is required to use Ladle.

##### User Stories
1. *As a user*, I want to know exactly which parts of my profile the other people in my household can see.
2. *As a recipe collector*, I want the recipes I publish to carry my name and picture.

#### Application Preferences

*Per-user settings covering theme mode (Light, Dark, System), a curated `Theme`, unit system (US, Metric), language, and timezone.*

##### Requirements
- These preferences are per user, not per household. Two people sharing a pantry can read it in different units, and the underlying quantities are the same quantities. Settings that describe a shared artifact rather than a person - the order a `GroceryList` is walked in, which follows one shop - belong to the `Household` instead, and live with the feature they serve.
- Themes are curated rather than freeform, so that contrast and legibility hold in every combination the app ships. Details in [`user-interface.md`](./user-interface.md).
- Timezone drives when "today" begins, which matters for both the `Today` tab and any reminder that fires near midnight.
- Language selection is inert until a translation service exists, and should not be offered before it does.

##### User Stories
1. *As a user*, I want to read quantities in the units I cook in, whatever units the recipe author used.
2. *As a user*, I want the app to follow my device's dark mode without my having to tell it twice.

#### Tags, Search, and Recommendation

*`Tag`s classify recipes and ingredients for search, drive recommendation, and express incompatibility constraints between recipes that do not belong in the same meal. The vocabulary is curated, closed, and faceted - every tag belongs to exactly one of allergen, dietary, course, cuisine, method, season, or effort - and is defined in [`taxonomy.md`](./taxonomy.md). A trained classifier applies the five discovery facets - course, cuisine, method, season, effort - to a `Recipe` from its ingredients and steps whenever it is created or updated. Allergen tags are curated on ingredients, and dietary tags are derived from those or declared by the author; neither is ever inferred.*

##### Requirements
- Cuisine tags are hierarchical and every applicable level is applied, so a Sichuan braise is tagged both Chinese and Sichuan and a search for the broad tradition finds its regional cooking. Regions exist only where the cooking genuinely differs.
- The vocabulary is closed so that everything built on it stays reliable. Search, recommendation, and incompatibility rules can only be trusted when "weeknight", "week-night", and "quick" cannot become three unrelated concepts.
- Facets are what make a tag more than a label. Search can offer "filter by cuisine" without knowing which terms are cuisines, and the allergen rule can be written against a facet rather than a hardcoded list, so adding an allergen never means revisiting the code that protects people from one.
- Automatic tagging is what makes a closed vocabulary bearable. Nobody should have to learn Ladle's tag list to have their recipe found, and a recipe typed in at speed with no tags at all must still be discoverable.
- The classifier decides only the five discovery facets. Every tag that carries a safety claim or a promise of compliance is curated by a person or derived deterministically, so the accuracy bar is a question about search quality rather than about trust.
- Dietary compliance is worked out, not guessed. Vegan, vegetarian, pescatarian, dairy-free, and gluten-free follow from the curated tags on a recipe's ingredients; keto, low-carb, high-protein, and low-sodium follow from the nutrition Ladle already computes; kosher, halal, and the frameworks resting on contested definitions are the author's own claim, shown as theirs and never as a Ladle verification.
- Derivation depends on every ingredient being reconciled with the catalog, because only a reviewed ingredient's missing allergen tag means anything. A recipe still holding an unreconciled ingredient carries no derived dietary tag and reports its allergy check as incomplete rather than as clean.
- Manual tagging exists independently of the classifier and is never removed by it. An author frequently knows something about their own recipe that no model will recover from its ingredient list.
- Classification runs server-side on create and update, so that the model can be retrained and swapped without shipping an app release. Tagging is never on the path between a cook and a saved recipe: the recipe saves immediately and is classified behind it.
- The corpus is built only from public-domain and permissively licensed open sources, confirmed before any labelling begins. A licence that forbids commercial training would invalidate the corpus after the work was done, which is the most expensive moment to discover it.
- That constraint bites unevenly. Openly licensed recipe text skews old and Anglophone, and the tags least likely to be represented in it are exactly the long-tail cuisines the vocabulary was expanded to honour.
- A tag the corpus cannot support ships dormant rather than being cut from the vocabulary or applied badly. The classifier emits only tags that reached their floor; the rest can still be searched and applied by hand, and a model guessing at a term it has barely seen produces confident nonsense that is worse than an absent tag.
- Dormancy is invisible to the people using Ladle and resolves itself through use. An author applying a dormant tag by hand produces exactly the labelled example it needs, corrections are durable so the label survives, and the backfill after a retraining pass activates the tag across every recipe that should carry it. The full vocabulary therefore ships on day one without the corpus having covered all of it first.
- The training corpus is sized by the vocabulary, not by the recipe count. A classifier needs a floor of examples for every tag it decides, so the corpus is a stratified sample built to that floor rather than a flat random draw - which would leave the rare cuisines with a handful of examples each and reveal it only at evaluation.
- The floor is measured per facet rather than picked, because a facet of five coarse terms and a facet of ninety-four fine ones do not need the same evidence. A first tranche is labelled at a working figure, the accuracy curve is fitted from it, and each facet's floor is set where its curve flattens.
- Every term added to the vocabulary enlarges that corpus. Roughly two thirds of the classifier's tags are cuisines, so the cuisine facet grows on evidence rather than ambition: a region is added when recipes do not fit the existing terms or someone who cooks that food asks for it.
- When a newly trained model ships, existing recipes are backfilled rather than left at whatever the previous model gave them. A vocabulary that only applies to recipes written after a particular release is a search index with a hole in it.
- An Author can correct the tags on their own recipe, and a correction is durable. A later pass may add tags, but it never restores one a person removed. A classifier that overwrites corrections teaches people to stop correcting it.
- Classification is a suggestion everywhere except allergens. An allergen tag is a safety claim, so allergy checking is grounded in ingredient-level matches against the curated catalog rather than in anything a model inferred, and an absent tag is never treated as evidence of absence.
- Search finds a recipe by its title, by an ingredient it uses, or by its tags, and treats the household's cookbook and the showcase as separate places. Discovery is the way into the showcase, but a cookbook of two hundred recipes still has to be searchable - and searching by ingredient is the query people actually have, because it is the one that starts at the fridge.
- Recommendation must be explainable. "Because you have most of this already" and "because you cooked this last month" are reasons a person can act on; an unexplained ranked list is not.
- What the household already has in the `Pantry` is a first-class input to recommendation. Suggesting meals that shorten the shopping list is the most useful thing Ladle can suggest.
- Incompatibility is advisory. Ladle can say two recipes make an odd meal; it does not prevent the cook from disagreeing.

##### User Stories
1. *As a household cook*, I want suggestions weighted toward what is already in my pantry, so that planning reduces shopping.
2. *As a household cook*, I want to know why a recipe was suggested to me.
3. *As a recipe collector*, I want the recipe I typed in at midnight to be findable later without my having tagged it.
4. *As an Author*, I want to tag my own recipe when I know better than the classifier does.
5. *As an Author*, I want to remove a tag the classifier got wrong and have it stay removed.

#### Notifications and Reminders

*Time-based prompts tied to the calendar and pantry: start-cooking reminders derived from a meal's preparation window, and expiry warnings from the pantry's stock.*

##### Requirements
- Every notification must be worth the interruption, and every category must be independently switchable off.
- Reminders derive from data the app already holds, so that no one is asked to set an alarm Ladle could have set itself.
- Household-wide events notify the people they concern - the person who made a request, the people who can approve it - and no one else.

##### User Stories
1. *As a household cook*, I want to be told to start cooking, rather than remembering to check.
2. *As a household cook*, I want to hear about the spinach before it turns, and not once a day about everything else.

#### Reporting and Moderation

*One report queue covering everything published to the app-wide showcase: dietary claims believed to be wrong, spam, unsafe instructions, and copied content. Reports route to the Application Administrator, who rules on them. A contested dietary claim is suppressed while it waits, though the recipe carrying it stays published.*

##### Requirements
- Reporting is available wherever a public recipe is read, costs one tap and a reason, and never requires the reporter to write an explanation. A report path that asks for an essay collects nothing.
- One queue with several reasons, from the first release. A public showcase needs all of this eventually, and the second reason always arrives sooner than a roadmap expects - building the surface once is markedly cheaper than building it twice.
- Suppression is not a verdict and must not read as one. The author is told immediately, sees the reason, and can respond before anyone rules.
- Reports are not votes. Volume may order the queue; it never decides an outcome. A coordinated campaign must not be able to remove anything an administrator has not agreed to - escalation keys on how long a report has waited and what kind it is, never on how many people filed it.
- The queue is worked by the Application Administrator - an application-level role, unrelated to a household's Owner and Admin, held at present by one person. Everything else about moderation follows from that: the design assumes a single reader and is built so that the important things happen without one.
- That rests on labelling and moderation never overlapping: the queue has nothing in it until recipes are published, and the release is gated on a classifier whose corpus is labelled first. The assumption is recorded so that it is tested rather than assumed, and if it fails the answer is capacity rather than a target quietly slipping.
- Each phase watches the measure that carries its deadline. Before launch that is labelling throughput against the tag floors still unmet and the release date; afterwards it is the age of the oldest unresolved report in each tier against that tier's target. Waiting for someone to say they are underwater is not a measure, because that is the thing people reliably do not say.
- Turnaround is tiered by what happens without a person, not by how serious a category sounds. A disputed dietary claim is suppressed the moment it is reported, so the reader is already protected and what waits is the author's restoration; an unsafe instruction triggers nothing at all, so until someone reads it nothing has happened. The second is the urgent one, and it is the only urgent one.
- An unattended queue must fail toward caution, because a single administrator is sometimes simply away. An urgent report left past its target withdraws the recipe from the showcase by itself until it is ruled on - the recipe stays fully visible to its own household, and only strangers stop seeing it.
- The queue is bounded by design rather than by goodwill. A person may report a given recipe once, daily reports are capped, and many reports of the same thing collapse into one item carrying a count. The scarce resource is one person's attention, and anything unbounded consumes it.
- A resolved report goes back to the person who raised it. Reporting into silence teaches people to stop, and the reports Ladle most needs are the ones about claims nobody else is checking.

##### User Stories
1. *As a household cook who keeps kosher*, I want a contested claim hidden while it is checked, rather than displayed until someone gets round to it.
2. *As an Author*, I want to hear that a claim of mine is disputed, and why, rather than noticing the label has gone.
3. *As a recipe collector*, I want to report a recipe and find out what came of it.

#### Account Security and Privacy

*Authentication, session management, and the controls governing what a user shares with their households and with the showcase.*

##### Requirements
- Signing in must be routine and rare. Sessions persist across app restarts, and a returning user lands on `Today`, not on a login screen.
- The defences match the threat that actually exists. Nobody is mounting a targeted attack to read a shopping list; what happens to apps like Ladle is a password reused from somewhere it leaked, tried in bulk. So a password known to have appeared in a breach is refused, and sign-in attempts are rate limited. Multi-factor authentication is deliberately not offered: a second factor on an app that is signed into twice a year has usually been lost by the time it is needed, and a lockout would need a recovery path that a single operator cannot staff. That is a decision to revisit if Ladle ever holds something worth stealing, not a gap to fill quietly.
- Publishing is the only action that makes anything visible outside a household, and it must be clearly reversible.
- Account deletion removes the person's data and transfers or dissolves the households that depend on them, rather than leaving either in an undefined state.

##### User Stories
1. *As a user*, I want to open the app and be where I left off, without signing in again.
2. *As a user*, I want to unpublish a recipe and have it leave the showcase.
3. *As a user*, I want to delete my account and understand, before I confirm, what happens to the household I own.

## User Experience Paths

Features describe capability. These paths describe the seams between them - the sequences a person actually moves through, where a gap between two well-built features is felt as a broken product.

### First run

The shortest path from installing Ladle to getting value out of it, walked by someone who has not decided whether they want it yet.

1. Sign up, and give a display name. Nothing else is required.
2. Record allergies and dietary models, or skip. This is asked early because it is a safety input to everything that follows, and it is skippable because a first-run questionnaire is where applications lose people.
3. A household is created silently, with the new user as its *Owner*. No naming, no invitations, no explanation of roles.
4. Land on `Today`, which is empty and says what to do about it.
5. Plan one meal - from the showcase, since the cookbook is empty. The grocery list fills itself as a consequence, which is the first moment Ladle does something a paper calendar cannot.

### Bringing in the household

Walked once, usually days after first run, when one person's plan becomes several people's plan.

1. Name the household, which until now has not needed a name.
2. Invite by link or address. The invitation says which household, from whom, and what the recipient will be able to see.
3. The recipient installs, signs up, and accepts, arriving directly in the household rather than in an empty first-run state.
4. Assign a role. The default is *Member*; promotion to *Admin* is deliberate.
5. The new member sees the week already planned, which is the payoff for joining.

### Planning a week

The core loop, walked weekly, and the flow that has to be pleasant because it is the one people repeat.

1. Open the calendar in week view and see which nights are already spoken for.
2. Add meals - from the cookbook, from the showcase, or from suggestions weighted by what the pantry already holds.
3. Set serving times; blocks size themselves backwards through preparation and cooking time.
4. Name participants where the table is smaller than the household, and raise the serving count where leftovers are the point.
5. Review any conflicts the plan raises: an allergy among the participants, two recipes that do not belong in one meal, a night with no time to cook.
6. The grocery list is now complete and needs no separate assembly.

### Shopping

Walked in a shop, one-handed, on a phone that may have no signal in the back aisles.

1. Open the grocery list, grouped by aisle.
2. See what the pantry already covers before deciding what to buy.
3. Check items off while walking.
4. Add anything unplanned in the moment - a *Member* requests, an *Owner* or *Admin* adds directly.
5. Checked items become pantry stock. Nothing further is required at home.

### Cooking a meal

Walked most days; the only path where the phone is competing with a hot pan for attention.

1. A reminder fires when preparation should start.
2. Open the meal and see every recipe in it together, rather than switching between them.
3. Cook, with the screen staying awake and the steps large enough to read from across the counter.
4. Mark the meal cooked. Ingredients decrement from the pantry, and everyone at the table is recorded as having eaten it - correctable afterwards by anyone who did not.

### Discovering and keeping a recipe

The recipe collector's loop, which touches the household features only at its end.

1. Browse the showcase without a specific goal.
2. Open a recipe and see its author, its tags, and any conflict with the household's allergies.
3. Copy it into the household cookbook, taking a snapshot the household now owns, and file it into as many collections as it belongs to.
4. Edit it freely, with attribution to the original author preserved, and take or ignore the author's later corrections as they are offered.
5. Plan it, or publish an adaptation of it back to the showcase.
