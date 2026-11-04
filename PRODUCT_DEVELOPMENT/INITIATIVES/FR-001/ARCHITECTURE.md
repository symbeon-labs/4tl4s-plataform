# Financial Reconciliation — Architecture Baseline v0.1

## Architectural stance

Start as a modular monolith with explicit domain boundaries. Avoid distributed services until measured scale, isolation or deployment requirements justify them. The reconciliation domain must remain independent from source adapters, OCR providers, Omie connectors and the 4TL4S control plane.

## Multi-dimensional source model

Do not model "import type" as a single enum. Use separate dimensions:

- **source_family:** BANK, ERP, ACQUIRER, PAYMENT_GATEWAY, PIX_PROVIDER, POS, CASH, BILLING, MARKETPLACE, PAYROLL_TAX_SUPPORT, OTHER.
- **source_system:** institution/provider/tenant identity, e.g. a specific bank, Omie company, acquirer or POS.
- **ingestion_channel:** FILE_UPLOAD, API_PULL, WEBHOOK_PUSH, CONTROLLED_BATCH, MANUAL_ENTRY.
- **format:** OFX, CSV, XLSX, CNAB240, CNAB400, PDF_TEXT, PDF_SCAN, IMAGE, XML, JSON_API, PROVIDER_NATIVE.
- **record_role:** BANK_MOVEMENT, SALE, RECEIVABLE, PAYABLE, FEE, REFUND, CHARGEBACK, PAYOUT, CASH_MOVEMENT, SETTLEMENT, SUPPORTING_DOCUMENT.
- **adapter_version / mapping_version:** explicit parser and field-mapping revisions.

The registry must permit new source families, providers, formats and record roles without changing the canonical transaction semantics or hardcoding provider logic into the matching engine.

## Logical components

```
BANKS | ERP | ACQUIRERS | GATEWAYS/PIX | POS | CASH | BILLING | MARKETPLACES
                              |
                              v
                  SOURCE REGISTRY + CONNECTORS
                              |
             FILE UPLOAD | API | WEBHOOK | BATCH | MANUAL
                              |
                              v
                   SOURCE PRESERVATION
             raw payload + hash + source metadata
                              |
                              v
                   ADAPTER / PARSER LAYER
              format parser + source mapping
                              |
                              v
                  CANONICAL SOURCE RECORDS
                              |
              VALIDATION + IDEMPOTENCY + DEDUP
                              |
                              v
                 RECONCILIATION RELATIONSHIP ENGINE
            one-to-one | one-to-many | many-to-one
                              |
                              v
                   CASES + HUMAN REVIEW
                              |
                    DECISION / AUDIT LOG
                              |
                  REPORTS / CONTROLLED EXPORTS
                              |
                    4TL4S EVIDENCE POINTERS
```

## Domain modules

1. **Source Registry:** organization, source family, institution/provider, account/entity, permitted channel, credentials reference and active mapping.
2. **Ingestion Gateway:** batch creation, upload/API/webhook validation, idempotency, payload hash and provenance.
3. **Adapter Registry:** format parsers, provider mappings, versioning and conformance fixtures.
4. **Canonical Source Records:** normalized bank movements, titles, sales, payouts, fees, refunds, cash movements and supporting records; preserve raw values.
5. **Validation Engine:** schema, arithmetic, date, currency, sign, account/entity and duplicate checks.
6. **Entity Resolution:** candidate counterparty/account identification; suggestions only.
7. **Relationship Engine:** deterministic candidate matching and explainable one-to-one, one-to-many and many-to-one links.
8. **Case Management:** unmatched, ambiguous, conflict and invalid cases.
9. **Decision & Audit:** human decisions, authority, rationale, timestamps and rule versions.
10. **Integration Adapters:** Omie and future sources through scoped contracts.
11. **Reporting:** source-batch totals, gross/net/fee breakdowns, exceptions and reconciliation outcomes.

## Initial adapter portfolio

The domain contract is multi-source from day one. Adapter implementation is prioritized after discovery and representative samples.

| Family | Candidate sources | Candidate formats/channels | v0.1 posture |
|---|---|---|---|
| Banking | Bank accounts, PIX, fees, transfers | OFX, mapped CSV, API | Initial pilot priority |
| ERP / financial | Omie payable/receivable titles, settlements | API, CSV/XLSX exports | Read-only adapter priority |
| Acquirers | Cielo, Rede, Stone, Getnet or actual client provider | CSV/XLSX, API, provider files | Contract + sample-driven |
| Gateways / PIX | Payment processors and PIX providers | API, webhook, CSV | Contract + sample-driven |
| POS / checkout | Sales, cancellations, cash closures | API, CSV/XLSX | Contract + sample-driven |
| Cash | Cashbook, deposits, withdrawals | CSV/XLSX, manual structured entry | Contract + sample-driven |
| Billing / receivables | Boleto and invoice collections | API, CSV/XLSX, CNAB where relevant | Contract + sample-driven |
| Marketplaces | Orders, fees, payouts, refunds | API, CSV/XLSX | Contract + sample-driven |
| Payroll / tax support | Payment schedules and confirmations | CSV/XLSX/PDF/XML as defined | Deferred specialized scope |

A row in this table does not mean the provider or format is implemented or certified.

## Canonical record model (candidate)

A shared envelope should carry:
- record_id;
- organization_id / tenant_id;
- source_id and source_family;
- source_system and external_record_id;
- import_batch_id;
- record_role;
- event_date and posting/settlement_date when applicable;
- amount_minor and currency;
- direction where meaningful;
- raw_description and normalized_description;
- counterparty_reference;
- source_reference / end_to_end_reference;
- raw_payload_reference and payload_hash;
- adapter_version and mapping_version;
- field_provenance;
- validation_status.

Use role-specific extensions for installments, gross/net amount, fees, MDR, commissions, taxes, refunds, chargebacks and settlement references. Do not force non-bank records into a bank-only transaction schema. Store money as integer minor units or exact decimal types; never binary floating point.

## Relationship model

A reconciliation relationship links two or more source records and records:
- relationship_type and cardinality;
- member record references;
- amount equation / tolerance policy;
- date window;
- fees, discounts, commissions or adjustments accounted for;
- matching rule and version;
- signals and evidence;
- outcome and review state.

The engine must not assume that a payout equals one sale. It must support aggregation and decomposition where supported by evidence and approved rules.

## Omie integration boundary

Begin read-first. Retrieve only the financial records required for matching, using documented permissions and tenant/entity scope. Do not post, settle, delete or modify Omie records in v0.1. Confirm API operations, rate limits, identifiers and homologation environment before implementation.

## OCR and pattern recognition

- Prefer native extraction for structured files and digital PDFs.
- Use OCR only for image-based/scanned documents.
- Preserve page/region and extraction confidence where available.
- Use deterministic patterns and fuzzy similarity to generate candidates, never automatic identity assertions.
- Keep vector/semantic search optional; structured indexes should cover initial queries.

## 4TL4S integration

4TL4S tracks the initiative, contract version, release metadata, approvals and evidence references. FR-001 owns source ingestion, transaction processing and reconciliation state. Integration is via versioned APIs/events with explicit scopes. FR-001 must remain executable if 4TL4S is unavailable.

## Deployment options

The product should support a separately governed Symbeon-hosted environment or client-controlled deployment, subject to the commercial agreement and security review. No deployment topology is assumed before data residency, access and operational constraints are known.
