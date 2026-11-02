# SOA–4TL4S Context Exchange Contract

**Contract ID:** 4TL4S-INT-SOA-001  
**Version:** 0.1  
**Status:** PROPOSED — interface contract; connector not implemented  
**Source:** Symbeon Intelligence / Symbeon Organizational Atlas  
**Consumer:** 4TL4S — Symbeon Operations Platform  
**Date:** 2026-11-01  
**Related:** ADR-0004, 4TL4S-DOM-OU-001, 4TL4S-SEC-OU-001

## 1. Purpose and boundary

Define a narrow, versioned, read-only exchange of authorized organizational context from SOA to 4TL4S. SOA remains authoritative for research records and interpretations; 4TL4S remains authoritative for operational initiatives, work packages, approvals and execution records. The connector does not merge repositories, databases, identities, IP ownership or operational authority.

## 2. Direction and permitted operations

Initial mode: SOA → 4TL4S, read-only.

Permitted:
- request an explicitly authorized context package by stable SOA record ID;
- retrieve approved metadata, typed relationships, bounded summaries and evidence references;
- record a local reference to source package and version;
- refresh or mark a reference stale/revoked according to source response.

Not permitted:
- write, edit, delete or approve SOA records;
- query the entire Intelligence repository or unrestricted document store;
- enumerate unrelated organizations, cases, people or assets;
- retrieve raw confidential documents unless separately authorized and scoped;
- execute code, commands, workflows or agent actions in the source;
- infer implementation status, legal identity, authority, ownership or IP rights;
- use SOA data as authorization to access 4TL4S records.

No reverse synchronization is included in v0.1.

## 3. Context package envelope

| Field | Meaning |
|---|---|
| contract_id | 4TL4S-INT-SOA-001 |
| contract_version | 0.1 |
| source_system | Stable source identifier, e.g. symbeon_intelligence |
| source_record_id | Stable SOA record identifier |
| source_record_type | organization, organizational_unit, project, capability, relationship, evidence, opportunity |
| source_revision | Immutable source revision/version |
| content_hash | Hash of exact canonical payload, when available |
| generated_at | Source package generation timestamp |
| retrieved_at | Consumer retrieval timestamp |
| classification | Public, internal, confidential, restricted; taxonomy alignment required |
| authorization_basis | Grant/policy reference and scope, never secret credentials |
| permitted_fields | Explicit field allowlist |
| payload | Bounded normalized context |
| provenance | Source references and transformation history |
| state | current, stale, revoked, conflicted, superseded |

A hash supports integrity comparison only. It does not prove truth, authorship, completeness or legal ownership.

## 4. Minimum normalized payload

Initial allowlist may include stable entity ID/type; display name and non-sensitive description; organization/unit references and typed relationship labels; information state; evidence references and source dates; scoped capability summaries and explicit uncertainty; source revision and classification.

Do not copy personal data, client source material, credentials, contract contents, private repository contents or raw evidence by default. A field is excluded unless explicitly listed and authorized.

## 5. Identity, authorization and tenancy

- Authenticate with a dedicated, revocable service identity.
- Bind each request to a named source record, consumer organization, purpose and allowed field set.
- Enforce authorization at the source before returning data.
- A source relationship does not prove that the consumer may access a corresponding 4TL4S tenant or unit.
- Map source IDs to local records through explicit tenant-scoped mapping records; never match solely by display name.
- Keep source identity and consumer tenant identity separate.
- Never place service secrets in code, client bundles, repository files or package payloads.
- Fail closed when source authorization, record identity, classification or mapping is ambiguous.

## 6. Versioning, freshness and provenance

Store source system, record ID, revision, hash, retrieval time, contract version and field allowlist with every imported reference. Preserve previous revisions as history or immutable reference metadata; do not silently overwrite provenance.

A changed hash with unchanged revision is an integrity conflict. A changed revision marks context update-available until accepted by refresh policy. A revoked or inaccessible reference becomes revoked/unavailable; cached content is hidden or retained only under an approved retention basis. Stale context must be visibly distinct from current operational facts. Decisions must reference the exact source revision used.

## 7. Failure and revocation

Distinguish unavailable source, unauthorized request, missing/superseded record, invalid schema/version, hash mismatch, rate limit/transient error and explicit revocation. Retries are bounded and idempotent. Authorization failures are not retried as transient. Revocation stops future retrieval immediately; cached-data disposition follows approved retention policy. Connector disablement does not delete audit history.

## 8. Audit

Record requester/service identity, source record, consumer tenant, purpose, contract version, field set, source revision/hash, result state, timestamp and correlation ID. Never log secrets or unrestricted payloads.

## 9. Acceptance criteria

Before activation:
- schema validation rejects unknown versions and unapproved fields;
- source authorization is tested for allowed and denied records;
- tenant mapping prevents cross-tenant attachment;
- source revision/hash changes are detected;
- revocation and stale-cache behavior are tested;
- no write operation exists in connector identity or API surface;
- audit records exist for successful, denied, failed and revoked retrievals;
- synthetic tests demonstrate tenant isolation;
- privacy, confidentiality, IP and retention review is recorded.

## 10. Implementation status

Proposed contract only. No API endpoint, service identity, connector runtime, synchronization job or production exchange is claimed to exist. Implementation requires explicit approval, source-side authorization design and test evidence.
