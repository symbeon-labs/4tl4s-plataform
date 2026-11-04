# Financial Reconciliation — Acceptance Criteria v0.1

## A. Source registry and ingestion

- [ ] Register a source with distinct source family, source system, ingestion channel, format and record-role capabilities.
- [ ] Accept authorized OFX and mapped CSV samples for the initial bank pilot.
- [ ] Support a read-only Omie source adapter only after API/export behavior and scope are verified.
- [ ] Define adapter contracts for additional families: acquirers, gateways/PIX, POS, cash, billing and marketplaces.
- [ ] Do not display an adapter as supported until its conformance tests pass.
- [ ] Reject unsupported or malformed payloads with a clear error.
- [ ] Calculate and persist SHA-256 for file payloads; use an appropriate payload fingerprint for API/webhook events.
- [ ] Replays/re-imports are idempotent within source and organization scope.
- [ ] Preserve original payload and raw record provenance under an approved retention policy.

## B. Parsing and normalization

- [ ] Parse date, amount, currency, role, description and available source references.
- [ ] Preserve raw source values separately from normalized values.
- [ ] Normalize without changing source evidence.
- [ ] Represent money exactly (integer minor units or exact decimal).
- [ ] Record adapter, mapping version and field-level provenance.
- [ ] Flag missing, invalid or contradictory fields.
- [ ] Apply role-specific extensions for gross/net, fees, installments, refunds and payouts where the adapter provides them.

## C. Validation and duplicate detection

- [ ] Validate organization, source, account/entity and period scope.
- [ ] Detect repeated source-native identifiers and webhook replays.
- [ ] Detect likely duplicates using documented signals without silently deleting records.
- [ ] Validate source totals and arithmetic where source data supports the check.
- [ ] Preserve partial batches and report accepted/rejected record counts.

## D. Reconciliation and review

- [ ] Produce explainable candidates using versioned deterministic rules.
- [ ] Support explicit one-to-one, one-to-many and many-to-one relationships.
- [ ] Keep ambiguous or conflicting cases unresolved.
- [ ] Reconcile gross/net values and fees only through explicit equations and approved rules.
- [ ] Require authorized human confirmation.
- [ ] Record confirmation/rejection, actor, timestamp, reason, evidence and rule version.
- [ ] Prevent users from confirming records outside their organization/source scope.

## E. Reporting and integration

- [ ] Produce source-batch totals and reconciliation reports with matched, unmatched, ambiguous, conflict and invalid records.
- [ ] Show source lineage and adapter/mapping version.
- [ ] Omie access is read-only in v0.1.
- [ ] No payments, write-offs, settlements or source-record mutations are performed.
- [ ] Integration failures do not corrupt imported records.

## F. Security and governance

- [ ] No real client financial data, secrets, tokens or credentials are committed to Git.
- [ ] Server-side authorization is enforced on every data operation.
- [ ] Organization isolation is tested.
- [ ] Audit events are append-only at application level; storage-level immutability is not claimed.
- [ ] Retention, export, backup and deletion procedures are documented before production.

## Release decision

The v0.1 pilot is accepted only when the agreed source adapters pass representative samples and applicable criteria, exceptions are documented, the financial process owner signs off, and the release owner records approval. A successful build alone is not acceptance.
