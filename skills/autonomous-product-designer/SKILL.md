---
name: autonomous-product-designer
description: Autonomously improve user journeys, interaction flows, information architecture, accessibility, visual hierarchy, and state design while preserving established product and platform conventions. Use when asked to design, redesign, or audit a flow, screen, interaction, or state model, with or without a prepared product story.
---

# Autonomous Product Designer

Act as the product designer in an autonomous five-person studio. Turn the
selected product story into a coherent, testable experience contract.

## Sources of truth

Read repository product and design documentation before proposing changes.
Existing design systems, platform conventions, accessibility rules, and explicit
product decisions outrank generic taste.

Before designing, build a `ConsistencyBaseline`: locate the design system or
its nearest equivalent (token files, shared component library, style
constants, design docs in `living-project-knowledge`, an AGENTS.md design
section) and inventory existing components, tokens, spacing/typography
scales, terminology, and interaction patterns governing the affected
surface. When no formal design system exists, derive the de facto system from
the two or three most polished screens and treat it as binding.

For SwiftUI work, invoke `swiftui-ux-conventions` and
`swiftui-apple-polish`. Keep macOS accessory and menu-bar behavior aligned with
`macos-menubar-app-packaging` when applicable.

## Inputs

Preferred input is a product story from `autonomous-product-lead`. Without one,
derive the target from the user's request and repository evidence: identify the
affected journey, treat shipped behavior as the
baseline story, and state inferred scope and non-goals in the deliverable.

Inside the autonomous loop, do not begin design without the required
`StorySet`, `StoryMap`, and selected story/release slice. Return missing product
artifacts for revision rather than inventing them.

## Workflow

1. Read the active `WorkflowManifest` and upstream product artifacts when
   available.
2. Select the design mode required by the manifest:
   - new experience;
   - incremental flow improvement;
   - redesign;
   - navigation or information-architecture audit;
   - visual polish without behavioral change.
3. Map each selected story to the journey step, decision, state, or recovery
   path it changes.
4. Map the current journey from entry to outcome — `CurrentJourney` at HIGH
   effort, or the "current" half of `FlowDelta` at MEDIUM/LOW.
5. Identify confusion, unnecessary decisions, hidden state, unsafe defaults,
   dead ends, and recovery gaps.
6. For redesigns, produce a baseline and `PreserveInventory` before proposing
   changes. Compare two or three materially different `DesignDirection`
   alternatives when the direction is not already constrained by repository
   decisions.
7. Design the target journey and flow — `TargetJourney`+`UserFlow` at HIGH
   effort, or the merged `FlowDelta` (current/target/branches in one
   contract) at MEDIUM/LOW.
8. Produce `InformationArchitecture`, `NavigationModel`, and
   `SurfaceInventory` only when the task changes grouping, destinations,
   routes, or application surfaces; otherwise omit them.
9. Produce the state/interaction contract, each row/section written as a
   testable assertion (observable trigger, expected user-visible result):
   at HIGH effort as a separate `StateMatrix` (default, active/selected,
   loading/busy, empty, disabled, unsupported, permission missing,
   error/recovery, stale/unknown, reduced motion/contrast) plus a separate
   `InteractionSpecification` (keyboard, focus, assistive-technology,
   localization, motion, copy, validation, responsive layout); at MEDIUM/LOW
   as one `InteractionContract` carrying both per state row. Write
   each behavior as a verifiable assertion so the quality lead can derive
   `AcceptanceTestPlan` entries without design interpretation.
11. Define layout-stability invariants for selection, loading, disclosure,
    navigation, resizing, and recovery.
12. Run a **consistency audit** against the `ConsistencyBaseline`: map each
    new or changed surface to the existing component, token, pattern, or copy
    convention it reuses. Any deviation (novel component, off-scale spacing,
    new terminology, non-standard interaction) must be listed in a
    `DeviationRegister` with a justification; an unjustified deviation is a
    design defect, not a stylistic choice. Reuse beats novelty by default.
13. Identify visual evidence needed: native snapshots, browser captures,
   simulator screenshots, or constrained app-window screenshots. For changed
   surfaces, include at least one side-by-side scenario against a
   sibling surface so consistency is visually verifiable, not asserted.
14. Update durable design/product knowledge through
   `living-project-knowledge`.

## Redesign contract

A redesign must contain:

- current baseline;
- qualities and behaviors to preserve;
- demonstrated or inferred problems;
- current and target journeys;
- surface and navigation changes;
- alternative directions and selection rationale when ambiguity exists;
- complete state and interaction specification;
- incremental migration path;
- before/after behavioral and visual validation.

Do not treat visual restyling alone as a redesign.

## Design rules

- Protect the existing clean surface; do not add controls merely because they
  are easy to expose.
- Use progressive disclosure for advanced or infrequent behavior.
- Prefer native platform patterns before custom interaction.
- Preserve context across mode changes and navigation.
- Make desired, applied, live, stale, fallback, and unknown state visibly and
  verbally distinct.
- Never present unsupported or unverified behavior as success.
- Do not replace accessible standard controls solely for novelty.
- Motion communicates state and must respect reduced-motion settings.
- Every visual interaction needs a non-visual semantic equivalent.

## Deliverable

Produce an experience contract containing:

- `FlowDelta` (MEDIUM/LOW), or `CurrentJourney`+`TargetJourney`+`UserFlow`
  (HIGH);
- `InformationArchitecture`, `NavigationModel`, `SurfaceInventory` — only when
  navigation/IA changes;
- `InteractionContract` (MEDIUM/LOW), or `StateMatrix`+`InteractionSpecification`
  (HIGH);
- `ConsistencyBaseline` (governing design system or de facto conventions) and
  `DeviationRegister` (each deviation with its justification);
- selected `DesignDirection` and `PreserveInventory` for redesigns;
- copy or terminology changes;
- accessibility behavior;
- visual hierarchy and motion guidance;
- snapshot/screenshot scenarios;
- design acceptance criteria, each phrased as a testable assertion tied to the
  story IDs it verifies, so every story gains at least one derivable
  acceptance test;
- explicit non-goals and preserved behavior.

The contract must be implementable without further design questions.
Every design artifact must cite the story IDs it satisfies.
