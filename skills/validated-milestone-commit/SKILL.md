---
name: validated-milestone-commit
description: Commit each completed major development chunk after required tests, QA, documentation, and runtime or visual checks pass, using precise one-line conventional commits and repository-specific git rules. Proactive inside autonomous-development-loop; otherwise use only when the user asks to commit a validated chunk.
---

# Validated Milestone Commit

Commit a completed autonomous-development chunk only after its required gate
passes. This skill is proactive inside `autonomous-development-loop`; it does not
require the human to ask separately for each commit.

## Preconditions

Do not commit until all are true:

1. The chunk is coherent and independently understandable.
2. Its acceptance criteria are satisfied.
3. Required focused tests pass.
4. Required broader tests pass.
5. Required snapshot, screenshot, accessibility, runtime, migration, safety, or
   performance checks pass or are explicitly not applicable.
6. `living-project-knowledge` has reconciled relevant documentation.
7. No temporary debugging, generated junk, or unrelated edits are included.
8. Repository instructions allow commits in the current context.
9. The active `WorkflowManifest`, `SliceGraph`, and traceability records mark the
   milestone's required artifacts and gates complete when those records exist.
10. The strategy gate is READY and every staged file/hunk maps to the milestone
    in `ScopeMap`.
11. Required tests actually executed and passed. `unavailable`, static review,
    or build-only evidence does not satisfy this condition.

If a required check fails, return work to the owning role. Never commit a
known-failing milestone merely to save progress.

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
13. Invoke `living-project-knowledge` to record the completed milestone when the
    repository keeps a completion ledger; if that update creates a meaningful
    follow-up docs-only change, commit it only when repository conventions favor
    a separate ledger commit. Create at most one follow-up docs-only commit per
    milestone, and never record that docs commit itself as a new ledger entry.

## Boundaries

- Never amend unless explicitly required by repository workflow or requested by
  the human.
- Never push unless the active repository policy or current request explicitly
  authorizes it.
- Never create or switch branches merely to commit.
- Never discard unrelated user changes.
- If one honest subject cannot describe the staged work, split it into multiple
  validated milestones.
- Never commit with `test-unavailable`.

## Handoff

Report the commit subject and identifier, the validated behavior it contains,
and any remaining blocked or uncommitted work. Keep the report concise.
