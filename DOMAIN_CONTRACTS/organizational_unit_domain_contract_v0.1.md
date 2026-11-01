# Organizational Unit Domain Contract

**Contract ID:** 4TL4S-DOM-OU-001  
**Version:** 0.1  
**Status:** PROPOSED — design contract; not implemented  
**Owner:** Symbeon Labs / 4TL4S  
**Date:** 2026-11-01  
**Related decision:** ADR-0004

## 1. Purpose

Define the first-class representation of an organizational unit without creating a new tenant, asserting legal identity, or weakening organization, project, client, confidentiality, or intellectual-property boundaries. This is a design baseline, not an applied schema or an authorization to migrate.

## 2. Canonical concepts

**Organization** is the tenant and primary data-isolation boundary. It owns memberships, units, initiatives and tenant-scoped records.

**OrganizationalUnit** is a named internal or operational unit situated within exactly one Organization. Examples include a department, business unit, research group, technology arm or delivery team. It is not automatically a tenant, legal entity, customer, contracting party, employer, owner or IP holder.

**Initiative / Project** is a bounded body of work belonging to one Organization. It may optionally be associated with one OrganizationalUnit. That association describes operational context; it does not transfer ownership, authority, responsibility or IP.

**Membership** establishes a user's relationship to an Organization. **Unit Membership** is a separate, explicit grant for a particular unit. Neither record silently creates the other.

## 3. Proposed persistence model

This is a logical target, not an applied schema.

### organizational_units

| Field | Type | Requirement |
|---|---|---|
| id | uuid | Primary key |
| organization_id | uuid | Required tenant key |
| parent_unit_id | uuid, nullable | Optional parent within same tenant |
| name | text | Required, length 2–160 |
| slug | text | Unique within organization |
| unit_type | text | Controlled, versioned vocabulary |
| description | text, nullable | Descriptive context |
| lifecycle_state | text | proposed, active, suspended, archived |
| source_state | text | declared, observed, documented, verified, conflicted, unknown |
| source_reference | jsonb, nullable | Provenance pointer; no unrestricted source dump |
| created_by | uuid | Authenticated actor |
| created_at / updated_at | timestamptz | Audit timestamps |

Constraints:
- Unique organization/id and organization/slug.
- Composite self-reference for parent within the same organization.
- Parent cannot equal child; cycles must be prevented by a controlled write path or recursive validation.
- Tenant key, identity and creator provenance are immutable.
- Parent deletion cannot cascade-delete child units or historical records.
- Archive preserves evidence, decisions, audit history and IP records.

### unit_memberships

| Field | Type | Requirement |
|---|---|---|
| id | uuid | Primary key |
| organization_id | uuid | Required tenant key |
| organizational_unit_id | uuid | Required unit key |
| user_id | uuid | Existing authenticated user |
| role | text | unit_admin, unit_manager, contributor, reviewer, viewer |
| status | text | invited, active, suspended, revoked |
| granted_by | uuid | Actor granting access |
| created_at / updated_at | timestamptz | Audit timestamps |

Constraints:
- Composite FK to organizational_units using organization_id and organizational_unit_id.
- Composite FK to memberships using organization_id and user_id.
- An active unit grant requires an active organization membership.
- A unit role cannot grant organization owner/admin authority, billing authority, connector-secret access, or contractual/IP approval authority.
- Reassignment, suspension and revocation are auditable.

### Initiative association

Add nullable organizational_unit_id to initiatives only after migration approval. Enforce a composite FK on organization_id and organizational_unit_id. Null means organization-level/unassigned scope; it does not mean public or accessible to every organization member.

Work packages, artifacts, evidence and decisions inherit the Initiative's narrowest access scope. Child records cannot be exposed more broadly than their parent. Existing tenant-scoped composite FKs remain mandatory.

## 4. Relationship semantics

Supported relationship types may include HAS_OPERATIONAL_UNIT, REPORTS_TO, RESPONSIBLE_FOR, DEVELOPS and OPERATES. Do not infer:
- legal ownership or corporate control from HAS_OPERATIONAL_UNIT;
- employment or legal authority from REPORTS_TO;
- IP ownership from DEVELOPS;
- contracting authority from RESPONSIBLE_FOR;
- separate legal identity from operational affiliation.

Material relationships carry source reference, information state, scope, effective date where known, actor and review history. A graph edge is not proof of a legal or contractual fact.

## 5. Lifecycle and invariants

1. Unit creation requires an authenticated actor authorized to manage organizational structure.
2. Creation does not create memberships, projects, contracts or IP assets automatically.
3. Unit hierarchy remains within one organization and is acyclic.
4. Unit identity and tenant key are immutable; material changes are audited.
5. A referenced unit is archived, not hard-deleted; reparenting is explicit.
6. A unit may be conflicted or unverified without becoming authoritative.
7. Initiative reassignment is a material scope change requiring authorization, audit and access re-evaluation.
8. Unit lifecycle changes do not silently change user access or IP classification.
9. Missing or ambiguous authorization fails closed.

## 6. Explicit non-goals

This contract does not model legal-entity registries, corporate ownership trees, employment, delegated powers, contracting authority, financial consolidation or IP title. Those require distinct evidence-backed domains.

## 7. Migration and compatibility requirements

Before production migration:
- inventory current RLS policies, grants, triggers, FKs and application queries;
- add tables and constraints without seeding client data;
- add unit scope to initiatives and enforce descendant scope consistently;
- revise RLS so unit-scoped rows require explicit unit access;
- define a separate access rule for organization-level records;
- update relationship endpoint validation for organizational_unit;
- add indexes for composite FKs and RLS predicates;
- preserve existing organization-level records and document their initial scope;
- provide rollback/forward-repair strategy and verification queries.

Do not ship the tables while leaving broad organization-member policies in place. That would create a false sense of unit isolation.

## 8. Acceptance criteria

The model is not implementation-complete until tests demonstrate:
- cross-tenant parent and initiative references are rejected;
- cross-unit and cross-tenant membership grants are rejected;
- a Unit A member cannot read or mutate Unit B records without explicit grant;
- organization membership alone does not expose unit-scoped content;
- unit_admin cannot grant organization owner/admin or alter organization membership;
- unit reassignment changes access only after authorized change;
- archive preserves historical evidence and audit references;
- concurrent hierarchy changes cannot create cycles;
- append-only audit records capture material changes;
- runtime tests use distinct authenticated identities and at least two synthetic tenants.

## 9. Status and change control

Version 0.1 is proposed for architecture review. No OrganizationalUnit table, Unit Membership table, initiative unit association, RLS enforcement or runtime test is claimed to exist. Changes to tenant boundaries, authorization semantics, relationship taxonomy or lifecycle invariants require versioned review and an ADR update.
