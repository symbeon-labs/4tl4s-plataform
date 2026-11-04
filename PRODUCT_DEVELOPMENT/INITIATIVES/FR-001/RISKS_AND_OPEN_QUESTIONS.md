# Financial Reconciliation — Risks and Open Questions

## Blocking discovery items

1. Which banks and account types are in the first pilot?
2. Can the client provide authorized representative OFX files for each target bank?
3. Are CSV or PDF sources actually required in the first release?
4. Which Omie financial records must be read for matching, and which identifiers are available?
5. Is there a non-production Omie environment and test company?
6. Who is the financial process owner and who may approve reconciliation decisions?
7. What are the accepted date/settlement windows, fee/tariff rules, split payments, partial payments, and chargeback cases?
8. What are the expected transaction volumes and statement periods?
9. What hosting/data-residency constraints apply?
10. What retention, export, and deletion rules apply?
11. What is the authorized commercial scope and IP/license arrangement?

## Risks

| Risk | Consequence | Mitigation |
|---|---|---|
| Unknown bank layouts | Parser failure or data loss | Sample-first adapter design |
| Inaccurate counterparty inference | False financial association | Candidate-only resolution + human review |
| Incorrect matching rules | False reconciliation | Versioned rules + labeled test cases |
| Duplicate imports | Inflated totals | Hash/idempotency + duplicate signals |
| Omie API assumptions | Integration rework | Verify docs, permissions, and homologation |
| Sensitive financial/personal data | Exposure | Minimize, isolate, encrypt, restrict, audit |
| Unclear commercial/IP terms | Dispute over code/data/updates | Agreement before operational deployment |
| OCR errors | Incorrect extracted values | Confidence/provenance + manual review |

## Deferred decisions

- Frontend framework and component system.
- Database engine and tenancy implementation.
- Hosting topology.
- OCR provider and document-layout engine.
- Vector search or semantic retrieval.
- Omie API vs controlled file exchange.
- OFX output generation, if required by verified Omie workflow.
- Release channel and 4TL4S integration contract.

These decisions must be made from actual requirements and representative samples, not assumed in advance.
