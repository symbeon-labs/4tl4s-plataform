# ADR-0001 — Separate operating domains under shared governance

- **Status:** Accepted
- **Decision date:** 2026-11-01
- **Decision owner:** Symbeon Labs platform direction
- **Scope:** 4TL4S operating model

## Context

Symbeon initiatives include applied research, engineering and product development, production of discrete artifacts, and commercial/client engagements. These activities have different purposes, evidence standards, approval gates, and success criteria. Treating them as a single generic project type would obscure these differences.

## Decision

4TL4S will model Applied Research, Product Development, Artifact Production, and Commercial Operations as distinct operating domains under shared governance services.

Every initiative must have one primary classification. Cross-domain work is represented through explicit relationships and bounded work packages rather than by collapsing domain identities.

## Consequences

- Domain-specific workflows and measures can evolve without losing common identity and governance.
- A commercial engagement can contain development and artifact work while retaining contract-level control.
- Research outcomes are not assumed to be products or deliverables.
- The application and data model must support typed relationships and domain-specific authorization.
- Initial implementation has additional modeling complexity, accepted in exchange for clearer boundaries.
