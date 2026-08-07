---
name: autonomous-micro-sweep
description: Run a low-cost swarm of up to 10 parallel gpt-5.6-luna bug-hunt sessions over disjoint focus areas of a repository, each finding and committing one small fix (or returning a proposed patch when repository policy forbids sub-agent writes), then consolidate all results in a single final review-and-commit pass. Also runs in performance mode as the loop's PERF_SWEEP stage, hunting safe micro-optimizations on slice-touched surfaces after review and before QA. Use standalone for a quick low-cost bug sweep, or inside autonomous-development-loop when no high-value slice remains or a slice needs a performance pass.
---

# Autonomous Micro-Sweep

Act as a cheap, high-parallelism bug-hunting sweep. Unlike
`autonomous-development-loop`, this skill does not run product/design/technical
preparation. It exists to catch small, localized, mechanical bugs across a
repository at very low cost, then consolidate the results into one safe,
reviewed commit (or a small set of them).

Two phases: **SWARM** (parallel, cheap, disjoint) then **CONSOLIDATION**
(single session, accountable for the final result).

## Write-policy modes

Before partitioning, read the repository's authoritative instructions and
select exactly one mode. Record the selected mode and its evidence in the
`MicroSweepReport`.

- **COMMIT mode (default).** Each swarm sub-agent applies and commits its own
  fixes in its owned area. Use only when repository policy permits multiple
  writers or provides isolated checkouts/worktrees per sub-agent.
- **PROPOSE-ONLY mode.** Mandatory when the repository declares a
  single-writer rule (e.g. "only one agent may modify files at a time"),
  requires sub-agents to be read-only, or offers a single shared working tree
  with worktrees forbidden. Swarm sub-agents never edit or commit: the hunt
  stays fully parallel and read-only, and each sub-agent returns a
  `ProposedFixSet` instead of commits. Consolidation becomes the single
  accountable writer and applies the patches serially.

The parallelism this skill pays for lives in the hunt, not the apply: serial
application in PROPOSE-ONLY mode costs little and buys incremental
validation — when a patch breaks the build, it is immediately attributable.
Never resolve the conflict the other way (letting sub-agents write anyway);
repository guardrails outrank skill defaults.

`ProposedFixSet` (one per sub-agent, replacing commits in PROPOSE-ONLY mode):

- per fix: diagnosis, severity, exact patch as a unified diff against the
  current tree, files touched, the narrowest validation command expected to
  prove it, and residual risk;
- unresolved findings, exactly as in COMMIT mode;
- no working-tree modification of any kind, including scratch files inside
  the repository.

## When to use

- Standalone: the user asks for a quick sweep, cleanup pass, or "find small
  bugs" across a repository or a named area.
- Inside `autonomous-development-loop`: in `OBSERVE_AND_PRIORITIZE_NEXT`, when
  no remaining slice clears the value/risk bar for a full preparation pass but
  the repository would still benefit from a low-cost pass.
- Inside `autonomous-development-loop` as the `PERF_SWEEP` stage (performance
  mode): after implementation review converges and before QA, scoped to the
  slice's touched surfaces.

Do not use this skill for feature work, redesigns, architecture changes, or any
change that alters user-facing meaning. It is bug-fixing and small correctness
work only. If a sub-agent discovers that a "bug" is actually a product/design
question, it must flag it as a finding, not fix it.

## Performance mode

When invoked as the loop's `PERF_SWEEP` stage (or explicitly asked for a
performance pass), run the same two-phase structure with these overrides:

- **Target**: micro-optimizations instead of bugs — redundant computation,
  avoidable allocations, unnecessary copies, O(n^2) on growing data,
  repeated scans replaceable by a cursor/index, redundant re-renders or
  layout passes, needless synchronous I/O on hot paths.
- **Scope**: only the surfaces touched by the current slice plus their direct
  hot paths, partitioned disjointly as usual. Not a whole-repo hunt unless
  explicitly requested.
- **Safety bar (stricter than bug mode)**: a sub-agent may apply an
  optimization only when behavior preservation is self-evident from the code
  (no semantic change, no ordering/timing contract affected) AND the win is
  plausible without instrumentation. Anything needing a benchmark to justify,
  or touching concurrency, caching semantics, or data freshness, becomes a
  finding — never a change.
- **Evidence discipline**: consolidation applies
  `autonomous-quality-lead`'s performance policy (and
  `swiftui-performance-research` for Apple-platform repos): claimed wins that
  the repository can measure should be measured there; unmeasurable ones must
  be self-evidently free.
- Commit rule, model policy (Luna, medium, max 10, no escalation), and
  single-consolidation-commit rule are unchanged.

## Phase 1: SWARM

### Partition

When the target scope is broad or unfamiliar, invoke
`autonomous-discovery-swarm` first to map the repository/area, then derive the
partition from its `DiscoveryDossier` instead of guessing blind. For a small or
already-well-understood scope, partition directly.

Divide the target scope into up to 10 **disjoint** focus areas before
launching anything, following `model-aware-orchestration`'s ownership rule: no
two sessions may own overlapping files. Prefer partitioning by:

- feature area or UI surface (e.g. "settings panel", "pagination", "forms and
  dialogs");
- subsystem or package boundary;
- or, for a small repo, by concern (accessibility, error handling, state
  management, performance-adjacent bugs) rather than by file, if file-based
  partitioning would be too fine-grained.

Fewer than 10 sessions is fine when the repository or scope does not support
10 disjoint areas — size the swarm to the scope (a focused sweep of one
subsystem may need only 3–4 sessions; parallelism buys latency, not lower
cost). Do not force a partition that creates overlap. This swarm earns its
cost because every fix is checked by a deterministic verifier (build, lint,
tests) — keep each focus area on surfaces where such a check exists, and let
anything unverifiable become a finding instead of a fix.

### Kickoff contract (identical shape for every sub-agent)

Every sub-agent receives, at minimum:

1. Read the repository's authoritative instructions
   (AGENTS.md/CONTRIBUTING/etc.) first and follow them strictly (package
   manager, commit policy, push policy, layering rules).
2. The selected write-policy mode (COMMIT or PROPOSE-ONLY), stated
   explicitly by the coordinator — the sub-agent does not choose.
3. Its exact focus area and the files/surfaces it owns. It must not touch
   files outside that boundary.
4. Instruction to find real, concrete, low-risk bugs in that area only —
   not speculative, cosmetic, or style issues.
5. In COMMIT mode: instruction to apply the minimal correct fix per bug
   found. In PROPOSE-ONLY mode: instruction to stay strictly read-only and
   express every fix as a `ProposedFixSet` patch instead.
6. **Mandatory clean-tree rule (COMMIT mode)**: before finishing, the
   sub-agent must leave a clean working tree for the files it touched —
   either committed with one conventional-commit message per coherent fix,
   or fully reverted if it could not reach a safe, complete fix. Never end
   the session with uncommitted edits sitting in the working tree. In
   PROPOSE-ONLY mode the equivalent rule is zero working-tree modification.
7. Instruction to report: bugs found, files touched, commit hash(es) per fix
   (or the `ProposedFixSet`), anything it found but did not fix (with
   reason), and residual risk.

### Model policy (fixed, not delegated)

- Every swarm sub-agent runs on **gpt-5.6-luna, effort medium**, unconditionally.
  Do not escalate model or effort within the swarm phase even if a sub-agent
  struggles — a struggling sub-agent should mark its item as a finding
  instead of a fix (see Escalation below).
- This overrides the general model-routing guidance in
  `model-aware-orchestration` for this skill specifically: the swarm's value
  is breadth at minimal cost, not depth.

### Escalation instead of forcing a fix

If a sub-agent finds a bug that looks nontrivial, risky, cross-cutting, or
ambiguous in intent, it must not attempt a forced fix. It records the bug as
an unresolved finding with severity and rationale, and leaves that file
untouched. When the suspect code looks deliberate — a workaround, a marked
"temporary" construct, or an odd guard — the sub-agent (or consolidation)
should check its history with `commit-archaeologist` (when installed) before
treating it as a bug: history showing an intentional fix or revert turns the
item into a finding with that evidence attached, not a change.
Consolidation decides what happens to these findings (see below).

### Parallel execution rule

Launch all selected sub-agents as real sub-agent calls in the same batch of
tool invocations — never narrated inline (full delegation mechanics:
`model-aware-orchestration` §Delegation mechanics). In COMMIT mode each
sub-agent commits its own fix directly; in PROPOSE-ONLY mode it returns only
its `ProposedFixSet`. Either way the coordinator's context grows only by the
short report, never the full working transcript. Cap at 10 concurrent
sessions per sweep pass. If the environment cannot spawn a real sub-agent,
say so explicitly and fall back to a smaller, honestly-sequential sweep
instead of simulating parallel fixes inline.

## Phase 2: CONSOLIDATION

Run as a single accountable session after all swarm sub-agents complete. In
PROPOSE-ONLY mode this session is the sweep's only writer.

0. **PROPOSE-ONLY apply loop**: take the collected `ProposedFixSet`s and
   apply them one at a time — apply one patch, run its narrowest stated
   validation, then either keep it or revert it cleanly before touching the
   next. Reject any patch that no longer applies to the current tree, fails
   validation, or exceeds the minimal/low-risk bar. Never batch-apply
   unvalidated patches. After the loop, proceed with the steps below exactly
   as if the surviving fixes were sub-agent commits.
1. Collect every sub-agent's commits (via `git log`/`session_refs`, not by
   re-reading full diffs blindly) and every unresolved finding.
2. Deduplicate: if two sub-agents fixed overlapping or contradictory things
   (should not happen if partitioning was disjoint, but verify), keep the
   correct one and drop or revert the other.
3. Discard or flag for revert any fix that:
   - is not actually minimal/low-risk;
   - lacks any plausible validation path;
   - contradicts repository conventions found during read of AGENTS.md-equivalent
     docs.
4. Run the smallest relevant validation for the combined change set (targeted
   tests/build for touched surfaces). Invoke `autonomous-quality-lead` in
   post-hoc mode (reviewing the accumulated working-tree/commit diff, not a
   `PreparationPacket`) when the repository has a required test/build gate.
5. Produce the final commit(s) via `validated-milestone-commit`:
   - prefer squashing the sweep's many small commits per sub-agent into one
     coherent commit per logical fix when repository convention favors small
     commit counts, otherwise keep them as-is if the repository favors granular
     history;
   - never open one PR per sub-agent; the consolidation owns exactly one
     PR/commit set per sweep pass.
6. Turn every unresolved finding into a backlog entry via
   `living-project-knowledge` (or the repository's own backlog convention) —
   do not silently drop them.
7. Produce a `MicroSweepReport`:
   - focus areas swarmed and sub-agent count;
   - bugs found / fixed / discarded / escalated as findings;
   - commits produced (final, consolidated);
   - validation run and result;
   - cost signal (approximate turns/sessions used) vs value found, so the
     human can judge whether the next sweep is worth running.

## Guardrails

- **Respect the repository's write policy.** When AGENTS.md-equivalent docs
  declare single-writer or read-only sub-agents, PROPOSE-ONLY mode is
  mandatory; letting swarm sub-agents write anyway is a contract violation
  even if every fix is correct.
- **No dirty working trees at handoff.** Every swarm sub-agent must commit or
  revert before finishing (COMMIT mode) or leave the tree untouched
  (PROPOSE-ONLY mode). A sweep pass that leaves any uncommitted edits in
  the working tree has failed its contract, regardless of how many bugs it
  found.
- **Disjoint ownership only.** Never let two sub-agents in the same pass own
  overlapping files.
- **One consolidated commit surface, not N.** Fragmented per-sub-agent PRs are
  an anti-pattern this skill exists to avoid.
- **Fixed cheap model in the swarm phase.** Do not let sub-agents self-escalate
  to a stronger model; they escalate to "finding" status instead.
- **No product/design decisions.** A sub-agent that finds a genuine UX/product
  question must report it as a finding, not resolve it unilaterally.
- **Cap at 10 parallel sessions** per pass to keep review load and noise
  bounded.

## Relationship to autonomous-development-loop

This skill is a lightweight, optional companion stage, not a replacement for
the loop's preparation/implementation/QA pipeline:

- Invoke it directly from `OBSERVE_AND_PRIORITIZE_NEXT` when the loop has no
  remaining high-value slice but the repository would benefit from a cheap
  cleanup pass.
- Route the consolidation phase's commits through the same
  `validated-milestone-commit` and `living-project-knowledge` skills the loop
  already uses, so sweep results stay consistent with ordinary loop output.
- Do not use it to substitute for `adaptive-workflow-compiler` classification
  on anything beyond LOW-effort, behavior-preserving bug fixes. If a sweep
  finding turns out to require product/design/technical preparation, hand it
  to the full loop instead of fixing it inside the sweep.

## Completion report

At the end of a sweep, report to the user:

- number of focus areas and sub-agents used, all on gpt-5.6-luna;
- write-policy mode used (COMMIT or PROPOSE-ONLY) and the repository evidence
  that selected it;
- bugs fixed vs. escalated as findings vs. discarded;
- final consolidated commit(s);
- validation evidence;
- whether the working tree is clean;
- a short recommendation on whether another sweep pass is worth running soon.
