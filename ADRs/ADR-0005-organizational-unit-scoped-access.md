# ADR-0005 - Introduce first-class organizational units with explicit scoped access

- **Status:** Accepted
- **Decision date:** 2026-11-01
- **Decision owner:** Symbeon Labs Architecture & Platform Direction
- **Scope:** Shared Governance, identity and authorization, organizational context, initiative scope

## Context

ADR-0004 establishes Organization and OrganizationalUnit as distinct conceptual entities and requires tenant-safe references and explicit authorization semantics before schema changes. The previous baseline schema had organization-level memberships and broad organization-member access policies. Adding an organizational_units table alone would not create meaningful unit isolation and could expose unit-scoped records to every tenant member.

## Decision

1. Keep Organization as the primary tenant boundary.
2. Introduce OrganizationalUnit (`organizational_units`) as an internal/operational entity belonging to exactly one Organization.
3. Introduce explicit Unit Membership grants (`unit_memberships`) subordinate to active Organization Membership.
4. Permit an Initiative to be associated with at most one OrganizationalUnit in its Organization; null means organization-level scope, not public access.
5. Descendant work packages, artifacts, evidence and decisions inherit the Initiative's narrowest access scope and cannot broaden it.
6. Organization roles do not automatically grant access to unit-scoped content. Administrative responsibility and content access are distinct permissions.
7. Unit roles cannot grant organization roles, contractual authority, financial approval or IP transfer authority.
8. SOA references provide context and provenance but never grant 4TL4S access.
9. Unit records are archived, not hard-deleted, when historical references exist.
10. Enforce invariants in database constraints, RLS and server-side use cases, with authenticated multi-identity tests.

## Selected default access policy

- Unassigned initiatives and their descendants remain available to active members of the organization, preserving the current tenant-wide baseline.
- Unit-scoped initiatives and descendants require explicit active Unit Membership in that exact unit.
- Organization owner/admin roles can manage unit structure and unit grants under policy, but do not automatically gain access to unit-scoped content.
- Read-only unit roles may read; only `unit_admin`, `unit_manager` and `contributor` may write ordinary scoped work. Approval, contractual, financial, disclosure and IP-transfer powers remain separate human-authorized permissions.
- Archived or suspended units confer no content access through their memberships.

## Consequences

- Schema, RLS, indexes and relationship endpoint validation enforce organizational unit isolation.
- Explicit composite foreign keys (`organization_id`, `id`) and (`organization_id`, `parent_unit_id`) ensure parent-child units never cross organization boundaries.
- Composite foreign keys in `unit_memberships` require that any unit member is already an active member of the parent organization.
- Test suites (`p0_integrity_contracts.test.sql`) validate unit-level constraints and RLS isolation.

## Alternatives considered

- Generic relationships table only: rejected as sole model because it does not provide stable identity, scoped membership or reliable RLS joins.
- Separate Organization/tenant per unit: rejected because it invents tenant/legal boundaries and fragments governance.
- Unit table without revised access policies: rejected because representation without enforcement creates false security.
- Implicitly inherit all organization membership into every unit: rejected because it defeats unit-level boundaries.

## Implementation status

- Domain contract: Approved in `DOMAIN_CONTRACTS/organizational_unit_domain_contract_v0.1.md`.
- Authorization contract: Approved in `GOVERNANCE/organizational_unit_authorization_contract_v0.1.md`.
- Database migration: Promoted and applied in `supabase/migrations/20261101150000_organizational_unit_scoped_access.sql`.
- Initial benchmark & seed: Calibrated against real multi-unit operations (`Hub Açaí` and `Mundo Sabor`).