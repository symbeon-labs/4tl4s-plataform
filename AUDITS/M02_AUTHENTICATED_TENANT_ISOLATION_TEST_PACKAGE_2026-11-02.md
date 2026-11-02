# 4TL4S — M02 Authenticated Tenant-Isolation Test Package

**Record ID:** 4TL4S-M02-TEST-2026-11-02-01  
**Date:** 2026-11-02  
**Branch:** integration/foundation-reconciled  
**Status:** Test package added; execution on current integration head pending.

## 1. Scope

Added supabase/tests/database/p0_authenticated_tenant_isolation.test.sql as the first executable runtime-oriented security suite using synthetic identities and explicit authenticated JWT subject contexts.

The suite is transaction-scoped and rolls back all fixtures. It does not access or modify the connected live Supabase project.

## 2. Assertions included

The initial suite contains ten pgTAP assertions:

1. Tenant A owner sees only Tenant A's initiative.
2. Tenant A cannot read Tenant B's initiative by direct identifier.
3. Tenant A cannot insert an initiative into Tenant B.
4. Tenant A cannot update Tenant B's initiative.
5. Tenant A cannot delete Tenant B's initiative.
6. Composite tenant-scoped foreign key rejects a child in Tenant A referencing a parent in Tenant B.
7. Tenant A owner can write within Tenant A.
8. Authenticated clients cannot directly insert audit events.
9. Switching JWT subject to Tenant B exposes only Tenant B's initiative.
10. Tenant A admin cannot grant owner authority.

The test uses SET LOCAL ROLE authenticated and changes request.jwt.claim.sub between synthetic users to exercise RLS under separate identities.

## 3. CI changes

The Database Validation workflow was hardened after its first integration-PR attempt failed during pgTAP package installation. The installation now adds the PostgreSQL PGDG repository in the PostgreSQL 17 service container and verifies that pg_prove is present.

The workflow's pgTAP step now runs both:
- p0_integrity_contracts.test.sql
- p0_authenticated_tenant_isolation.test.sql

The Supabase CLI workflow was also changed from invoking only the original contract file to supabase test db, so the complete database test directory is executed.

## 4. Verification boundary

The initial PR #5 Database Validation attempt failed before migration replay or test execution, at the pgTAP installation step. The workflow was corrected afterwards.

A successful pgTAP run on PR #3 commit 12f11ec5d46b3fcdb7592be3a6248b542da8e643 is recorded in the M01 follow-up evidence, but it predates this new authenticated suite.

No claim is made that the ten M02 assertions have passed. They must execute successfully on the current integration PR head. Any test failure must be corrected in the test harness or underlying policy, not suppressed or weakened.

## 5. Explicitly not covered

- Two-session concurrent last-owner race.
- Stale JWT/session revocation behavior.
- Auth invitations, MFA, recovery, session lifecycle.
- Server-side trusted audit ingestion.
- Storage object authorization.
- API-layer authorization and application workflows.
- Organizational Unit authorization, which remains a separate proposed model and is not activated.

## 6. Next gate

After the CI suite passes on the exact integration PR head:
1. Review each assertion and its actual execution output.
2. Add the two-session last-owner concurrency test in a separate isolated harness.
3. Add stale-session/revocation tests at the Auth/API boundary.
4. Keep client onboarding blocked until the complete P0 test set and trusted audit-ingestion decision are satisfied.


## 7. CI harness correction

The first Database Validation run after the PGDG installation repair successfully installed pgTAP and replayed the migration files, but failed at the test step with `pg_prove: command not found`. The package had been installed inside the PostgreSQL service container while the workflow invoked `pg_prove` on the GitHub runner host.

The workflow was corrected to copy both test files into the PostgreSQL service container and execute `pg_prove` there. This keeps the client binary and PostgreSQL runtime in the same container.

The next run must verify this correction and the M02 assertions on the current integration head.


The JWT subject changes use `SET LOCAL request.jwt.claim.sub` rather than SELECT-returning `set_config` calls, so setup statements do not emit non-TAP rows into the pgTAP output stream.
