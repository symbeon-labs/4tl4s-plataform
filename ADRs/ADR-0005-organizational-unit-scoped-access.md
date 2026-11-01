# ADR-0005 — Introduce first-class organizational units with explicit scoped access

- **Status:** Proposed
- **Decision date:** 2026-11-01
- **Decision owner:** Symbeon Labs platform direction
- **Scope:** Shared Governance, identity and authorization, organizational context, initiative scope

## Context

ADR-0004 establishes Organization and OrganizationalUnit as distinct conceptual entities and requires tenant-safe references and explicit authorization semantics before schema changes. The current schema has organization-level memberships and broad organization-member access policies. Adding an organizational_units table alone would not create meaningful unit isolation and could expose unit-scoped records to every tenant member.

## Decision proposed

1. Keep Organization as the tenant boundary.
2. Introduce OrganizationalUnit as an internal/operational entity belonging to exactly one Organization.
3. Introduce explicit Unit Membership grants subordinate to active Organization Membership.
4. Permit an Initiative to be associated with at most one OrganizationalUnit in its Organization; null means organization-level scope, not public access.
5. Descendant work packages, artifacts, evidence and decisions inherit the Initiative's narrowest access scope and cannot broaden it.
6. Organization roles do not automatically grant access to unit-scoped content. Administrative responsibility and content access are distinct permissions.
7. Unit roles cannot grant organization roles, contractual authority, financial approval or IP transfer authority.
8. SOA references provide context and provenance but never grant 4TL4S access.
9. Unit records are archived, not hard-deleted, when historical references exist.
10. Enforce invariants in database constraints, RLS and server-side use cases, with authenticated multi-identity tests.

## Consequences

Requires coordinated changes to schema, RLS, indexes, relationship endpoint validation and application queries. Explicit organization-level access rules are required for unassigned initiatives. Existing broad policies must be revised before unit-scoped records are introduced. Existing data needs a compatibility and scope migration plan.

## Alternatives considered

- Generic relationships table only: rejected as sole model because it does not provide stable identity, scoped membership or reliable RLS joins.
- Separate Organization/tenant per unit: rejected because it invents tenant/legal boundaries and fragments governance.
- Unit table without revised access policies: rejected because representation without enforcement creates false security.
- Implicitly inherit all organization membership into every unit: rejected because it defeats unit-level boundaries.

## Implementation gates

Before migration: approve domain and authorization contracts; define organization-level record access and explicit grants; produce migration/rollback plan; update RLS for every scoped read/write; add tenant-safe composite FKs and indexes; update relationship validation; test synthetic tenants, units and distinct authenticated identities; review privacy, client confidentiality and IP boundaries.

This ADR remains proposed until these contracts and gates are explicitly approved. It does not claim implementation.
