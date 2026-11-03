# 4TL4S–ICIE Integration Contract

**Contract ID:** 4TL4S-INT-ICIE-001  
**Version:** 0.1  
**Status:** PROPOSED — normative integration boundary; no connector implementation implied  
**Producer / Domain Authority:** ICIE — Industrial Cost & Inventory Engine  
**Consumer / Coordination Authority:** 4TL4S — Symbeon Operations Platform  
**Date:** 2026-11-02  
**Related:** ICIE IIP v1.0; ICIE API_CONTRACTS.md; ICIE EVENT_CATALOG.md; 4TL4S architecture and governance foundations

## 1. Purpose

This contract defines the minimum safe boundary through which 4TL4S may register, authorize, reference and consume explicitly published ICIE capabilities and evidence without absorbing ICIE's domain model, operational authority, data store or intellectual property.

The integration is intended to make ICIE a governed, independently operated system within the 4TL4S coordination environment. It does not make 4TL4S the source of truth for industrial inventory, costing, valuation, manufacturing genealogy or financial reconciliation.

**Core rule:** 4TL4S governs the relationship and its authorization; ICIE governs its own domain state and the validity of its domain operations.

This is an interface and governance specification. It does not assert that an API, adapter, service identity, event publisher or runtime integration currently exists.

## 2. Systems, authority and non-goals

### 2.1 System responsibilities

| Concern | Authoritative system |
|---|---|
| ICIE products, receipts, inventory movements, cost layers, balances and domain events | ICIE |
| ICIE internal rules, calculations, ledger semantics and reconciliation | ICIE |
| ICIE capability publication and source revision | ICIE |
| 4TL4S initiatives, work packages, integration registration and coordination | 4TL4S |
| 4TL4S approvals, access grants, decisions and governance records | 4TL4S |
| Cross-system organization mapping | Explicit bilateral mapping governed through 4TL4S; validated by both sides |
| Imported references and evidence provenance | 4TL4S for its local reference; ICIE remains authoritative for source content |

### 2.2 Non-goals

This contract does not:
- merge repositories, databases, schemas, authentication systems or deployment environments;
- grant 4TL4S direct access to ICIE's database, filesystem, internal queues or secrets;
- make ICIE dependent on 4TL4S availability for its internal domain operations;
- turn 4TL4S into an ERP, inventory ledger, costing engine or financial posting authority;
- authorize writes, adjustments, receipts, issues, transfers, reservations, period close or other domain mutations;
- imply that candidate endpoints in ICIE API_CONTRACTS.md are implemented or stable;
- imply that ICIE's outbox has a functioning publisher or that events are being delivered;
- transfer, license, assign or reclassify intellectual property.

No reverse synchronization or write-back is included in v0.1.

## 3. Integration topology and direction

Initial topology:

```
4TL4S Coordination & Governance
        |
        | scoped request / authorization context
        v
4TL4S–ICIE Integration Adapter
        |
        | versioned, allowlisted interface
        v
ICIE Published Read Interface
        |
        v
ICIE Domain Engine and authoritative records
```

Initial exchange is **ICIE → 4TL4S, read-only**, initiated by an authorized 4TL4S consumer. 4TL4S may register the integration, define its purpose and scope, authorize a service identity, request published resources, and store provenance-bearing references or evidence metadata.

ICIE must authorize each request at the source. A 4TL4S grant alone cannot override ICIE source-side policy. If either side cannot establish authorization, identity mapping or scope, the request fails closed.

## 4. Contract 1 — System Identity

Each system must have a stable, non-secret identifier independent of repository names, URLs, deployment IDs and human-readable labels.

| Field | ICIE | 4TL4S |
|---|---|---|
| system_id | `icie` | `4tl4s` |
| system_name | ICIE — Industrial Cost & Inventory Engine | 4TL4S — Symbeon Operations Platform |
| role | Domain authority / provider | Coordination authority / consumer |
| repository | `symbeon-labs/icie` | `symbeon-labs/4tl4s-plataform` |
| contract_party_id | Stable registered party identifier | Stable registered party identifier |

System identifiers are not credentials. They must not be used as proof of identity by themselves.

Every integration instance must also have:
- `integration_id`: immutable identifier for this specific relationship;
- `environment`: development, test, staging or production;
- `contract_id` and `contract_version`;
- accountable owner on each side;
- declared purpose and lifecycle state.

A repository rename or deployment replacement must not silently create a new system identity. Identity changes require an explicit migration record.

## 5. Contract 2 — Organization Mapping and tenancy

### 5.1 Separate identity domains

The following identifiers are different namespaces and must never be assumed equal:

1. 4TL4S organization ID;
2. ICIE organization/tenant ID;
3. legal or operational organization identity;
4. integration service principal identity.

An organization ID from one system must never be copied into the other system's tenant field without an explicit mapping record.

### 5.2 Mapping record

Minimum mapping fields:

| Field | Requirement |
|---|---|
| mapping_id | Immutable local identifier |
| integration_id | Parent integration |
| source_system_id | `icie` |
| source_organization_id | Exact ICIE tenant identifier |
| consumer_system_id | `4tl4s` |
| consumer_organization_id | Exact 4TL4S organization identifier |
| mapping_status | proposed, verified, active, suspended, revoked |
| purpose | Specific business/operational purpose |
| scope | Allowed resources, fields and actions |
| approved_by | Authorized human approver(s) |
| source_validation | Evidence that ICIE recognizes the source tenant |
| effective_from / expires_at | Time-bounded validity |
| created_at / updated_at | Audit timestamps |

### 5.3 Mapping rules

- Mapping is explicit, tenant-scoped, versioned and auditable.
- Display-name matching, email-domain matching or repository membership is insufficient.
- One mapping must not imply access to every record or capability in either tenant.
- Mapping ambiguity, duplicate active mappings or conflicting ownership causes denial until reconciled.
- Mapping changes do not rewrite historical evidence or decision provenance.
- Revocation blocks future retrieval; cached-data disposition follows approved retention rules.
- Cross-organization aggregation requires a separate, explicit authorization and privacy review.

## 6. Contract 3 — Capability Registry

4TL4S may register only capabilities explicitly declared by ICIE. A capability record describes an interface promise; it is not evidence that the capability is available in a given environment.

### 6.1 Capability states

The registry must preserve these distinct states:

| State | Meaning |
|---|---|
| DOCUMENTED | Described in a controlled ICIE artifact |
| IMPLEMENTED | Code exists in a named revision |
| TESTED | A defined test suite passed against a named revision/environment |
| AVAILABLE | Authorized endpoint/resource is reachable and operational in the declared environment |
| DEPRECATED | Capability is being retired; replacement and sunset policy must be stated |

States are not interchangeable. A capability cannot be marked AVAILABLE merely because it is documented or implemented. Evidence, revision, environment and observation time must accompany each status claim. Status transitions must be recorded; no state may be silently inferred.

### 6.2 Initial candidate capability registry

The following are candidates derived from ICIE's current documented scope. They are **not declared implemented or available by this contract**.

| Capability ID | Description | Initial access |
|---|---|---|
| `icie.inventory.receipts.read` | Read authorized confirmed-receipt references and metadata | Read |
| `icie.inventory.balances.read` | Read authorized inventory balance snapshots, if exposed | Read |
| `icie.inventory.movements.read` | Read published movement references, if exposed | Read |
| `icie.cost.layers.read` | Read published cost-layer references, if exposed | Read |
| `icie.reconciliation.results.read` | Read reconciliation result references, if exposed | Read |
| `icie.capabilities.read` | Read capability declarations and their evidence | Read |

Candidate capabilities must remain disabled until ICIE identifies the exact resource, field allowlist, authorization behavior, version and acceptance evidence.

### 6.3 Capability descriptor

Minimum descriptor:

```json
{
  "capability_id": "icie.inventory.receipts.read",
  "system_id": "icie",
  "contract_version": "0.1",
  "status": "DOCUMENTED",
  "interface_version": null,
  "environment": "development",
  "access_mode": "read",
  "resource_types": ["inventory_receipt"],
  "allowed_fields": [],
  "tenant_scope_required": true,
  "evidence_refs": [],
  "source_revision": null,
  "observed_at": null,
  "limitations": ["Not enabled until source interface and tests are supplied"]
}
```

The example is illustrative. Empty fields are intentionally not permissions. Unknown fields are denied by default.

## 7. Contract 4 — Evidence Exchange

### 7.1 Purpose

The exchange allows 4TL4S to retain a bounded, provenance-bearing reference to an ICIE source record or an explicitly authorized evidence package. It does not transfer ICIE's internal database or make a local copy authoritative.

### 7.2 Evidence envelope

Minimum envelope:

| Field | Meaning |
|---|---|
| contract_id / contract_version | Contract identity and schema version |
| integration_id | Integration instance |
| source_system_id | `icie` |
| source_record_id | Stable ICIE record identifier |
| source_record_type | Typed ICIE resource |
| source_revision | Immutable source revision/version, when supported |
| source_tenant_id | ICIE tenant namespace |
| consumer_tenant_id | Mapped 4TL4S tenant namespace |
| capability_id | Capability used to retrieve the record |
| classification | Source information classification |
| field_allowlist | Exact fields returned |
| content_hash | Hash of canonical payload, when available |
| generated_at | Source generation timestamp |
| retrieved_at | Consumer retrieval timestamp |
| correlation_id | End-to-end request correlation |
| authorization_ref | Non-secret policy/grant reference |
| payload | Bounded normalized content or reference |
| provenance | Source URI/reference, revision and transformation details |
| state | current, stale, revoked, superseded, unavailable, conflicted |

A content hash supports integrity comparison only. It does not prove truth, completeness, authorship, business correctness or legal ownership.

### 7.3 Payload rules

- Only fields listed in the active capability allowlist may be returned or persisted.
- Decimal quantities and monetary values must remain decimal-safe; use canonical decimal strings at JSON boundaries. Never coerce financial values through binary floating point.
- Preserve source units, currency, precision, effective time and timezone where applicable.
- Preserve source status semantics; do not translate a draft, pending or unverified record into a confirmed state.
- Preserve source identifiers and revisions. Local 4TL4S IDs are references, not replacements.
- AI-generated summaries or classifications must be labeled INTERPRETED and linked to the original source reference. They are not source facts or approvals.
- Raw evidence, personal data, client-confidential material and commercially sensitive fields are excluded unless separately authorized and justified.
- Unknown fields, unsupported resource types and schema versions are rejected.

### 7.4 Reference versus snapshot

Default mode is a **reference record** containing source identity, revision, hash, classification, retrieval metadata and a stable source reference. A bounded snapshot may be stored only when the capability explicitly permits it and retention, confidentiality and IP rules have been reviewed.

A snapshot must never be represented as a live balance or current operational fact without a freshness policy and visible as-of timestamp.

## 8. Contract 5 — Authorization, service identity and audit

### 8.1 Service identity

- Use a dedicated, revocable service principal per integration environment.
- Authenticate through a supported machine-to-machine mechanism agreed by both systems.
- Bind every request to integration ID, source tenant, mapped consumer tenant, purpose, capability and field allowlist.
- Keep secrets in an approved secret manager; never commit them to either repository, log them, or expose them to browser clients.
- Human user identity may be propagated as an audit attribution claim, but must not replace service authentication or source authorization.
- Credentials must be rotated and revocable. Rotation and revocation must be tested before activation.

### 8.2 Authorization model

Authorization is the intersection of:
1. active 4TL4S integration approval;
2. active organization mapping;
3. consumer-side user/service permission;
4. ICIE source-side authorization;
5. capability status and field allowlist;
6. environment and purpose constraints.

No single condition grants access by itself. Denial by either system takes precedence.

### 8.3 Prohibited authority

The v0.1 integration identity is read-only. It must not:
- create or confirm receipts;
- reserve, issue, transfer or adjust inventory;
- change cost layers or valuation;
- execute reconciliation writes or period close;
- create, modify or delete ICIE domain records;
- run arbitrary SQL, shell commands, code or internal agent workflows;
- administer ICIE tenants, users, roles or secrets.

A future write capability requires a new contract version or separately approved extension, explicit domain command semantics, human authorization, idempotency, compensating-action policy and independent security review. It is not enabled by this document.

### 8.4 Audit events

Both systems must retain sufficient audit information for material requests and state transitions.

Minimum audit attributes:
- event ID and timestamp;
- actor/service principal and initiating user attribution, if available;
- integration ID and contract version;
- source and consumer tenant IDs;
- capability, resource type and source record ID;
- purpose and authorization reference;
- requested field set;
- source revision/hash and result state;
- correlation ID;
- denial/failure reason code, where applicable.

Do not log credentials, secrets or unrestricted payload contents. Audit history must be access-controlled and append-only or otherwise tamper-evident under each system's controls.

## 9. Transport, API and event semantics

### 9.1 Initial transport

The preferred initial transport is a versioned HTTPS REST interface exposed by ICIE, with a dedicated adapter on the 4TL4S side. Exact routes, schemas, authentication mechanism, pagination and rate limits remain to be specified by the ICIE implementation contract before coding.

ICIE's current API_CONTRACTS.md is an interface design baseline, not a published stable API. Candidate routes must not be treated as callable endpoints until implementation and tests prove otherwise.

### 9.2 Request metadata

Where supported, requests should carry:
- `Authorization`: service authentication credential (never persisted in evidence);
- `X-Correlation-ID`: end-to-end trace identifier;
- `Idempotency-Key`: required for any future retryable request with side effects; read-only GET requests do not require write idempotency;
- explicit contract and interface version headers or negotiated version fields.

### 9.3 Event delivery

Event-driven consumption is deferred. ICIE's documented outbox record does not prove a publisher, delivery guarantee or consumer availability. No event subscription may be activated until publisher behavior, event schema, delivery semantics, retries, deduplication, replay and dead-letter handling are implemented and tested.

If enabled in a later version:
- delivery is assumed at-least-once unless proven otherwise;
- consumers deduplicate by stable event ID and source revision;
- ordering is scoped to a documented aggregate/version;
- gaps and conflicting versions are detected;
- events are emitted only after source transaction commit;
- consumers never treat event receipt alone as authorization to perform a write.

## 10. Freshness, consistency and reconciliation

- Every imported reference must retain source revision and retrieval time.
- Freshness thresholds are capability-specific and must be agreed before activation.
- A changed source revision marks the local reference update-available or stale until refreshed.
- Same revision with a different canonical hash is an integrity conflict and must be quarantined for investigation.
- Source revocation or authorization loss blocks future retrieval immediately.
- A failed refresh must not silently preserve a stale record as current.
- Historical decisions must point to the exact evidence revision used at decision time.
- Reconciliation compares source identifiers, revisions, hashes and expected record counts where the interface supports them; it must not rewrite ICIE source records.
- Local deletion, retention or archival follows 4TL4S policy and applicable agreements; it does not issue a deletion command to ICIE.

## 11. Failure model

The adapter must distinguish at least:

| Code | Meaning | Expected behavior |
|---|---|---|
| UNAUTHENTICATED | Missing/invalid service identity | Deny; do not retry blindly |
| UNAUTHORIZED | Identity lacks source or consumer permission | Deny; record audit |
| TENANT_MAPPING_MISSING | No verified mapping | Fail closed |
| TENANT_MAPPING_CONFLICT | Ambiguous or duplicate mapping | Quarantine; require human review |
| CAPABILITY_UNAVAILABLE | Capability not AVAILABLE in environment | Do not call |
| FIELD_NOT_ALLOWED | Request/response contains unapproved field | Reject response; alert |
| CONTRACT_VERSION_UNSUPPORTED | Unsupported contract/interface version | Stop; negotiate explicitly |
| SOURCE_NOT_FOUND | Source record absent or no longer addressable | Mark unavailable; preserve provenance |
| SOURCE_REVOKED | Source explicitly revoked | Stop retrieval; apply cache policy |
| INTEGRITY_CONFLICT | Same revision, different hash | Quarantine and investigate |
| RATE_LIMITED | Source rate limit | Bounded backoff respecting retry guidance |
| SOURCE_UNAVAILABLE | Transient source failure | Bounded retry; preserve last-known state as stale |
| SCHEMA_INVALID | Payload violates declared schema | Reject; do not coerce |
| INTERNAL_ERROR | Unexpected adapter/provider failure | Correlate, audit and fail safely |

Retries must be bounded, observable and safe. Authorization, mapping, schema and integrity failures are not transient retry candidates.

## 12. Intellectual property, confidentiality and data handling

- ICIE remains an independently owned and governed system. Integration does not assign, license or transfer ICIE source code, schemas, methods, documentation or know-how.
- The connector receives only the minimum information necessary for the approved purpose.
- Repository visibility or organization membership does not grant permission to retrieve source artifacts.
- ICIE background IP and reusable product knowledge remain distinct from client-specific data and deliverables.
- Evidence references must preserve source ownership and classification; imported data must not be reclassified as 4TL4S-owned.
- No secrets, credentials, personal data or confidential client content may be placed in public repository documentation.
- Retention, export, deletion, backup, data residency and incident-notification obligations must be reviewed before production activation.
- Legal ownership and licensing questions require the relevant agreements and human/legal review; this contract is not a legal assignment instrument.

## 13. Acceptance criteria and activation gates

The integration remains PROPOSED until all gates below have evidence.

### Gate A — Contract and ownership
- [ ] Both systems' accountable owners are named.
- [ ] Purpose, environment, data classes and resource scope are approved.
- [ ] ICIE confirms source authority and exact published read resources.
- [ ] Field allowlists and schema versions are version-controlled.
- [ ] IP, confidentiality and retention review is recorded.

### Gate B — Identity and tenant isolation
- [ ] Dedicated service identity exists per environment.
- [ ] Source-side authorization is enforced.
- [ ] Explicit tenant mapping is verified by both systems.
- [ ] Tests prove denial for missing, revoked, ambiguous and cross-tenant mappings.
- [ ] Secret storage, rotation and revocation are tested.

### Gate C — Data and evidence correctness
- [ ] Decimal-safe values, units, currency and timestamps are preserved.
- [ ] Unknown fields and unsupported schema versions are rejected.
- [ ] Source revision/hash and provenance survive retrieval and storage.
- [ ] Stale, revoked, superseded and conflicting states are represented correctly.
- [ ] No AI interpretation is promoted to verified or approved source state.

### Gate D — Operational and security validation
- [ ] Read-only surface is verified; no domain mutation path is available to the integration identity.
- [ ] Audit events exist for successful, denied, failed and revoked requests.
- [ ] Correlation IDs connect both systems' traces.
- [ ] Rate limits, bounded retries, timeouts and source outage behavior are tested.
- [ ] Synthetic tests demonstrate tenant isolation and prevent data leakage.
- [ ] Disablement and credential revocation are tested.
- [ ] A rollback/containment procedure and operational owner are documented.

Passing these gates permits a separately approved limited activation. It does not imply general production readiness of either platform.

## 14. Implementation sequence

1. Approve and version this contract without changing ICIE domain code.
2. ICIE publishes a minimal capability manifest and confirms one read-only resource with schema, auth and tenant semantics.
3. Implement an external 4TL4S integration adapter with identity mapping, allowlist validation and provenance capture.
4. Register the integration and its approvals in 4TL4S.
5. Build synthetic contract tests for allowed and denied access, tenant isolation, version changes, stale/revoked data and integrity conflicts.
6. Run a reference integration in a non-production environment.
7. Review evidence and authorize a narrowly scoped activation.
8. Consider additional capabilities only through explicit scope changes and renewed acceptance gates.

Do not build a broad connector, UI dashboard or event pipeline before the reference read-only exchange passes its acceptance tests.

## 15. Change control and versioning

- This contract uses semantic versioning for compatibility decisions.
- Patch changes clarify wording or fix non-semantic errors.
- Minor versions add backward-compatible optional fields or capabilities without expanding existing authority.
- Major versions are required for breaking schema changes, new data classes, write permissions, new authority or changed tenancy semantics.
- Every activation records the exact contract version and capability manifest revision.
- Changes to permissions, field allowlists, tenant mappings or purpose require explicit approval and audit history.
- Contract changes do not retroactively authorize prior access.

## 16. Current implementation status and explicit non-claims

**Status: PROPOSED.**

At the time of this version:
- the ICIE IIP describes a contract-first integration approach;
- ICIE API_CONTRACTS.md is a design baseline, not a published stable API;
- ICIE D05 documents a limited confirmed-receipt slice, but this contract does not independently verify its current code or deployment state;
- the documented outbox record does not establish a functioning publisher;
- no 4TL4S–ICIE adapter, service identity, verified organization mapping, capability endpoint, event subscription or end-to-end integration test is claimed here;
- no production integration is authorized by this document alone.

**This contract establishes the boundary and the conditions for integration. It is not evidence that integration has been implemented.**
