# Project Workspace & Embedded Roadmap Experience

**Product experience specification · 2026-11-01**

## Purpose

Define a project presentation that supports professional internal Symbeon coordination and controlled client-facing communication.

The experience should make active projects legible at a glance while keeping the operational roadmap connected to the underlying project data.

## Primary concept

Each active project has a **Project Workspace** composed of:
1. a project identity and status header;
2. a compact operational summary;
3. an embedded roadmap checklist;
4. milestone and deliverable context;
5. risks, blockers, decisions, and evidence;
6. a clear next-action area.

The roadmap checklist should be embedded in the project information presented, not hidden in a detached planning document. This workspace is one experience within 4TL4S, not the whole product.

## Project header

Display, where authorized:
- project name and reference;
- client / organization;
- project owner and delivery lead;
- lifecycle phase;
- status;
- last meaningful update;
- next milestone and target date, when approved;
- confidentiality / visibility indicator.

Avoid displaying unsupported percentages or dates. If progress cannot be derived reliably, show the number of completed, active, blocked, and pending checklist items instead of an artificial percentage.

## Embedded roadmap checklist

The checklist is a view over structured roadmap items and work packages. It must not become a separate, manually maintained copy of project status.

Each roadmap item should support:
- stable identifier;
- title and short outcome;
- phase or milestone;
- status: not_started, ready, in_progress, blocked, in_review, completed, cancelled;
- accountable owner;
- assigned human or agent actor, when applicable;
- due date, only when committed;
- dependencies;
- acceptance criteria;
- evidence references;
- visibility classification;
- last updated timestamp.

Interaction:
- expand/collapse phases;
- mark progress only through authorized state transitions;
- open the underlying task or work package;
- inspect dependencies and blockers;
- view evidence and review state;
- record a decision or request approval where permitted.

A checkbox must not directly imply technical verification, human approval, delivery, or client acceptance. Those are separate lifecycle states.

## Internal and client-facing presentation

Use one canonical project data model with two authorized projections.

### Internal view
May include:
- internal work breakdown;
- operator assignments and capacity;
- agent execution metadata;
- internal estimates and cost data;
- technical risks and candid blocker notes;
- IP classification and reuse constraints;
- internal decisions and review comments;
- client commitments and change-control history.

### Client view
May include only explicitly approved information:
- agreed project objective and scope;
- milestones and approved roadmap items;
- delivery status;
- approved dates;
- client-relevant blockers and dependencies;
- deliverables and acceptance criteria;
- evidence or artifacts approved for client access;
- decisions requiring client input;
- next steps and accountable contacts.

Never expose by default:
- internal margin, cost, or utilization;
- private operator notes;
- internal risk assessments not cleared for disclosure;
- other clients' data;
- credentials, secrets, or internal system details;
- proprietary Symbeon background IP or internal agent traces;
- draft proposals or unapproved commitments.

Client access must be enforced server-side through organization, project, and record-level authorization. A frontend toggle or hidden component is not a security boundary.

## Visual direction — Dark-first, V0-inspired

The 4TL4S interface adopts a **dark-first visual system**. Light mode may be considered later as an explicit secondary theme, but dark mode is the canonical design baseline for the initial product experience.

Use the visual language associated with polished V0-generated SaaS interfaces as inspiration, not as a claim of affiliation or a pixel-perfect copy. The result should have its own Symbeon identity.

### Visual character
- dark graphite / near-black application canvas, avoiding pure black as the only surface;
- layered charcoal surfaces for navigation, cards, panels, and overlays;
- subtle neutral borders and restrained separators;
- high-contrast primary text and calm secondary text;
- one controlled accent color for primary actions and selected states;
- semantic status colors used sparingly and always paired with text labels;
- clear typographic hierarchy and generous but efficient spacing;
- refined tables, compact badges, and precise data presentation;
- restrained transitions and purposeful hover/focus states;
- responsive layouts for desktop, tablet, and mobile.

### Surface hierarchy
Establish a clear depth system:
1. **Canvas:** deepest neutral background for the application shell.
2. **Navigation / Sidebar:** slightly elevated or differentiated dark surface.
3. **Primary panels:** readable charcoal surfaces for project content.
4. **Interactive surfaces:** hover, selected, focused, and expanded states with clear contrast.
5. **Overlays:** dialogs, command menus, and popovers with distinct elevation and boundaries.

Do not rely on shadows alone to distinguish dark surfaces; use subtle luminance differences and borders.

### Interaction and readability
- maintain WCAG-conscious contrast for text and interactive controls;
- never use muted gray text that becomes illegible on dark surfaces;
- ensure keyboard focus is visible against every surface;
- pair status colors with labels and, where useful, icons;
- make disabled, loading, error, empty, and permission-denied states explicit;
- avoid excessive gradients, neon effects, glassmorphism, and decorative glow;
- avoid dense dashboards with too many competing cards;
- avoid oversized charts without decision value;
- avoid fake progress metrics and decorative checkboxes without operational meaning.

The visual system should communicate precision, calm, technical confidence, and professional delivery—not a generic cyberpunk aesthetic. Final tokens, typography, components, and responsive behavior must follow the product's own design system once established.

## Suggested page hierarchy

- Global navigation: organization / workspace / projects / operations.
- Project page: Overview | Roadmap | Deliverables | Evidence | Decisions | Activity.
- Overview: compact summary + embedded checklist preview + next milestone + blockers.
- Roadmap: phase-grouped checklist with filters for status, owner, and visibility.
- Deliverables: version, review, delivery, acceptance.
- Evidence: source, verification, sensitivity, access.
- Decisions: rationale, authority, date, affected scope.
- Activity: auditable event history, filtered by authorization.

The overview should remain useful without opening every tab.

## Data and state semantics

Keep these concepts separate:
- roadmap item status;
- task execution status;
- evidence verification;
- internal approval;
- client delivery;
- client acceptance.

A completed checklist item means only that its defined work item reached its completion condition. It does not automatically mean that its output is verified, approved, delivered, or accepted.

Progress summaries must be computed from authorized canonical records and explain their denominator (for example, completed items out of total active roadmap items).

## Accessibility and usability

- Keyboard-operable checklist and navigation.
- Visible focus states.
- Accessible labels for controls.
- Text labels in addition to status colors.
- Responsive table alternatives on narrow screens.
- Confirmations for consequential state changes.
- Clear feedback for blocked permissions and failed actions.

## Implementation status

This document specifies the intended experience. It does not assert that the UI, checklist interactions, client projection, or access-control implementation currently exists.
