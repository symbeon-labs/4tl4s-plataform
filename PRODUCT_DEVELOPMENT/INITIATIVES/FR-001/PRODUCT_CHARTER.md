# Financial Reconciliation — Product Charter v0.1

## 1. Problem

Financial operations are distributed across banks, ERPs, acquirers, payment gateways, POS/checkout systems, cash controls, billing platforms and marketplaces. Each source describes only part of an operation and may use different identifiers, dates, gross/net values, fees, installments and settlement states. Manual comparison across these sources is slow and error-prone.

The product must correlate these records without pretending they are identical transaction types, preserve uncertainty, and expose the evidence behind every proposed relationship.

## 2. Users and roles

- **Financial operator:** imports sources, reviews candidates, resolves exceptions.
- **Financial approver:** confirms high-impact or ambiguous decisions within delegated authority.
- **System administrator:** manages organization-scoped users, accounts, connectors and configuration.
- **Symbeon maintainer:** publishes product releases and maintains reusable product components under the governing agreement.
- **Auditor/reviewer:** reads permitted decision and evidence history without changing operational state.

Roles are conceptual until an authorization model is implemented and reviewed.

## 3. Source families and ingestion model

The product must distinguish:
1. **Source family:** bank, ERP, acquirer, gateway/PIX provider, POS/checkout, cash, billing/receivables, marketplace, or statutory/payroll support.
2. **Source system/institution:** the actual bank, Omie tenant, acquirer, gateway, POS or platform.
3. **Ingestion channel:** upload, API, webhook, controlled batch or manual structured entry.
4. **Format/protocol:** OFX, CSV, XLSX, CNAB 240/400, PDF/image, XML, REST or provider-specific schema.
5. **Record role:** bank movement, sale, receivable, payable, fee, refund, chargeback, payout, cash movement, settlement or supporting evidence.

This taxonomy prevents a sales record, a receivable and a bank credit from being flattened into the same semantic object.

## 4. Core workflow

1. Register an organization-scoped source, source family, account/entity and permitted ingestion channel.
2. Create an import batch for a defined period and scope.
3. Upload/receive the source payload or request a scoped API synchronization.
4. Validate authorization, source identity, payload integrity, format and schema version.
5. Preserve original payload and raw records with provenance and content hash.
6. Parse and normalize into source-specific canonical records.
7. Run deterministic validation, idempotency and duplicate detection.
8. Generate candidate relationships across compatible record roles.
9. Assign outcomes: MATCH_CANDIDATE, UNMATCHED, AMBIGUOUS, CONFLICT or INVALID.
10. Route exceptions to an authorized operator.
11. Record confirmation/rejection with actor, timestamp, reason, evidence references and rule version.
12. Generate source and reconciliation reports; export permitted results.

## 5. Matching policy

Matching must be explainable and versioned. Signals may include exact amount/currency, date and settlement window, source identifiers, account/entity, counterparty, document/title reference, payment method, installment, gross/net amount, fees and transaction direction.

Matching must support one-to-one, one-to-many and many-to-one relationships where the business process justifies them (for example, several card sales settling in one payout, or one receivable paid in installments). These relationship types must be explicit; amounts must reconcile under documented fee, discount, refund and timing rules.

No single fuzzy-text similarity score is sufficient to confirm a financial match. Ambiguous or conflicting candidates remain unresolved until human review.

## 6. Intelligence boundary

OCR, fuzzy matching, recurring-pattern detection and entity resolution are optional assistive capabilities. They may propose extracted fields or candidate relationships, but they do not establish facts or authorize financial actions. Every extracted or inferred field must retain source, method, confidence and provenance metadata.

## 7. Non-functional requirements

- Tenant and organization isolation enforced server-side.
- Least-privilege access and scoped connector credentials.
- Encryption in transit and at rest according to deployment environment.
- No secrets or real client financial records in source control.
- Idempotent ingestion and replay-safe webhooks.
- Reproducible parser, mapping and matching-rule versions.
- Structured audit events for state-changing actions.
- Explicit retention, export and deletion policies.
- Safe failure: parsing or integration failure must not mutate source records.
- Source-specific reconciliation totals and cross-source lineage.

## 8. Commercial and IP boundary

Background IP, product IP, client-specific deliverables, third-party IP, client data and configuration must be classified under the applicable agreement. Repository placement does not establish ownership. Access to a deployed product does not imply access to source code or rights to modify/re-distribute it.

## 9. Success measures for the pilot

Measured on authorized, representative, manually validated samples:
- parsing/ingestion success by source adapter;
- percentage of records normalized without manual correction;
- candidate match precision by relationship type;
- unresolved/ambiguous rate;
- duplicate detection precision and recall;
- gross-to-net / fee reconciliation coverage where applicable;
- operator time per source batch;
- full traceability of confirmed and rejected decisions.

Targets must be set only after baseline samples and ground truth are available.
