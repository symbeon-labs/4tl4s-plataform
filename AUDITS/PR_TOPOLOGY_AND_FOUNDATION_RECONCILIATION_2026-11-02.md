# 4TL4S — PR Topology & Foundation Reconciliation

**Audit ID:** 4TL4S-M01-2026-11-02-01  
**Date:** 2026-11-02  
**Repository:** `symbeon-labs/4tl4s-plataform`  
**Scope:** Read-only review of PRs #1–#3, their branch relationships, database migrations, test workflows, and reconciliation claims.

> This addendum records repository evidence and branch comparisons. It does not approve a merge, migration, production write, client-data import, or change to the live Supabase project.

## 1. Executive disposition

**M01 is not merge-ready.** PR #3 is currently the most reconciled implementation branch for the live database facts, but the PR stack is not a clean linear chain from PR #1 through PR #3. PR #1 contains an Organizational Unit implementation and seed path that conflict with the live reconciliation recorded in PR #3. The migration histories represented by PR #1 and the live project also differ.

Recommended disposition:

- Keep PR #4 (this audit plan) open as a documentation review.
- Do not merge PR #1, #2, or #3 until their branch ancestry and migration history are explicitly reconciled.
- Treat PR #3 as the current corrective reference for the connected live database, not as proof that runtime security gates have passed.
- Keep Organizational Units proposed and inactive for the first implementation sequence unless a separate decision is made after the authorization model and tests are validated.
- Do not execute `supabase/seed.sql` from PR #1 against any shared or production environment.

## 2. Branch and PR topology

Observed PR targets:

| PR | Head branch | Base branch | Declared purpose |
|---|---|---|---|
| #1 | `feat/platform-foundation-mvp` | `main` | Platform foundation and OU implementation |
| #2 | `feat/managed-engineering-operating-model` | `feat/platform-foundation-mvp` | Managed Engineering operating model and Project Workspace specification |
| #3 | `fix/audit-reconciliation-and-readiness-gates` | `feat/managed-engineering-operating-model` | Live database reconciliation and audit hardening |
| #4 | `docs/technical-audit-remediation-v1` | `main` | Technical audit and remediation plan |

GitHub compare results at audit time:

| Comparison | Status | Ahead | Behind | Commits |
|---|---:|---:|---:|---:|
| `main...feat/platform-foundation-mvp` | ahead | 47 | 0 | 47 |
| `feat/platform-foundation-mvp...feat/managed-engineering-operating-model` | diverged | 7 | 9 | 7 |
| `feat/managed-engineering-operating-model...fix/audit-reconciliation-and-readiness-gates` | ahead | 9 | 0 | 9 |
| `main...fix/audit-reconciliation-and-readiness-gates` | ahead | 54 | 0 | 54 |

### Finding M01-01 — PR #2 is not a descendant of PR #1

Although PR #2 targets PR #1's head branch, GitHub compare reports the branches as **diverged (7 commits ahead, 9 behind)**. This is not the linear ancestry implied by a simple stacked-PR description.

Impact:
- The current PR #2 head does not contain all commits present in PR #1.
- PR #3 descends from PR #2, so its lineage also does not automatically include PR #1's complete implementation.
- A merge sequence based only on PR numbers or PR target fields can omit, duplicate, or conflict with foundation changes.

Required action:
1. Inspect the exact commit graph and file-level merge base before changing PR bases.
2. Choose one canonical foundation commit.
3. Reconcile PR #1 changes against the PR #2/#3 lineage in a dedicated integration branch.
4. Re-run database and application checks on the resulting exact commit.
5. Only then decide whether to retarget or merge any PR.

No branch was rebased, retargeted, merged, or closed during this audit.

## 3. Organizational Units: contradictory implementation states

### PR #1 claims

PR #1 contains:
- ADR-0005 marked **Accepted**.
- A migration at `supabase/migrations/20261101150000_organizational_unit_scoped_access.sql`.
- A seed file creating Hub Açaí and Mundo Sabor organizations and organizational units.
- A pgTAP suite that expects 14 public RLS tables, including Organizational Unit tables.
- A CI workflow that explicitly fails if `organizational_units` or `unit_memberships` do not exist.

ADR-0005 on that branch states that the migration was promoted and applied.

### PR #3 and live reconciliation

PR #3's live reconciliation states:
- The connected live database has 12 public domain tables.
- No Organizational Unit or Unit Membership tables exist.
- OU SQL remains under `supabase/proposals/`.
- ADR-0005 remains Proposed in the reconciled implementation state.
- OU activation is deferred pending authorization design, tenant-safe migration review, RLS coverage, and authenticated runtime tests.

The PR #3 branch contains the OU SQL under `supabase/proposals/`, not as an active migration. Its database README repeats that the OU schema has not been applied.

### Finding M01-02 — PR #1's OU implementation cannot be merged as-is

The PR #1 claim of an applied/active OU migration is not supported by the connected live schema or by PR #3's reconciliation. Merging PR #1 without reconciling this difference would reintroduce a false implementation status and could activate an authorization model that has not passed the required runtime tests.

Required action:
- Preserve the PR #3 status: OU is proposed, not live.
- Decide whether the first Managed Engineering pilots actually require unit-level access.
- If required, implement OU in a separate, reviewed migration after distinct-identity tests and a rollback plan exist.
- Keep ADR status, migration directory, seed behavior, test expectations, and database README synchronized.

## 4. Migration-history divergence

PR #1's active migration set includes:
- `202611010001_initial_platform_schema.sql`
- `20261101123353_p0_tenant_integrity_and_membership_authority.sql`
- `20261101123510_consolidate_membership_management_policies.sql`
- `20261101123533_remove_redundant_single_column_parent_foreign_keys.sql`
- `20261101140000_harden_audit_event_ingestion.sql`
- `20261101150000_organizational_unit_scoped_access.sql`

PR #3's live reconciliation records the connected project's applied history as:
- `20261101115251_initial_platform_schema`
- `20261101123353_p0_tenant_integrity_and_membership_authority`
- `20261101123510_consolidate_membership_management_policies`
- `20261101123533_remove_redundant_single_column_parent_foreign_keys`
- `20261102041633_harden_audit_event_insert_and_index_foreign_keys`

### Finding M01-03 — migration ledger and repository history are not yet reconciled

The initial migration version in PR #1 differs from the live migration ledger. PR #1 also includes an earlier audit-ingestion migration and an OU migration that are not listed as applied in PR #3's live history. PR #3 adds a later corrective migration that is recorded as applied live.

This is a migration-governance blocker. Do not apply, reorder, rename, delete, or mark migrations as applied to make the histories appear aligned.

Required action:
1. Export the exact migration ledger and schema state from the connected project.
2. Compare every repository migration against that ledger by version, checksum/content and resulting schema effect.
3. Establish one canonical migration directory on the integration branch.
4. Document any intentional baseline reconciliation and the approved Supabase migration repair procedure, if one is genuinely required.
5. Validate the canonical sequence from an empty disposable database before any production deployment.

## 5. Audit-event hardening: correct distinction

PR #1's migration revokes authenticated direct INSERT and drops the authenticated insert policy. PR #3's corrective migration drops the policy and revokes INSERT from both `anon` and `authenticated`, then adds indexes identified by the advisor.

PR #3's documentation correctly distinguishes:
- preventing ordinary clients from fabricating audit events; and
- implementing a trusted server-side ingestion pipeline.

The second capability is still outstanding. No deployed Edge Function or complete server-side event-ingestion path was evidenced in the reviewed material.

### Finding M01-04 — do not describe the audit subsystem as complete

The direct client-insert gap is reported corrected in the live project. Trusted actor attribution, event validation, idempotency, correlation, failure handling, and coverage of material mutations remain unimplemented or unverified.

Acceptance evidence for closure:
- approved event contract;
- server-side identity and authorization design;
- append-only ingestion path;
- idempotency and correlation behavior;
- tests proving a client cannot impersonate another actor or tenant;
- operational failure and retry behavior.

## 6. Seed and client-data boundary

PR #1's `supabase/seed.sql` creates tenant records named Hub Açaí and Mundo Sabor and unit records with business-specific descriptions. It does not establish a complete authorized membership model for real client users.

### Finding M01-05 — seed is not safe to treat as generic test data

The file contains named client contexts and operational descriptions. Before it is used in a shared environment or retained as a reusable fixture, classify whether each value is synthetic, public, client-confidential, or derived from client material. Confirm the contractual basis and intended audience.

Required action:
- Keep the seed disabled for production.
- Replace with clearly synthetic tenant names and neutral descriptions for automated tests.
- Keep any client-specific fixture separate, access-controlled, and explicitly authorized.
- Do not treat seeded organization/unit records as proof of onboarding readiness.

## 7. CI and test evidence

PR #1 adds a PostgreSQL 17 workflow that applies repository migrations, runs pgTAP, applies the seed, and asserts OU objects exist. Those expectations correspond to PR #1's OU-active branch state.

PR #3 adds a Supabase CLI workflow that starts an isolated local stack, resets the local database, and invokes the pgTAP suite. PR #3's test and documentation stance is more conservative: catalog assertions are not equivalent to pgTAP execution, and pgTAP is not equivalent to authenticated runtime isolation tests.

No successful CI run or pgTAP execution was established by this read-only review.

### Finding M01-06 — tests must be bound to the canonical commit

Required evidence before accepting the database foundation:
- successful migration replay from an empty disposable database;
- pgTAP output tied to the exact commit SHA;
- distinct-JWT cross-tenant SELECT/INSERT/UPDATE/DELETE tests;
- membership privilege-escalation tests;
- multi-session last-owner race test;
- stale-session/revocation behavior test.

A clean Security Advisor result and passing catalog assertions do not prove end-to-end tenant isolation.

## 8. PR-by-PR disposition

| PR | Disposition | Reason |
|---|---|---|
| #1 | **Hold / reconcile** | OU-active migration and seed conflict with live state; migration ledger differs; branch must be reconciled with PR #2/#3 lineage. |
| #2 | **Retain as product decision/specification** | Managed Engineering-first and human-agent boundaries are coherent; branch ancestry is not a simple stack and its specs do not implement runtime capabilities. |
| #3 | **Preferred corrective reference; hold merge pending integration** | Best current reconciliation of live DB facts; does not close runtime security, audit ingestion, Auth, Storage, or data-classification gates. |
| #4 | **Keep draft for review** | Audit plan and this addendum are documentation-only; they authorize no implementation or production action. |

## 9. M01 exit criteria

M01 is complete only when:
1. A canonical integration branch and commit graph are documented.
2. The migration ledger and canonical repository migration sequence are reconciled.
3. ADR-0005 and OU implementation status agree across all branches and docs.
4. Client-specific seed values are classified or replaced by synthetic fixtures.
5. Database CI passes from an empty disposable environment on the canonical commit.
6. The remaining P0 runtime tests are assigned and scheduled.
7. No client-confidential data is onboarded before the P0 gates pass.

## 10. Actions explicitly not performed

- No PR merged, retargeted, rebased, closed, or approved.
- No database migration applied or repaired.
- No live data seeded or modified.
- No client documents or repository history deleted or rewritten.
- No claim of production readiness or security certification made.
