# ADR-0004 — Represent organizational units separately and consume SOA context by reference

- **Status:** Accepted
- **Decision date:** 2026-11-01
- **Decision owner:** Symbeon Labs platform direction
- **Scope:** Shared Governance, Applied Research, Commercial Operations, organizational context integration

## Context

4TL4S must coordinate work across organizations with different internal structures. An organization may operate through departments, business units, innovation teams, development arms or other operational units. Such a unit may have its own responsibilities, capabilities, projects and approval workflows without being a separate legal entity or tenant.

The Symbeon Organizational Atlas (SOA), maintained as a methodology and knowledge-model capability in Symbeon Intelligence, is intended to discover and represent these structures using evidence, typed relationships and explicit uncertainty.

The RS Advogados / RS2BUILD context illustrates the requirement: RS2BUILD is described by the user as a development arm of RS Advogados. This is an operational relationship declaration; formal legal status, mandate and contractual authority remain subject to evidence. The platform must not infer separate legal identity, corporate control, contracting authority or IP ownership from the existence of a unit record.

The current 4TL4S database has an organizations table and a general relationships table, but an organizational-unit domain model, its authorization semantics and an SOA context contract have not yet been implemented or runtime-validated.

## Decision

1. **Separate conceptual identities.** Model Organization and OrganizationalUnit as distinct conceptual entity types. An OrganizationalUnit belongs to or operates within an organizational context through an explicit, typed and scoped relationship. It is not automatically a separate legal entity, tenant, customer or contracting party.

2. **Preserve legal and operational uncertainty.** The model must distinguish operational affiliation, reporting, delegation, ownership, control, contracting authority and legal identity. These relationships must not be inferred from one another.

3. **Keep projects independently bounded.** Projects and initiatives may be associated with an organization and, where supported, an operational unit. Each project retains its own scope, evidence, decisions, responsible roles, access boundaries and IP records.

4. **Use SOA as a context source, not as an execution authority.** Symbeon Intelligence is the knowledge authority for its organizational research records. 4TL4S may consume authorized, versioned references and bounded context summaries from SOA. A map, inference or opportunity recommendation does not itself authorize execution, access or contractual commitment.

5. **Integrate by explicit contract.** Any future connector must declare source identity, record identifiers, version/hash or equivalent revision reference, retrieval timestamp, permitted fields, data classification, access scope, synchronization direction, revocation behavior and failure handling. Default mode is read-only. No broad repository or document-store access is implied.

6. **Preserve source provenance.** 4TL4S must distinguish source assertions, observations, interpretations, verification states and operational decisions. It must retain the SOA reference and version rather than presenting copied context as independently verified 4TL4S fact.

7. **Do not duplicate confidential source material by default.** Store references and minimum necessary context. Copying source documents or client data requires a defined purpose, authorization, retention policy and access control.

8. **Do not prematurely alter the database.** The current schema is not declared to support OrganizationalUnit as a first-class entity. Before adding tables, columns or relationship types, define the domain contract, authorization model, tenant invariants, migration path and tests. Until then, this ADR is a target design constraint, not an implementation claim.

## Consequences

### Positive

- Represents real organizational structures without inventing legal entities.
- Supports organizations with internal development, research, innovation or operational units.
- Keeps client projects and IP boundaries independent.
- Allows Intelligence and 4TL4S to exchange context without merging their responsibilities.
- Creates a controlled path for future organizational mapping and operational planning.

### Trade-offs and risks

- Requires a richer domain model and explicit relationship semantics.
- Authorization must account for both organization-level access and unit/project scope.
- Incorrectly classified units could create misleading ownership or authority assumptions.
- Context synchronization introduces versioning, revocation and stale-data risks.
- The current database and application do not yet enforce this model.

## Implementation implications

Before implementation:

1. Define Organization, OrganizationalUnit, Project and Relationship contracts.
2. Define relationship types and which require documentary evidence or human approval.
3. Define authorization inheritance and explicit exceptions; membership in an organization must not automatically grant access to every unit or case.
4. Add tenant-safe constraints and tests for cross-organization and cross-unit references.
5. Define the SOA read-only context package and provenance/version contract.
6. Test with synthetic organizations and units before importing client context.
7. Review privacy, confidentiality, IP and contractual constraints for each integration.

## References

- Symbeon Intelligence — SOA methodology: `09_EXTERNAL_PROJECTS/03_METHODOLOGY/symbeon_organizational_atlas_v0.1.md` on branch `feat/soa-methodology-foundation`.
- Symbeon Intelligence — RS Advogados organization profile and RS2BUILD operational-unit record.
- 4TL4S ADR-0002 — Preserve project autonomy and IP boundaries.
- 4TL4S ADR-0003 — Govern research-to-development transfer.

## Review condition

Review this ADR when the Organization/OrganizationalUnit domain contract is approved, when SOA context exchange is implemented, or when legal/contractual evidence materially changes the RS Advogados / RS2BUILD relationship.
