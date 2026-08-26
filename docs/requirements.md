---
name: requirements.md
description: This file describes the functional and non-functional requirements of the Ladle application, which should be used to guide test-driven development.
---
# Requirements

This file is the canonical, testable statement of what Ladle must do. [`user-experience.md`](./user-experience.md) states requirements as intent, in prose, beneath the feature they shape; this document turns that intent into numbered claims a test can pass or fail.

## Conventions

- **Identifiers** are `FR-<AREA>-<NN>` for functional requirements and `NFR-<ATTRIBUTE>-<NN>` for non-functional ones. Each functional area maps to exactly one feature in [`user-experience.md`](./user-experience.md), except `JRN`, which maps to its user experience paths.
- **Identifiers are stable.** A withdrawn requirement's number is retired rather than reused, and a new requirement is appended to the end of its area rather than inserted, so a reference in a test or a commit message never silently comes to mean something else.
- **A material change issues a new identifier.** If a requirement changes such that a test currently passing against it could now be wrong, the old identifier is retired and a new one issued. Edits to wording, clarity, or formatting keep theirs. The judgement is whether the claim moved, not whether the sentence did.
- **Stability binds from first external citation.** Until an identifier is cited outside this document - by a test, by `roadmap.md`, or in a commit - it may be amended in place, because there is nothing yet to mislead.
- **One requirement, one claim.** Each is a single declarative statement that is either satisfied or not. A statement needing the word "and" to join two independent claims is two requirements.
- **Criteria appear where they earn their place** - where the statement alone does not determine the test - as indented *Given / when / then* lines beneath it. Their absence means the statement is its own test, not that the requirement matters less.
- **Every requirement carries a verification method**, because some of what this document commits to cannot be a test and should not pretend to be:

| Marker | Verified by |
| --- | --- |
| `test` | An automated test in the application test suite |
| `ci` | An automated check in the build pipeline rather than a product test |
| `manual` | Human inspection, each release |
| `monitor` | An operational measure watched over time rather than passed at a point |
| `policy` | A standing commitment with no automated check |

- **Numbers are initial targets** unless they cite an external standard. They exist to be measured against and revised, not defended.
- **Release scope is not recorded here.** Sequencing lives in [`roadmap.md`](./roadmap.md), which cites these identifiers, so that re-planning never edits this document and the two cannot drift.
- **Coverage is kept in sync at review.** A change to a feature's Requirements section in [`user-experience.md`](./user-experience.md) obliges a matching pass over the corresponding area here. The intent document stays free of identifiers so that it stays readable as prose, which puts the burden on the reviewer rather than on a script.
- **The `manual` markers are the release checklist.** The set of requirements marked `manual` is what whoever cuts a release works through, generated from the markers rather than maintained as a separate list that could fall out of step with them.

| Area | Feature |
| --- | --- |
| `HH` | Households |
| `MEAL` | Meal Planning |
| `RCP` | Recipes and Cookbooks |
| `PAN` | Pantry and Grocery |
| `NUT` | Nutrition Tracking |
| `ING` | Ingredient Catalog |
| `DIET` | Dietary and Allergy Profiles |
| `PROF` | Profile and Identity |
| `PREF` | Application Preferences |
| `TAG` | Tags, Search, and Recommendation |
| `NOTIF` | Notifications and Reminders |
| `MOD` | Reporting and Moderation |
| `ACCT` | Account Security and Privacy |
| `JRN` | User Experience Paths |

## Functional Requirements

### Households

- **FR-HH-01** `test` A `Household` is created at signup with the signing-up `User` as its Owner, without prompting for a name.
- **FR-HH-02** `test` A `Household` with one member renders no role, invitation, or approval interface.
- **FR-HH-03** `test` Role, invitation, and approval interfaces become available when a `Household` gains a second member, with no migration of existing data.
  - *Given* a solo `Household` holding a `Calendar`, `Cookbook`, `Pantry`, and `GroceryList`, *when* a second member joins, *then* every existing record remains addressable by its original identifier.
- **FR-HH-04** `test` Exactly one Owner exists per `Household` at all times.
- **FR-HH-05** `test` An Owner holds read, write, and delete permission over every resource its `Household` owns.
- **FR-HH-06** `test` An Admin holds read and write permission over every resource its `Household` owns, and may issue `Invitation`s.
- **FR-HH-07** `test` A Member holds read permission over its `Household`'s resources and may submit `Meal` and `GroceryList` requests.
- **FR-HH-08** `test` A Member's request is resolved by an Owner or Admin as approved or denied, and the requester is notified of the outcome either way.
- **FR-HH-09** `test` A denial may carry a reason, which is shown to the requester.
- **FR-HH-10** `test` An Owner cannot leave a `Household` until ownership has been transferred to another member.
- **FR-HH-11** `test` A `User` may belong to any number of `Household`s.
- **FR-HH-12** `test` Accepting an `Invitation` adds the `User` to the `Household` as a Member.
- **FR-HH-13** `test` An `Invitation` states the `Household`, the sender, and what the recipient will be able to see, before it is accepted.
- **FR-HH-14** `test` Accepting an `Invitation` requires a single confirmation and no further setup for an existing account.
- **FR-HH-15** `test` In a `Household` with more than one member, the household screen displays each member's role and the permissions that role carries.
- **FR-HH-16** `test` An action a Member cannot perform directly is presented as requiring approval, rather than hidden or failed after the attempt.
- **FR-HH-17** `test` Dissolving a `Household` states, before confirmation, exactly what will be destroyed: its `Cookbook`, `Calendar`, `Pantry`, and `GroceryList`.
- **FR-HH-18** `test` Dissolving a `Household` unpublishes every `Recipe` its `Cookbook` had published.
- **FR-HH-19** `test` A dissolved `Household` is recoverable for 30 days, after which it is permanently deleted.
- **FR-HH-20** `test` Dissolving a `Household` does not alter copies other `Household`s took of its `Recipe`s.
- **FR-HH-21** `test` A `Household` may contain people who have no `User` account.
- **FR-HH-22** `test` A person with no account holds no role and no permissions.
- **FR-HH-23** `test` Adding, editing, and removing a person with no account is an Owner or Admin action.
- **FR-HH-24** `test` A person with no account may be linked to a `User` account, retaining their recorded allergies, dietary tags, and meal participation history.
  - *Given* a `Recipe` published by one `Household` and copied by another, *when* the publishing `Household` is dissolved, *then* the copy remains readable, editable, and planned exactly as before.

### Meal Planning

- **FR-MEAL-01** `test` A `Meal`'s calendar block begins at (serving time − prep time − cook time) and ends at its serving time.
- **FR-MEAL-02** `test` The `Calendar` offers week and month views and opens on week.
- **FR-MEAL-03** `test` A `Meal` holds one or more `Recipe`s, with no ordering or role distinction among them.
- **FR-MEAL-04** `test` A `Meal`'s serving count defaults to its participant count and is editable independently of it.
  - *Given* a `Meal` with four participants, *when* it is created, *then* its serving count is four.
  - *Given* that `Meal`, *when* the cook sets servings to six, *then* servings is six and participants remains four.
- **FR-MEAL-05** `test` `GroceryList` quantities for a `Meal` are calculated from its serving count.
- **FR-MEAL-06** `test` Nutrition contributions from a `Meal` are apportioned across its participants.
- **FR-MEAL-07** `test` Moving or reshaping a `Meal` updates its `GroceryList` contributions without any further user action.
- **FR-MEAL-08** `test` Deleting a `Meal` removes from the `GroceryList` only the quantities that `Meal` contributed.
  - *Given* two `Meal`s each requiring two cloves of garlic, *when* one is deleted, *then* two cloves remain on the `GroceryList`.
  - *Given* garlic added to the `GroceryList` by hand and a `Meal` also requiring garlic, *when* that `Meal` is deleted, *then* the hand-added garlic remains.
- **FR-MEAL-09** `test` A `Meal` records a cooked state at `Household` level, changeable in a single action.
- **FR-MEAL-10** `test` A `Meal`'s participants are drawn from the people in its `Household`, whether or not they hold accounts.
- **FR-MEAL-11** `test` Each `Household` has exactly one `Calendar`.
- **FR-MEAL-12** `test` Adding a `Recipe` from the `Cookbook` to a `Calendar` slot completes in no more than three interactions, an interaction being a tap, a drag, or a text entry; scrolling and scrubbing do not count.
- **FR-MEAL-13** `test` Each participant on a `Meal` carries an `ate` state, distinct from that `Meal`'s cooked state.
- **FR-MEAL-14** `test` Marking a `Meal` cooked sets the `ate` state of every one of its participants to true.
  - *Given* a `Meal` with four participants, *when* the cook marks it cooked, *then* four participants are recorded as having eaten and no further prompt is shown.
- **FR-MEAL-15** `test` A participant may change their own `ate` state after the fact, and no one else's.

### Recipes and Cookbooks

- **FR-RCP-01** `test` Each `Household` has exactly one `Cookbook`.
- **FR-RCP-02** `test` A `Recipe` is saveable with any subset of its optional fields populated.
  - *Given* a `Recipe` with a title, three steps, no photo, and an ingredient quantity of "a knob", *when* it is saved, *then* it persists complete and is usable in a `Meal`.
- **FR-RCP-03** `test` Collections are views over the `Cookbook`; a `Recipe` may appear in any number of them simultaneously.
- **FR-RCP-04** `test` Removing a `Recipe` from a collection does not delete the `Recipe` or remove it from any other collection.
- **FR-RCP-05** `test` A `Recipe` is Private on creation.
- **FR-RCP-06** `test` Publishing is an explicit action and is reversible by unpublishing.
- **FR-RCP-07** `test` The creator of a `Recipe` is its default Author.
- **FR-RCP-08** `test` An Author may add further Authors, each of whom must be an Owner or Admin of the `Household` owning the `Cookbook`.
- **FR-RCP-09** `test` Copying a public `Recipe` produces an independent `Recipe` owned by the copying `Household`, snapshotted at the moment of copying.
- **FR-RCP-10** `test` A copied `Recipe` carries attribution to the original Author, and that attribution survives subsequent edits.
- **FR-RCP-11** `test` When an original is edited, each copy surfaces a non-blocking notice that the original has changed, with a view of what changed.
- **FR-RCP-12** `test` An upstream change is applied to a copy only when that `Household` accepts it.
  - *Given* a copied `Recipe` and an edit to its original, *when* the copying `Household` takes no action, *then* the copy is byte-for-byte unchanged.
- **FR-RCP-13** `test` A `Recipe` conflicting with any `Household` person's recorded allergy is marked as such wherever it is displayed, including in the showcase.
- **FR-RCP-14** `test` An unverifiable dietary claim on a published `Recipe` is displayed as the Author's claim, attributed by name.
- **FR-RCP-15** `test` No verification badge is displayed against any dietary claim.
- **FR-RCP-16** `test` A `Recipe` in progress is retained when its editor is dismissed, and is recoverable.
- **FR-RCP-17** `test` The showcase offers browsable entry points that require no search query to reach a `Recipe`.
- **FR-RCP-18** `test` The publishing confirmation states what becomes visible outside the `Household` and to whom.
- **FR-RCP-19** `test` When an Author's account is deleted, attribution on every copy of their `Recipe`s degrades to a non-identifying placeholder, and the copied content is unchanged.
  - *Given* a copied `Recipe` attributed to an Author, *when* that Author deletes their account, *then* the copy retains its content and shows an attribution naming no one.
- **FR-RCP-20** `test` A `Recipe` without a photo displays no image area and no generated stand-in imagery.

### Pantry and Grocery

- **FR-PAN-01** `test` Each `Household` has exactly one `Pantry` and exactly one `GroceryList`.
- **FR-PAN-02** `test` Adding a `Meal` to the `Calendar` adds its required `Ingredient`s to the `GroceryList`.
- **FR-PAN-03** `test` Every `GroceryList` quantity records the contribution that produced it.
- **FR-PAN-04** `test` A manually added `GroceryList` item is never removed by the deletion of a `Meal`.
- **FR-PAN-05** `test` The `GroceryList` groups its items by `IngredientCategory`.
- **FR-PAN-06** `test` Category order on the `GroceryList` follows the `Household`'s own sequence, seeded from a shipped default.
- **FR-PAN-07** `test` A `Household`'s category order is editable by its Owner and Admins.
- **FR-PAN-08** `test` Checking off a `GroceryList` item adds it to the `Pantry`.
- **FR-PAN-09** `test` The `GroceryList` indicates which of its items the `Pantry` already stocks.
- **FR-PAN-10** `test` Owners and Admins add and edit `GroceryList` items directly; Members submit requests for approval.
- **FR-PAN-11** `test` Marking a `Meal` cooked decrements its `Ingredient`s from the `Pantry`.
- **FR-PAN-12** `test` An empty, stale, or inaccurate `Pantry` never blocks meal planning or `GroceryList` generation.
- **FR-PAN-13** `test` Checking off a `GroceryList` item presents no confirmation dialog and is reversible by a single action.

### Nutrition Tracking

- **FR-NUT-01** `test` Daily targets are computed from date of birth, height, weight, sex, and activity level, against a stated goal.
- **FR-NUT-02** `test` Targets use the Mifflin-St Jeor equation for basal rate, scaled by an activity factor and adjusted toward the goal.
- **FR-NUT-03** `test` Every computed target is overridable, and an override survives recomputation.
  - *Given* a user-set protein target, *when* their recorded weight changes, *then* the protein target retains the user's figure.
- **FR-NUT-04** `test` Nutrition tracking is dismissible in full, and dismissing it removes it from the `Today` tab.
- **FR-NUT-05** `test` Demographic inputs are readable only by the `User` who entered them.
- **FR-NUT-06** `test` Demographic inputs are deletable without deleting the account.
- **FR-NUT-07** `test` No feature outside Nutrition Tracking requires a demographic input.
- **FR-NUT-08** `test` The sex input is a distinct field from pronouns, collected in the nutrition context with its purpose stated.
- **FR-NUT-09** `test` Ladle tracks energy, protein, carbohydrate, fat, fibre, and sodium, and no other nutrient.
- **FR-NUT-10** `test` Nutrition figures are rounded on display - energy to the nearest 5 kcal, macronutrients and fibre to the nearest gram, sodium to the nearest 10 mg - and never carry a decimal place.
- **FR-NUT-11** `test` The `Today` tab shows the day's planned meals against targets before any of them is cooked.
- **FR-NUT-12** `test` Only a participant's own `ate` state contributes to their nutrition ledger; a `Meal`'s cooked state does not.
  - *Given* a `Meal` marked cooked whose participant then clears their own `ate` state, *when* their `Today` tab is read, *then* that `Meal` contributes nothing to it and the `Pantry` decrement is unaffected.
- **FR-NUT-13** `test` Where a threshold rests on convention rather than regulation, the app states so where the figure is used.
- **FR-NUT-14** `manual` The app presents no health claim, no outcome claim, and no medical advice.
- **FR-NUT-15** `manual` Nutrition surfaces use neutral, reporting language, offering no congratulation, warning, or evaluative judgement.
- **FR-NUT-16** `test` The nutrition display presents no colour change or other state change on a target being reached or exceeded.
- **FR-NUT-17** `manual` Ladle makes no health claim, outcome claim, or comparative nutritional claim outside the app - in store listings, marketing, or any other external material - before the thresholds and target equation have been reviewed by a qualified dietitian.
- **FR-NUT-18** `policy` A threshold resting on convention keeps its stated-as-convention labelling and remains overridable until that review has taken place.
- **FR-NUT-19** `test` Nutrition tracking is not offered to a `User` under 18.

### Ingredient Catalog

- **FR-ING-01** `test` `Ingredient` search matches recorded synonyms.
  - *Given* the catalog entry for spring onion, *when* a user searches "scallion", *then* that entry is returned.
- **FR-ING-02** `test` The `Ingredient` catalog is not editable by users.
- **FR-ING-03** `test` A `Recipe` may reference an ingredient absent from the catalog and remain saveable and usable.
- **FR-ING-04** `test` Every `Ingredient` belongs to exactly one `IngredientCategory`.
- **FR-ING-05** `test` `IngredientCategory` is a single global set and does not vary by `Household` or locale.
- **FR-ING-06** `policy` `Ingredient` tags are published only after an Application Administrator has approved them; suggestion tooling may propose but never publish.
- **FR-ING-07** `test` Every `Ingredient` carries an `IngredientNutrition` estimate.
- **FR-ING-08** `test` An unreconciled ingredient can later be matched to a catalog entry, and the match applies to every `Recipe` referencing it.

### Dietary and Allergy Profiles

- **FR-DIET-01** `test` Allergies are recorded as individual `Ingredient`s or as allergen-facet `Tag`s.
- **FR-DIET-02** `test` An allergen match excludes a `Recipe` from recommendation absolutely.
- **FR-DIET-03** `test` An allergen match is displayed as a warning wherever the `Recipe` appears.
- **FR-DIET-04** `test` An `Ingredient` belonging to an allergen group carries both the group tag and its specific tag.
  - *Given* a user allergic to cashew alone, *when* they view a recipe containing almond, *then* no allergen warning is shown.
- **FR-DIET-05** `test` `DietaryModel`s affect ranking and never exclude.
- **FR-DIET-06** `test` `DietaryModel`s combine without precedence between them.
- **FR-DIET-07** `test` A derived dietary tag is applied only when every `Ingredient` in the `Recipe` is reconciled with the catalog.
  - *Given* a `Recipe` containing one unreconciled ingredient, *when* dietary derivation runs, *then* no derived dietary tag is applied.
- **FR-DIET-08** `test` A `Recipe` containing any unreconciled ingredient reports its allergy check as incomplete rather than as clean.
- **FR-DIET-09** `test` The absence of an allergen tag is never displayed as evidence that the allergen is absent.
- **FR-DIET-10** `test` Where a `Meal`'s participants have conflicting dietary requirements, the conflict is displayed and not resolved automatically.
- **FR-DIET-11** `test` Allergies and dietary tags are recordable for a person with no `User` account.
- **FR-DIET-12** `test` No demographic health data is stored for a person with no `User` account.

### Profile and Identity

- **FR-PROF-01** `test` A profile consisting only of a display name is complete and imposes no further prompts.
- **FR-PROF-02** `test` The boundary between public and private fields is stated on the screen where the data is entered.
- **FR-PROF-03** `test` Pronouns are optional, self-selected, and used wherever the app refers to a `User` in the third person.

### Application Preferences

- **FR-PREF-01** `test` Theme mode, theme, unit system, language, and timezone are per-`User`.
- **FR-PREF-02** `test` Unit system affects display only; stored quantities are unchanged by it.
  - *Given* a `GroceryList` item stored as 500 g, *when* one member reads it in US units and another in metric, *then* both read the same underlying quantity and neither display mutates it.
- **FR-PREF-03** `test` Themes are selected from a curated set and are not user-authored.
- **FR-PREF-04** `test` Timezone determines the day boundary for the `Today` tab and for scheduled notifications.
- **FR-PREF-05** `test` Language selection is not offered until a translation service exists behind it.
- **FR-PREF-06** `test` A setting describing a shared artifact rather than a person belongs to the `Household`.
- **FR-PREF-07** `test` Theme token values are resolved from the application bundle and are never fetched at runtime.

### Tags, Search, and Recommendation

- **FR-TAG-01** `test` Every `Tag` belongs to exactly one facet.
- **FR-TAG-02** `test` The tag vocabulary is closed; neither a user nor the classifier may create a term.
- **FR-TAG-03** `test` The classifier assigns tags in the course, cuisine, method, season, and effort facets only.
- **FR-TAG-04** `test` No allergen tag is ever assigned by the classifier.
- **FR-TAG-05** `test` No dietary tag is ever assigned by the classifier.
- **FR-TAG-06** `test` `dietary:vegan`, `dietary:vegetarian`, `dietary:pescatarian`, `dietary:dairy-free`, and `dietary:gluten-free` are derived from the curated allergen and ingredient tags of a `Recipe`'s ingredients.
- **FR-TAG-07** `test` `dietary:keto`, `dietary:low-carb`, `dietary:high-protein`, and `dietary:low-sodium` are derived from computed nutrition against the thresholds recorded in [`taxonomy.md`](./taxonomy.md), evaluated per serving.
- **FR-TAG-08** `test` `dietary:kosher`, `dietary:halal`, `dietary:paleo`, `dietary:whole-food`, and `dietary:low-fodmap` are applied only by an Author and are attributed to them.
- **FR-TAG-09** `test` A `Recipe` carrying a regional cuisine tag also carries its parent.
  - *Given* a `Recipe` tagged `cuisine:sichuan`, *when* its tags are read, *then* `cuisine:chinese` is among them.
- **FR-TAG-10** `test` A search for a parent cuisine returns `Recipe`s carrying any of its regional tags.
- **FR-TAG-11** `test` Classification runs server-side.
- **FR-TAG-12** `test` A `Recipe` save completes without waiting for classification.
- **FR-TAG-13** `test` An Author may apply or remove any tag on a `Recipe` they author, including a dormant one.
- **FR-TAG-14** `test` A tag removed by a person is never reapplied by a later classification pass.
  - *Given* an Author who removed `cuisine:thai` from their `Recipe`, *when* a retrained model classifies it again, *then* `cuisine:thai` is not restored.
- **FR-TAG-15** `test` A tag whose labelled examples fall below its facet's floor is dormant, and the classifier never emits it.
- **FR-TAG-16** `test` A dormant tag remains searchable and remains applicable by hand.
- **FR-TAG-17** `test` Tag dormancy is not surfaced anywhere in the app.
- **FR-TAG-18** `test` A retraining pass backfills classification across existing `Recipe`s.
- **FR-TAG-19** `test` A retraining pass activates each tag that has reached its floor and applies it retroactively.
- **FR-TAG-20** `policy` Dormant tags are reviewed at each retraining pass and are never retired automatically.
- **FR-TAG-21** `ci` Retiring a tag remaps every `Recipe` carrying it within the same migration.
- **FR-TAG-22** `test` Recommendation weights `Recipe`s by what the `Household`'s `Pantry` already stocks.
- **FR-TAG-23** `test` Every recommendation displays the reason it was made.
- **FR-TAG-24** `test` Incompatibility rules are advisory and never prevent a `Meal` from being saved.
- **FR-TAG-25** `policy` The training corpus draws only on public-domain or permissively licensed sources, with terms confirmed before labelling begins.
- **FR-TAG-26** `policy` The training corpus is stratified to a per-facet floor rather than sampled flat.
- **FR-TAG-27** `test` Search supports filtering by facet without enumerating which terms belong to it.
- **FR-TAG-28** `test` A `Recipe` carrying no author-applied tag is discoverable through the tags classification assigned it.
- **FR-TAG-29** `policy` A cuisine term is added to the vocabulary only with a recorded case for it.
- **FR-TAG-30** `test` Recipe search matches a `Recipe`'s title, the `Ingredient`s it uses, and its tags.
- **FR-TAG-31** `test` Searching the `Household`'s `Cookbook` and searching the showcase are separate scopes, and a result set never mixes them.
- **FR-TAG-32** `test` A search by ingredient returns `Recipe`s using that `Ingredient`, including where the query used a recorded synonym.
  - *Given* a `Recipe` using spring onion, *when* a user searches the showcase for "scallion", *then* that `Recipe` is returned.

### Notifications and Reminders

- **FR-NOTIF-01** `test` Each notification category is independently switchable off.
- **FR-NOTIF-02** `test` A start-cooking reminder fires at the beginning of a `Meal`'s preparation window.
- **FR-NOTIF-03** `test` Expiry warnings derive from `Pantry` stock and are not user-scheduled.
- **FR-NOTIF-04** `test` A `Household` event notifies only the members it concerns.
- **FR-NOTIF-05** `test` An expiry warning for a given `Pantry` item is delivered to a given `User` at most once.
- **FR-NOTIF-06** `test` Notification delivery history is pruned 90 days after the delivery it records.

### Reporting and Moderation

- **FR-MOD-01** `test` A report control is available wherever a published `Recipe` is displayed.
- **FR-MOD-02** `test` Reporting requires selecting a reason and never requires free text.
- **FR-MOD-03** `test` One queue accepts every report reason.
- **FR-MOD-04** `test` A reported dietary claim is suppressed while it awaits review, and the `Recipe` carrying it remains published.
  - *Given* a published `Recipe` claiming `dietary:kosher`, *when* it is reported, *then* the claim is hidden and the `Recipe` remains readable.
- **FR-MOD-05** `test` The Author is notified when a claim of theirs is reported, is shown the reason, and may respond before a ruling.
- **FR-MOD-06** `test` Report volume orders the queue and never determines an outcome.
  - *Given* a `Recipe` reported by many accounts, *when* no Application Administrator has ruled, *then* the `Recipe` remains published.
- **FR-MOD-07** `test` The outcome of a resolved report is communicated to the person who raised it.
- **FR-MOD-08** `test` A suppressed claim is displayed as under review rather than as a ruling.
- **FR-MOD-09** `monitor` Turnaround targets are tiered by what happens without a human: an `unsafe` report carries the shortest, because nothing acts on it until it is reviewed; a `wrong_dietary_claim` a longer one, because the claim is already suppressed and only its restoration waits; `spam` and `copied_content` longer still.
- **FR-MOD-10** `test` An `unsafe` report left unreviewed beyond its target hides the reported `Recipe` from the showcase until an Application Administrator rules on it.
  - *Given* an `unsafe` report past its threshold with no ruling, *when* the showcase is browsed, *then* the reported `Recipe` does not appear, and its owning `Household` still sees it in their `Cookbook`.
- **FR-MOD-11** `test` A `User` may report a given `Recipe`, or a given claim on it, at most once.
- **FR-MOD-12** `test` The number of reports a `User` may raise in a day is capped.
- **FR-MOD-13** `test` Reports naming the same target and reason collapse into one queue item carrying a count, rather than appearing as separate items.
- **FR-MOD-14** `test` A resolved report is deleted 12 months after its resolution.

### Account Security and Privacy

- **FR-ACCT-01** `test` A session persists across app restarts.
- **FR-ACCT-02** `test` A returning authenticated `User` lands on the `Today` tab rather than a login screen.
- **FR-ACCT-03** `test` Unpublishing removes a `Recipe` from the showcase.
- **FR-ACCT-04** `test` Account deletion transfers or dissolves every `Household` the `User` owns, and states which before the deletion is confirmed.
- **FR-ACCT-05** `test` No action other than publishing makes any `Household` data visible outside that `Household`.
- **FR-ACCT-06** `test` A password known to have appeared in a public breach corpus is refused at signup and at password change, with the reason stated.
- **FR-ACCT-07** `test` Authentication attempts are rate limited, per account and per source address.
- **FR-ACCT-08** `test` Creating an account requires a stated date of birth, and no account is created for anyone under 13.
- **FR-ACCT-09** `test` A `User` may export every record they can read — profile, preferences, health data, and the contents of every `Household` they belong to — in a machine-readable format.
  - *Given* a `User` in two `Household`s, *when* they request an export, *then* it contains both cookbooks, both calendars, both pantries, and their own demographic inputs.
- **FR-ACCT-10** `test` The export is produced and delivered within the app, without a request to the developer and without passing through a third-party service.
- **FR-ACCT-11** `test` Account deletion removes the `User`'s rows on confirmation rather than after a recovery window.

### User Experience Paths

Feature requirements are each scoped to one feature, which means the joins between features are unasserted by construction. These are the paths from [`user-experience.md`](./user-experience.md) stated as end-to-end claims, and they are where a product built from correct parts still fails.

- **FR-JRN-01** `test` A new `User` reaches a planned meal with a populated `GroceryList` without naming a `Household`, issuing an `Invitation`, or encountering a role.
  - *Given* a fresh install, *when* the user signs up, supplies a display name, skips the dietary questions, and plans one `Meal` from the showcase, *then* the `GroceryList` holds that `Meal`'s ingredients and no household, role, or approval interface has appeared.
- **FR-JRN-02** `test` An invited `User` completes signup and arrives directly in the inviting `Household`, seeing its existing plan rather than an empty first-run state.
  - *Given* a `Household` with a planned week, *when* an invitee installs the app and accepts, *then* the planned week is visible to them on arrival.
- **FR-JRN-03** `test` Planning a week produces a complete `GroceryList` with no separate assembly step.
  - *Given* an empty week, *when* the cook adds meals, sets serving times, names participants, and resolves any flagged conflict, *then* the `GroceryList` is complete and required no direct editing.
- **FR-JRN-04** `test` A shopping trip moves items from `GroceryList` to `Pantry` with no action required after leaving the shop.
  - *Given* a populated `GroceryList`, *when* every item is checked off in the shop, *then* the `Pantry` reflects them and the `GroceryList` is empty.
- **FR-JRN-05** `test` Cooking a `Meal` marks it cooked, decrements the `Pantry`, and credits each participant's ledger, driven from the reminder that opened it.
- **FR-JRN-06** `test` A `Recipe` found in the showcase can be copied, filed, edited, and planned without leaving the copy coupled to its original.
  - *Given* a public `Recipe`, *when* a user copies it into two collections and edits it, *then* the original is unchanged, attribution is intact, and the copy is planned like any other `Recipe`.

## Non-Functional Requirements

These are cross-cutting: each holds across every feature above rather than belonging to any of them. Several restate invariants established in [`data.md`](./data.md), repeated here because an invariant nobody verifies is a preference.

Latency targets are stated at the 95th percentile, measured on a reference device pair - a Pixel 8a and an iPhone 13 - chosen to represent the mid-range rather than the machines the app is developed on. Both the percentile and the pair are initial choices and should be revised against real device data.

### Performance

- **NFR-PERF-01** `test` The `Calendar` week view renders its first frame within 1000 ms of a cold start, at P95 on the reference devices.
- **NFR-PERF-02** `test` Checking off a `GroceryList` item reflects in the interface within 100 ms at P95, independent of network round-trip.
- **NFR-PERF-03** `test` `Ingredient` search returns results within 300 ms of the final keystroke, at P95 on the reference devices.
- **NFR-PERF-04** `test` Classification never sits between a cook and a saved `Recipe`; save latency is unaffected by it.
- **NFR-PERF-05** `test` Recipe search returns results within 500 ms of the final keystroke, at P95 on the reference devices.

### Reliability and Offline

- **NFR-OFF-01** `test` Previously fetched `Calendar`, `Pantry`, `GroceryList`, and `Cookbook` data is readable with no network connection.
- **NFR-OFF-02** `test` The app indicates how recently displayed data was refreshed when it is served from cache without a connection.
- **NFR-OFF-03** `test` A write attempted without connectivity fails in a way that is retryable and loses no user input.
- **NFR-OFF-04** `test` Mutations apply optimistically against the cache and reconcile against the server response.
- **NFR-OFF-05** `test` Cached data survives an app restart.
- **NFR-OFF-06** `test` A `GroceryList` remains readable and checkable through a loss of signal mid-shop, with check-offs reconciling on reconnection.

### Security and Privacy

- **NFR-SEC-01** `ci` Every user-owned table has row-level security enabled in the same migration that creates it.
- **NFR-SEC-02** `ci` The `service_role` key appears in neither the mobile bundle nor the repository.
- **NFR-SEC-03** `ci` The client ships only the `anon` key.
- **NFR-SEC-04** `test` Sessions are short-lived JWTs refreshed in the background, with refresh tied to the app's foreground state.
- **NFR-SEC-05** `test` Refresh tokens are held in secure device storage rather than general application storage.
- **NFR-SEC-06** `test` Realtime subscriptions run on the authenticated channel, and no row is delivered to a subscriber that could not have selected it.
- **NFR-SEC-07** `test` Demographic health data is never returned to any principal other than the `User` it belongs to.
- **NFR-SEC-08** `test` Private Storage objects are served only through short-lived signed URLs.
- **NFR-SEC-09** `manual` An Edge Function acts as its caller by default; escalation to `service_role` is explicit and commented at each call site.
- **NFR-SEC-10** `test` Signing out removes that device's push notification token.
- **NFR-SEC-11** `test` No health data — a demographic input or a recorded allergy — is stored before the `User` has given an explicit opt-in consent presented separately from any other consent.
  - *Given* a `User` who has not consented, *when* they open the dietary or nutrition screens, *then* consent is requested before any field accepts a value, and declining leaves the rest of Ladle fully usable.
- **NFR-SEC-12** `policy` Ladle publishes a consumer health data privacy policy as a document distinct from, and separately linked to, its general privacy policy.

### Accessibility

- **NFR-A11Y-01** `test` Interactive targets on the `GroceryList` measure at least 44×44 points.
- **NFR-A11Y-02** `ci` Text and background meet WCAG AA contrast in every shipped theme, in both light and dark mode.
- **NFR-A11Y-03** `manual` The app honours the platform's dynamic type settings without truncation or overlap.
- **NFR-A11Y-04** `test` Every interactive control carries an accessible label.
- **NFR-A11Y-05** `manual` The cooking view keeps the screen awake and is operable one-handed.
- **NFR-A11Y-06** `manual` Allergen warnings are conveyed by more than colour alone.
- **NFR-A11Y-07** `manual` The app honours the platform's reduced-motion setting, and no state change is conveyed by motion alone.
- **NFR-A11Y-08** `manual` The focus indicator is drawn outside a control's bounds, so it is always evaluated against a surface rather than against the control's own fill.

### Data Integrity

- **NFR-DATA-01** `manual` Invariants are enforced by database constraints, generated columns, and triggers rather than by client validation.
- **NFR-DATA-02** `test` `GroceryList` quantities record their provenance per contribution, so a contribution can be withdrawn without disturbing the others.
- **NFR-DATA-03** `test` `Recipe` version history is retained sufficiently to diff a published original against the snapshot a copy was taken from.
- **NFR-DATA-04** `ci` Every migration builds from empty; `supabase db reset` replays the full chain successfully.
- **NFR-DATA-05** `ci` TypeScript types are generated from the live schema and committed, so a schema change that breaks the app fails at compile time.
- **NFR-DATA-06** `policy` Production data is never restored, seeded, or copied into any other environment.
- **NFR-DATA-07** `test` Nutrition figures are stored as estimates, with the basis of each recorded alongside it.
- **NFR-DATA-08** `policy` Backups are retained for 30 days, after which deleted data is unrecoverable from them.

### Operability

- **NFR-OPS-01** `test` The active environment is shown on the debug screen and by the non-production app icon badge.
- **NFR-OPS-02** `monitor` Moderation queue age is measured per tier and reported against that tier's target.
- **NFR-OPS-03** `monitor` Labelling throughput is measured against the tag floors still unmet and the target release date.
- **NFR-OPS-04** `monitor` Classifier accuracy is measured per facet against a held-out set drawn from the labelled corpus.
- **NFR-OPS-05** `policy` Per-facet floors are set from the evaluation curve rather than fixed in advance.
- **NFR-OPS-06** `ci` Applying a migration to production requires explicit human approval.
- **NFR-OPS-07** `policy` A breach response procedure covering health data notification exists before production holds any user data.
- **NFR-OPS-08** `test` Crash and error reports are collected from production builds.
- **NFR-OPS-09** `test` No demographic input, allergy, or other health data appears in a crash or error payload.
  - *Given* a crash raised while the nutrition screen holds a user's weight and date of birth, *when* the payload is captured, *then* neither value appears in it, in any frame, breadcrumb, or attached context.
- **NFR-OPS-10** `test` Crash reporting captures no screenshot, session replay, or network request body.
