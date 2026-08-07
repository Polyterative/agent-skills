---
name: lean-orchestrate
description: Coordinate multi-step or multi-repo work while minimizing new worktrees/branches. Default to working inline on the current repo's real shared branch and reusing already-open sessions; spawn a new session only for genuine parallelism the user explicitly wants. Never invent random branch or commit names.
---

# Lean Orchestrate

A coordination skill tuned for an operator who works on each repo's shared
long-lived branch and does NOT want a pile of worktree folders to manage. Invert
the usual "one session = one branch = one PR" default: **inline-first,
shared-branch-first, reuse-first.** This applies to every project — never assume
a specific branch name; detect the repo's real one.

## Prime directive

Do the work in the CURRENT session on the CURRENT branch unless there is a
concrete, present need for parallelism. Every new session is a new worktree
folder the user has to manage — treat spawning one as a cost, not the default.

## Decision order (stop at the first that fits)

1. **Single repo, no parallelism needed → do it inline.** Never spawn a session
   for a normal change, a research question about the current repo, or a
   multi-file edit. Just make the change on the existing branch.
2. **Multi-repo, sequential → reuse the already-open session per repo.** Before
   creating anything, run `list_sessions_and_chats` and route each repo's work
   to the session already open for it via `send_session_message`. Do not create
   a second session for a repo that already has one.
3. **Multi-repo, no open session for a repo → create ONE session per missing
   repo, on its real branch** (see branch rules). This is the only routine
   reason to create a session.
4. **Genuine parallel fan-out the user explicitly asked for → spawn independent
   sessions.** Only when tasks truly run at the same time AND the user wants
   that. Otherwise prefer sequential inline work.
5. **Explore an alternative without disturbing current work → fork_session.**
   Only on explicit request; call out that it creates another worktree.

If more than one path seems to apply, pick the one that creates the fewest new
worktrees.

## Branch rules (no surprise branches, works for any repo)

- **Default to the repo's real working branch — detected, not assumed.** For any
  session you must create, set `base_branch` to that repo's canonical branch so
  work lands where the user actually commits. Determine it per repo, in this
  order:
  1. an open session for that repo already on a real branch → match it;
  2. the branch the user is currently on / referenced;
  3. the repo's default branch from `list_projects` or its git config
     (`develop`, `main`, `master`, `trunk`, etc. — whatever that repo uses).
- **Never leave a session on an auto-generated branch** (e.g. `stunning-enigma`,
  `psychic-sniffle`) when the intent is to work on the repo's real branch.
- **Only create a NEW branch when the user explicitly asks.** If they do, ask for
  the name (or propose a conventional one and confirm) — never accept a random
  generated name silently.
- **State each session's repo + branch in your plan** before spawning, e.g.
  "session in <repo> on <branch>", so the user is never surprised by where work
  lands.

## Naming rules (never "a terrible name")

- **Never invent throwaway commit messages** like
  `chore(workspace): save current work`. Commits follow the user's convention: a
  single-line conventional-commits message (`feat: …`, `fix: …`, `chore: …`)
  that describes the actual change.
- If you cannot summarize the change in one honest conventional line, that's a
  signal to split the commit, not to write a vague catch-all.
- Respect each repo's own commit rules (e.g. some repos forbid the
  Co-authored-by trailer) — check `AGENTS.md`/repo instructions before committing.

## Synchronizing work back (the part that usually hurts)

- When you DO delegate to sessions, create them coordinated
  (`coordinate_with_creator: true`, `notify_on_idle: "once"`) so results return
  without you polling.
- **Hand off, end your turn, wait for the idle notification.** Never block on
  sleep/watch loops.
- On completion, pull each session's result together and give ONE consolidated
  summary: what landed, in which repo, on which branch, at which commit.
- Prefer finishing and committing on the shared branch over leaving work
  stranded in a side worktree the user then has to reconcile.

## Cleanup

- After a spawned session's work has landed and been summarized,
  `archive_session` it so the sidebar and worktree list stay short.
- If you forked to explore and the alternative is rejected, archive the fork.

## When NOT to use this skill

- Nothing to coordinate and nothing to build — just answer.
- The user explicitly wants the full stacked-PR / one-branch-per-layer workflow;
  use the built-in `orchestrate` skill instead. This skill deliberately biases
  the other way.
