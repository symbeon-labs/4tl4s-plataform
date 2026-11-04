# Financial Reconciliation — Risks and Open Questions

## Blocking discovery items

1. Which banks and account types are used by the pilot?
2. Which acquirers/sub-acquirers process card sales, and how are fees, installments, anticipation and chargebacks reported?
3. Which payment gateways and PIX providers are used?
4. Which POS, checkout or sales systems originate sales and cash closures?
5. Which cash controls are currently maintained outside the ERP?
6. Which billing, boleto and receivables sources must be correlated?
7. Are marketplace/delivery-platform payouts in scope?
8. Which Omie financial records must be read, and which identifiers are available?
9. Can authorized representative samples be provided for every source family prioritized?
10. Is there a non-production Omie environment and test company?
11. Who is the financial process owner and who may approve reconciliation decisions?
12. What are the accepted date/settlement windows, fees, split payments, partial payments, refunds and chargeback rules?
13. What are expected volumes, periods and retention requirements?
14. What hosting/data-residency constraints apply?
15. What is the authorized commercial scope and IP/license arrangement?

## Risks

| Risk | Consequence | Mitigation |
|---|---|---|
| Unknown provider layouts | Parser failure or incorrect mapping | Sample-first adapter design and fixtures |
| Source roles flattened into one transaction type | False or invalid relationships | Role-aware canonical records |
| Acquirer gross/net and fee complexity | False reconciliation totals | Explicit amount equations and settlement model |
| Inaccurate counterparty inference | False financial association | Candidate-only resolution + human review |
| Incorrect matching rules | False reconciliation | Versioned rules + labeled test cases |
| Duplicate imports/webhook replay | Inflated totals | Scoped idempotency keys + duplicate signals |
| Omie API assumptions | Integration rework | Verify docs, permissions and homologation |
| Sensitive financial/personal data | Exposure | Minimize, isolate, encrypt, restrict, audit |
| Too many adapters in first release | Scope expansion and delayed pilot | Multi-source contract, phased adapter delivery |
| Unclear commercial/IP terms | Dispute over code/data/updates | Agreement before operational deployment |
| OCR errors | Incorrect extracted values | Confidence/provenance + manual review |

## Adapter prioritization rule

Prioritize an adapter only when there is:
- a confirmed operational need;
- an authorized representative sample or accessible homologation environment;
- a defined record role and mapping;
- a named process owner;
- test cases and expected outcomes;
- a clear read/write permission boundary.

## Deferred decisions

- Exact provider list and adapter implementation order.
- Frontend framework and component system.
- Database engine and tenancy implementation.
- Hosting topology.
- OCR provider and document-layout engine.
- Vector search or semantic retrieval.
- Omie API vs controlled file exchange.
- Any write-back/export format required by a verified workflow.
- Release channel and 4TL4S integration contract.

These decisions must be made from actual requirements and representative samples, not assumed in advance.
