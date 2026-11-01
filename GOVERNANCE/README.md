# Governance — 4TL4S

## Purpose

Governance defines who may see, change, approve, transfer, disclose, or commit resources and information in 4TL4S. It applies across all operating domains.

## Core principles

1. **Least privilege** — grant only the access needed for a defined responsibility.
2. **Scope isolation** — client, project, and research scopes remain separated unless a documented relationship and authorization permit access.
3. **Human accountability** — critical decisions have an accountable human authority.
4. **Evidence before assertion** — claims must identify their source and verification status.
5. **Provenance** — preserve origin, version, author/contributor, and transformation history.
6. **Reversibility where possible** — consequential changes should support review, rollback, or compensating action.
7. **Fail closed** — uncertainty about authorization or scope does not grant access.
8. **Separation of duties** — proposal, review, approval, and execution may require distinct roles.

## Information states

Records should distinguish at least:
- **Declared** — supplied by a person or system but not independently checked.
- **Observed** — captured from a named source or system.
- **Interpreted** — analysis or inference, including AI-generated interpretation.
- **Verified** — checked using a recorded method and accountable verifier.
- **Approved** — accepted by an authorized decision-maker for a defined purpose.
- **Rejected / Superseded** — no longer accepted as current.

A state transition must record who or what performed it, when, under which method or policy, and what scope it applies to. A boolean flag alone is insufficient for consequential evidence.

## Organizational unit access

OrganizationalUnit is a proposed scope narrower than Organization. Organization Membership and Unit Membership are distinct grants. Organization membership alone must not be interpreted as access to every unit-scoped initiative or record. Unit roles cannot elevate organization privileges or imply contractual, financial, disclosure or IP-transfer authority.

See the [Organizational Unit Authorization Contract](organizational_unit_authorization_contract_v0.1.md). This is a proposed security contract; RLS and application enforcement remain unimplemented and require authenticated runtime validation.

## Human approval gates

Explicit authorization is required before:
- creating, changing, or accepting contractual commitments;
- approving expenditure, payments, refunds, or financial terms;
- changing access privileges or sharing confidential data;
- publishing, disclosing, licensing, assigning, or transferring IP;
- merging or deploying consequential production changes where configured;
- deleting or irreversibly altering important records;
- accepting client deliverables or closing contractual obligations.

An agent may prepare a recommendation or draft action. It may not treat its own analysis as authorization.

## Intellectual-property register

Each IP asset must record, where applicable:
- stable identifier and description;
- asset type and repository/storage location;
- origin and creation date;
- contributors and relevant agreements;
- classification: Background IP, Research IP, Product IP, Client IP, or Third-party IP;
- license, assignment, ownership basis, and restrictions;
- derivative relationships and permitted reuse;
- review status and responsible reviewer.

Classification is not a legal conclusion by itself. Conflicts or missing agreements must be escalated for review. Repository ownership alone does not establish all rights in contributions or dependencies.

## Evidence governance

Evidence records should capture:
- claim or requirement supported;
- source reference and source owner;
- capture time and source version;
- integrity information where useful;
- evidence type and sensitivity;
- interpretation separately from source;
- verification method, verifier, and result;
- approval status and authorized approver;
- retention and access constraints.

A hash can support integrity checking; it does not prove truth, authorship, completeness, or legal ownership.

## Audit history

Material changes should create append-only audit events containing actor, action, target, timestamp, previous/new state where appropriate, reason, and correlation reference. Audit access must itself be controlled.

## Data protection and client confidentiality

Client records must be scoped to the relevant engagement and authorized participants. Reuse of client data, artifacts, or learnings outside the engagement requires a documented rights basis and appropriate de-identification or permission. Do not place secrets, credentials, personal data, or confidential client material in this public-facing documentation repository.

## Policy status

This document establishes intended governance requirements. Organizational unit authorization is specified but not implemented. Operational enforcement, legal review, security controls, and compliance validation remain implementation tasks.
