# Agent instructions — 4TL4S

Before planning or changing this repository, read `AUDITS/4TL4S_FOUNDATION_AND_DELIVERY_AUDIT_2026-11-01.md` in full.

## Mandatory operating rules

- Verify the current branch, commit SHA, open PRs and their base/head relationships before editing.
- Do not assume `main` contains the latest foundation or product decisions. The repository has a stacked PR structure; verify the branch that contains the relevant artifacts.
- Distinguish implemented code, repository-documented implementation claims, proposed contracts, and future product targets.
- Never treat SQL under `supabase/proposals/` as an applied migration.
- Do not claim that Organizational Units, SOA exchange, Project Workspace, client projections, or agent execution are implemented unless code and tests prove it.
- Do not weaken RLS, tenant-scoped foreign keys, authorization checks or audit boundaries to unblock UI work.
- Do not seed real client data or expose secrets without explicit human authorization.
- Preserve project autonomy, client confidentiality, IP provenance and least-privilege access.
- Do not merge, rebase, retarget or close PRs without explicit human direction.
- Run tests in disposable local/test environments; report commands and actual results.
- Every consequential change must state scope, owner, authorization, evidence, tests, security/data impact and residual risks.
- Never claim production readiness, security certification, compliance or autonomous capability without evidence.

## Required workflow

1. Read the audit and relevant ADRs/contracts.
2. Inspect repository state and relevant implementation.
3. Identify the canonical domain record and authorization boundary before changing data models.
4. Propose the smallest coherent implementation.
5. Implement with tests and migration/rollback considerations.
6. Report what is implemented versus still proposed.
