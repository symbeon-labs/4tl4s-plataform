# Financial Reconciliation — Product Charter v0.1

## 1. Problem

Financial teams receive bank movements and financial records through heterogeneous sources. Descriptions, identifiers, timing, fees, split settlements, and account formats make manual comparison slow and error-prone. The product should reduce repetitive search and expose uncertainty rather than conceal it.

## 2. Users and roles

- **Financial operator:** imports statements, reviews candidates, resolves exceptions.
- **Financial approver:** confirms high-impact or ambiguous decisions within delegated authority.
- **System administrator:** manages organization-scoped users, accounts, connectors, and configuration.
- **Symbeon maintainer:** publishes product releases and maintains reusable product components under the governing agreement.
- **Auditor/reviewer:** reads permitted decision and evidence history without changing operational state.

Roles are conceptual until an authorization model is implemented and reviewed.

## 3. Core workflow

1. Create an import batch for a specific organization, bank account, and period.
2. Upload an authorized source file.
3. Validate file type, size, integrity, and account scope.
4. Parse source records without discarding original values.
5. Normalize fields while retaining source-field provenance.
6. Run deterministic validations and duplicate detection.
7. Generate match candidates against an explicitly imported/connected set of financial records.
8. Assign outcomes: MATCH_CANDIDATE, UNMATCHED, AMBIGUOUS, CONFLICT, or INVALID.
9. Route cases requiring review to an authorized operator.
10. Record confirmation or rejection with actor, timestamp, reason, evidence references, and rule version.
11. Generate a batch report and export permitted results.

## 4. Matching policy

Matching must be explainable and versioned. Candidate signals may include:
- exact amount and currency;
- transaction date and configurable settlement window;
- normalized counterparty or description;
- bank transaction identifier / end-to-end identifier;
- document or title reference;
- account and direction (credit/debit).

No single fuzzy-text similarity score is sufficient to confirm a financial match. Ambiguous or conflicting candidates must remain unresolved until human review.

## 5. Intelligence boundary

OCR, fuzzy matching, recurring-pattern detection, and entity resolution are optional assistive capabilities. They may propose extracted fields or candidate relationships, but they do not establish facts or authorize financial actions. Every extracted or inferred field must retain source and confidence/provenance metadata.

## 6. Non-functional requirements

- Tenant and organization isolation enforced server-side.
- Least-privilege access.
- Encryption in transit and at rest according to deployment environment.
- No secrets or real client financial records in source control.
- Idempotent import processing.
- Reproducible parser and matching-rule versions.
- Structured audit events for state-changing actions.
- Explicit retention, export, and deletion policies.
- Safe failure: parsing or integration failure must not mutate source records.

## 7. Commercial and IP boundary

Background IP, product IP, client-specific deliverables, third-party IP, client data, and configuration must be classified under the applicable agreement. Repository placement does not establish ownership. Access to a deployed product does not imply access to source code or rights to modify/re-distribute it.

## 8. Success measures for the pilot

Measured on an authorized, representative, manually validated sample:
- statement parsing success rate;
- percentage of transactions normalized without manual correction;
- candidate match precision;
- unresolved/ambiguous rate;
- duplicate detection precision and recall;
- operator time per statement batch;
- full traceability of confirmed and rejected decisions.

Targets must be set only after baseline samples and ground truth are available.
