---
name: autonomous-development-loop
description: Run an autonomous end-to-end product and software development loop from a single area of interest. Coordinates product discovery, UX design, technical direction, implementation, living project documentation, testing, screenshots, QA, performance work, and test-gated milestone commits without routine human questions.
---

# Autonomous Development Loop

Act as the operating system for an autonomous five-person product studio. The
human supplies only an area of interest, such as "onboarding", "menu-bar
responsiveness", or "preset reliability". Infer the smallest useful objective
from repository and product evidence, then continue without routine questions.

## Hard sequencing rules (non-negotiable)

These rules bind every model tier, especially cheaper ones. Violating any of
them invalidates the pass.

1. **No production-code edit before a READY verdict.** Reading code is always
   allowed; changing it before `StrategyReadinessVerdict: READY` exists as a
   session-state artifact is a contract violation, no matter how obvious the
   fix looks.
2. **Every stage produces a named artifact file before the next stage starts.**
   Write each required artifact (`WorkflowManifest`, `StorySet`,
   `TechnicalContract`, `PreparationPacket`, verdicts, ...) to session state.
   An artifact that exists only "in the conversation" does not count.
3. **Track stages as todos.** At compile time, insert one row per selected
   stage into the session `todos` table with `todo_deps` mirroring stage
   dependencies. Mark a stage `in_progress` when starting it and `done` only
   when its artifact file exists. Never start a stage whose dependency todos
   are not `done`.
4. **Skipping requires a written justification.** A stage may be omitted only
   when the compiled `WorkflowManifest` lists it under
   `omitted_roles_and_stages` with a rationale. "It seemed unnecessary" during
   execution is not an omission decision; go back to the manifest.
5. **Seeing the fix does not authorize writing it.** When investigation reveals
   an apparently obvious code change, record it in the relevant artifact and
   continue the sequence. The urge to jump straight to code is the primary
   failure mode this loop exists to prevent.
6. **Role invocation means a real sub-agent, not narration.** Invoking any role
   or swarm member requires an actual sub-agent/child-session call with its own
   fresh context, never inline narration in the coordinator's own turn — see
   `model-aware-orchestration` §Delegation mechanics for the full mechanics and
   the post-invocation context-growth check.
7. **The coordinator never writes production code.** Implementation belongs to
   the `autonomous-delivery-lead` sub-agent, always; a repository single-writer
   policy constrains writer concurrency, never who the writer is. Parallel
   writers require isolated worktrees, integrated serially with zero worktrees
   left behind before the loop closes — see `model-aware-orchestration`
   §Delegation mechanics and §Session hygiene for the full single-writer,
   inline-artifact, and worktree-cleanup rules.

## Company model

Invoke `adaptive-workflow-compiler` to classify effort and construct the
task-specific workflow before assigning role work.

Use five accountable capabilities. Instantiate only the roles selected by the
compiled workflow:

1. **Product lead** - invoke `autonomous-product-lead`.
2. **Product designer** - invoke `autonomous-product-designer`.
3. **Technical lead** - invoke `autonomous-technical-lead`.
4. **Delivery lead** - invoke `autonomous-delivery-lead`.
5. **Quality and reliability lead** - invoke `autonomous-quality-lead`.

The coordinator owns prioritization, conflict resolution, integration, and loop
state. Temporary specialist agents may assist with bounded research, tests,
profiling, screenshots, accessibility, security, or review, but they do not
replace the five accountable seats.

Never load all role skills by habit. Compile first, then invoke each selected
role at most once per full pass and reuse that role context for revisions.

## Start contract

The invocation must contain an area of interest. Treat that as sufficient input.

1. Read the repository's authoritative instructions and relevant product,
   design, architecture, testing, workflow, and roadmap documentation.
2. Inspect the current branch, working tree, recent history, active work, and
   existing sessions before proposing new work.
3. When the area of interest is broad or unfamiliar, invoke
   `autonomous-discovery-swarm` before classification. It spawns up to 10
   parallel, read-only gpt-5.6-luna research sessions across distinct angles
   of the area, then consolidates their findings into a `DiscoveryDossier`.
   Skip it only for a target the coordinator already understands precisely
   (a single named file/function). This stage never edits files or commits.
4. Invoke `adaptive-workflow-compiler` before any role skill or production-code
   edit. Classify the request as LOW, MEDIUM,
   or HIGH effort and produce the `WorkflowManifest`, artifact graph, gates,
   selected roles, omitted stages, scope map, slices, commit boundaries, and
   stop policy. When step 3 ran, the compiler classifies from the
   `DiscoveryDossier` instead of a cold start.
5. Invoke `living-project-knowledge` only for durable repository knowledge;
   keep transient manifests and telemetry in session state.
6. Detect the repository's actual workflow:
   - current checkout and current branch;
   - inline-only versus child-session work;
   - package manager and build/test wrappers;
   - snapshot or screenshot facilities;
   - runtime install/relaunch requirements;
   - commit and push policy.
7. Record assumptions instead of asking questions. Prefer the smallest
   reversible interpretation that creates user value.

Repository instructions always override generic defaults. Never create branches,
worktrees, sessions, dependencies, documentation structures, or release actions
that repository guidance forbids.

## Adaptive state machine

The compiled workflow chooses the internal stages. The coordinator runs this
state machine:

```text
QUICK_TRIAGE (coordinator, one cheap judgment)
     LIKELY_LOW_VALUE -> BACKLOG_RECOMMENDATION (stop before spending)
     GENUINE_BREAKAGE -> EXPEDITE_LANE
     PROCEED          -> DISCOVERY_SWARM
DISCOVERY_SWARM (optional, read-only, gpt-5.6-luna)
  -> UNDERSTAND
  -> CLASSIFY_AND_COMPILE
       BEHAVIOR_CONTRACT_PATH -> DIRECT (explicit bypass of DISCOVER/DESIGN,
                                          only per the narrow escape-hatch rules)
  -> PREPARE_STRATEGY
  -> STRATEGY_READINESS_GATE
       REVISE  -> RETURN_TO_OWNING_PREPARATION_STAGE (DISCOVER, DESIGN, or DIRECT)
       BLOCKED -> PARK (record unblock condition) + CONTINUE_INDEPENDENT_WORK
       READY   -> IMPLEMENT_SLICES
  -> INTEGRATE_AND_REVIEW
  -> PERF_SWEEP (optional, manifest-selected)
  -> QUALITY_GATE
       PASS    -> DOCUMENT -> COMMIT -> OBSERVE_AND_PRIORITIZE
       REPAIR  -> RETURN_TO_OWNING_STAGE
       REWORK  -> RETURN_TO_NAMED_UPSTREAM_STAGE -> RE-FLOW_FORWARD
       REPLAN  -> NEXT_FULL_PASS_OR_ASK
       BLOCKED -> PARK (record unblock condition) + CONTINUE_INDEPENDENT_WORK

PARK registry -> reviewed at every OBSERVE_AND_PRIORITIZE
       unblock condition met -> RE-ENTER at the owning stage
EXPEDITE_LANE -> minimal fix -> mandatory post-hoc QA + retroactive artifacts
       -> COMMIT -> OBSERVE_AND_PRIORITIZE
```

Any execution stage (IMPLEMENT, REVIEW, PERF_SWEEP, QA) may also raise a
`ReworkRequest` directly, without waiting for the quality gate, when it
discovers evidence that invalidates an upstream artifact.

Local failures return only to the owning stage. Targeted rework returns to the
earliest invalidated upstream stage and re-flows forward. Restart the complete
workflow only for a REPLAN verdict.

### QUICK_TRIAGE (before spending on the swarm)

Before invoking `autonomous-discovery-swarm`, the coordinator makes one cheap
judgment from available evidence: is this plausibly worth a full
pass, is it an expedite case, or is it likely low value? If likely low value,
produce the backlog recommendation (per the compiler's value/cost check)
using existing evidence only — do not spend the swarm to confirm a rejection.
This avoids burning up to 10 sessions on work the compiler would decline.

### EXPEDITE_LANE (incident fast path)

Real breakage takes a fast path, mirroring real incident response. Entry
criteria — ALL must hold, and the coordinator must record them:

- reproducible breakage of core behavior, a failing build/test on the main
  branch, an active data-loss risk, or a security exposure;
- the fix is plausibly small and behavior-restoring (back to a previously
  known-good contract), not new behavior;
- delay has a real cost (the user or the product is blocked now).

Feature requests, quality expansion, polish, and "while we're here"
improvements never qualify. Abusing the lane to skip preparation is the same
violation as Hard sequencing rule 5.

Procedural debt is repaid immediately after the fix:

- mandatory post-hoc QA validation of the fix (the hard test gate still
  applies), including a regression test that reproduces the incident and now
  passes — added in the same expedite window, not deferred;
- a retroactive `BehaviorContract` recording what was restored and why;
- an entry in the `LoopRunRecord` marking the expedite, its justification,
  and any follow-up work discovered;
- if the "small fix" grows beyond restoring known-good behavior, stop and
  route the work through the normal pipeline.

### PARK registry (blocked work re-entry)

Blocked items are parked, never abandoned: each PARK entry records the exact
unblock condition and owning stage. The coordinator reviews the registry at
every OBSERVE_AND_PRIORITIZE; when an unblock condition is met, the item
re-enters at its owning stage with its retained artifacts. Parked items that
stay blocked across a full pass are surfaced in the completion report instead
of silently accumulating.

## Strategy-first rule

The loop has two phases:

1. **Preparation** - understand, discover, create stories and story map, design
   journeys/flows/UI/navigation, direct technical strategy, define slices, and
   pass the strategy gate.
2. **Execution** - implement only the READY preparation packet, then review,
   validate, document, and commit.

During Preparation:

- do not edit production code;
- do not create implementation commits;
- do not let delivery agents infer missing product or design behavior;
- preserve a clear chain from user need to implementation evidence.

The mandatory preparation chain (ProblemFrame through StrategyReadinessVerdict
READY), the story-count-by-effort targets, and the narrow `BehaviorContract`
escape hatch — including the quality-expansion/polish exclusion — are defined
once by `adaptive-workflow-compiler` §Mandatory preparation policy. The loop
enforces whatever chain and role selection the compiler emits in the
`WorkflowManifest`; it does not re-derive them.

## Workflow manifest and effort

Treat the `WorkflowManifest` as the live execution contract:

- LOW effort uses the smallest artifact set and normally one writer and one
  milestone.
- MEDIUM effort uses explicit product/design/technical contracts for affected
  concerns and may use several slices.
- HIGH effort uses the full relevant role set, dependency graph, baseline,
  alternatives, rollback, specialist reviews, and plan-first risky slices.

Do not run stages merely because they exist in this skill. Every stage must
produce a required artifact, decision, or quality signal in the manifest.

The manifest must preserve traceability:

```text
User need -> story -> journey/flow/state -> technical behavior
          -> planned acceptance test -> implementation slice
          -> test/evidence -> commit
```

Persist the manifest and artifact statuses in session-state checkpoints.
Persist only durable decisions and current truth
through `living-project-knowledge`.

## Stage library

The following stages are reusable modules selected and ordered by the compiled
workflow. New features, redesigns, navigation work, bug fixes, refactors,
migrations, and performance work use different subsets and dependencies.

### 1. UNDERSTAND

- If `autonomous-discovery-swarm` ran, start from its `DiscoveryDossier`
  instead of re-deriving context from scratch, including its external
  `DomainResearch` and `TechnicalApproaches` sections when present.
- Build a concise repository, product, and user-context map.
- Identify current behavior, known limitations, relevant metrics, and active
  work.
- Establish what is measured, observed, inferred, and unknown.
- Update project knowledge before proceeding.

### 2. DISCOVER

When the manifest selects product discovery, invoke
`autonomous-product-lead`. Otherwise use the compiler-approved
`BehaviorContract`.

- Generate user needs, jobs, friction points, stories, and measurable outcomes.
- Develop the effort-appropriate `StorySet` and arrange it into a `StoryMap`
  before selecting the release slice.
- Include design, reliability, maintainability, and performance opportunities.
- Rank candidates by user value, confidence, effort, risk, and dependency.
- Select one vertical slice, not a broad theme.
- Update the backlog and current-work documentation.
- Produce the named product artifacts required by the manifest, such as
  `ProblemFrame`, `UserNeedSet`, `OpportunityMap` (only for open-ended
  discovery, not a named area/story), `StorySet`, and `StoryMap` and
  `SelectedStory`.

### 3. DESIGN

When user behavior, UI, navigation, interaction, accessibility, or product
meaning changes, invoke `autonomous-product-designer`. Do not invoke it for a
purely technical behavior-preserving slice.

- Map the current and proposed user flow.
- Define states, edge cases, accessibility, platform conventions, and visual
  validation needs.
- Protect existing product simplicity and use progressive disclosure.
- Update product/design documentation with durable decisions.
- For redesign work, baseline the current experience, record what must be
  preserved, compare alternative directions, and define incremental migration.
- Produce the required journey, flow, information architecture, navigation,
  surface, state, interaction, and design-direction artifacts.
- Derive every design decision from one or more selected stories. Do not design
  disconnected screens or controls.

### 4. DIRECT

Invoke `autonomous-technical-lead` for MEDIUM/HIGH work and LOW work with
nontrivial architecture or risk. For established-pattern LOW correction, the
coordinator may produce a compact `TechnicalContract`.

- Map the affected architecture and data/state flow.
- Decide the smallest correct implementation shape.
- Include tests, migration, rollback, observability, performance, and error
  behavior.
- Separate prerequisite refactors only when they reduce implementation risk.
- Update architecture and decision documentation.

### 5. PLAN_SLICE

The coordinator owns and combines product, design, and technical contracts into
one `PreparationPacket` — embedding `TraceabilityMatrix` and `SliceGraph` as
sections at MEDIUM/LOW with one slice, standalone at HIGH or multi-slice work
per `adaptive-workflow-compiler`'s artifact contracts — containing:

- user problem and expected outcome;
- scope and explicit non-goals;
- user flow and all meaningful states;
- files and architectural boundaries;
- acceptance criteria;
- the `AcceptanceTestPlan` entries the slice must turn green, each traced to
  its stories and states;
- required unit, integration, snapshot, screenshot, runtime, accessibility, and
  performance validation;
- documentation changes;
- commit boundary and proposed conventional commit type;
- dependencies and rollback.
- artifact and acceptance-criterion coverage for every slice.

The brief must be independently executable without access to earlier chat.

### 5A. STRATEGY READINESS GATE

Invoke `autonomous-quality-lead` in pre-implementation mode. It reviews the
`PreparationPacket`, not code, and returns:

- **READY** - implementation can proceed without inventing missing user,
  interaction, architecture, scope, or validation decisions.
- **REVISE** - return named artifacts to their owning preparation role.
- **BLOCKED** - record the exact missing evidence or unsafe decision.

The coordinator may not invoke `autonomous-delivery-lead` until READY.

### 6. IMPLEMENT

Invoke `autonomous-delivery-lead`.

Entry checklist — the canonical, binary-checkable gate is
`references/quick-reference-card.md` §BEFORE-DELEGATE (C1-C7). Run it
mechanically before the first code edit and abort to the owning stage if any
item fails; do not re-derive or duplicate the checklist here.

- Follow repository session and branch policy.
- Work test-first per the `AcceptanceTestPlan`'s RED-before-GREEN rule (see
  `adaptive-workflow-compiler`'s `references/artifact-contracts.md`
  §AcceptanceTestPlan for the rule; see `autonomous-delivery-lead` for the
  execution steps).
- Verify and refresh the compiler's `ScopeMap` before editing, keeping unrelated
  dirty-tree work outside the active slice.
- Keep one writing agent per overlapping code surface.
- Use read-only agents for independent research or review.
- Implement the whole vertical slice, including tests and documentation hooks.
- Run targeted validation during development.
- Update current knowledge after each meaningful implementation milestone.
- Write a `LoopCheckpoint` after preparation, each milestone commit, and before
  context handoff or compaction.

### 7. REVIEW

Use independent, read-only review appropriate to the change:

- design/interaction review for UI changes;
- code review for correctness, regressions, concurrency, and error handling;
- security review only when security-sensitive behavior is changed;
- architecture review for cross-cutting or migration work.

Classify findings:

- **blocking** - violates the original objective, corrupts data, creates a crash
  or security problem, breaks an acceptance criterion, or invalidates evidence;
- **non-blocking** - optional robustness, style, speculative edge cases, or
  unrelated cleanup.

Only blocking findings reopen implementation. Cap review/fix convergence at
three rounds. Record remaining non-blocking improvements and stop.

The three review rounds and the quality lead's three repair rounds are separate
budgets. If their combined total reaches five, stop and mark the slice blocked.

### 7B. PERF_SWEEP (optional)

After review converges and before QA, if the manifest selects it, invoke
`autonomous-micro-sweep` in **performance mode**, scoped strictly to the
surfaces the slice touched (plus their direct hot paths). Select this stage
when the slice touched rendering, loops over data, I/O, startup, or other
plausibly hot code; omit it for trivial or non-performance-relevant slices.

- The swarm hunts only safe, behavior-preserving micro-optimizations;
  anything needing measurement to justify or architectural change becomes a
  backlog finding, not a change.
- The sweep's consolidated diff goes through the same review classification
  as stage 7 (blocking/non-blocking, within the same combined budget cap).
- Hand the combined result (slice + surviving optimizations) to QA as one
  increment: QA validates behavior preservation and, where the repository
  supports measurement, verifies claimed wins.

### 8. QA AND PERFORMANCE

Return to the quality lead's retained context from the strategy gate; do not
reload the skill.

- Run the smallest relevant checks first, then the broader required suite.
- Reconcile the `AcceptanceTestPlan`: every planned test executed and green,
  every justified exception backed by alternative evidence. Unreconciled
  entries block PASS.
- Exercise unit, integration, snapshot, visual, accessibility, runtime, and
  performance gates selected for the slice.
- Require reproducible evidence for performance work.
- Never accept tests as the sole UI signal or screenshots as a substitute for
  behavioral tests.
- Require a traceability matrix from acceptance criteria to flow/state,
  implementation, and evidence.
- Required tests must actually execute and pass. Static analysis is not a
  substitute for an unavailable required test.
- For UI work, verify production-host parity and repeated interaction/layout
  stability, not only isolated snapshots.

### 9. DOCUMENT

Invoke `living-project-knowledge`.

Reconcile current work, backlog, decisions, product behavior, architecture,
quality evidence, known limitations, and follow-up opportunities. Documentation
must describe current truth, not merely narrate implementation.

Out-of-scope documentation problems go to the `DocDebt` ledger, not this
stage. When a trigger in `living-project-knowledge` §Consolidation pass fires
(ledger ≥ 5, ~3 milestones since last consolidation, or run end), schedule the
consolidation pass as its own `docs:` chunk.

### 10. COMMIT

Invoke `validated-milestone-commit`.

Before invoking it, run `references/quick-reference-card.md` §BEFORE-COMMIT
(K1-K7) — the canonical gate; `validated-milestone-commit` owns the full
commit mechanics. Commit each completed major chunk only when its required
checks pass. That chunk's documentation belongs in the same
commit unless repository conventions require a separate documentation commit.

### 11. OBSERVE AND PRIORITIZE NEXT

- Verify the fresh runtime or deployed artifact when supported by repository
  tooling.
- Capture post-change evidence and compare it with the original objective.
- Add new facts and opportunities to project knowledge.
- Select the next highest-value safe slice and repeat.
- Produce an `ObservationRecord` containing post-change evidence, regressions,
  success signals, and whether workflow recompilation is needed.
- Review the PARK registry: re-enter any item whose unblock condition is now
  met at its owning stage; report items still blocked.
- Do not start a slice that modifies files carrying uncommitted changes from a
  blocked slice. Finish, revert, or isolate that work first according to
  repository policy.
- When no remaining slice clears the value/risk bar for a full preparation
  pass but the repository would still benefit from a cheap cleanup, invoke
  `autonomous-micro-sweep` instead of closing the loop. Treat its
  `MicroSweepReport` findings as new backlog input rather than as a full-pass
  replan.

## Quality-driven full-pass iteration

Use three levels of correction:

### Local repair

When the framing, story, flow, design, and technical contract remain correct,
return only to the stage that owns the defect. Local repair does not increment
the full-pass counter.

### Targeted rework (mid-execution recursion)

Use when execution finds evidence that invalidates one or more upstream
artifacts, but the overall problem framing and selected story remain correct.
Typical triggers: implementation reveals the designed flow is technically
infeasible; a performance blocker requires a different interaction or data
shape; review exposes a wrong technical contract; QA finds a state the design
never specified.

Protocol:

1. The discovering stage raises a `ReworkRequest` naming the **earliest**
   upstream stage whose artifact is invalidated (DISCOVER, DESIGN, DIRECT, or
   PLAN_SLICE), the invalidated artifacts, the new evidence, and what remains
   valid.
2. The coordinator routes the request to that stage's **retained role
   context** — do not reload the role skill. The role updates only the
   invalidated artifacts, marks superseded versions rather than deleting
   them, and preserves everything the evidence did not touch.
3. Work then re-flows through every downstream stage that consumes a changed
   artifact. Reopen those stage todos (and dependents) so sequencing rules
   keep holding. Unchanged artifacts are not re-derived.
4. If the `PreparationPacket` changed, the strategy gate must re-verify it
   (delta review in the quality lead's retained context, not a full re-gate).
5. Implementation already committed for this slice stays committed only if
   still valid; otherwise the rework includes reverting or amending it per
   repository policy before re-flowing.

Budget: at most **two targeted reworks per slice**. A third rework signal
means the slice was mis-framed: escalate to REPLAN or mark the slice blocked.
Targeted
rework does not increment the full-pass counter, but every
`ReworkRequest`, its trigger, and its outcome must be recorded in the
`LoopRunRecord`.

### Full replan

When final quality shows that the problem framing, selected story, target
journey, user flow, design direction, architecture, or slicing was materially
wrong, accept a `REPLAN` verdict from `autonomous-quality-lead`.

1. A REPLAN verdict during pass 1 starts pass 2 at UNDERSTAND and increments
   `pass.current`.
2. Carry forward evidence and mark invalid artifacts superseded.
3. Reinvoke `adaptive-workflow-compiler` and execute pass 2.
4. Pass 2 is the final automatic full pass.
5. Never start pass 3 automatically.
6. If pass 2 still returns REPLAN or otherwise fails the required quality bar,
   use `ask_user` once to ask whether to continue. Include:
   - what remains below quality;
   - why two passes did not resolve it;
   - the proposed third-pass approach;
   - expected effort and risk;
   - a recommended continue/stop choice.
7. Each human continuation authorization grants exactly one additional full
   pass. If that pass remains below quality, ask again rather than continuing
   indefinitely.

Do not consume a full pass for optional polish or non-blocking findings. Stop as
soon as the requested outcome and required gates pass.

## What counts as a major chunk

A major chunk is the smallest coherent change that:

- delivers an independently understandable behavior, refactor, test
  infrastructure improvement, or measured optimization;
- has complete tests for its changed contract;
- leaves the repository buildable and internally consistent;
- updates relevant project knowledge;
- can be honestly described by one conventional commit subject.

Do not commit half-implemented behavior, knowingly failing checks, temporary
debugging, speculative scaffolding, or a mixture of unrelated work.

## Autonomous decision policy

Do not ask the human about ordinary implementation, naming, file placement,
test selection, refactoring mechanics, or reversible UX details.

The only routine-loop exception is the continuation decision after two complete
autonomous passes remain below the required quality bar.

When evidence is incomplete:

1. choose the smallest reversible option consistent with existing patterns;
2. record the assumption and confidence;
3. add validation or instrumentation;
4. continue.

When work requires credentials, unavailable hardware, destructive data changes,
material equipment risk, production access, or an irreversible product choice:

1. mark only that item blocked;
2. record the evidence, recommended action, and exact unblock condition;
3. continue with independent work;
4. do not simulate completion or repeatedly ask the human.

## Agent and model policy

Invoke `model-aware-orchestration` before delegating, including its mandatory
delegation-mechanics section. Prefer retained context and few agents over large
swarms, but every role stage and every swarm member still runs as a real
sub-agent or child session — never as inline narration in the coordinator's
own context. Concretely: use a sub-agent call (background mode by default, so
the coordinator keeps moving; sync only for work small enough to block
on) for in-repo role work, and a genuine child project session for cross-repo
or PR-sized work. Launch disjoint swarm members in the same batch of calls.

- Product/UX judgment: design-capable model.
- Difficult architecture or adversarial review: high-capability reasoning model.
- Sustained implementation/debugging: repository-aware coding model.
- Mechanical checks, test execution, and narrow inventory: faster model.

Use `lean-orchestrate` unless repository guidance or the user explicitly
requires PR stacks. Reuse current sessions and branches. Parallelize only
disjoint work with clear ownership.

### AgentRegistry (warm-agent reuse)

Maintain an `AgentRegistry` in session state (a small table or artifact):
`role | agent_id | scope | model | last_commit_seen | tasks_done | status`.
Update it at every launch, completion, and retirement. Before delegation,
consult the registry and apply `model-aware-orchestration` §Delegation
protocol's warm-agent reuse and staleness rules in full — an idle agent with
the same role and overlapping scope gets a follow-up message, not a cold
relaunch. Role revisions in the same pass ("send revisions back to the
existing role context") are the mandatory case of this rule, not an exception
to it.

### Harvest and dismiss (end of loop)

Idle agents left behind at the end of a run are leaked resources and stale-
context hazards for the next run. Before the completion report: walk the
registry, collect any unconsumed findings or open observations from still-idle
agents (one short final message each, only where the agent plausibly holds
something unreported), fold them into `OBSERVE AND PRIORITIZE NEXT`, then
consider every agent retired and the registry closed. Never carry a previous
run's idle agents into a new loop pass — the new pass starts from the
registry's recorded outcomes, not from stale conversations.

Keep product -> design -> technical preparation sequential for their decision
artifacts. One bounded exception: once the `StorySet`/`SelectedStory` is
stable, the technical lead may begin **architecture reconnaissance only**
(tracing affected paths, invariants, existing patterns) in parallel with
design — like a staff engineer running feasibility alongside the designer.
The `TechnicalContract` itself is still produced only after the design
artifacts exist. Do not re-invoke a role skill in the same pass; send
revisions back to the existing role context.

### Slice pipelining (HIGH effort only)

For HIGH-effort work with a `SliceGraph` whose slices are provably disjoint
(no shared files, no dependent contracts), the coordinator may start
implementing slice N+1 while slice N is in QA — like a pipeline. Conditions:

- one writer per surface still holds absolutely;
- a REPAIR/REWORK verdict on slice N that could touch slice N+1's files or
  contracts immediately pauses N+1;
- commits remain per-slice and test-gated; no combined commits across
  pipelined slices;
- at most two slices in flight. Fall back to sequential the moment either
  slice needs more than one coordinator message per sub-agent turn to keep
  N and N+1 off each other's files (judgment call on the trend, not a
  precise threshold — see `model-aware-orchestration` for the full
  reasoning).

## Completion report

At the end of each loop, report:

- effort score and pass number;
- stories and selected release slice;
- preparation-gate verdict;
- implemented slices and commits;
- tests, snapshots, runtime, accessibility, and performance evidence;
- documentation updated;
- omitted stages and unresolved limitations.

Update the session-state `LoopRunRecord` with user interventions, local repairs,
full replans, and termination reason. Also record per-stage routing telemetry:
which model/effort ran each stage, escalations and their triggers, gate
verdicts, and whether cheap-tier output survived downstream gates unchanged.
This telemetry is raw material for tuning routing rules and skill
guardrails in later passes; without it the system cannot learn from its own
runs.

## Swift and Apple-platform adapter

When the repository is a Swift or macOS app:

- invoke `swift-app-repo-guide` first;
- invoke `swiftui-ux-conventions` and `swiftui-apple-polish` for UI work;
- invoke `swiftui-performance-research` for performance work;
- invoke `macos-menubar-app-packaging` for menu-bar, activation, bundle, or
  signing concerns;
- invoke `swiftui-rebuild-relaunch` after app-code changes when the fresh app
  must be run;
- prefer repository `Tools/` wrappers over hand-written build/test/install
  commands;
- use repository-native snapshot tests before desktop screenshots.

## Stop conditions

Stop the loop when:

- no safe, valuable, unblocked slice remains;
- the area objective is satisfied and additional work is lower value than its
  risk or complexity;
- three repair attempts fail for the same root cause and no independent
  unblocked slice remains; otherwise mark that slice blocked and continue;
- repository or environment constraints prevent further honest validation.
- pass 2 remains below quality and the human declines another pass.

Leave project knowledge accurate, completed chunks committed, failed or blocked
work uncommitted, and the working tree free of abandoned scratch changes.
