# Financial Reconciliation — Data Contract Draft v0.1

Status: Draft. Validate against authorized bank and Omie samples before implementation.

## Import batch

| Field | Type | Required | Notes |
|---|---|---:|---|
| batch_id | UUID | yes | Internal stable identifier |
| organization_id | UUID | yes | Tenant boundary |
| account_id | UUID | yes | Registered bank account |
| source_format | enum | yes | OFX initially; CSV only with approved mapping |
| source_file_hash | string | yes | SHA-256 of original bytes |
| source_filename | string | yes | Metadata only; sanitize |
| received_at | timestamp | yes | UTC |
| parser_version | string | yes | Reproducibility |
| period_start / period_end | date | conditional | Derived/validated against content |

## Canonical transaction

| Field | Type | Required | Notes |
|---|---|---:|---|
| transaction_id | UUID | yes | Internal ID |
| batch_id | UUID | yes | Import provenance |
| account_id | UUID | yes | Bank account scope |
| transaction_date | date | yes | Source date |
| posting_date | date | no | If supplied |
| amount_minor | integer | yes | Signed or paired with direction; one convention only |
| currency | ISO 4217 | yes | Do not assume BRL without account metadata |
| direction | CREDIT/DEBIT | yes | Must agree with amount convention |
| raw_description | string | yes | Preserve source text |
| normalized_description | string | no | Derived, versioned |
| bank_reference | string | no | Bank-provided identifier |
| end_to_end_reference | string | no | If supplied |
| counterparty_name | string | no | Source-provided, not inferred as fact |
| extraction_method | enum | yes | OFX_PARSER / CSV_PARSER / PDF_TEXT / OCR |
| field_provenance | JSON | yes | Field-level source and transformation |
| validation_status | enum | yes | VALID / WARNING / INVALID |

## Match candidate

| Field | Type | Required | Notes |
|---|---|---:|---|
| candidate_id | UUID | yes | Internal ID |
| transaction_id | UUID | yes | Bank-side record |
| target_record_ref | string | yes | External financial title reference |
| rule_version | string | yes | Deterministic rule set |
| signals | JSON | yes | Explainable matching signals |
| score | decimal | no | Advisory only; not authority |
| outcome | enum | yes | CANDIDATE / AMBIGUOUS / CONFLICT |
| reviewed_by | UUID | no | Human reviewer |
| reviewed_at | timestamp | no | Human review time |

## Decision record

Each confirmation/rejection must include:
- decision_id;
- organization_id;
- actor_id and role;
- action and prior/new state;
- reason;
- linked transaction and target references;
- rule version and evidence references;
- timestamp;
- correlation/request ID.

## Contract invariants

1. Original source values are never overwritten by normalized values.
2. A source file hash identifies bytes, not semantic equivalence.
3. Duplicate imports must be detected idempotently and reported.
4. A match candidate is not a confirmed reconciliation.
5. Human confirmation must be attributable to an authorized identity.
6. No write operation to Omie is allowed in v0.1.
7. Cross-organization references are rejected by default.
