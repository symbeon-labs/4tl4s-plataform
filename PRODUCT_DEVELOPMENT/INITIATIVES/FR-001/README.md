# FR-001 — Financial Reconciliation

**Product:** Financial Reconciliation  
**Version:** 0.1 (definition baseline)  
**Initiative:** ENG-MS-01 — Mundo do Sabor  
**Product owner:** Symbeon Labs (proposed; subject to governing agreements)  
**Initial operational context:** RSBUILD / Mundo do Sabor  
**Status:** Proposed — requirements and technical validation in progress

## Purpose

Create a controlled financial reconciliation product that ingests bank statement data, normalizes transactions, identifies candidate matches against financial records, surfaces divergences, and preserves an auditable decision history.

The first release is a bounded pilot. It is not an ERP replacement, payment processor, accounting authority, or autonomous settlement system.

## Repository and lifecycle boundary

4TL4S records the initiative, scope, decisions, contracts, milestones, release references, and evidence pointers. The product's source code, runtime, technical backlog, CI/CD, and release lifecycle belong in a separate product repository and remain independently governed.

The product must integrate with 4TL4S only through explicit, versioned contracts. It must not depend on 4TL4S to execute core reconciliation.

## Initial scope

- Register an organization-scoped bank account and statement source.
- Ingest OFX as the primary candidate format; support CSV only after its mapping is explicitly defined.
- Preserve source-file provenance and calculate a content hash.
- Parse and normalize transactions into a canonical model.
- Validate required fields, dates, amounts, signs, account identity, and duplicate candidates.
- Match bank transactions to imported financial records using deterministic criteria.
- Produce candidate matches, unmatched items, conflicts, and review cases.
- Require authorized human confirmation for consequential reconciliation decisions.
- Record who decided what, when, on which evidence and rule version.
- Export a reconciliation report and a controlled OFX output only if the Omie homologation test establishes that output is required and accepted.

## Explicit exclusions for v0.1

- Automatic payments, transfers, or write-offs.
- Automatic posting or settlement in Omie.
- Unreviewed AI decisions.
- Cross-company data pooling.
- Production deployment before security, operational, and client acceptance gates.
- OCR as a mandatory ingestion path. OCR is an optional adapter for scanned PDFs/images and is deferred until representative samples justify it.
- Semantic/vector search as a prerequisite. Initial search should use structured fields and indexed text.

## Release gates

1. Representative, authorized sample statements are available.
2. Bank layout and account metadata are documented.
3. Omie import/export behavior is verified in a non-production environment.
4. Matching rules and exception policy are approved by the financial process owner.
5. Test cases cover normal, duplicate, ambiguous, missing, and conflicting transactions.
6. Data access, retention, backup, and deletion rules are approved.
7. Release evidence and human acceptance are recorded.

## Source-of-truth principle

The bank statement remains source evidence for bank movements. Omie remains the operational system of record for its own financial titles and accounting records. FR-001 proposes relationships between records; it does not silently overwrite either source.

## Related documents

- [Product charter](PRODUCT_CHARTER.md)
- [Architecture baseline](ARCHITECTURE.md)
- [Canonical data contract](DATA_CONTRACT.md)
- [Acceptance criteria](ACCEPTANCE_CRITERIA.md)
- [Risk and open questions](RISKS_AND_OPEN_QUESTIONS.md)

## Current limitations

This is a proposed product baseline, not proof of implementation, compatibility with any bank or Omie environment, accounting correctness, security certification, or production readiness.
