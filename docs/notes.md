- `User` Profiles
    - Profile Data
        - `UserPublic` includes:
            - `UserPublic.id` : uuid (PK)
            - `UserPublic.userId` : uuid (FK)
            - `UserPublic.displayName` : str - The `User`
            - `UserPublic.profilePicture` : url
            - `UserPublic.aboutMe` : nullable str - The `User` may optionally add an 
            - ...
        - `UserDemographics`:
            - `UserDemographics.id` : uuid (PK)
            - `UserDemographics.userId` : uuid (FK)
            - `UserDemographics.dob` : date
            - `UserDemographics.height` : number
            - `UserDemographics.pronouns` : nullable ENUM( "she/her" | "he/him" | "they/them" )
            - ...
        - `UserMetadata`:
            - `UserMetadata.id` : uuid (PK)
            - `UserMetadata.userId` : uuid (FK)
            - `UserMetadata.createdAt` : timestamptz
            - `UserMetadata.lastLoggedIn` : timestamptz
            - `UserMetadata.isActive` : boolean
            - ...
    - Application Preferences (themeing, unit system, notification preferences)
        - `UserPreferences` includes:
            - `UserPreferences.id` : uuid (PK)
            - `UserPreferences.userId` : uuid (FK)
            - `UserPreferences.themeMode` : ENUM( "Light" | "Dark" | "System" )
            - `UserPreferences.theme` : uuid (FK) - Associated with `Theme.id`. The `Theme` table records a list of curated themes from which `User`s can choose. This value defaults to the same uuid when a new `User` is created.
            - `UserPreferences.unitSystem` : ENUM( "US" | "Metric" | ...)
            - ``UserPreferences.language` : ENUM( "English - US" | "English - UK" | "Spanish" | ... ) - will need to build a translation service before this does anything.
            - ...
    - Dietary Profiles (individual ingredients like "garlic" or categories like "nightshades")
        - `UserDiets` :
            - `UserDiets.id` : uuid (PK)
            - `UserDiets.userId` : uuid (FK)
            - `UserDiets.allergies` : nullable List[uuid] (FK) - A list of `Ingredient.id`s and `IngredientCategory.id`s that the `User` selects during onboarding or updates in settings. These are strictly avoided during `Recipe` recommendation processes.
            - `UserDiets.favorites` : nullable List[uuid] (FK) - A list of `Recipe.id`s selected by the `User`.
            - `UserDiets.model` : nullable List[uuid] (FK) - A list of `DietaryModel.id`s that link a framework of dietary rules, restrictions, etc. to a specific `User`. For example, a `User` can observe Kosher and be Vegetarian. (Vegan, Keto, Kosher, High Protein, etc.)
    - Security Settings (MFA, Privacy Settings, etc.)
        - ...

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
    - Every `Ingredient` has one-and-only-one *IngredientCategory*s to which it belongs. These *IngredientCategory*s can be from the following list:
        - "Animal Products"

- `Tag`s in Search, Recommendation, and Recipe Incompatibility constraints
    - A `Tag` looks like:


- Nutrition Tracking
    - 