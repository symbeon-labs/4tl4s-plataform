# FR-001 — Financial Reconciliation

**Product:** Financial Reconciliation  
**Version:** 0.1 (definition baseline)  
**Initiative:** ENG-MS-01 — Mundo do Sabor  
**Product owner:** Symbeon Labs (proposed; subject to governing agreements)  
**Initial operational context:** RSBUILD / Mundo do Sabor  
**Status:** Proposed — requirements and technical validation in progress

## Purpose

Create a controlled, multi-source financial reconciliation product that ingests bank movements and financial records from different operational systems, normalizes them into governed canonical representations, identifies explainable relationships, surfaces divergences, and preserves an auditable decision history.

The first release is a bounded pilot. It is not an ERP replacement, payment processor, accounting authority, or autonomous settlement system.

## Repository and lifecycle boundary

4TL4S records the initiative, scope, decisions, contracts, milestones, release references, and evidence pointers. The product's source code, runtime, technical backlog, CI/CD, and release lifecycle belong in a separate product repository and remain independently governed.

The product must integrate with 4TL4S only through explicit, versioned contracts. It must not depend on 4TL4S to execute core reconciliation.

## Source taxonomy

A **source family** identifies where a financial record originates. An **ingestion channel** identifies how it is obtained. A **file/API format** identifies its technical representation. These dimensions must not be conflated.

### Source families

- **Banking:** current accounts, savings accounts, bank statements, bank fees, transfers, PIX and other bank movements.
- **ERP / financial management:** payable and receivable titles, settlements, cash/bank registers, chart-of-accounts references and financial exports (including Omie).
- **Card acquirers and sub-acquirers:** sales, installments, gross/net amounts, MDR/fees, anticipated receivables, cancellations and chargebacks (e.g. Cielo, Rede, Stone, Getnet, subject to client usage).
- **Payment gateways and PIX providers:** collections, payment intents, PIX receipts, refunds, fees and settlement reports.
- **POS / checkout / sales systems:** orders, sales, cancellations, discounts, cash register closures and payment-method breakdowns.
- **Cash operations:** opening/closing balances, cash withdrawals, deposits, petty cash and recorded cash movements.
- **Billing and receivables:** invoices, boletos, collections, partial payments, overdue titles and settlement references.
- **Marketplaces and delivery platforms:** orders, commissions, withheld fees, refunds and payout/settlement statements.
- **Payroll, tax and statutory obligations:** payment schedules and confirmations as supporting sources; defer specialized tax/accounting treatment until separately specified.

A source family does not imply that every record is a bank movement. The canonical model must distinguish source record types and their roles in a reconciliation relationship.

### Ingestion channels

- Manual upload by an authorized user.
- API connector with explicitly scoped credentials.
- Webhook/event reception with signature and replay validation.
- Controlled batch import from an approved storage location.
- Manual structured entry for documented exceptions, always marked as manually supplied.

### Candidate formats and protocols

- Structured financial files: OFX, CSV, XLSX.
- Banking/remittance files: CNAB 240 and CNAB 400, where applicable and layout-validated.
- Documents: digital PDF and scanned PDF/image through text extraction or optional OCR.
- Structured business documents: XML only for a defined use case and schema (for example, a relevant fiscal or payment document).
- Integrations: REST APIs, webhooks and provider-specific exports.

Support is adapter-specific, not universal. Every format requires a versioned mapping, sample fixtures and validation tests. A file extension alone is not proof of compatibility.

## Initial v0.1 implementation boundary

The v0.1 domain model and adapter contracts must be multi-source from the beginning. The first operational pilot should prioritize sources confirmed in discovery, with OFX and mapped CSV as initial bank-statement adapters and a read-only Omie adapter for financial records. Other families are represented in the contract and source registry but are not claimed as implemented until their adapters pass acceptance tests.

## Explicit exclusions for v0.1

- Automatic payments, transfers, write-offs or settlement.
- Automatic posting or mutation in Omie or any external source.
- Unreviewed AI decisions.
- Cross-company data pooling.
- Production deployment before security, operational and client acceptance gates.
- OCR as a mandatory ingestion path.
- Assuming every listed source, institution or format is already supported.
- Semantic/vector search as a prerequisite; structured fields and indexed text come first.

## Release gates

1. Authorized representative samples exist for each source adapter included in the pilot.
2. Source identity, account/entity scope, format/layout and mapping are documented.
3. Omie capabilities are verified in a non-production environment.
4. Matching rules and exception policy are approved by the financial process owner.
5. Tests cover normal, duplicate, ambiguous, missing, partial, split, reversed and conflicting records where relevant.
6. Data access, retention, backup and deletion rules are approved.
7. Release evidence and human acceptance are recorded.

## Source-of-truth principle

Each originating system remains authoritative for the records it owns. A bank statement is evidence of bank movements; an ERP is authoritative for its own titles and operational records; an acquirer or gateway is authoritative for its own sales, fees and payout reports. FR-001 preserves source assertions and proposes traceable relationships; it does not silently overwrite any source.

## Related documents

- [Product charter](PRODUCT_CHARTER.md)
- [Architecture baseline](ARCHITECTURE.md)
- [Canonical data contract](DATA_CONTRACT.md)
- [Acceptance criteria](ACCEPTANCE_CRITERIA.md)
- [Risk and open questions](RISKS_AND_OPEN_QUESTIONS.md)

## Current limitations

This is a proposed product baseline, not proof of implementation, compatibility with any bank/provider/ERP, accounting correctness, security certification, or production readiness.

## Pilot source confirmation and adapter priority

The pilot discovery response identifies these source families as used by Mundo do Sabor: **Omie, banks (any institution), acquirers, POS/checkout, Excel/Google Sheets spreadsheets, and boletos/receivables**. “Other” was left unspecified; no additional source is assumed.

The initial adapter sequence is:

1. **Bank statements — cross-institution file adapter:** OFX first where available, then institution-mapped CSV. “Any institution” means the source registry and mapping layer must be institution-extensible; it does not mean universal API connectivity or guaranteed support for every bank.
2. **Omie — read-only financial adapter:** payable/receivable titles, settlements and relevant identifiers, subject to API/export validation and homologation.
3. **Acquirers — settlement adapter:** sales, installments, gross/net, MDR/fees, anticipation, cancellations and chargebacks, based on the actual provider(s) and sample reports.
4. **POS / checkout — sales and closure adapter:** sales, payment-method breakdowns, cancellations, discounts and cash closures.
5. **Boletos / receivables — collection adapter:** titles, references, partial payments and settlement events; evaluate CNAB/API/CSV according to the actual issuer/bank/provider workflow.
6. **Excel / Google Sheets — controlled tabular adapter:** XLSX/CSV upload first with versioned column mapping; Google Sheets API integration only after access, ownership and update semantics are agreed.

This is a delivery priority, not a claim that adapters are already implemented. Initial technical validation should run a thin vertical slice across bank + Omie first, then add acquirer/POS/receivables relationships. Spreadsheets are a supporting ingestion path and must preserve workbook/sheet/row provenance.

Duplicate mention of “Bancos” in the discovery response is consolidated into one source family. The “Other” field is blank and remains an open discovery item.
