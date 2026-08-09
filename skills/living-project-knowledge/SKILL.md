---
name: living-project-knowledge
description: Continuously keep a project's product, design, architecture, current-work, backlog, decisions, quality evidence, performance findings, and completed-work documentation synchronized with each major autonomous development stage.
---

# Living Project Knowledge

Maintain repository documentation as operational memory for humans and
agents. Update knowledge after every major stage and completed chunk, not only
at the end.

Operational orchestration state is not automatically repository knowledge.
Store transient manifests, checkpoints, role-selection details, token/turn
telemetry, and run records in session state. Promote only durable product,
design, architecture, quality, and completed-work truth into repository docs.

## Authority and discovery

1. Read repository instructions before editing documentation.
2. Discover existing product, design, architecture, ADR, roadmap, testing,
   workflow, backlog, current-feature, completed-work, and performance docs.
3. Reuse established locations and formats. Do not create a competing
   documentation system.
4. Keep repository docs authoritative over this generic skill.

If the repository has no workflow documentation, create the minimum useful
structure, not a documentation bureaucracy:

- one current-work document;
- one backlog or roadmap document;
- one decision log;
- links to existing product, design, architecture, and testing docs.

## Knowledge model

Maintain these concepts where the repository already stores them:

- **Product truth** - users, jobs, behavior, scope, and success criteria.
- **Design truth** - flows, states, accessibility, interaction, and visual rules.
- **Architecture truth** - boundaries, contracts, invariants, and dependencies.
- **Current work** - active objective, selected story, stage, checklist,
  assumptions, blockers, and next action.
- **Backlog** - prioritized opportunities with evidence, impact, effort, risk,
  and dependency.
- **Decisions** - durable choices, alternatives, rationale, and consequences.
- **Quality evidence** - tests, snapshots, screenshots, runtime checks,
  performance evidence, and limitations.
- **Completed work** - concise outcomes and commit/PR links when available.
- **Known improvements** - non-blocking findings deferred intentionally.
- **Preparation truth** - durable user needs, stories, story map, journeys,
  flows, design decisions, technical contracts, and accepted release slices.

## Stage updates

Update documentation at these boundaries:

1. **Understanding complete** - repository map, current behavior, evidence gaps.
2. **Workflow compiled** - write transient manifest/checkpoint to session state;
   update repository docs only if compilation revealed durable scope or product
   truth.
3. **Discovery complete** - problem frame, user needs, selected story, backlog
   ranking.
4. **Design complete** - journeys, flow, navigation, surfaces, states,
   interaction, accessibility, and visual validation plan.
5. **Strategy ready** - accepted preparation packet, story map, design,
   architecture, traceability, tests, rollback, and release slices.
6. **Implementation milestone complete** - actual behavior, artifact status,
   slice status, and deviations.
7. **QA complete** - evidence, failures, limitations, gate verdict, and whether
   local repair or full replan is required.
8. **Commit complete** - commit identifier and next unblocked work.
9. **Observation complete** - new facts, regressions, and next priority.
10. **Full pass restarted** - superseded artifacts, carried evidence, pass
    counter, and revised workflow manifest.

## Editing rules

- Document current truth, not a transcript of agent activity.
- Write agent-facing documentation per `controlled-language-authoring` (W1–W16).
- Write durable decisions as **distilled, executable guidance**: state the
  rule, its boundary, and the concrete pattern to follow, so a cheaper
  or smaller model can later act on it without re-deriving the reasoning.
  Every well-distilled decision lowers the capability tier future work in
  that area requires.
- Replace stale current-state text instead of endlessly appending status notes.
- Append only durable decisions, evidence, and completed outcomes.
- Reconcile contradictions across docs in the same chunk.
- When you notice a documentation problem **outside** the current chunk's scope
  (duplication, stale section, missing cross-link, contradiction between docs,
  oversized file), do not fix it now: append one line to a `DocDebt` ledger in
  session state (`file | problem | suggested action`).
- Keep docs concise and link to deeper material.
- Skip a stage update when the stage produced no durable change to record. An
  empty update is churn, not truth.
- Use explicit labels for measured, observed, inferred, and unknown claims.
- Never claim tests, screenshots, hardware checks, deployments, or measurements
  that did not occur.
- Keep blocked work and exact unblock conditions visible.
- Do not include secrets, private captured data, or transient local paths unless
  the repository convention requires them.
- Do not paste entire `WorkflowManifest`, `LoopCheckpoint`, or `LoopRunRecord`
  documents into project documentation unless the repository uses an
  execution ledger.

## Consolidation pass

Incremental stage updates accumulate drift; a consolidation pass is the
garbage collector. Run it only when triggered, not every loop:

- `DocDebt` ledger has ≥ 5 entries, **or**
- ~3 milestone commits have landed since the last consolidation, **or**
- the run is ending (alongside harvest-and-dismiss).

One agent (Claude Sonnet 5, low; reuse a warm one if available), documentation
files only. Consume the `DocDebt` ledger plus docs touched this run, then:

- merge duplicated or overlapping sections into one canonical location;
- delete superseded status and stale current-state text;
- add cross-links instead of restating content;
- align terminology across docs;
- **split oversized files**: if a documentation file exceeds ~400 lines,
  split it by topic into linked files and leave a short index in place.

Budget rules: never restructure the documentation system from scratch, never
touch code. A structural problem too big for this pass goes to the backlog.
Output is a standalone `docs:` commit (see below). Clear consumed ledger
entries.

## Commit relationship

Documentation describing a code or behavior change should normally be committed
with that chunk. Pure documentation reconciliation may be its own `docs:`
milestone when independently useful and validated for consistency.

Before milestone commit, ensure:

- current-work status matches reality;
- durable docs match shipped behavior;
- backlog excludes completed work or marks it complete;
- decisions and limitations are recorded;
- next work is unambiguous.
