# Financial Reconciliation — Data Contract Draft v0.1

Status: Draft. Validate against authorized samples from every adapter included in the pilot. This contract separates source identity, ingestion channel, technical format and financial record role.

## Source registration

| Field | Type | Required | Notes |
|---|---|---:|---|
| source_id | UUID | yes | Internal stable identifier |
| organization_id | UUID | yes | Tenant boundary |
| source_family | enum | yes | BANK, ERP, ACQUIRER, PAYMENT_GATEWAY, PIX_PROVIDER, POS, CASH, BILLING, MARKETPLACE, PAYROLL_TAX_SUPPORT, OTHER |
| source_system | string | yes | Institution/provider/tenant identity |
| account_or_entity_ref | string | conditional | Bank account, ERP company, merchant/store or cash register |
| ingestion_channel | enum | yes | FILE_UPLOAD, API_PULL, WEBHOOK_PUSH, CONTROLLED_BATCH, MANUAL_ENTRY |
| format | enum | yes | OFX, CSV, XLSX, CNAB240, CNAB400, PDF_TEXT, PDF_SCAN, IMAGE, XML, JSON_API, PROVIDER_NATIVE |
| adapter_version | string | yes | Parser/connector version |
| mapping_version | string | yes | Source-to-canonical mapping version |
| credential_reference | string | no | Secret-manager reference only; never credential value |

## Import batch

| Field | Type | Required | Notes |
|---|---|---:|---|
| batch_id | UUID | yes | Internal stable identifier |
| organization_id | UUID | yes | Tenant boundary |
| source_id | UUID | yes | Registered source |
| payload_hash | string | conditional | SHA-256 of original bytes/body where applicable |
| payload_reference | string | conditional | Controlled object-storage reference |
| received_at | timestamp | yes | UTC |
| period_start / period_end | date | conditional | Derived/validated against content |
| adapter_version / mapping_version | string | yes | Reproducibility |
| idempotency_key | string | yes | Channel-scoped replay protection |
| batch_status | enum | yes | RECEIVED / VALIDATING / ACCEPTED / PARTIAL / REJECTED / FAILED |

## Canonical source record envelope

| Field | Type | Required | Notes |
|---|---|---:|---|
| record_id | UUID | yes | Internal ID |
| organization_id | UUID | yes | Tenant boundary |
| source_id | UUID | yes | Originating source |
| batch_id | UUID | yes | Import provenance |
| external_record_id | string | no | Source-native identifier |
| record_role | enum | yes | BANK_MOVEMENT / SALE / RECEIVABLE / PAYABLE / FEE / REFUND / CHARGEBACK / PAYOUT / CASH_MOVEMENT / SETTLEMENT / SUPPORTING_DOCUMENT |
| event_date | date/timestamp | yes | Date of source event |
| posting_date | date | no | Posting date |
| settlement_date | date | no | Settlement date |
| amount_minor | integer | yes | Exact minor units; sign convention documented |
| currency | ISO 4217 | yes | Never infer silently |
| direction | CREDIT/DEBIT/NOT_APPLICABLE | yes | Role-aware |
| raw_description | string | no | Preserve original source text |
| normalized_description | string | no | Derived, versioned |
| counterparty_reference | string | no | Source-provided or explicitly inferred |
| source_reference | string | no | Bank/provider/document reference |
| raw_payload_reference | string | no | Restricted source evidence |
| payload_hash | string | no | Hash of original payload or source record |
| field_provenance | JSON | yes | Field-level source and transformation |
| validation_status | enum | yes | VALID / WARNING / INVALID |

Role-specific extensions may include installment number/count, gross amount, net amount, MDR, commission, fee, discount, tax, refund reference, chargeback reference, payout reference, payment method and cash register close ID. Extensions must be versioned and must not overload unrelated fields.

## Reconciliation relationship

| Field | Type | Required | Notes |
|---|---|---:|---|
| relationship_id | UUID | yes | Internal ID |
| organization_id | UUID | yes | Tenant boundary |
| member_record_refs | array | yes | Two or more source record references |
| cardinality | enum | yes | ONE_TO_ONE / ONE_TO_MANY / MANY_TO_ONE |
| relationship_type | enum | yes | e.g. BANK_SETTLEMENT, SALE_PAYOUT, RECEIVABLE_SETTLEMENT, CASH_CLOSING |
| amount_equation | JSON | yes | Explain gross/net/fees/adjustments |
| date_window | JSON | yes | Rule-defined window |
| rule_version | string | yes | Reproducible rules |
| signals | JSON | yes | Explainable evidence |
| outcome | enum | yes | CANDIDATE / AMBIGUOUS / CONFLICT / CONFIRMED / REJECTED |
| reviewed_by / reviewed_at | UUID/timestamp | conditional | Required for human-reviewed decision |

## Decision record

Each confirmation/rejection includes decision_id, organization_id, actor_id and role, action and prior/new state, reason, linked record/relationship references, rule version, evidence references, timestamp and correlation/request ID.

## Contract invariants

1. Original source values are never overwritten by normalized values.
2. A payload hash identifies bytes, not semantic equivalence.
3. Re-imports and webhook replays are idempotent within a defined source scope.
4. A candidate relationship is not a confirmed reconciliation.
5. Human confirmation is attributable to an authorized identity.
6. No write operation to Omie or other source system is allowed in v0.1.
7. Cross-organization references are rejected by default.
8. One-to-many and many-to-one relationships require explicit amount equations and approved rules.
9. Every imported record retains source family, source system, channel, format and adapter/mapping versions.
