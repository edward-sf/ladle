---
name: user-experience.md
description: This file describes the target audience(s), major and minor features, and intended user experience paths for the Ladle application.
---
# User Experience

## Who is this for?

The primary audience for Ladle is the **household cook**, providing them tools to plan meals on their household calendar, manage their household membership and cookbook, and keep their household pantry stocked. This work requires regular, often unseen mental labor that could be reduced by the more integrated tooling that Ladle provides.

Another audience for Ladle is the **nutrient tracker** - the health-conscious person who wants to understand what they're consuming and whether they are hitting their health goals. Meal planning is more than deciding what to cook; it's a strategy for health and diet. Ladle's `Today` tab provides an overview of the current day's planned meals and how that plan satisfies 

## Features

- `User` Profiles
    - Demographic Data (some public, some private)
        - Public data (displayName, profilePicture)
        - Private
    - Application preferences (themeing, unit system, notification preferences)
        - Themeing (Light/Dark/System mode, curated themeing)
        - Unit System (imperial/metric/etc.)
        - Language Settings
        - Timezone
    - Allergy Profiles (individual ingredients like "garlic" or categories like "nightshades")
        - Individual `Ingredient`s like *Garlic* are allowed, as well as `IngredientCategory`s 
    - Dietary Model (Vegan, Keto, Kosher, High Protein, etc.)
    - Security Settings (MFA, Privacy Settings, etc.)

- `Household` Management
    - `User`s can create and be a member of one-or-more `Household`s.
        - `User`s may be:
            - an *Owner* (one-and-only-one per `Household`),
                - The *Owner* of a `Household` has full Read-Write-Delete permissions for that Household. They can manage membership, manage roles, add `Meal`s to the `Household`'s `Calendar`, approve or deny `Meal` requests, etc.
            - an *Admin* (zero-or-more per `Household`),
                - An *Admin* of a `Household` has Read-Write permissions for that `Household`. They can send `Invitation`s to the `Household`, 
            - a *Member* (zero-or-more per `Household`),
                - A *Member* of a `Household` has View-Request permissions for that `Household`. They can suggest `Meal` for the meal plan `Calendar`, which can be approved or denied by the *Owner* or *Admin*s. They can also request an `Ingredient` be added manually to the `GroceryList`, which can be approved or denied by the *Owner* or *Admin*s.

- `Meal` Planning
    - `Household`s have one-and-only-one meal plan `Calendar`. This `Calendar` has week/month views.
    - `Meal`s are represented like Google Calendar's or Outlook's calendar events with the `ServingTime` being set when creating the `Meal`; the block on the `Calendar` is then sized to reflect $ServingTime - (PrepTime + CookTime)$ as the starting time of the block.
    - A `Meal` can have one-or-more `Recipe`s added to it. The `Meal` is agnostic about whether a `Recipe` is a drink, side, main, etc.
    - `User`s can be added to a `Meal`'s participants to indicate that they'll be eating 

- `GroceryList` Management
    - `Household`s have one-and-only-one `GroceryList`s, a collection of `Ingredient`s that the *Owner* or *Admin*s manage. `Ingredient`s populate on a `GroceryList` automatically when a `Meal` is added to the `Household`'s `Calendar`. When a `Meal` is removed from the `Calendar`, the `Ingredient`s it added to the `GroceryList` are removed.
    - The *Owner* and *Admin*s of a `Household` can manually add `Ingredient`s to the `GroceryList` and manually edit their quantities. *Member*s of the `Household` can request `Ingredients` to add to the `GroceryList`, which the *Owner* and *Admin*s can approve - adding the `Ingredient` to the `Household`'s `GrocerList` - or deny.

- `Recipe` Management
    - `Household`s have one-or-more `Cookbook`s, which contain zero-or-more `Recipes`.
    - The original creator of a `Recipe` is the default *Author* for that `Recipe`. Additional *Author*s can be added manually, providing them Write permissions on that `Recipe`. *Author*s must be the *Owner* or an *Admin* for the `Household` owning the `Cookbook` in which the `Recipe` is written.
    - `Recipe`s can either be *Private*, readable only by the *Owner*, *Admin*s, or *Member*s of the `Household` in which the `Cookbook` is held, or they can be *Public*, which lists it in the app-wide showcase.
    - A `Household`'s *Owner* or *Admin*s can add `Recipe`s to that `Household`'s `Cookbook`, either by manually creating a new `Recipe` or by copying a `Recipe` from the app-wide showcase.

- `Pantry` Management
    - `Household`s have one-and-only-one `Pantry`, an inventory of `Ingredient`s. These `Ingredient`s can automatically populate to the `Pantry` inventory from the `GroceryList`. The *Owner* and *Admin*s of a `Household` can manually add `Ingredient`s to the `Pantry` inventory.

- `Ingredient` Catalog
    - Ladle provides an app-wide catalog of generic `Ingredient`s to be used in `Recipe`s, inventoried in `Pantry`s, and tracked in `GroceryList`s.
    - Every `Ingredient` has an associated `IngredientNutrition` entry, which provides nutritional estimates for those generic `Ingredient`s and served to `User`s through Nutrition Tracking features.

- Nutrition Tracking
    - 


### Major Features

#### Major Feature 1

*Description*

##### Requirements
- This feature must feel ergonomic.

##### User Stories
1. *As a user*, I

### Minor Features

#### Minor Feature 1

*Description*

##### Requirements
- This feature must feel ergonomic.

##### User Stories
1. *As a user*, I
