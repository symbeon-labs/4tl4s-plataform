# Financial Reconciliation — Acceptance Criteria v0.1

## A. Ingestion

- [ ] Accept an authorized OFX sample from a registered account.
- [ ] Reject unsupported or malformed files with a clear error.
- [ ] Calculate and persist SHA-256 for the original file.
- [ ] Re-importing identical bytes is idempotent and does not duplicate transactions.
- [ ] Preserve original file and raw record provenance under an approved retention policy.

## B. Parsing and normalization

- [ ] Parse date, amount, currency, direction, description, and available bank references.
- [ ] Preserve raw description and source values.
- [ ] Normalize text without changing source evidence.
- [ ] Represent money exactly (integer minor units or exact decimal).
- [ ] Record parser version and field-level provenance.
- [ ] Flag missing, invalid, or contradictory fields.

## C. Validation and duplicate detection

- [ ] Validate account scope and statement period.
- [ ] Detect repeated source transaction identifiers.
- [ ] Detect likely duplicates using documented signals without silently deleting records.
- [ ] Report opening/closing balance inconsistencies when source data supports the check.

## D. Matching and review

- [ ] Produce explainable candidates using versioned deterministic rules.
- [ ] Keep ambiguous or conflicting cases unresolved.
- [ ] Require authorized human confirmation.
- [ ] Record confirmation/rejection, actor, timestamp, reason, evidence, and rule version.
- [ ] Prevent users from confirming records outside their organization/account scope.

## E. Reporting and integration

- [ ] Produce a batch report with totals, valid/invalid records, candidate matches, unmatched items, and exceptions.
- [ ] Omie access is read-only in v0.1.
- [ ] No payments, write-offs, settlements, or source-record mutations are performed.
- [ ] Integration failures do not corrupt imported bank data.

## F. Security and governance

- [ ] No real client financial data, secrets, tokens, or credentials are committed to Git.
- [ ] Server-side authorization is enforced on every data operation.
- [ ] Organization isolation is tested.
- [ ] Audit events are append-only at application level; storage-level immutability is not claimed.
- [ ] Retention, export, backup, and deletion procedures are documented before production.

## Release decision

The v0.1 pilot is accepted only when the agreed representative sample passes the applicable criteria, exceptions are documented, the financial process owner signs off, and the release owner records the approval. A successful build alone is not acceptance.
