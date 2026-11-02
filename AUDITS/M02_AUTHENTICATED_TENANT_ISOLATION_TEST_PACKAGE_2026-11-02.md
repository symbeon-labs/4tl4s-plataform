# 4TL4S — M02 Authenticated Tenant-Isolation Test Package

**Record ID:** 4TL4S-M02-TEST-2026-11-02-01  
**Date:** 2026-11-02  
**Branch:** integration/foundation-reconciled  
**Status:** 12 authenticated tenant-isolation assertions passed in Database Validation on integration head `059342676c6a4d4ea03d0fd400aa0301f10948e9`; the separate Supabase CLI workflow is still running.

## 1. Scope

Added supabase/tests/database/p0_authenticated_tenant_isolation.test.sql as the first executable runtime-oriented security suite using synthetic identities and explicit authenticated JWT subject contexts.

The suite is transaction-scoped and rolls back all fixtures. It does not access or modify the connected live Supabase project.

## 2. Assertions included

The initial suite contains twelve pgTAP assertions:

1. Tenant A owner sees only Tenant A's initiative.
2. Tenant A cannot read Tenant B's initiative by direct identifier.
3. Tenant A cannot insert an initiative into Tenant B.
4. Tenant A's UPDATE against Tenant B is filtered without an error.
5. Tenant A's DELETE against Tenant B is filtered without an error.
6. The Tenant B initiative remains unchanged after Tenant A's UPDATE attempt.
7. The Tenant B initiative remains present after Tenant A's DELETE attempt.
8. Composite tenant-scoped foreign key rejects a child in Tenant A referencing a parent in Tenant B.
9. Tenant A owner can write within Tenant A.
10. Authenticated clients cannot directly insert audit events.
11. Switching JWT subject to Tenant B exposes only Tenant B's initiative.
12. Tenant A admin cannot grant owner authority.

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


## 8. SQL assertion correction

The first M02 execution reached the test file but failed because PostgreSQL does not allow a data-modifying CTE nested inside the scalar expression passed to pgTAP's `is()`. The UPDATE and DELETE checks were rewritten as `lives_ok()` statements under the authenticated role, followed by post-reset assertions that prove the other tenant's row was unchanged and still exists. The plan is now twelve assertions.


## 9. Verified execution — integration head 0593426

**GitHub Actions workflow:** Database Validation  
**Run ID:** `41545893344`  
**Job ID:** `125621300128`  
**Commit:** `059342676c6a4d4ea03d0fd400aa0301f10948e9`  
**Job conclusion:** `success`

The workflow replayed all five active migrations against a disposable PostgreSQL 17 database, then executed both pgTAP files:

- `p0_integrity_contracts.test.sql` — PASS
- `p0_authenticated_tenant_isolation.test.sql` — PASS
- Combined result: **Files=2, Tests=26, Result=PASS**

The 12 assertions in this M02 suite executed successfully. The workflow also parsed/applied the Organizational Unit proposal in the disposable database and completed its fail-closed object/policy checks. This did not activate OU in the live Supabase project.

### Defects corrected before the passing run

1. Fixed the UPDATE and DELETE pgTAP SQL dollar-quote delimiters.
2. Replaced a data-modifying CTE nested in `is()` with a direct `lives_ok()` INSERT assertion; PostgreSQL rejects the former placement.
3. Fixed two literal escaped newline sequences (`\\n`) in the OU proposal that caused psql to interpret `\\nREVOKE` as an invalid meta-command.

### Remaining verification boundary

The passing Database Validation run is tied to the exact commit above and uses a disposable PostgreSQL 17 service database. The separate `Database pgTAP` workflow, which starts a full local Supabase stack, is still in progress for the same commit and must be observed to completion.

M02 is not fully closed: the two-session concurrent last-owner test, stale JWT/session revocation, and Auth/API lifecycle tests remain outstanding. No live Supabase writes or destructive live tests were performed.
