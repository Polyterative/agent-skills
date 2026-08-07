---
name: adaptive-workflow-compiler
description: Autonomously classify a requested product or engineering task as low, medium, or high effort and compile a task-specific workflow from reusable discovery, story, journey, flow, design, architecture, implementation, QA, documentation, and commit stages. Use standalone to plan work or inside autonomous-development-loop before execution.
---

# Adaptive Workflow Compiler

Turn an area of interest or concrete task into an executable development
workflow. Do not force every request through the same pipeline. Select only the
stages, artifacts, specialists, gates, and iteration budget required to produce
a high-quality result.

## Hard ordering rule

Compile the workflow before invoking any role skill. Do not edit production code
until the compiled preparation phase is complete and its
`StrategyReadinessVerdict` is READY.

Read these references before compiling:

- `references/artifact-contracts.md`
- `references/workflow-recipes.md`
- `references/workflow-examples.md` — load only if the recipes alone leave
  the classification or chain shape ambiguous.

## Inputs

Use whatever is available:

- the user's area of interest or requested change;
- repository product, design, architecture, testing, workflow, and roadmap docs;
- current behavior, working-tree state, recent commits, and active work;
- existing tests, snapshots, screenshots, telemetry, benchmarks, and issues;
- repository restrictions on branches, sessions, commits, tools, and runtime.

Do not ask routine scoping questions. Infer the smallest reversible objective,
label assumptions, and preserve unknowns.

## Effort classification

Score five dimensions from 0 to 2:

| Dimension | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Breadth | One local behavior or file cluster | Several files or one complete surface | Cross-cutting, multi-surface, multi-package, or multi-repo |
| Product/design novelty | Existing behavior with an obvious correction | New states, flow changes, or bounded design work | New journey, redesign, navigation/IA change, or ambiguous product direction |
| Technical risk | Established pattern, reversible | New abstraction, concurrency, persistence, or integration | Migration, privilege/security boundary, hardware/protocol, destructive or difficult rollback |
| Validation burden | Focused automated checks | Broader suite plus snapshots/runtime | Multi-environment, performance baseline, hardware, migration, safety, or extensive visual evidence |
| Coordination | One agent and one coherent chunk | Multiple roles or sequential slices | Several dependent workstreams, specialist reviews, or coordinated repositories |

Classify the total:

- **LOW: 0-2**
- **MEDIUM: 3-6**
- **HIGH: 7-10**

Apply these minimum overrides:

- Any redesign, navigation/IA change, persistence migration, or measured
  performance project is at least MEDIUM.
- Security-sensitive, destructive-data, safety-critical, unknown hardware or
  protocol, and coordinated multi-repo work is HIGH.
- Do not inflate effort because a repository is large when the affected surface
  is narrow and well understood.

Record the score, evidence, uncertainty, and override in the manifest. Effort is
an execution-control classification, not a time estimate.

## Effort behavior

### LOW

- Prefer one coherent implementation path and one writer.
- Use only artifacts necessary to make the changed contract explicit.
- Invoke product or design roles only when behavior or UI meaning changes.
- For product or UI behavior, produce 1-3 substantive stories and one primary
  flow. A purely technical correction may use a `BehaviorContract` instead.
- Produce a compact `AcceptanceTestPlan`: at least one named test per story
  (or the regression test for a `BehaviorContract`), written and failing
  before the production change.
- Run focused checks plus the repository-required broader gate.
- Usually one milestone commit.

### MEDIUM

- Produce explicit product/design/technical contracts for affected concerns.
- For product or UI behavior, produce 5-12 substantive stories, a `StoryMap`,
  current and target journeys, and complete affected flows.
- Produce an `AcceptanceTestPlan` covering every selected story and every
  applicable `StateMatrix` row; implementation is test-first against it.
- Include current and target flow when user behavior changes.
- Use design and code review where applicable.
- Split work into independently validated slices when useful.
- Usually one to three milestone commits.

### HIGH

- Use the full relevant role set and explicit dependency graph.
- For broad product work or redesign, produce 12-30 substantive stories grouped
  into a `StoryMap`, unless the user specifies an exact count.
- Require baseline evidence, alternatives, migrations, rollback, observability,
  and specialist reviews appropriate to the risk.
- Produce a complete `AcceptanceTestPlan` before implementation; every story,
  state, and recovery path has a named planned test, and risky slices may not
  start until their planned tests exist and fail for the intended reason.
- Use plan-first execution for risky or cross-cutting slices.
- Parallelize only independent read-only research or disjoint implementation.
- Commit only stable, test-gated milestones.

## Workflow manifest

Produce a `WorkflowManifest` containing:

```yaml
workflow_id:
objective:
intent_classes: []
phase: PREPARATION | EXECUTION | VALIDATION
effort:
  level: LOW | MEDIUM | HIGH
  score:
  rationale:
  uncertainty:
pass:
  current: 1
  autonomous_maximum: 2
assumptions: []
preserved_behavior: []
non_goals: []
selected_roles: []
omitted_roles_and_stages: []
execution_policy:
  writer: autonomous-delivery-lead
  coordinator_may_edit: false
  max_concurrent_writers: 1         # >1 requires isolation: worktree + disjoint scopes
  isolation: shared-tree            # shared-tree | worktree
  parallel_scopes: []               # when writers >1: one disjoint file-scope entry per writer
  inline_artifacts_allowed: false   # true only for the LOW compressed chain
artifacts:
  - id:
    type:
    producer:
    consumers: []
    completion_criteria: []
stages:
  - id:
    owner:
    inputs: []
    outputs: []
    entry_criteria: []
    exit_criteria: []
    required: true
dependencies: []
parallel_groups: []
strategy_gate:
  status: PENDING | READY | REVISE | BLOCKED
scope_map:
slices: []
test_plan:
  acceptance_test_plan:
  story_test_coverage:
  untestable_exceptions: []
quality_gates: []
commit_boundaries: []
documentation_targets: []
stop_conditions: []
blocked_item_policy:
checkpoint_path:
run_record_path:
```

The manifest is the execution contract. The coordinator may adapt it when new
evidence appears, but must record why.

## Intent classification

Classify one or more intents:

- new feature;
- restoration of previous behavior;
- redesign;
- existing-flow improvement;
- navigation or information architecture;
- bug or recovery;
- refactor;
- migration;
- performance or micro-optimization;
- accessibility;
- reliability or observability;
- research or evidence spike;
- maintenance or tooling.

Compose recipes when several intents apply. For example, a redesign with a
responsiveness problem combines redesign artifacts with performance baseline and
measurement stages.

## Mandatory preparation policy

For new features, redesigns, existing-flow changes, navigation/IA, accessibility,
and broad product areas, the workflow must produce:

```text
ProblemFrame
-> UserNeedSet
-> StorySet
-> StoryMap
-> SelectedStory or selected release slice
-> CurrentJourney
-> TargetJourney
-> UserFlow
-> affected IA/navigation/surfaces/states/interactions
-> TechnicalContract
-> AcceptanceTestPlan
-> TraceabilityMatrix
-> SliceGraph
-> PreparationPacket
-> StrategyReadinessVerdict
```

The compiler may not remove these stages merely to save effort. It may compress
their representation for LOW work.

Pure bug, refactor, maintenance, or performance work that does not change user
meaning may replace the full product chain with a `BehaviorContract`. This
escape hatch is narrow — it applies only when ALL of the following hold:

- observable user behavior, copy, and UI are provably unchanged;
- the request names a specific defect or technical change, not an area;
- no judgment about what users need is required to do the work.

Requests phrased as quality expansion, polish, hardening, improvement, or
"make X better" for an area or feature are **product work**, not technical
work: deciding what "better" means requires typical use cases and stories.
When in doubt, or when the request is an area of interest rather than a named
defect, default to the full preparation chain. If user behavior, copy,
workflow, or UI changes during investigation, expand the workflow to the full
preparation chain before implementation.

When the escape hatch legitimately applies, compile the bypass explicitly:
the workflow's preparation phase starts at technical direction (DIRECT) with
the `BehaviorContract` as its input artifact, and the manifest lists DISCOVER
and DESIGN under `omitted_roles_and_stages` with the escape-hatch rationale.
The strategy readiness gate still runs on the resulting packet. The bypass
never removes the `AcceptanceTestPlan`: at minimum it contains one regression
test that reproduces the named defect (or pins the preserved behavior) and
must fail before the fix is written.

Story counts are coverage targets, not filler quotas. Each story must represent
a distinct user goal, state, recovery path, or meaningful variation. If the user
requests an exact count, produce exactly that count.

Fall below an effort range only when the `StoryMap` demonstrably covers all
applicable primary, alternate, error, recovery, empty/loading/permission, and
expert paths. Record the coverage rationale in the manifest.

## Role selection and invocation budget

- Record selected and omitted roles before loading role skills.
- Do not invoke all five roles by default.
- LOW: invoke at most one of product/design unless behavior meaning requires
  both. Technical direction may be a compact coordinator artifact for an
  established-pattern correction or use the technical lead when risk warrants
  it. Delivery and quality remain execution gates.
- At LOW, the coordinator or single selected product/design role may produce the
  compressed combined preparation chain; separate role invocations are not
  required merely because the artifacts have distinct names.
- MEDIUM: invoke only roles owning required artifacts.
- HIGH: use the full relevant role set, not automatically every role.
- Invoke a role skill at most once per full pass. Reuse its existing context for
  revisions and local repairs.
- The quality role handles both strategy readiness and final QA in the same
  retained context; do not reload the skill between gates.
- Product, design, and technical preparation are sequential for their decision
  artifacts because they depend on one another. Launching DESIGN before the
  `StorySet` and `SelectedStory` exist, or DIRECT's `TechnicalContract` before
  the design artifacts exist, is a compile violation — "time constraints" or a
  desire to parallelize never authorize running decision stages concurrently.
  One exception: technical **reconnaissance** (tracing affected paths,
  invariants, existing patterns — strictly read-only, producing no decision
  artifact) may run in parallel with design once the story selection is
  stable; the `TechnicalContract` still follows the design artifacts.

## Compilation procedure

1. Establish current truth, historical behavior, dirty-tree scope, and
   repository constraints without editing production code.
2. Classify intent and effort.
3. Record a compact value/cost estimate: expected user value, confidence, and
   the approximate preparation-plus-execution cost the classification implies.
   When value is clearly low relative to cost and risk, do not compile the
   full workflow — return a backlog recommendation with the evidence instead,
   and let the caller decide. This check must stay cheap: one coordinator
   judgment, not a delegated analysis.
4. Select the nearest recipes from `references/workflow-recipes.md`.
5. Select roles and explicitly record omitted roles/stages with rationale.
6. Remove optional stages that produce no required artifact or evidence, while
   preserving the mandatory preparation policy.
7. Add prerequisite stages for unknowns, migrations, safety, or baseline
   evidence.
8. Build the artifact dependency graph.
9. Assign each stage to one accountable role, and record the
   `execution_policy`: writer is `autonomous-delivery-lead`, coordinator may
   not edit production code, `max_concurrent_writers`/`isolation`/
   `parallel_scopes` follow the manifest's own field comments. Single-writer
   concurrency, worktree isolation, and integration/cleanup are governed in
   full by `model-aware-orchestration` §Delegation mechanics and §Session
   hygiene — this step only records the resulting fields, it does not
   re-derive the policy.
10. Define scope ownership, slice, review, QA, documentation, and commit
    boundaries.
11. Define quality-driven repair and full-pass iteration behavior.
12. Record a compact manifest and `LoopRunRecord` in session state before role
    invocation, and insert one todo per selected stage into the session
    `todos` table with `todo_deps` mirroring stage dependencies. These todos
    are the loop's enforcement backbone: a stage whose todo dependencies are
    not `done` must not start.
13. Check that every need and acceptance criterion maps through story, flow,
    design, planned acceptance test, implementation, evidence, and commit.

## Manifest storage

Keep operational manifests, checkpoints, and run telemetry in session-state
artifacts by default. Write only durable product, design, architecture, and
quality truth into repository documentation. Do not make project docs carry
transient orchestration noise.

## Iteration and termination

The compiler supports three kinds of iteration (canonical definitions and
routing mechanics: `autonomous-development-loop` §Quality-driven full-pass
iteration):

### Local repair

Use when the workflow and contracts remain correct but implementation or
evidence fails. Return only to the owning stage. This does not increment the
full-pass counter.

### Targeted rework (mid-execution recursion)

Use when a specific upstream artifact (a contract, a design decision, a slice
plan) is found materially wrong during execution while the overall framing
holds. Return to the named upstream stage via a `ReworkRequest`, re-run only
the dependent stages, and do not increment the full-pass counter.

### Full replan pass

Use when final quality shows the problem framing, selected story, user flow,
design direction, architecture, or slice plan was materially wrong or
incomplete.

- A REPLAN verdict during pass 1 starts pass 2 from UNDERSTAND and increments
  `pass.current`.
- Carry forward all evidence and explicitly supersede invalid artifacts.
- Pass 2 is the final automatic full pass.
- After pass 2, never start pass 3 automatically.
- If quality still does not pass, use `ask_user` once to ask whether to continue.
  Include the remaining gap, why two passes did not resolve it, expected next
  approach, effort/risk, and a recommended choice.
- Each human continuation authorization grants exactly one additional full pass.
  If that pass also fails, ask again rather than continuing indefinitely.

Do not trigger a full pass for optional polish or non-blocking findings. The
system stops when the requested outcome and required quality gates pass, not
when no conceivable improvement remains.

## Standalone completion

When invoked only to plan, return:

- effort classification;
- workflow manifest;
- artifact graph;
- stage and dependency graph;
- expected milestone commits;
- iteration and stop policy;
- assumptions and blocked risks.

Do not implement unless the caller also requested execution.
