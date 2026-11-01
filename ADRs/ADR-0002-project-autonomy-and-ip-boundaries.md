# ADR-0002 — Preserve project autonomy and IP boundaries

- **Status:** Accepted
- **Decision date:** 2026-11-01
- **Decision owner:** Symbeon Labs platform direction
- **Scope:** Platform governance and integrations

## Context

4TL4S coordinates work across Symbeon initiatives and client engagements. Central visibility could be mistaken for ownership, unrestricted access, or authority over the internal operation of every connected project.

## Decision

4TL4S is a coordination and governance layer. Connected products and projects retain their own repositories, technical decisions, execution environments, and lifecycles unless a separate explicit delegation says otherwise.

The platform must classify Background IP, Research IP, Product IP, Client IP, and Third-party IP using provenance and rights information. Access and reuse are separately authorized.

## Consequences

- Integrations must use scoped permissions and documented contracts.
- Client data is isolated from unrelated clients and reusable Symbeon assets.
- Repository access does not itself confer rights to reuse or disclose contents.
- Reusable components require provenance, license, version, and permission records.
- Missing or conflicting rights information blocks unapproved transfer or publication.
