---
name: validated-milestone-commit
description: Commit each completed major development chunk after required tests, QA, documentation, and runtime or visual checks pass, using precise one-line conventional commits and repository-specific git rules. Proactive inside autonomous-development-loop; otherwise use only when the user asks to commit a validated chunk.
---

# Validated Milestone Commit

Commit a completed autonomous-development chunk only after its required gate
passes. This skill is proactive inside `autonomous-development-loop`; it does not
require separate human requests for each commit.

## Preconditions

Do not commit until all seven hold. These are the canonical kill items (also
mirrored as K1-K7 in `autonomous-development-loop`'s
`references/quick-reference-card.md` for pause-point use inside the loop);
this file owns their mechanics.

1. **K1** `git diff --staged --stat` file/hunk list is a subset of
   `ScopeMap[milestone]` — no unmapped file or hunk staged.
2. **K2** The strategy gate's `StrategyReadinessVerdict` reads READY.
3. **K3** The repository's declared focused-test command exits `0`.
4. **K4** The repository's declared broader/required-suite command exits `0`,
   or is explicitly marked not-applicable per written repository policy.
5. **K5** Every `AcceptanceTestPlan` entry is green, or carries a named
   `justified_exception`: `COUNT(status != 'green' AND justified_exception IS
   NULL) == 0`.
6. **K6** `living-project-knowledge`'s last-updated marker is newer than this
   milestone's start checkpoint.
7. **K7** Repository instructions were re-read this turn and confirmed to
   permit a commit in the current context (branch, worktree, and push policy).

Procedure note (judgment calls, not gates — apply before staging, not as a
pass/fail check): confirm the chunk is coherent enough for one honest
conventional-commit subject to describe it, and that no temporary
debugging, generated junk, or unrelated edit rides along — K1's ScopeMap
match is the objective backstop, but a human-legible single subject
line is still worth a sanity read.

If a required check fails, return work to the owning role. Never commit a
known-failing milestone to save progress.

## Workflow

1. Read repository commit rules.
2. Inspect `git status`, unstaged diff, and staged diff.
3. Identify the exact files and hunks belonging to the chunk.
4. Reconcile every file/hunk against `ScopeMap`; reject unmapped or multi-slice
   changes.
5. Confirm unrelated user work will remain untouched.
6. If the diff contains multiple independently describable outcomes or mixes
   accepted pre-existing work with the active slice, split it before staging.
   A large diff is not automatically wrong, but it requires an explicit
   scope-integrity review.
7. Stage only the chunk. Never use a blanket add when unrelated changes exist.
8. Create one single-line conventional commit:
   - `feat:` for user-facing capability;
   - `fix:` for corrected behavior;
   - `refactor:` for behavior-preserving structure;
   - `perf:` for evidenced optimization;
   - `test:` for test infrastructure or coverage;
   - `docs:` for standalone documentation truth;
   - `chore:`, `build:`, or `ci:` where accurate.
9. Use an imperative, lowercase description with no trailing period.
10. Follow repository attribution rules. The user's default is no generated-by or
   co-author attribution.
11. Verify the commit and remaining working tree. If the milestone involved
    parallel worktrees, verify the commit is reachable from the main branch
    and `git worktree list` shows no leftover worktrees from this work: a
    commit stranded on a worktree branch does not count as a milestone.
12. Produce a `MilestoneRecord` containing the outcome, completed artifacts,
    quality verdict, commit subject and identifier, and deferred work.
13. Invoke `living-project-knowledge` to record the completed milestone if the
    repository keeps a completion ledger; if that update creates a meaningful
    follow-up docs-only change, commit it only if repository conventions favor
    a separate ledger commit. Create at most one follow-up docs-only commit per
    milestone, and never record that docs commit as a new ledger entry.

## Boundaries

- Never amend unless required by repository workflow or requested by
  the human.
- Never push unless the active repository policy or current request
  authorizes it.
- Never create or switch branches merely to commit.
- Never discard unrelated user changes.
- If one honest subject cannot describe the staged work, split it into multiple
  validated milestones.
- Never commit with `test-unavailable`.

## Handoff

Report the commit subject and identifier, the validated behavior it contains,
and any remaining blocked or uncommitted work. Keep the report concise.
