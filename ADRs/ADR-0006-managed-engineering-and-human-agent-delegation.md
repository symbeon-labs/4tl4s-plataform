# ADR-0006 — Managed Engineering and Human-Agent Delegation

- **Status:** Accepted
- **Date:** 2026-11-01
- **Decision owner:** Symbeon Labs / Product Owner
- **Affected domains:** Commercial Operations, Product Development, Shared Governance, Experience Layer, Application Layer
- **Related records:** ADR-0001, ADR-0002, ADR-0003, ADR-0004, ADR-0005

## Context

4TL4S is being developed as a Symbeon product for enterprise-assisted development and engineering operations. Its first commercial operating mode is expected to allow Symbeon to receive, qualify, coordinate, and deliver bounded technical demands for clients, including RS2BUILD, while the platform itself is still evolving.

The initial operation may be founder-led and supported by AI tools. As resources become available, work can be delegated to human operators and specialists. In parallel, the platform must be designed so that suitable tasks can progressively be delegated to supervised agents and, only after demonstrated reliability, to bounded autonomous execution.

The product must not assume that a fully staffed delivery organization or mature autonomous-agent infrastructure exists today.

## Decision

4TL4S will follow a **Managed Engineering first, Enterprise Platform next** commercial strategy.

The product combines:
1. enterprise demand intake and qualification;
2. contextual research and engineering preparation;
3. work decomposition and orchestration;
4. allocation of work to human operators, specialists, agents, or combinations thereof;
5. execution governance, evidence, review, and delivery assurance;
6. a future platform mode in which client organizations may operate these capabilities themselves, subject to product maturity and access controls.

The operating model evolves through these stages:

1. **Founder-led operations:** a Symbeon accountable owner coordinates work; AI tools assist with research, planning, implementation support, and documentation.
2. **Human-operated network:** bounded work packages are delegated to authorized human operators and specialists, with agent assistance where useful.
3. **Human-supervised agent execution:** agents execute specifically authorized tasks under scoped identities, tool permissions, validation requirements, and human review.
4. **Bounded autonomous operations:** only proven workflows may execute autonomously within explicit limits, monitoring, escalation, and revocation controls.

These stages are a target evolution path, not a claim that the later stages are currently implemented.

## Human accountability and authority

Humans remain part of the operating model at every stage. Human accountability is required for, at minimum:
- contractual commitments, pricing, and scope changes;
- access grants and confidential-data sharing;
- IP licensing, assignment, publication, or disclosure;
- production deployments and consequential architecture changes;
- financial commitments;
- acceptance of client deliverables and contractual closure;
- exceptions, safety-sensitive actions, and unresolved conflicts.

An agent may research, interpret, prepare, recommend, draft, and execute a bounded task when explicitly authorized. An agent's own output is not approval or authorization.

## Task execution contract

Every executable work item should be able to express:
- objective and acceptance criteria;
- initiative and work-package scope;
- accountable human owner;
- execution mode: human, assisted, supervised-agent, or bounded-autonomous;
- assigned actor or execution identity;
- allowed tools and operations;
- prohibited operations;
- required tests and evidence;
- review and approval gates;
- escalation and stop conditions.

Permissions must be enforced by the backend and integration identities. UI visibility alone is not authorization. Default behavior is least privilege and fail closed.

## Commercial model

The initial commercial offer is **Managed Engineering**: Symbeon assumes an explicitly scoped technical demand and coordinates the resources needed to deliver it.

The future complementary offer is **Enterprise Platform**: a client organization uses 4TL4S to coordinate its own engineering operations.

These offers may coexist later, but platform licensing, self-service operation, and autonomous execution must not be represented as available capabilities until implemented and validated.

## Operational learning

Each engagement may generate reusable operational knowledge only where the governing contract, client permissions, confidentiality obligations, and IP classification allow it. Client data and client-owned artifacts must remain isolated. Generalized know-how must be reviewed and de-identified where required before entering cross-project intelligence.

## Consequences

- The product model must support both human and agent actors without making either a special-case afterthought.
- Work packages need explicit scope, ownership, permissions, acceptance criteria, evidence, and review state.
- Commercial Operations must connect client commitments to bounded initiatives and delivery records.
- The platform must distinguish task completion, technical verification, human approval, client delivery, and client acceptance.
- Agent autonomy is capability-specific and evidence-gated; it is not a global platform switch.
- The initial product should prioritize the workflows needed for Symbeon's own managed delivery operations before broad client self-service.

## Non-goals

This decision does not:
- authorize any specific client engagement or scope;
- establish that agents can safely execute arbitrary engineering work;
- imply that 4TL4S is production-ready;
- replace project-specific repositories, CI/CD, issue trackers, or source-of-truth systems;
- permit cross-client reuse of confidential data or client IP.

## Review triggers

Revisit this ADR when:
- the first managed engagements provide operational evidence;
- human delegation and role models are validated;
- an agent execution contract is implemented;
- client self-service is introduced;
- commercial packaging or contractual responsibilities materially change.
