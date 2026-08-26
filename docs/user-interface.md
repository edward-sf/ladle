---
name: user-interface.md
description: This file describes the UI tooling, brand identity, and layout(s) for the Ladle application.
---
# User Interface

This file owns how Ladle looks and how it is operated: the libraries it is built
from, its visual system, its navigation, the patterns that recur across screens,
and layout notes for the screens that carry real constraints.

It does not restate behaviour. What a screen must do lives in
[`user-experience.md`](./user-experience.md) as intent and in
[`requirements.md`](./requirements.md) as testable claims; identifiers from the
latter are cited here where a visual decision exists to satisfy one.

## Technologies

Ladle makes use of open-source UI elements from the following resources:

- [React Native Reusables](https://reactnativereusables.com/docs)
- [Lucide's React Native Library](https://lucide.dev/guide/packages/lucide-react-native)

| Concern | Choice |
| --- | --- |
| Component primitives | React Native Reusables |
| Styling | NativeWind (Tailwind for React Native) |
| Icons | `lucide-react-native` |
| Navigation | Expo Router, file-based |
| Animation | `react-native-reanimated` |

React Native Reusables is copy-in rather than installed-from: components are
vendored into the repository and edited, which means the visual system below
governs code we own rather than props we pass to someone else's.

## Principles

Five rules that decide the cases this document does not enumerate.

- **Confirm what cannot be undone; never confirm what can.** Dissolving a
  household is itemised and confirmed (`FR-HH-17`); checking an item off in a
  shop is instant and reversible, with no dialog at all (`FR-PAN-13`). A
  confirmation on a reversible action teaches people to dismiss confirmations.
- **Never show certainty the data does not have.** An estimate is rounded until
  it reads as an estimate, an unverifiable claim is attributed to whoever made
  it, and an allergy check that could not complete does not look like one that
  passed.
- **The hand comes before the eye.** The grocery list and the cooking view are
  used one-handed, at arm's length, with something else occupying the other
  hand. Where legibility and density conflict on those screens, legibility wins.
- **Report, do not evaluate.** Nutrition surfaces state figures and never
  congratulate, warn, or grade (`FR-NUT-15`).
- **An empty screen says what to do next.** Every empty state names the action
  that fills it, because the emptiest the app will ever be is the first time
  someone opens it.

## Brand

The values below are **provisional**. They exist so that components can be built
and contrast can be tested today, and every one of them is a token value that can
be replaced without touching a component.

### Palette

Ladle's primitives are a warm neutral ramp and a paprika accent, chosen because
the product is about food and because a cool grey interface makes photographs of
food look grey too.

| Primitive | Value | Primitive | Value |
| --- | --- | --- | --- |
| `neutral-0` | `#FFFFFF` | `accent-400` | `#E08A62` |
| `neutral-50` | `#FAF7F2` | `accent-500` | `#CE6B3F` |
| `neutral-100` | `#F2ECE3` | `accent-600` | `#A9522D` |
| `neutral-200` | `#E4DACD` | `accent-700` | `#83401F` |
| `neutral-300` | `#CFC0AE` | `danger-500` | `#C0392B` |
| `neutral-400` | `#A89684` | `danger-600` | `#9B2C21` |
| `neutral-500` | `#7E6D5C` | `warning-400` | `#D99B2B` |
| `neutral-600` | `#5E5044` | `warning-500` | `#A97400` |
| `neutral-700` | `#443A31` | `success-500` | `#5B8C5A` |
| `neutral-800` | `#2C251F` | `success-600` | `#47703F` |
| `neutral-900` | `#191410` | `focus-400` | `#7FA9E0` |
| `neutral-950` | `#0F0B08` | `focus-500` | `#3B6FB8` |

`warning-500` is an ochre rather than the brighter `warning-400`, because amber
on a cream surface reaches only 2.27:1 and the caution colour has to be visible
on the surface it warns against. `warning-400` survives as a fill for tinted
backgrounds, where nothing is read off it directly.

No component references any of these names. They exist only to be mapped by a
theme, which is what the next section is about.

### Typography

**The interface uses the platform system font throughout** — San Francisco on
iOS, Roboto on Android. This is an accessibility decision before it is an
aesthetic one: the system font is the only one guaranteed to honour a user's
dynamic type setting at every size and weight without shipping a dozen font
files (`NFR-A11Y-03`).

Exactly one thing is set in another face: the wordmark.

Sizes are expressed as roles rather than points, because the point value moves
with the reader's settings.

| Role | Base size | Weight | Used for |
| --- | --- | --- | --- |
| `display` | 34 | 700 | Today's headline figure |
| `title` | 28 | 700 | Screen titles |
| `heading` | 20 | 600 | Section headings, recipe titles |
| `body` | 17 | 400 | Everything by default |
| `body-strong` | 17 | 600 | Emphasis within body |
| `label` | 15 | 500 | Buttons, tabs, field labels |
| `caption` | 13 | 400 | Timestamps, units, estimate qualifiers |
| `step` | 22 | 400 | Recipe steps in the cooking view only |

`step` exists because the cooking view is read from across a counter, and
inheriting `body` there would make the one screen with a physical distance
requirement the same size as a settings label.

### Wordmark

*ladle*, lowercase, set in **Fraunces** — a warm high-contrast serif under the
SIL Open Font License, so it can be embedded and redistributed without a licence
question ever arising. The contrast with the system sans doing the interface work
is deliberate: the wordmark should read as handmade and kitchen-ish where the
interface reads as plain and quiet.

Lowercase throughout, including at the start. Around −1% tracking at display
sizes, weight 600, and Fraunces' optical size axis set for display rather than
text.

**The font is not shipped.** The wordmark is produced in Fraunces and exported as
an asset; the application bundle carries the artwork, not the typeface. One word
does not justify a variable font file, and shipping one would invite it being
used for a heading later, which is where the dynamic type guarantee would start
to leak.

It appears on the splash screen, on the signed-out and signup screens, and
nowhere else. Inside the app the user is cooking, not being marketed to.

### Photography

One aspect ratio, **4:3**, in every context — cookbook cards, the recipe hero,
and showcase tiles. A single ratio means a single crop to reason about and one
set of cached sizes, and no photograph that looks right in a list and wrong on
the page it belongs to. Landscape suits food and wastes less of a phone's height
than 16:9.

Derivative sizes come from Supabase Storage's on-the-fly transformation rather
than being generated and stored, as [`data.md`](./data.md) describes.

**Grids and lists load the thumbnail derivative, never the full image**
(`NFR-PERF-06`). This reads as a performance rule and is also the largest cost
decision in the project: showcase egress scales with people browsing rather than
with people storing, and a grid of full-size images spends roughly ten times the
bandwidth of a grid of thumbnails for no visible gain at that size. See
[`operating-model.md`](./operating-model.md).

**A recipe with no photo has no image area at all** (`FR-RCP-20`). It is a text
card, and the title takes the room the image would have. Nothing is generated to
stand in — no tinted block, no course icon, no muted logo — because a household
cookbook of handwritten family recipes will be mostly photoless, and twenty
identical placeholders down a list reads as a failed load rather than as a set of
recipes nobody photographed.

This costs the showcase grid its even rhythm, which is the honest trade: cards
vary in height, and a photoless recipe looks like a deliberate kind of card
rather than a broken one. `FR-RCP-02` makes photoless a first-class state, and a
placeholder would quietly contradict that.

### Deferred: the mark and app icon

The icon, the mark, and any illustration style are **deliberately not specified
here** and belong to a later design phase. This is a recorded gap rather than an
oversight, so that nobody fills it by accident.

Two constraints for whoever picks it up: it has to hold at 16pt in a tab bar and
at 1024pt in a store listing, and it has to sit beside a lowercase
high-contrast serif wordmark without arguing with it.

### Spacing, radius, elevation

Spacing is a 4pt scale: `1`=4, `2`=8, `3`=12, `4`=16, `6`=24, `8`=32, `12`=48.
Screen gutters are `4`. Radii are `sm`=6, `md`=10, `lg`=16, and `full` for
pills and avatars. Elevation is expressed as three levels — `flat`, `raised`,
`overlay` — realised as shadow on iOS and elevation on Android, never as a
colour change alone, so it survives a theme swap.

### Iconography

Lucide at 24pt for navigation and actions, 20pt inline, 16pt for adornments,
stroke width 2. An icon never carries meaning alone: every icon-only control has
an accessible label (`NFR-A11Y-04`), and every status conveyed by an icon is also
conveyed by text (`NFR-A11Y-06`).

### Motion

Animation is decoration. **No state change is ever conveyed by movement alone**
(`NFR-A11Y-07`) — a thing that moved to tell you something also says it in text.

The platform's reduced-motion setting is honoured: transitions become
cross-fades or resolve instantly, and nothing slides, scales, or parallaxes.
This is not a preference to be respected where convenient. Vestibular triggers
ship unnoticed precisely because nobody building the app has the setting turned
on, so the default has to be correct rather than remembered.

Durations are short — 150ms for state changes, 250ms for navigation — because a
meal planner opened three times a day should not perform.

## Theming

### Two layers, and only one of them is visible to components

Primitives are values. **Semantic tokens** are meanings, and they are the only
thing a component may reference.

| Token | Meaning |
| --- | --- |
| `surface` | The page behind everything |
| `surface-raised` | Cards, sheets, the tab bar |
| `surface-sunken` | Wells, inputs, empty states |
| `border` | Decorative hairlines and dividers |
| `border-control` | Input outlines and control edges |
| `text` | Primary reading colour |
| `text-muted` | Secondary, captions, units |
| `accent` | The primary action colour |
| `on-accent` | Text and icons on an `accent` fill |
| `danger` | Allergens, destructive actions |
| `on-danger` | Text and icons on a `danger` fill |
| `warning` | Expiry, incomplete checks |
| `success` | Confirmations, in-stock indicators |
| `focus` | Focus and selection rings |

`border` and `border-control` are separate because WCAG 1.4.11 asks 3:1 of a
control's boundary and asks nothing of a decorative divider. Holding both to the
same bar would make every list separator a heavy rule, and dropping the bar for
both would let an input outline disappear.

A theme is a table mapping every semantic token to a primitive, once for light
and once for dark. Adding a theme is therefore a data change and never a
component change, which is the property that makes the contrast check below
possible at all.

### The default theme

Ladle ships one theme at launch. Its mapping is below, and it is the input the
contrast check runs against.

| Token | Light | Dark |
| --- | --- | --- |
| `surface` | `neutral-50` | `neutral-900` |
| `surface-raised` | `neutral-0` | `neutral-800` |
| `surface-sunken` | `neutral-100` | `neutral-950` |
| `border` | `neutral-200` | `neutral-700` |
| `border-control` | `neutral-500` | `neutral-400` |
| `text` | `neutral-900` | `neutral-50` |
| `text-muted` | `neutral-600` | `neutral-300` |
| `accent` | `accent-600` | `accent-400` |
| `on-accent` | `neutral-0` | `neutral-900` |
| `danger` | `danger-600` | `danger-500` |
| `on-danger` | `neutral-0` | `neutral-0` |
| `warning` | `warning-500` | `warning-500` |
| `success` | `success-600` | `success-500` |
| `focus` | `focus-500` | `focus-400` |

The accent inverts between modes — a dark terracotta on cream, a light one on
near-black — which is why `on-accent` inverts with it. A theme that kept one
accent for both modes would fail one of them.

### Themes are code, not rows

The `themes` table in [`data.md`](./data.md) stores a theme's identity — its key
and display name — and `user_preferences.theme_id` points at it. **The token
values ship in the application bundle.** They are not columns.

The reason is the contrast check: a theme whose values arrived from the server
could not have been validated in CI, and `NFR-A11Y-02` requires every shipped
theme to meet AA. A theme that cannot be checked before it reaches a user is a
theme that can ship an unreadable combination to everyone at once.

### Modes

`user_preferences.theme_mode` is `light`, `dark`, or `system` (`FR-PREF-01`).
Every theme defines both modes; there is no light-only theme, because `system`
must always resolve to something.

### Contrast validation

For each theme, in each mode, the pairs below are checked against WCAG AA in CI
(`NFR-A11Y-02`). The list is fixed so the check has a definite input rather than
a crawl of the component tree.

| Foreground | Background | Minimum |
| --- | --- | --- |
| `text` | `surface`, `surface-raised`, `surface-sunken` | 4.5:1 |
| `text-muted` | `surface`, `surface-raised` | 4.5:1 |
| `on-accent` | `accent` | 4.5:1 |
| `on-danger` | `danger` | 4.5:1 |
| `accent` | `surface`, `surface-raised` | 3:1 |
| `danger`, `warning`, `success` | `surface`, `surface-raised` | 3:1 |
| `border-control` | `surface`, `surface-raised` | 3:1 |
| `focus` | `surface`, `surface-raised` | 3:1 |

`border` is absent deliberately: a decorative divider is not a UI component
boundary and holding it to 3:1 would turn every list into a table.

**The focus ring is never checked against a fill, because it is never drawn on
one.** It sits outside the control's bounds with a 2pt gap, so the colour behind
it is always a surface. Drawn on the fill it would be blue on terracotta, which
is 1.06:1 — an indicator that is present, compliant on paper, and invisible.

A theme failing any pair does not ship. Since a theme is only a value table,
fixing one is editing a value rather than revisiting a screen.

## Device scope

**Phone-first, and phone-only in the sense that matters.** Every layout in this
document assumes one column, portrait, and one thumb. Tablets run the phone
layout scaled rather than a bespoke one.

This is a scope statement rather than a preference. The ergonomic constraints
here — a 44pt row reached one-handed in a shop, steps read from across a counter
— are claims about a phone held in a hand, and hedging them across form factors
would weaken the ones that are actually load-bearing. A two-column tablet layout
is a later decision with its own evidence behind it.

Layouts use logical start and end rather than left and right throughout, so that
adding a right-to-left language later is a translation problem and not a
re-layout of every screen.

## Navigation

Four tabs, and a profile avatar in the header for everything that is
configuration rather than cooking.

```
┌──────────────────────────────┐
│  Today                  (●)  │  ← avatar
│                              │
│                              │
├──────────────────────────────┤
│   ☉      ▦      ☰      ☑     │
│ Today   Plan  Cookbook  Shop │
└──────────────────────────────┘
```

| Tab | Holds | Why it is a tab |
| --- | --- | --- |
| **Today** | The day's meals, and targets if nutrition is on | The landing surface; where a returning user arrives (`FR-ACCT-02`) |
| **Plan** | The week and month calendar | The core loop, opened weekly |
| **Cookbook** | The household's recipes, collections, and the showcase | Two audiences: the cook looking something up, the collector browsing |
| **Shop** | The grocery list | Used one-handed in a supermarket and must be one reach from anywhere |

Shop earns a permanent slot on ergonomics rather than on frequency. It is the
only screen used while standing up, holding a basket, possibly without signal,
and putting it one tap deeper inside Plan would charge that tap in exactly the
situation least able to afford it.

The showcase lives inside Cookbook rather than taking a fifth tab. Discovery is
the way into it (`FR-RCP-17`), and a Discover tab would compete with Shop for
the reachable end of the bar while being visited far less often.

### Behind the avatar

Household and members, invitations, dietary and allergy profile, nutrition
inputs, application preferences, account and security, and the debug screen
showing the active environment (`NFR-OPS-01`).

The household screen shows roles and their permissions only once there is more
than one member (`FR-HH-02`, `FR-HH-15`). For someone cooking alone it shows an
invite action and nothing else — no roles, no approvals, no vocabulary to learn.

### Entry points from outside

A start-cooking notification opens the cooking view for that meal, not the app's
last screen. An invitation link opens the accept flow, for a signed-out visitor
through signup and directly into the household afterwards (`FR-JRN-02`).

## Patterns

These recur across screens and are specified once here.

### Allergen warning

Icon, plus the word, plus `danger` colour — in that order of reliance, so the
warning survives greyscale, colour blindness, and a bright kitchen
(`NFR-A11Y-06`). Appears on recipe cards, recipe detail, meal detail, and in the
showcase (`FR-RCP-13`). It names which ingredient and for whom, because a
household plans for several people and "contains an allergen" is not actionable.

### An incomplete check is not a passed check

Where a recipe holds an unreconciled ingredient, its allergy check cannot
complete (`FR-DIET-08`). This is shown in `warning`, with the reason and the
ingredient named — never as a clean state, and never as an allergen warning
either, since neither is true.

The failure mode this exists to prevent is a green tick meaning "we did not
find an allergen" being read as "there is no allergen". Absence of a finding and
absence of a risk are the same pixels unless they are deliberately made
different.

### Estimates

Nutrition figures round on display — energy to 5 kcal, macronutrients and fibre
to the gram, sodium to 10 mg, never a decimal (`FR-NUT-10`). The unit is
`caption` weight next to the figure, and the word *estimated* appears once per
surface rather than once per number.

Where a figure rests on convention rather than regulation, that is stated where
it is used and not in a settings page (`FR-NUT-13`).

### Claims and derivations

A dietary tag Ladle derived and one its author asserted look different, because
they are different (`FR-RCP-14`).

| Kind | Treatment |
| --- | --- |
| Derived (`vegan`, `keto`, …) | Plain tag chip, no attribution |
| Author-declared (`kosher`, `halal`, …) | Chip with the author's name and avatar |
| Under review | Chip in `text-muted`, struck, labelled *under review* |

There is no badge, tick, or shield anywhere near a dietary claim
(`FR-RCP-15`). A suppressed claim reads as under review and never as a verdict
(`FR-MOD-08`), because the author may be entirely right and waiting.

### Requests instead of refusals

Where a Member lacks permission, the control is present and reads *Request*
rather than *Add* (`FR-HH-16`). Nothing is hidden and nothing fails after the
fact — the difference is visible before the tap, not discovered after it.

### Empty states

Each names its filling action: an empty Today offers to plan a meal, an empty
cookbook offers the showcase, an empty grocery list points at the week's plan.
The first-run Today is the most important screen in the app and the one most
likely to be built last.

### Staleness

When data is served from cache without a connection, the screen carries a single
quiet line stating when it was last refreshed (`NFR-OFF-02`). Content is never
greyed, disabled, or hidden for being cached — it is the user's own pantry, and
it is probably still true.

### Loading

The query cache persists across restarts (`NFR-OFF-05`), so most opens already
have something true to show. Show it, refresh behind it, and reconcile.

Skeletons appear only when there is genuinely nothing cached — a first run, a new
household, a screen never visited. They mirror the shape of what is coming rather
than being generic grey blocks, and they never animate under reduced motion.

A user with good cached data should never watch a loading state. Doing otherwise
makes an offline-tolerant app feel slower than it is, which is the opposite of
what the caching was for.

### Failure

A write attempted without a connection, or one the server rejects, fails in
place and keeps everything the person typed (`NFR-OFF-03`).

The pattern is the same everywhere: the input stays exactly as it was, an
inline message in `danger` says what failed in plain words, and a *Try again*
action sits beside it. Nothing is a modal, nothing is a toast that disappears
before it is read, and nothing discards a draft to show an error.

The case this is written for is the recipe typed out over ten minutes in a
kitchen with poor signal. Losing that once is enough for someone to stop
trusting the app with anything longer than a line.

## Screens

### Today

The day's meals in time order, and — only if nutrition is enabled — the day's
figures against targets (`FR-NUT-04`, `FR-NUT-11`).

With nutrition dismissed, Today is a clean list of what is being eaten and when.
That is the whole screen, and it must not look like a screen with a hole in it;
this is the version the household cook who does not track sees every day.

Each meal shows its start time rather than only its serving time, since the
question the screen answers in the afternoon is *when do I need to start*.

**The nutrition panel is six rings**, one per tracked nutrient (`FR-NUT-09`),
each direct-labelled with its name and its figure.

Because every ring is labelled, colour carries no identity here — so all six use
a single hue, `accent`, rather than six. Six hues would be a categorical palette
needing colourblind separation between adjacent pairs, and it would buy nothing
that the labels are not already providing. The track behind each ring is
`border`: a decorative rail, exempt from the 3:1 bar for the same reason
dividers are. Fill against track is 3.87:1 in light and 4.21:1 in dark, so the
two read as two things.

The rings report position and never grade it (`FR-NUT-15`, `FR-NUT-16`):

- **No state colour, in either direction.** A ring does not turn green on
  reaching its target and does not redden past it. There is one colour.
- **No completion event.** Nothing fills with a flourish, pulses, or celebrates.
- **The ring caps at full; the figure does not.** Over-target is stated in the
  text — *2,340 of 2,300 mg* — rather than dramatised in the geometry. Sodium is
  the nutrient this matters most for and the one a warning colour would be most
  tempting on.
- **Figures wear text tokens**, never the ring's colour. The ring is the glance;
  the numbers are the reading, and they are the accessible equivalent of the
  whole panel.
- Rings do not animate on appearance under reduced motion (`NFR-A11Y-07`).

Rings carry completion-framing by convention, which is why every convention that
expresses completion is removed above. What remains is a shape showing how far
along the day is.

### Plan

Week view by default, month for orientation (`FR-MEAL-02`). Blocks run from
`starts_at` to `serving_time`, so a block's height is preparation plus cooking
and its top edge is when work begins (`FR-MEAL-01`).

Month view shows density rather than detail — which evenings are committed —
because at that zoom a recipe title is unreadable anyway and the question being
asked is different.

### Cookbook

The household's recipes, its collections, and the showcase, in one tab.

A search field sits persistently at the top, with a two-option scope control
directly beneath it: **My cookbook** and **Showcase**. The scope is always
visible and switchable without retyping, because a result set never mixes the two
(`FR-TAG-31`) and a list of results is otherwise indistinguishable from the same
list drawn from the other place.

Search matches titles, ingredients, and tags (`FR-TAG-30`). Ingredient matches
are worth surfacing as such — *uses chicken thigh* beneath the title — since
searching by ingredient is a different question from searching by name and the
answer should show it understood which was asked.

Below search: collections as a horizontal row of chips, then the recipes
themselves. Collections filter rather than navigate, so leaving one is dismissing
a chip rather than going back (`FR-RCP-03`).

The showcase scope opens on browsable entry points rather than an empty search
field (`FR-RCP-17`) — discovery is how the recipe collector gets in, and an
insertion point waiting for a query asks a question they do not have an answer to.

### Shop

The screen with the hardest physical constraints: one hand, a basket in the
other, a moving queue, and possibly no signal.

- Grouped by `IngredientCategory`, ordered by the household's own sequence
  (`FR-PAN-05`, `FR-PAN-06`).
- Row targets at least 44×44pt (`NFR-A11Y-01`), full-width, with the whole row
  as the target rather than a checkbox in it.
- Check-off is immediate, optimistic, and reversible; no dialog, ever
  (`FR-PAN-13`, `NFR-PERF-02`).
- Items the pantry already stocks carry a `text-muted` note rather than being
  hidden, because "we have paprika" is information, not a filter (`FR-PAN-09`).
- Fully operable offline, reconciling on reconnection (`NFR-OFF-06`).

Quantities read as a single summed figure. The contributing sources are
available on the row but not shown by default — a shopper needs to know they
want six cloves of garlic, not which two meals asked for them.

### Cooking view

Opened from a reminder or from a meal. Every recipe in the meal is in one
continuous scroll rather than in tabs, because switching between a sauce and a
main with wet hands is the thing this screen exists to avoid.

Steps are `step` size. The screen stays awake throughout (`NFR-A11Y-05`).
Marking the meal cooked is a single action at the end that decrements the pantry
and records everyone present as having eaten (`FR-MEAL-14`, `FR-PAN-11`).

### Recipe

Ingredients first, then steps — the order in which a recipe is used, not the
order in which it is written.

Each ingredient shows its reconciliation state where it matters: an unreconciled
line reads as the cook typed it and carries the quiet note that it is why the
allergy check is incomplete. Attribution, when present, sits under the title
with the original author's name, or a placeholder where that account is gone
(`FR-RCP-19`).

An upstream notice appears as a dismissible banner offering to show what changed
(`FR-RCP-11`). It never applies anything by itself, and dismissing it is not
accepting it (`FR-RCP-12`).

### Recipe editor

The screen most likely to be got wrong, because most of it looks like a form and
one part of it is not.

**Saving is not gated on completeness.** A title alone is a saveable recipe
(`FR-RCP-02`). There is no validation summary, no disabled save button, and no
required-field asterisk anywhere on this screen — the requirement is that a
recipe with three steps, no photo, and "a knob of butter" persists exactly as
written.

**Leaving does not discard.** Dismissing the editor keeps the draft, and it is
recoverable from the cookbook (`FR-RCP-16`). Nothing asks *are you sure* on the
way out, because there is nothing to be sure about.

**Ingredient entry is the subtle part.** As a cook types, the field offers catalog
matches, including by synonym (`FR-ING-01`). Three outcomes are all legitimate:

| The cook | Result |
| --- | --- |
| Accepts a match | Reconciled; nutrition, allergens, and derived dietary tags all work |
| Declines and keeps their own words | Unreconciled; the line persists exactly as typed (`FR-ING-03`) |
| Types something the catalog has never heard of | Unreconciled, and no different from declining |

Declining a match is a normal outcome and must not read as an error or an
unfinished state. It has one consequence, and the editor states it plainly and
once, near the affected line rather than as a banner: while any ingredient is
unreconciled, the recipe's allergy check cannot complete (`FR-DIET-08`).

Quantity and unit are optional per line and never block anything. The unit field
offers the ingredient's default where one is known, and accepts free text where
it is not, because *a knob* is a unit in the only sense that matters here.

## Accessibility

Not a section of its own work so much as a set of constraints the rest of this
document is shaped around. Stated here so they can be checked in one place.

| Requirement | Where it is met |
| --- | --- |
| `NFR-A11Y-01` | 44×44pt row targets on Shop; full-row hit areas |
| `NFR-A11Y-02` | The contrast pair table, validated per theme per mode in CI |
| `NFR-A11Y-03` | Platform system font throughout; sizes as roles, not points |
| `NFR-A11Y-04` | Every icon-only control carries a label |
| `NFR-A11Y-05` | Cooking view keeps the screen awake; one-handed layout |
| `NFR-A11Y-06` | Icon and text before colour, on every status |

The two that are easiest to lose are the last two. Dynamic type breaks silently
when a layout assumes a line fits, and colour-only status looks correct to
everyone building it. Both are verified by inspection each release rather than
by a test, which is why both are marked `manual` in
[`requirements.md`](./requirements.md).
