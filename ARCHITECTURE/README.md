# Architecture — 4TL4S

## Architectural intent

4TL4S is designed as a modular operational platform with shared identity and governance services and distinct domain capabilities. The initial design is a logical architecture; it does not assert that these services or boundaries are already implemented in code.

## Logical layers

1. **Experience Layer** — role-aware workspaces, dashboards, queues, and initiative views.
2. **Application Layer** — use cases, workflows, validation, and orchestration.
3. **Domain Layer** — research, development, artifact production, commercial operations, and shared governance.
4. **Data Layer** — transactional records, versioned documents, evidence metadata, and audit events.
5. **Integration Layer** — scoped connectors to GitHub, document systems, financial systems, automation, and project-specific tools.

## Domain modules

### Shared Governance
Identity, organizations, memberships, roles, permissions, approvals, decisions, audit events, IP classifications, and policy versions.

### Applied Research
Research questions, hypotheses, literature and source references, protocols, experiments, datasets, findings, limitations, and reproducibility records.

### Product Development
Products, technical initiatives, requirements, architecture decisions, repositories, issues, milestones, releases, tests, and dependencies.

### Artifact Production
Artifact briefs, artifact types, source materials, versions, review cycles, approvals, delivery packages, and acceptance records.

### Commercial Operations
Organizations, contacts, opportunities, proposals, contracts, amendments, obligations, budgets, invoices/receivables references, client projects, delivery milestones, and acceptance.

## Core records (conceptual)

- **Organization** — legal or operational entity.
- **OrganizationalUnit** — internal or operational unit within an Organization; not automatically a tenant or legal entity.
- **Person / Membership** — identity and relationship to an organization.
- **Initiative** — common identity, primary classification, owner, status, and scope; may have an explicit unit association.
- **WorkPackage** — bounded work within an initiative.
- **Artifact** — a versioned output with provenance and lifecycle.
- **EvidenceRecord** — a pointer or controlled record of supporting material.
- **DecisionRecord** — decision, rationale, authority, timestamp, and affected scope.
- **IPAsset** — asset provenance, classification, contributors, rights basis, and restrictions.
- **Contract / Obligation** — governed commercial commitment.
- **Relationship** — typed link between records with access-aware traversal.

These are conceptual entities, not a finalized database schema.

## Tenant and access boundaries

The design must support organization-level and client-level isolation. A user may see a record only when both identity authorization and record-level scope permit it. Cross-client aggregation must be explicitly authorized and must avoid leaking identifying or confidential data.

Organizational-unit scope is narrower than tenant scope. Organization membership alone must not be treated as access to every unit-scoped record. See the [Organizational Unit Domain Contract](../DOMAIN_CONTRACTS/organizational_unit_domain_contract_v0.1.md) and [Organizational Unit Authorization Contract](../GOVERNANCE/organizational_unit_authorization_contract_v0.1.md). These are proposed contracts, not implemented controls.

Access control must be enforced server-side. Hiding a UI element is not authorization. Integrations and agents must use scoped identities and least privilege.

## Data and evidence boundaries

- Store operational metadata separately from binary files where appropriate.
- Preserve source, version, timestamp, contributor, and access classification for evidence.
- Distinguish source material from AI-generated interpretation.
- Record verification method, verifier, and result separately from approval.
- Avoid placing confidential client information or personal data on public ledgers or public repositories.
- Define retention, export, deletion, and backup policies before production use.

## Integration contract

Every connector must declare:
- system and account identity;
- permitted read/write operations;
- data classes and scopes;
- mapping and synchronization direction;
- conflict and retry behavior;
- provenance and timestamps;
- failure handling and revocation procedure.

The initial [SOA–4TL4S Context Exchange Contract](soa_4tl4s_context_exchange_contract_v0.1.md) defines a proposed read-only exchange. It is not an implemented connector.

No connector should infer broad permission from a repository or account connection.

## Implementation sequence

1. Domain model and authorization threat model.
2. Identity, organizations, memberships, and audit foundation.
3. Initiative registry and shared governance.
4. Research and development workspaces.
5. Artifact production and commercial workflows.
6. Integrations, reporting, and automation.
7. Security, reliability, and operational readiness validation.

## Explicit non-claims

This document is a logical target architecture. It does not certify implementation, scalability, compliance, security, availability, or production readiness.
