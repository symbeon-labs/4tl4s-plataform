# 4TL4S — Follow-up Verification and Remaining Gates

**Audit ID:** 4TL4S-FOLLOWUP-2026-11-02-02  
**Date:** 2026-11-02  
**Project:** Supabase `4TL4S-PLATFORM` (`izllfdhxunudouhseoca`)  
**Repository:** `symbeon-labs/4tl4s-plataform`  
**Branch:** `fix/audit-reconciliation-and-readiness-gates`

## Scope

Follow-up read-only verification after the initial live reconciliation. No customer data was created, no destructive tests were run, and no production schema changes were made in this follow-up.

## Additional live evidence

| Control | Observation |
|---|---|
| Audit-event INSERT grants | INSERT is present for `service_role` and `postgres`; absent for `anon` and `authenticated` |
| Audit-event write policies | No INSERT or ALL policy exists for `audit_events` |
| Audit-event columns | Event includes organization, optional actor, type, entity type/id, JSON payload, and occurrence timestamp |
| Last-owner guard | BEFORE UPDATE/DELETE trigger invokes `private.guard_membership_invariants()` |
| Concurrency primitive | Guard locks the parent organization row `FOR UPDATE` before counting active owners |
| Relationship validation | BEFORE INSERT/UPDATE trigger validates both endpoints against the same organization |
| Edge Functions | No Edge Functions are deployed in the project |
| Storage | Bucket inventory returned no rows |
| Security Advisor | No findings |
| Performance Advisor | 31 INFO-level unused-index notices; no unindexed-FK warning |

The last-owner lock is a sound serialization mechanism at the organization level, but it is not a substitute for executing a two-session race test. The function and trigger definitions were inspected; no claim of runtime concurrency test success is made.

## What is actually closed

- Authenticated client fabrication of audit events is blocked at both privilege and RLS-policy layers.
- Foreign-key indexes flagged by the advisor were added in the already-applied migration.
- All 12 public tables have RLS enabled.
- Membership identity fields are immutable in the membership guard.
- Last active owner removal is rejected by the database guard, with organization-row locking before the count.
- Relationship endpoints are checked against the relationship's organization.

## What remains open (must not be represented as complete)

### P0 — executable security tests

- Run the existing pgTAP suite against the PR head in a disposable local Supabase stack.
- Add authenticated JWT-context tests using two synthetic organizations and users.
- Verify cross-tenant read/write isolation, composite parent/child mismatch rejection, role escalation boundaries, and stale-session behavior.
- Run concurrent owner-removal transactions in two independent sessions and preserve the outputs.

The connected production database was not used for destructive testing. No local CLI/container execution was available in this integration session, so these tests remain unexecuted.

### P0 — trusted audit ingestion

There is no deployed Edge Function and no trusted ingestion API. The database currently accepts INSERT only from privileged database roles. Do not create a generic public SECURITY DEFINER function or grant clients direct INSERT as a shortcut.

Before implementation, define and approve:
- allowed event types and entity types;
- server-derived actor identity (never trust actor_user_id from request body);
- organization authorization on every event;
- bounded payload schema and size;
- server-generated occurred_at, request/correlation ID, and idempotency key;
- redaction rules for secrets and personal data;
- failure/retry behavior and operational alerting;
- tests proving clients cannot impersonate another actor or organization.

Then implement a server-side Edge Function with JWT verification enabled, service credentials held only in server-side secrets, and explicit authorization checks. Add integration tests before deployment.

### P1 — Auth and Storage

- No deployed Edge Functions exist.
- No Storage buckets were returned by the inventory query.
- MFA enforcement, recovery, invitations, role-change approval, session revocation, and application-level authorization are not evidenced as implemented.

### P1 — client-data and repository history review

A content-classification and secret-scanning review of `symbeon_intel` and its Git history is still required. This session did not enumerate or inspect those files. No file deletion or history rewrite was performed. If credentials are found, rotate first and coordinate any history rewrite; if client personal/confidential data is found, classify the legal/contractual basis, audience, minimization and retention before remediation.

### P1 — Organizational Units

OU remains unimplemented in the live schema and is not activated by this PR. Keep it proposed until the first engagement's actual access model demonstrates the need and its authorization contract and tests are approved.

## PR topology

PR #3 remains open and draft, based on `feat/managed-engineering-operating-model`. The GitHub compare endpoint reports the head is three commits ahead and zero behind its base. The current PR snapshot reports mergeable=true (the earlier false value was stale/transient). No status checks were reported for the current head commit. PR #1 and #2 remain open and unchanged.

## Exit criteria before production access

1. pgTAP suite passes on a disposable database and is tied to an exact commit SHA.
2. Authenticated tenant-isolation and privilege-escalation tests pass with distinct JWT identities.
3. Two-session last-owner race test passes.
4. Trusted audit ingestion is implemented and tested, or the product scope explicitly forbids operational writes until it exists.
5. Auth lifecycle and Storage policies are implemented and tested for the intended MVP.
6. Client-data classification and secret scanning are complete before client material is stored.
7. Security review and advisor checks are repeated after implementation.

**Conclusion:** the live database's known P0 schema misconfiguration is corrected, and additional catalog evidence supports the existing tenant and last-owner controls. The remaining P0 work is executable runtime testing and a trusted audit pipeline; these cannot honestly be closed by documentation-only changes.


## 2026-11-02 — catalog contract execution

A read-only SQL execution was run against the connected live project to evaluate the same 14 catalog assertions defined in `supabase/tests/database/p0_integrity_contracts.test.sql`.

**Result: 14/14 PASS.**

| # | Assertion | Result |
|---:|---|---|
| 1 | RLS enabled on all 12 public tables | PASS |
| 2 | Eight tenant-scoped parent foreign keys installed | PASS |
| 3 | Four tenant-scoped unique keys installed | PASS |
| 4 | Relationship endpoint validation trigger installed | PASS |
| 5 | Membership invariant trigger installed | PASS |
| 6 | Organization identity trigger installed | PASS |
| 7 | Four consolidated membership policies | PASS |
| 8 | No duplicate permissive policy groups | PASS |
| 9 | Four private trigger helpers are SECURITY DEFINER with explicit search_path | PASS |
| 10 | Authenticated cannot execute endpoint helper | PASS |
| 11 | Authenticated cannot execute membership guard helper | PASS |
| 12 | Authenticated cannot execute organization guard helper | PASS |
| 13 | Authenticated has no audit INSERT policy | PASS |
| 14 | Authenticated has no audit INSERT grant | PASS |

**Important test boundary:** this was an equivalent read-only catalog query, not execution of the pgTAP file. The live project does not have the `pgtap` extension installed. The container environment also could not clone the GitHub repository (DNS/network unavailable), and no local Supabase CLI/test stack was available. Therefore `supabase test db` remains unexecuted.

No data writes or destructive operations were performed. Authenticated multi-tenant behavior and concurrent last-owner behavior remain untested.
