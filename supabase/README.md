# 4TL4S Database Foundation

## Status

The initial schema and P0 tenant-integrity hardening migrations are applied to the dedicated Supabase project `4TL4S-PLATFORM` in `sa-east-1`. This is an implementation baseline, not a production security certification.

## Migration history

| Version | Migration |
|---|---|
| `202611010001` | `initial_platform_schema` |
| `20261101123353` | `p0_tenant_integrity_and_membership_authority` |
| `20261101123510` | `consolidate_membership_management_policies` |
| `20261101123533` | `remove_redundant_single_column_parent_foreign_keys` |\n| `20261101140000` | `harden_audit_event_ingestion` |

The initial schema migration creates the 12 domain tables. The P0 migrations add tenant-scoped composite foreign keys, relationship endpoint validation, membership authority boundaries, last-owner protection, immutable organization identity fields, and consolidated membership policies.

## Domain tables

| Area | Tables |
|---|---|
| Identity and tenancy | `profiles`, `organizations`, `memberships` |
| Operations | `initiatives`, `work_packages` |
| Artifact lifecycle | `artifacts` |
| Evidence and decisions | `evidence_records`, `decision_records` |
| IP governance | `ip_assets`, `relationships` |
| Integrations and audit | `integration_connections`, `audit_events` |

## Access and integrity model

- RLS is enabled on all 12 public tables.
- Membership-backed helper functions enforce organization membership.
- Organization creation assigns the creator the `owner` role.
- Parent/child references across initiatives, work packages, artifacts, evidence, decisions, and IP assets are constrained to the same organization.
- Relationship endpoints are checked for supported entity type, existence, and same-organization ownership.
- Only owners can grant or manage privileged owner/admin memberships; admins are limited to non-privileged membership roles.
- The final active owner cannot be demoted, suspended, or deleted.
- Membership organization and user identity fields are immutable.
- Organization `id` and `created_by` are immutable.
- Integration connection metadata is restricted to organization owners and admins.
- Authenticated clients have no direct INSERT, UPDATE or DELETE path into `audit_events`; trusted server/database ingestion is required. The ingestion pipeline is not yet implemented.
- New Auth users receive a profile row through an Auth trigger.

## Automated database tests

Schema-contract tests are located at:

- `tests/database/p0_integrity_contracts.test.sql`

They use pgTAP to verify installed RLS coverage, tenant-scoped constraints, triggers, membership policy consolidation, and function privilege boundaries.

Run locally with the Supabase CLI and a local database:

```bash
supabase start
supabase test db
```

The test file is a catalog-level contract suite. It passed in the GitHub Actions PostgreSQL 17 validation workflow on 2026-11-01 (14 assertions). It does **not** prove behavior under distinct authenticated JWT identities or concurrent owner-removal attempts. Those runtime tests must use isolated test identities and tenant fixtures in a disposable local/test database, never production.

## Remaining limitations before production

1. Cross-tenant read/write tests with distinct authenticated identities have not yet been executed.
2. Concurrent last-owner mutation behavior still requires a multi-session integration test.
3. The relationship entity-type allowlist is intentionally explicit; adding new entity types requires a migration and corresponding tests.
4. Audit events are append-only for authenticated clients through current grants and policies, but privileged service credentials can bypass RLS. Service-side controls and operational logging remain necessary.
5. No automatic audit trigger has yet been attached to every mutable business table.
6. Invitation flows, role-change approval, account recovery, MFA policy, and session hardening remain to be implemented.
7. Secrets must not be stored in `integration_connections`; `secret_reference` is only a pointer to an external secret manager.
8. Storage buckets and object-level policies are not yet configured.

## Data protection stance

No customer records, RS Advogados information, or third-party project payloads were seeded. The database remains intentionally empty. Client-specific data must only be introduced after organization isolation, access tests, and the relevant engagement scope have been reviewed.

## Next implementation sequence

1. Execute the pgTAP contract suite in a local Supabase environment.
2. Add authenticated multi-tenant integration tests and concurrency tests.
3. Implement Supabase Auth flows and server-side authorization.
4. Implement the Next.js application shell and organization onboarding.
5. Add audited APIs and scoped GitHub integration.
6. Configure Storage with private buckets and organization-scoped policies.
7. Run lint, type checks, build, and security review before opening the MVP for operational use.


## Organizational Unit access proposal (not applied)

The design package is available under `proposals/`:

- `organizational_unit_scoped_access_v0.1.sql` — proposed schema, helper functions, hierarchy and scope-consistency guards, scope-aware RLS policies, separate unit-administrator membership authority, and fail-closed relationship access.
- `organizational_unit_validation_matrix_v0.1.md` — synthetic multi-tenant authorization and integrity test matrix.

Selected policy proposal:
- Unassigned organization-level initiatives remain available to active members of that organization, preserving the current baseline.
- Unit-scoped initiatives and descendants require explicit active Unit Membership.
- Organization owners/admins manage unit structure but do not automatically gain access to unit-scoped content.
- Read-only unit roles can read; only unit_admin, unit_manager and contributor roles can write ordinary unit-scoped work.
- Suspended organization membership or inactive unit lifecycle blocks unit-content access.

**Relationship control:** the proposal now denies authenticated access to `relationships` until endpoint-aware authorization is implemented and runtime-tested. This is a deliberate fail-closed restriction; relationship graph functionality is unavailable under the proposal.

This SQL is stored under `proposals/`, not `migrations/`. It was successfully parsed and applied against a disposable PostgreSQL 17 database in GitHub Actions on 2026-11-01. This validates syntax and object creation only; authenticated authorization behavior and concurrency have not been runtime-tested. Do not execute it in production. ADR-0005 and the domain/security contracts remain proposed pending review and approval.
