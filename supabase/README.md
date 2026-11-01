# 4TL4S Database Foundation

## Status

Initial schema migration applied to the dedicated Supabase project `4TL4S-PLATFORM` in `sa-east-1`. This is an implementation baseline, not a production security certification.

## Migration

- `migrations/202611010001_initial_platform_schema.sql`
- Migration name: `initial_platform_schema`
- Applied successfully and confirmed in Supabase migration history.

## Domain tables

| Area | Tables |
|---|---|
| Identity and tenancy | `profiles`, `organizations`, `memberships` |
| Operations | `initiatives`, `work_packages` |
| Artifact lifecycle | `artifacts` |
| Evidence and decisions | `evidence_records`, `decision_records` |
| IP governance | `ip_assets`, `relationships` |
| Integrations and audit | `integration_connections`, `audit_events` |

## Access model

- Every tenant-owned record carries an `organization_id`.
- RLS is enabled on all 12 public tables.
- Membership-backed helper functions enforce organization membership.
- Organization creation assigns the creator the `owner` role.
- Integration connection metadata is restricted to organization owners and admins.
- Audit events have read and insert policies only; authenticated users are not granted update/delete privileges.
- New Auth users receive a profile row through an Auth trigger.

## Important limitations before production

1. RLS policies have been installed, but cross-tenant adversarial tests have not yet been executed.
2. Relationship endpoints use typed UUID references; entity existence and same-tenant consistency must be enforced in a subsequent constraint/trigger layer.
3. Child records must be validated against the same organization as their parent; this is not yet fully enforced by composite foreign keys.
4. Audit events are append-only for authenticated clients through current grants and policies, but privileged service credentials can bypass RLS. Service-side controls and operational logging remain necessary.
5. No automatic audit trigger has yet been attached to every mutable business table.
6. Invitation flows, role-change approval, account recovery, MFA policy, and session hardening remain to be implemented.
7. Secrets must not be stored in `integration_connections`; `secret_reference` is only a pointer to an external secret manager.
8. Storage buckets and object-level policies are not yet configured.

## Data protection stance

No customer records, RS Advogados information, or third-party project payloads were seeded. The database is intentionally empty. Client-specific data must only be introduced after organization isolation, access tests, and the relevant engagement scope have been reviewed.

## Next implementation sequence

1. Add integrity constraints for tenant-consistent parent/child references.
2. Add automated tests for RLS isolation and role boundaries.
3. Implement Supabase Auth flows and server-side authorization.
4. Implement the Next.js application shell and organization onboarding.
5. Add audited APIs and scoped GitHub integration.
6. Configure Storage with private buckets and organization-scoped policies.
7. Run lint, type checks, build, and security review before opening the MVP for operational use.
