# Artifact Contracts

Use these named artifacts to preserve traceability across product, design,
engineering, QA, documentation, and commits. Produce only artifacts the
compiled workflow requires.

## Common envelope

Every artifact records:

- ID and type;
- status: draft, accepted, implemented, verified, superseded, or blocked;
- producer and consumers;
- source evidence;
- assumptions and confidence;
- completion criteria;
- repository documentation destination;
- related acceptance criteria, slices, tests, and commits.

## Product artifacts

### ProblemFrame

- Area of interest.
- Affected users and jobs.
- Current behavior.
- Problem or opportunity.
- Evidence level.
- Constraints and non-goals.

### UserNeedSet

- User/group.
- Situation.
- Need or job.
- Current friction.
- Desired outcome.
- Evidence and confidence.

### OpportunityMap

- Only for open-ended discovery with no named area/story yet; otherwise skip
  and record under `omitted_roles_and_stages` for a named-area task.
- Candidate opportunity.
- User impact.
- Confidence.
- Effort classification.
- Risk and dependencies.
- Priority rationale.

### StorySet and SelectedStory

Each story contains:

- user;
- need;
- outcome;
- current/proposed behavior;
- meaningful states;
- acceptance criteria;
- success signal;
- evidence;
- non-goals;
- risks and dependencies.

Stories must be concrete enough to change a flow, state, decision, or
acceptance test. Do not count generic aspirations or implementation tasks as
user stories.

### StoryMap

- Backbone activities ordered across the end-to-end journey.
- User tasks beneath each activity.
- Stories linked to each task.
- Primary, alternate, error, recovery, and expert paths.
- Selected release slice and deferred stories.
- Dependencies and success signals.

### BehaviorContract

Use for technical work with no meaningful product-design change:

- current externally observable behavior;
- intended preserved or corrected behavior;
- affected users and failure impact;
- invariants and non-goals;
- acceptance and regression criteria.

## Experience artifacts

### CurrentJourney and TargetJourney

- HIGH-effort only; MEDIUM/LOW use `FlowDelta` instead.
- Entry condition.
- Ordered user steps.
- User intent and system response at each step.
- Friction, uncertainty, and recovery.
- Exit outcome.

### UserFlow

- HIGH-effort only; its branches fold into `FlowDelta` at MEDIUM/LOW.
- Nodes and decisions.
- Entry/exit conditions.
- System and user actions.
- Error, permission, unsupported, stale, and recovery paths.

### FlowDelta

MEDIUM/LOW default, replacing `CurrentJourney` + `TargetJourney` + `UserFlow`
as separate docs:

- Entry condition; current steps and target steps side by side.
- Decision nodes/branches, including error, permission, unsupported, stale,
  and recovery paths.
- Friction resolved and exit outcome; each branch is a distinct
  `AcceptanceTestPlan` coverage row.

### InformationArchitecture

- Content and capability groups.
- User-intent taxonomy.
- Labels and hierarchy.
- Progressive disclosure rules.

### NavigationModel

- Destinations and routes.
- Transition triggers.
- Back/dismiss behavior.
- Preserved context.
- Keyboard, focus, deep-link, and restoration behavior.

### SurfaceInventory

- Windows, screens, panes, menus, popovers, sheets, dialogs, and notifications.
- Purpose, entry point, ownership, and relationship to other surfaces.

### StateMatrix

For each surface or component (HIGH-effort only; MEDIUM/LOW use
`InteractionContract` instead):

- default;
- active/selected;
- loading/busy;
- empty;
- disabled;
- unsupported;
- permission missing;
- error/recovery;
- stale/unknown;
- offline where relevant;
- reduced motion, increased contrast, keyboard, and assistive-technology state.

### InteractionSpecification

- HIGH-effort only (folds into `InteractionContract` at MEDIUM/LOW).
- Controls and behavior.
- Validation.
- Focus and keyboard.
- Motion and timing.
- Copy and terminology.
- Accessibility semantics.
- Responsive/adaptive behavior.
- Layout-stability rules: controls and content that must not shift unexpectedly
  during selection, loading, resizing, disclosure, or state changes.

### InteractionContract

MEDIUM/LOW default, merging `StateMatrix` + `InteractionSpecification`. One
row per applicable state (default, active/selected, loading/busy, empty,
disabled, unsupported, permission missing, error/recovery, stale/unknown,
offline, reduced motion/contrast/keyboard/assistive-tech), each carrying its
trigger, expected result, controls/validation/copy, focus/keyboard/
motion/layout-stability, and accessibility semantics inline. Every row remains
an `AcceptanceTestPlan` source row, exactly as `StateMatrix` rows are today.

### DesignDirection

- Preserved qualities.
- Problems addressed.
- Alternative directions considered.
- Selected direction and rationale.
- Visual hierarchy and design-system mapping.
- Before/after validation scenarios.

### PreserveInventory

- Existing behavior, content, hierarchy, interaction, accessibility, and visual
  qualities that must remain.
- Why each item matters.
- Allowed degree of change.
- Regression evidence required.

The redesign workflow may embed this in `DesignDirection`, but it must remain a
named, independently reviewable section.

## Technical artifacts

### PreparationPacket

- Effort and intent classification.
- Required product and design artifacts.
- Selected story, release slice, or `BehaviorContract`.
- Technical contract, acceptance test plan, and traceability matrix.
- Scope map and slice graph.
- Validation and commit plan.
- Assumptions, preserved behavior, risks, and non-goals.

No production implementation begins before this packet receives READY.

### TechnicalContract

- Affected components and current control/data flow.
- Proposed interfaces and ownership.
- Invariants.
- Concurrency and lifecycle.
- Persistence, migration, compatibility, and rollback.
- Failure and unknown-state behavior.
- Observability.
- Performance risks and budgets.
- Test seams and fixtures.

### AcceptanceTestPlan

Produced during preparation, after the `TechnicalContract` and before the
`TraceabilityMatrix`. Owned by the quality lead (authoring or reviewing) and
grounded in the design contract's testable assertions.

- One or more named test cases per selected story, written as
  Given/When/Then against user-visible behavior.
- Coverage of every applicable `StateMatrix` row (error, empty, loading,
  recovery, permission, unsupported, stale) and every `UserFlow` branch.
- For a `BehaviorContract`, at least one regression test that reproduces the
  named defect or pins the preserved behavior.
- Each entry: story/criterion IDs covered, test type (unit, integration,
  snapshot, interaction, runtime), intended test file or harness, and the
  reason it should initially fail.
- `untestable_exceptions`: behavior that cannot be automated (for example
  purely visual polish), each with the alternative evidence (snapshot
  scenario, scripted manual check) and a justification. Silent gaps are
  defects.

Rules:

- No story may lack a mapped planned test or a justified exception.
- Planned tests are written and observed to fail for the intended reason
  before the production code that satisfies them (RED before GREEN).
- Weakening or deleting a planned test to make implementation pass requires a
  `ReworkRequest`, not a local edit.

### TraceabilityMatrix

Standalone at HIGH; embedded in `PreparationPacket` at MEDIUM/LOW.

Map:

```text
Need -> Story -> Flow/state -> Technical behavior -> Planned acceptance test
     -> Slice -> Test/evidence -> Commit
```

Every required acceptance criterion must have at least one implementation owner
and one quality signal, and every story must map to an
`AcceptanceTestPlan` entry or justified exception.

### SliceGraph

Standalone at HIGH or multi-slice tasks; embedded in `PreparationPacket`
at MEDIUM/LOW single-slice.

Each slice contains:

- independent outcome;
- artifacts and acceptance criteria covered;
- files/components likely affected;
- dependencies;
- implementation owner;
- tests and visual/runtime evidence;
- documentation updates;
- rollback;
- proposed commit boundary.

## Quality artifacts

### QualityPlan

- Acceptance criteria under test.
- Risk-based test matrix.
- Snapshot/screenshot scenarios.
- Accessibility and runtime checks.
- Performance method.
- Required specialist reviews.

### StrategyReadinessVerdict

- READY: product, design, technical, scope, and validation contracts are
  complete enough to implement without inventing missing behavior.
- REVISE: name missing or contradictory artifacts and their owning role.
- BLOCKED: unavailable evidence or an unsafe unresolved decision prevents honest
  planning.

This verdict is pre-implementation, distinct from final `QualityVerdict`.

### QualityEvidence

- Command/scenario.
- Environment/configuration.
- Result.
- Measured, observed, inferred, or unavailable status.
- Related acceptance criterion.
- Limitations.

### RuntimeParityEvidence

- Whether the snapshot/test harness uses the same hosting, routing, lifecycle,
  and container path as production.
- Differences between harness and production.
- Required live-path checks that close those differences.

### InteractionStabilityEvidence

- Repeated navigation, selection, disclosure, resize, loading, and recovery
  scenarios.
- Before/after geometry or state observations.
- Unexpected layout shifts, focus loss, clipping, or reordering.
- Result for each required window or viewport size.

### QualityVerdict

- PASS, REPAIR, REPLAN, or BLOCKED.
- Blocking findings.
- Non-blocking improvements.
- Owning stage for each finding.
- Full-pass recommendation.

## Operational artifacts

### WorkflowManifest

The compiled execution graph, effort level, pass counter, gates, documentation
targets, commit boundaries, and stop policy.

### ScopeMap

Classify every existing and changed file/hunk as:

- current slice;
- explicitly accepted pre-existing work;
- unrelated user work;
- generated evidence;
- temporary/scratch.

Every commit file must map to exactly one accepted category and one slice.

### LoopCheckpoint

- Workflow ID/version, effort, phase, and pass.
- Completed and pending artifacts/slices.
- Exact files owned and dirty-tree boundaries.
- Tests/evidence completed and still required.
- Commits created.
- Blocking findings and next executable action.

Write one after preparation, each milestone commit, and before any context
handoff or compaction.

### LoopRunRecord

- Repository, session, objective, intent, effort score, and workflow version.
- Selected/omitted roles and stages.
- Full passes, local repairs, user interventions, and continuation events.
- Tests, snapshots, runtime and performance evidence.
- Changed-file and commit summary.
- Termination reason and unresolved limitations.

Store operational telemetry in session state unless repository policy explicitly
maintains an execution ledger.

### MilestoneRecord

- Outcome.
- Artifacts completed.
- Quality verdict.
- Commit subject and identifier.
- Deferred work.

### ObservationRecord

- Post-change behavior.
- New evidence.
- Regression or success signal.
- Backlog changes.
- Whether workflow recompilation is necessary.
