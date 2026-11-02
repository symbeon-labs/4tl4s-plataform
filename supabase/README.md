# 4TL4S Database Foundation

## Live status — verified 2026-11-02

The connected Supabase project is `4TL4S-PLATFORM` (`izllfdhxunudouhseoca`), region `sa-east-1`, PostgreSQL 17. The live project reports 12 public tables, all with RLS enabled, and zero rows in the inspected domain tables.

The live migration history was checked directly. It contains the four foundation migrations plus `20261102041633_harden_audit_event_insert_and_index_foreign_keys`. Do not infer live state from a branch or migration file alone; reconcile both before every deployment.

This is an implementation baseline, not a production security certification.

## Applied migration history

| Version | Migration |
|---|---|
| `20261101115251` | `initial_platform_schema` |
| `20261101123353` | `p0_tenant_integrity_and_membership_authority` |
| `20261101123510` | `consolidate_membership_management_policies` |
| `20261101123533` | `remove_redundant_single_column_parent_foreign_keys` |
| `20261102041633` | `harden_audit_event_insert_and_index_foreign_keys` |

The fifth migration removes the authenticated-client INSERT policy on `audit_events`, revokes direct INSERT from `anon` and `authenticated`, and adds indexes covering the 12 foreign-key columns identified by the Supabase Performance Advisor.

## Domain tables

| Area | Tables |
|---|---|
| Identity and tenancy | `profiles`, `organizations`, `memberships` |
| Operations | `initiatives`, `work_packages` |
| Artifact lifecycle | `artifacts` |
| Evidence and decisions | `evidence_records`, `decision_records` |
| IP governance | `ip_assets`, `relationships` |
| Integrations and audit | `integration_connections`, `audit_events` |

## Verified controls

- RLS is enabled on all 12 public tables.
- Tenant-scoped composite foreign keys protect important parent/child references.
- Membership authority and last-active-owner protections are installed. The live trigger locks the parent organization row before counting active owners, serializing competing owner-removal attempts at that organization.
- Relationship endpoint validation is installed for the currently supported entity types.
- Authenticated clients have neither a direct INSERT grant nor an INSERT/ALL RLS policy on `audit_events`. The live grants show INSERT only for `service_role` and `postgres`.
- The live security advisor returned no findings on 2026-11-02.

**Important:** blocking direct client insertion does not implement trusted audit ingestion. There is currently no deployed Edge Function for this project. A server-side ingestion path, actor attribution, event schema validation, correlation IDs, idempotency, and coverage of material business mutations remain to be implemented. Until then, the audit table is deliberately not writable by ordinary authenticated clients.

## Migration and test workflow

Run in a local/disposable Supabase environment:

```bash
supabase start
supabase test db
```

The existing pgTAP contract file must be inspected and executed against the exact PR head before claiming database tests pass. Catalog inspection alone does not prove runtime tenant isolation.

Required runtime tests:
1. Two synthetic users in separate organizations: prove cross-tenant SELECT returns no rows and cross-tenant INSERT/UPDATE/DELETE are rejected.
2. Parent/child tenant mismatch: prove composite references reject cross-organization references.
3. Membership authority: prove a member cannot grant roles, an admin cannot create/modify owner/admin authority, and only an owner can manage owner-level membership.
4. Last-owner race: use two independent sessions attempting to deactivate/delete the final two active owners; assert at least one active owner remains and one competing transaction fails.
5. Stale-session/revocation: verify the application's chosen session invalidation behavior; JWT claims alone are not assumed to refresh immediately.

Do not run destructive authorization tests against the live project. Use synthetic identities and disposable databases.

## Remaining limitations before production

1. pgTAP and authenticated runtime tests have not yet been executed in this environment; do not report them as passed.
2. Trusted audit ingestion is not implemented; no automatic audit trigger covers every mutable business table.
3. Invitation flows, role-change approval, account recovery, MFA policy, and session hardening remain outstanding.
4. No Edge Functions are currently deployed for this project. Storage bucket inventory returned no buckets; private object storage and object-level policies are not configured.
5. Service-role credentials can bypass RLS; keep them server-side, scope their use, and add operational logging.
6. `secret_reference` must remain a pointer to an external secret manager; secrets must not be stored in `integration_connections`.
7. The Performance Advisor reports 31 unused-index notices. With the database currently empty, this is expected; review after representative workload rather than deleting indexes prematurely.

## Data protection stance

The live database currently contains no domain rows in the inspected tables. Do not seed customer or RS Advogados information until tenant isolation, authorization tests, and engagement scope have been reviewed.

The Git repository and its history require a separate content-classification review before client documents are committed. Private repository visibility is not a substitute for data minimization, access scoping, retention, or secret scanning.

## Organizational Unit access — not applied

The Organizational Unit design package remains under `proposals/`:

- `organizational_unit_scoped_access_v0.1.sql`
- `organizational_unit_validation_matrix_v0.1.md`

The live schema has no Organizational Unit tables or Unit Membership model. The proposed SQL has not been applied. ADR-0005 remains proposed in the reconciled implementation state. Do not move proposal SQL into active migrations until the domain and authorization contracts, migration/rollback plan, RLS changes, and authenticated runtime tests are approved.

## Next implementation sequence

1. Run the repository's pgTAP suite locally and preserve output with commit SHA.
2. Add and execute authenticated tenant-isolation tests with distinct JWT identities.
3. Add and execute multi-session concurrency tests for last-owner protection.
4. Approve an audit event contract and implement trusted server-side ingestion with actor identity, validation, correlation, idempotency, and failure handling.
5. Implement Auth flows and server-side authorization.
6. Implement the application shell and organization onboarding.
7. Configure private Storage buckets and organization-scoped object policies.
8. Review client files and Git history for classification and secret exposure before client materials enter this repository.
9. Run lint, type checks, build, security review, and advisor checks before MVP access.
