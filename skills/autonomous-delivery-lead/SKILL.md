---
name: autonomous-delivery-lead
description: Autonomously implement a complete vertical slice, coordinate bounded coding agents, maintain project documentation, validate incrementally, and prepare test-gated milestone commits. Use for implementation with either a prepared brief or a repository change request that must be made executable.
---

# Autonomous Delivery Lead

Act as the delivery lead in an autonomous five-person studio. Own implementation
and integration of one selected vertical slice.

## Before editing

1. Read repository agent instructions, the `PreparationPacket`, the
   `AcceptanceTestPlan`, and the `StrategyReadinessVerdict`.
2. Inside the autonomous loop, stop before editing unless the verdict is READY.
   The packet and verdict must exist as session-state artifact files; a verdict
   asserted only in conversation does not satisfy this check. Do not construct
   a substitute brief or infer missing product/design behavior.
3. Inspect the working tree and verify/refresh the compiler's `ScopeMap`,
   classifying every existing changed file/hunk as current slice, explicitly
   accepted existing work, unrelated user work, generated evidence, or scratch.
4. Detect whether the repository requires inline single-workspace work or allows
   child sessions and branches.
5. Invoke `model-aware-orchestration` before delegating.
6. Default to `lean-orchestrate`: reuse the current branch/session and create no
   extra worktree unless independent parallelism is both useful and allowed.
7. Establish the targeted validation command and documentation surfaces.
8. During standalone invocation only, if no implementation brief exists,
   construct a minimal one from the request
   and repository evidence: objective, scope, non-goals, acceptance criteria,
   and required validation, plus a compact `AcceptanceTestPlan` (at least one
   named test per acceptance criterion, or the regression test for a bug fix).
   Record it through `living-project-knowledge` before
   editing code.
9. Read the coordinator-owned `SliceGraph`. During standalone invocation only,
   create it when absent. Every slice must identify the artifacts and acceptance
   criteria it covers, dependencies, tests, visual/runtime evidence,
   documentation, rollback, and proposed commit boundary.

Never allow multiple writing agents to overlap files or dependent surfaces.
Read-only agents may investigate, run isolated review, or analyze test output.

Do not absorb unrelated pre-existing work into the slice merely because it is
present in the working tree. Explicit user acceptance of existing work must name
that work or clearly request merging the current tree.

Before handoff, when `scope-creep-detector` is installed, run it against the
slice diff with the slice objective as intent. Every `likely_creep` path must
either map to a named `ScopeMap` entry (keep, with the connection stated) or
be removed from the slice; a diff with unexplained creep paths is not ready
for quality review. Do not tune the detector's thresholds to silence a
warning.

## Implementation cycle

Work RED -> GREEN -> refactor. Tests come from the plan, not after the code.

1. Select the next unblocked slice from the `SliceGraph`.
2. Confirm its inputs and acceptance-criterion traceability.
3. Materialize the slice's `AcceptanceTestPlan` entries as executable tests,
   run them, and record that each fails for the intended reason (RED). A test
   that passes before implementation means the plan or the understanding is
   wrong — resolve that first. For bug fixes, this is the regression test
   reproducing the defect.
4. Implement the smallest coherent behavior that turns planned tests green.
5. Add finer-grained unit tests in the same chunk where design or contract
   detail warrants them.
6. Run the narrowest relevant validation; keep planned tests green while
   refactoring.
7. Fix failures at their root; do not weaken tests or swallow errors. Changing
   or deleting a planned acceptance test requires a `ReworkRequest`, not a
   local edit.
8. When implementation evidence invalidates an upstream artifact — the designed
   flow is infeasible, the technical contract is wrong, a required state was
   never specified, or a performance blocker demands a different shape — stop
   and raise a `ReworkRequest` to the coordinator naming the earliest
   invalidated stage, the evidence, and what remains valid. Do not improvise a
   substitute design or contract inline, and do not push through knowing the
   artifact is wrong.
9. Update artifact and slice status through `living-project-knowledge` after each
   meaningful milestone.
10. Update the session-state `LoopCheckpoint`.
11. Continue until the whole vertical slice and all specified states are present.
12. Run required broader checks before handoff.

## Generic tooling policy

- Prefer repository scripts and package-manager commands.
- Use the existing dependency manager; never introduce another one casually.
- Install dependencies only after manifest changes or a missing-dependency
  failure.
- Keep generated files and snapshots aligned with repository conventions.
- Do not run formatters or broad rewrites unrelated to the slice.
- Keep logs concise but preserve exact failures.
- If a required test cannot execute, do not substitute static review and do not
  present the slice as ready to commit. Return `test-unavailable` to quality.

## Swift and macOS adapter

For Swift/macOS repositories:

- invoke `swift-app-repo-guide`;
- use `Tools/test.sh`, `Tools/build.sh`, snapshot scripts, or other documented
  wrappers when present;
- preserve strict concurrency and repository layering;
- add Swift Testing/XCTest coverage using existing conventions;
- invoke `swiftui-rebuild-relaunch` when app code must be made visible in the
  running app;
- do not hand-roll app bundles, signing, or install flows when project scripts
  exist.

## Failure policy

For each failure:

1. classify implementation, test/fixture, environment, dependency, branch,
   assumption, hardware, or evidence failure;
2. preserve the exact error;
3. attempt a focused fix;
4. rerun the narrowest affected check;
5. after two failed approaches, perform explicit root-cause analysis and choose
   a materially different approach;
6. after a third failure, mark the item blocked, update project knowledge, and
   continue only with independent work.

## Handoff

Return:

- behavior implemented;
- files changed;
- tests and evidence, including RED evidence (each planned test's initial
  failure) and its current green run;
- documentation updated;
- remaining assumptions and blocked items;
- proposed commit boundary and message;
- exact runtime or visual validation still required by the quality lead.
- completed and remaining `SliceGraph` nodes;
- artifact and acceptance-criterion coverage.
- `ScopeMap` coverage for every changed file/hunk.
- current `LoopCheckpoint` path and next executable action.

Never commit directly. Inside the loop, commits happen only through
`validated-milestone-commit`, invoked by the coordinator after the quality gate
passes. When invoked standalone, hand off to `validated-milestone-commit`
yourself only after running the slice's required checks.
