# Security policy

## Status

Ladle is at the planning stage. There is no application code, no deployed
service, and no user data — this repository holds design documentation, and the
first release is scheduled for April 2027.

Until then the useful thing to report is a flaw in the design rather than a
vulnerability in a running system: a row-level security predicate in
[`docs/data.md`](docs/data.md) that does not hold, a requirement in
[`docs/requirements.md`](docs/requirements.md) that would be unsafe if built
exactly as written, or a claim in [`docs/privacy.md`](docs/privacy.md) that does
not survive contact with the regulation it cites. Those are cheaper to fix now
than at any later point, which is most of why this file exists this early.

## Reporting

Use GitHub's private vulnerability reporting — **Security → Report a
vulnerability** on this repository. It reaches the maintainer privately and does
not open a public issue.

Please do not open a public issue for anything you believe is exploitable.

## What to expect

Ladle is built and maintained by one person. This policy would rather be
accurate than impressive:

- Acknowledgement within a week.
- An assessment, or an honest "still looking at it", within a month.
- No bounty — there is no revenue to fund one.

If a report is valid and you would like the credit, you will get it.

## Scope

In scope, once there is something running:

- The Ladle mobile application.
- The Supabase project behind it — schema, row-level security policies, Edge
  Functions, and storage rules.
- This repository and its contents.

Out of scope:

- Supabase, Expo, Apple, and Google themselves. Those go to their own programmes.
- Anything requiring physical access to an already-unlocked device.
- Automated scanning against a production environment.

## Please do not

Access, modify, or retain data belonging to anyone but yourself. Ladle holds
health data for the households that use it — allergies, and the demographics
behind a nutrition target — and the point of reporting a flaw is to protect those
people rather than to demonstrate how far it reaches.
