---
name: migration
description: Writes a Supabase SQL migration from the data model in data.md, with its RLS policies in the same file. Use when adding or changing a table, column, constraint, index, or policy.
---

## Instructions

### 1. Take the shape from `data.md`, not from the requirement text

Every table is written up as `#### \`table_name\`` followed by its columns and,
beneath them, a line beginning `**RLS** —` stating the predicate in prose.

    sed -n '/^#### `grocery_list_items`/,/^\*\*RLS\*\*/p' docs/data.md

That prose line is the specification for the policies you are about to write.
Translate it; do not reinterpret it. Columns cite the requirement they exist to
satisfy - carry those identifiers into the migration as comments so the reason a
column exists survives into the schema.

If `data.md` does not describe what you are about to build, **stop and write it
there first.** The model is the design; the migration is its transcription. A
migration that invents a column is a design decision made in the least reviewable
place in the repository.

### 2. Scaffold it

    supabase migration new add_grocery_item_sources

Timestamped, never hand-named. One coherent change per migration.

### 3. Write RLS in the same file as the table

This is the invariant that matters most here, and it is not a convention:

> **A table without RLS is a data breach.** The client queries PostgREST
> directly, so the policy *is* the authorization model - there is no server-side
> layer behind it that will catch the omission.

`NFR-SEC-01` requires row-level security enabled in the same migration that
creates the table. Not the next one. In the same file, immediately beneath the
`create table`:

```sql
alter table public.grocery_list_items enable row level security;

create policy "members read their household's grocery list"
  on public.grocery_list_items for select
  using ( household_id in (
    select household_id from public.household_members
    where user_id = auth.uid()
  ) );
```

Where an operation legitimately crosses a user boundary - accepting an
invitation, an administrator acting on a report - it goes through a
`security definer` function so the action stays attributable to a person, rather
than through `service_role`. `NFR-SEC-09` requires each such escalation to be
explicit and commented at its call site.

### 4. Enforce invariants in the database

`NFR-DATA-01` puts invariants in constraints, generated columns, and triggers
rather than in client validation. The model already relies on this - the single
owner per household is a partial unique index, `meals.starts_at` is generated,
and `grocery_item_sources` uses a check to allow exactly one of its two parents.
If you find yourself planning to validate something in TypeScript, check whether
the database can hold it instead.

### 5. Verify from empty

    supabase db reset

This is the definition of a clean environment: it drops everything, replays every
migration in order, and applies the seed. `NFR-DATA-04` requires the chain to
build from empty, and a migration that only works against your current local
database fails here rather than in CI.

Then regenerate the types, which `NFR-DATA-05` requires to be committed so a
schema change that breaks the app fails at compile time:

    supabase gen types typescript --local > src/types/database.ts

### 6. Commit the migration on its own

The migration, its policies, and the regenerated types are one commit. Application
code that uses the new shape is a separate one, after it - so that reverting the
app never strands the schema.

```
Added grocery item source provenance

Each claim on a grocery list item is its own row, so deleting a meal
withdraws only that meal's claim.

Requirement: FR-MEAL-08, FR-PAN-03, NFR-DATA-02
Phase: P4
```

### Never

- **Edit a migration that has been merged.** It has been applied somewhere and
  `db reset` replays it. Corrections are new migrations; fix forward.
- **Change the schema in Supabase Studio.** Studio is for inspection. Schema
  lives in migrations, and there is no ORM to reconcile the difference.
- **Seed, reset, or restore production, or copy its data anywhere.** `NFR-DATA-06`.
  All non-production data is synthetic.
