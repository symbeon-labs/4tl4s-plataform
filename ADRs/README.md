# Architecture Decision Records

Architecture Decision Records (ADRs) preserve consequential decisions and their rationale. They prevent assumptions from silently becoming architecture.

## When to create an ADR

Create an ADR when a decision materially affects:
- domain boundaries or lifecycle rules;
- ownership, IP, or data isolation;
- identity, authorization, or agent permissions;
- core technology choices or persistence;
- integration contracts;
- evidence, audit, or approval semantics;
- deployment, security, or operational risk.

## Required structure

- ID and title;
- status: proposed, accepted, superseded, or rejected;
- date and decision owner;
- context and problem;
- considered options;
- decision and rationale;
- consequences and trade-offs;
- affected domains and migration implications;
- references and review date where applicable.

## Rules

- Keep accepted decisions immutable in meaning; supersede with a new ADR rather than rewriting history.
- Link implementation changes to relevant ADRs.
- Distinguish a proposal from an accepted decision.
- Record exceptions and their expiry or review condition.
- An ADR documents a decision; it does not prove implementation.

## Index

- [ADR-0001 — Separate operating domains under shared governance](ADR-0001-operating-domains.md)
- [ADR-0002 — Preserve project autonomy and IP boundaries](ADR-0002-project-autonomy-and-ip-boundaries.md)
- [ADR-0003 — Govern research-to-development transfer](ADR-0003-research-to-development-transfer.md)
- [ADR-0004 — Represent organizational units separately and consume SOA context by reference](ADR-0004-organizational-units-and-soa-context.md)
- [ADR-0005 — Introduce first-class organizational units with explicit scoped access](ADR-0005-organizational-unit-scoped-access.md)

ADR-0005 is **Accepted** and its database migration is active under supabase/migrations/20261101150000_organizational_unit_scoped_access.sql.
