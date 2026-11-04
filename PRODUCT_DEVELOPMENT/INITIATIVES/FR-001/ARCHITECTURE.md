# Financial Reconciliation — Architecture Baseline v0.1

## Architectural stance

Start as a modular monolith with explicit domain boundaries. Avoid distributed services until measured scale, isolation, or deployment requirements justify them. Keep the reconciliation domain independent from bank adapters, OCR providers, Omie connectors, and the 4TL4S control plane.

## Logical components

```
BANK / FINANCIAL SOURCES
       |
       v
INGESTION ADAPTERS
  OFX | CSV (mapped) | OCR adapter (later)
       |
       v
SOURCE PRESERVATION
  original file reference + SHA-256 + import metadata
       |
       v
PARSER & NORMALIZER
       |
       v
CANONICAL TRANSACTION MODEL
       |
       +------> VALIDATION ENGINE
       |
       +------> DUPLICATE DETECTION
       |
       v
MATCHING ENGINE
       |
       v
RECONCILIATION CASES
  candidate | unmatched | ambiguous | conflict | invalid
       |
       v
HUMAN REVIEW & DECISION LOG
       |
       +------> REPORT / EXPORT
       |
       +------> SCOPED OMIE ADAPTER (read-first; writes disabled)
       |
       v
EVIDENCE / AUDIT RECORDS
```

## Domain modules

1. **Source Registry:** organization, account, institution, format, and source identity.
2. **Ingestion:** batch creation, file validation, idempotency, provenance, hash.
3. **Parser Adapters:** format-specific parsing with explicit parser versions.
4. **Canonical Ledger:** normalized transaction representation preserving raw source fields.
5. **Validation Engine:** schema, arithmetic, date, sign, account, and duplicate checks.
6. **Entity Resolution:** candidate counterparty identification; suggestions only.
7. **Matching Engine:** deterministic candidate scoring and explainable rule outcomes.
8. **Case Management:** unmatched, ambiguous, conflict, and invalid cases.
9. **Decision & Audit:** human decisions, authority, rationale, timestamps, and rule versions.
10. **Integration Adapters:** Omie and future sources through scoped contracts.
11. **Reporting:** batch summaries, exceptions, and reconciliation outcomes.

## Canonical transaction fields (candidate)

- tenant_id / organization_id
- account_id
- import_batch_id
- source_record_id
- transaction_date
- posting_date (optional)
- amount_minor (integer minor currency units)
- currency
- direction (CREDIT | DEBIT)
- raw_description
- normalized_description
- counterparty_reference (optional)
- bank_transaction_reference (optional)
- end_to_end_reference (optional)
- source_file_hash
- parser_version
- extraction_method
- field_provenance
- validation_status

The final schema must be checked against real sample statements. Store monetary values as integer minor units or exact decimal types; never binary floating point.

## Omie integration boundary

Begin read-first. Import or retrieve only the financial records required for matching, using documented permissions and tenant/account scope. Do not post, settle, delete, or modify Omie records in v0.1. Confirm available API operations, rate limits, identifiers, and homologation environment before implementation.

## OCR and pattern recognition

- Prefer native text extraction for digital PDFs.
- Use OCR only for image-based/scanned documents.
- Preserve page/region and extraction confidence where available.
- Use deterministic patterns and fuzzy similarity to generate candidates, never automatic identity assertions.
- Keep vector/semantic search optional; structured indexes should cover the initial query set.

## 4TL4S integration

4TL4S tracks the initiative, contract version, release metadata, approvals, and evidence references. FR-001 owns transaction processing and operational state. Integration is via versioned APIs/events with explicit scopes. FR-001 must remain executable if 4TL4S is unavailable.

## Deployment options

The product should support a separately governed Symbeon-hosted environment or client-controlled deployment, subject to the commercial agreement and security review. No deployment topology is assumed before data residency, access, and operational constraints are known.
