# Organizational Unit Authorization Contract

**Contract ID:** 4TL4S-SEC-OU-001  
**Version:** 0.1  
**Status:** PROPOSED — security design; implementation and runtime validation pending  
**Owner:** Symbeon Labs / 4TL4S  
**Date:** 2026-11-01  
**Related:** 4TL4S-DOM-OU-001, ADR-0002, ADR-0004

## 1. Security objective

Preserve organization-level tenant isolation while introducing narrower unit and initiative scopes. Authorization is server-side and fail-closed. UI visibility, a SOA relationship, a unit name or possession of a record identifier is never sufficient authorization.

## 2. Authorization dimensions

Every protected request resolves: authenticated identity; active Organization Membership; target organization; target unit; target Initiative and inherited scope; requested action; explicit role/grant and policy version; data classification and confidentiality restrictions. Missing, stale, conflicting or ambiguous context denies access.

## 3. Role boundaries

### Organization roles

Existing organization roles remain defined by the membership contract. Owner/admin may manage organization configuration and organizational structure, subject to audit. They do not automatically gain access to every unit-scoped project or client record. Organization-wide content access requires an explicit grant/policy.

### Unit roles

| Role | Intended scope |
|---|---|
| unit_admin | Manage membership and configuration for that unit only |
| unit_manager | Coordinate unit work and scoped assignments |
| contributor | Create/update permitted work within unit scope |
| reviewer | Read and review assigned scope; approval requires separate grant |
| viewer | Read-only access to granted unit scope |

A unit role is subordinate to organization membership and cannot elevate it.

No unit role implies organization owner/admin privileges, contract signature, expenditure/payment approval, external disclosure, data export, IP licensing/assignment, client acceptance, production deployment or destructive deletion. These require distinct permissions and human approval.

## 4. Access decision model

For a unit-scoped record, allow access only if:
- the user is authenticated;
- active membership exists in the record's organization;
- unit and Initiative references resolve within that organization;
- active Unit Membership or separate explicit grant covers the exact unit and action;
- the role permits the action;
- no classification, case-isolation or explicit-deny rule blocks it.

For an organization-level record with no unit scope, apply a separately declared organization-level policy. Null unit scope is not a bypass and cannot be used as fallback for inaccessible unit-scoped records.

Descendants inherit the Initiative's narrowest scope. A child may be more restricted, never broader. A matching organization_id alone cannot expose an artifact or evidence record.

## 5. Administrative and membership operations

- Organization owners/admins may create or archive units under policy; actions are audited.
- Only explicitly authorized unit administrators manage ordinary memberships for their unit.
- Unit administrators cannot add users to the organization or change organization roles.
- Unit membership requires active organization membership.
- Suspending/revoking organization membership invalidates all unit grants immediately, regardless of stored unit-membership status.
- Removing the last authorized unit administrator requires replacement or controlled recovery.
- Role, scope, parentage and Initiative-unit changes are material authorization events.

## 6. RLS and service-layer enforcement

RLS is mandatory as the final boundary for user-scoped database operations. Server checks are defense in depth, not a replacement.

The migration must ensure every SELECT/INSERT/UPDATE/DELETE path applies correct scope; WITH CHECK validates tenant and unit scope; composite FKs protect references; security-definer helpers use fixed search_path and minimal privileges; policies avoid recursion and ambiguous permissive composition; service-role credentials never reach clients; background jobs have explicit policies.

## 7. Required threat tests

Use at least two synthetic organizations, two units within one organization and distinct authenticated identities. Test:
- cross-tenant unit, parent and Initiative references;
- organization member without unit grant attempting SELECT/INSERT/UPDATE/DELETE;
- Unit A member attempting Unit B access;
- viewer attempting writes;
- contributor attempting approval or membership administration;
- unit_admin attempting organization-role escalation or cross-unit access;
- suspended organization member with stale unit grant;
- reassignment, archive and historical evidence retention;
- concurrent hierarchy changes and last-unit-admin removal;
- service-role and background-job boundaries.

Catalog/structural checks do not replace authenticated runtime tests.

## 8. Audit requirements

Record actor, organization, unit, target, action, prior/new scope, policy/contract version, timestamp, reason and correlation ID for material authorization changes. Ordinary authenticated users cannot mutate audit history.

## 9. Status

Proposed security baseline only. It does not assert that RLS policies, application checks, tests or unit tables have been implemented. Approval is required before schema migration and connector activation.
