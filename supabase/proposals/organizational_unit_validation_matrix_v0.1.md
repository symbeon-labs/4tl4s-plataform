# Organizational Unit Scoped Access — Validation Matrix v0.1

**Status:** Test design only — not executed  
**Applies to:** organizational_unit_scoped_access_v0.1.sql  
**Required environment:** disposable local Supabase/PostgreSQL with distinct authenticated JWT identities  
**Do not run against production data.**

## 1. Fixture topology

Create two synthetic organizations:
- ORG-A with UNIT-A1 and UNIT-A2.
- ORG-B with UNIT-B1.

Create distinct users:
- A-OWNER: owner of ORG-A.
- A-ADMIN: admin of ORG-A, no unit grant.
- A-U1: active member of UNIT-A1.
- A-U1-VIEWER: viewer of UNIT-A1.
- A-U2: active member of UNIT-A2.
- A-ORG-ONLY: active ORG-A member with no unit grant.
- B-USER: active member of ORG-B.

Create initiatives:
- A-ORG-INIT: unassigned organization-level initiative.
- A-U1-INIT: assigned to UNIT-A1.
- A-U2-INIT: assigned to UNIT-A2.
- B-U1-INIT: assigned to UNIT-B1.

Add work packages, artifacts, evidence, decisions and IP assets under both organization-level and unit-scoped initiatives.

## 2. Required authorization tests

| ID | Scenario | Expected |
|---|---|---|
| OU-001 | A-ORG-ONLY reads A-ORG-INIT | Allow |
| OU-002 | A-ORG-ONLY writes A-ORG-INIT | Allow under compatibility policy |
| OU-003 | A-ORG-ONLY reads A-U1-INIT | Deny / invisible |
| OU-004 | A-ADMIN reads A-U1-INIT without unit grant | Deny / invisible |
| OU-005 | A-OWNER reads A-U1-INIT without unit grant | Deny / invisible |
| OU-006 | A-U1 reads A-U1-INIT | Allow |
| OU-007 | A-U1 reads A-U2-INIT | Deny / invisible |
| OU-008 | A-U1-VIEWER reads A-U1-INIT | Allow |
| OU-009 | A-U1-VIEWER updates/deletes A-U1-INIT | Deny |
| OU-010 | A-U1 writes A-U1-INIT | Allow |
| OU-011 | B-USER reads or writes ORG-A records | Deny / invisible |
| OU-012 | Unit member has suspended organization membership | Deny immediately |
| OU-013 | Unit is archived or suspended | Unit content access denied |
| OU-014 | A-U1 creates child record linked to A-U2 initiative | Deny |
| OU-015 | A-U1 assigns an ORG-B unit to an ORG-A initiative | FK rejection |
| OU-016 | A-ADMIN creates or archives a unit | Allow, audited |
| OU-017 | A-U1 unit_admin grants user a unit_admin role | Deny |
| OU-021 | contributor creates or changes unit membership | Deny |
| OU-022 | unit_admin creates or changes ordinary membership in same unit | Allow |
| OU-023 | unit_admin changes membership in another unit | Deny |
| OU-024 | unit_admin attempts to promote a member to unit_admin | Deny |
| OU-025 | unit_admin attempts to modify another unit_admin grant | Deny |
| OU-026 | unit_admin membership management after org suspension or unit archive | Deny |
| OU-018 | A-U1 unit_admin changes ordinary unit membership | Allow within same unit only |
| OU-019 | Unit role attempts organization role escalation | Deny |
| OU-020 | Unassigned child points to unit-scoped parent | Child must remain restricted to parent scope |

## 3. Referential integrity and hierarchy tests

- Parent unit from another organization is rejected.
- Self-parent assignment is rejected.
- A → B → C → A cycle is rejected.
- Concurrent hierarchy updates are serialized and cannot create a cycle.
- Unit identity, organization_id and created_by cannot be rewritten.
- Unit deletion is restricted; archive preserves references.
- Artifact initiative must match its work-package initiative when both are supplied.
- Evidence initiative must match the initiative derived from its artifact when both are supplied.
- Active unit membership requires an existing organization membership; authorization always re-checks that the organization membership remains active.

## 4. Critical unresolved blocker: generic relationships

The current proposal leaves public.relationships tenant-member visible. Its polymorphic endpoints can reveal the identifiers and existence of unit-scoped entities to organization members who do not have unit access.

**Do not activate unit-scoped production records until one of these is implemented and tested:**
1. endpoint-aware RLS that verifies access to both endpoints; or
2. a safe restriction that prevents relationships from referencing unit-scoped endpoints until endpoint-aware authorization is available.

This is an explicit pre-activation blocker, not an accepted residual risk.

## 5. Other required checks

- Verify policies are not accidentally permissive through overlapping policy names.
- Verify every SELECT/INSERT/UPDATE/DELETE operation for initiatives and descendants.
- Verify service-role and background-job behavior separately.
- Verify no secrets or service credentials are exposed.
- Verify trusted audit-event ingestion for unit creation, archive, membership grant/revocation and initiative reassignment. Direct authenticated INSERT into `audit_events` must be denied; trusted ingestion must derive actor and timestamp server-side.
- Run catalog checks and authenticated integration tests; catalog checks alone are insufficient.

## 6. Exit criteria

The proposal may move to a real migration only after:
- ADR-0005 and both contracts are approved;
- the relationship blocker is resolved;
- all critical tests pass in a disposable local database;
- migration rollback/forward-repair is reviewed;
- the migration is tested against a copy of the empty current schema;
- security and IP/confidentiality review is recorded.

No test in this document is claimed to have run or passed.
