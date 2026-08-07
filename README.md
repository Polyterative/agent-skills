# agent-skills

An autonomous multi-agent development-loop skill system for [GitHub Copilot CLI](https://docs.github.com/copilot). It turns Copilot CLI into a self-directed product + engineering team: a coordinator drives a workflow compiler, which assigns bounded work to five role skills, backed by discovery/sweep swarms and a handful of support skills for orchestration, documentation, and commit hygiene.

## What's here

- **Coordinator**: `autonomous-development-loop` — runs the end-to-end loop from a single area of interest: discovery, design, technical direction, implementation, documentation, testing, QA, and a test-gated commit.
- **Workflow compiler**: `adaptive-workflow-compiler` — classifies requested work as low/medium/high effort and compiles a task-specific workflow from reusable stages (discovery, story, journey, flow, design, architecture, implementation, QA, documentation, commit).
- **Delivery**: `autonomous-delivery-lead` — implements a vertical slice, coordinates bounded coding agents, keeps docs in sync, validates incrementally, prepares milestone commits.
- **Five role skills**:
  - `autonomous-product-lead` — needs, opportunities, stories, acceptance criteria, backlog.
  - `autonomous-product-designer` — journeys, flows, IA, accessibility, visual hierarchy, state design.
  - `autonomous-technical-lead` — architecture, refactoring, migration, testability, security, performance direction.
  - `autonomous-quality-lead` — strategy readiness review and risk-based QA (unit, integration, snapshot, screenshot, accessibility, runtime, performance, regression).
  - `living-project-knowledge` — keeps product/design/architecture/backlog/decisions/QA/perf docs synchronized with each stage.
- **Swarms**:
  - `autonomous-discovery-swarm` — up to 10 parallel read-only research sessions that explore a repo from distinct angles before planning.
  - `autonomous-micro-sweep` — up to 10 parallel bug-hunt sessions, each committing one small fix (or a proposed patch), then a consolidated review pass. Also runs in performance mode as a loop stage.
- **Support skills**:
  - `lean-orchestrate` — coordinates multi-step/multi-repo work while minimizing new worktrees/branches; reuses open sessions.
  - `model-aware-orchestration` — model/effort selection and context-preserving delegation policy for sub-agents.
  - `validated-milestone-commit` — commits a completed chunk only after tests, QA, docs, and runtime/visual checks pass, using precise conventional commit messages.

## Architecture overview

- **Artifact-gated state machine**: the loop advances stage-to-stage only when the current stage produces its required artifact (brief, stories, design spec, architecture direction, implementation, QA report, docs update). No stage starts on an incomplete predecessor.
- **ATDD chain**: acceptance criteria are authored by the product role before implementation and used by the quality role as the pass/fail contract for QA, so behavior is validated against intent rather than against the implementation itself.
- **Single-writer delegation**: for any given file/slice, one agent owns the write at a time; sub-agents doing independent research or sweeps run in parallel, but code changes to the same surface are never delegated concurrently to two writers.
- **Warm-agent reuse**: idle background agents are messaged with follow-ups (`write_agent`) instead of being re-spawned, preserving their context and avoiding redundant re-discovery.
- **Message protocol**: coordinator ↔ role and coordinator ↔ swarm communication follows a consistent shape — bounded scope, complete context up front (agents are stateless per invocation unless kept warm), and a structured result (status, artifact location, findings, follow-ups) rather than free-form narration.

```
autonomous-development-loop (coordinator)
        │
        ├─ adaptive-workflow-compiler  (classify + compile stage plan)
        │
        ├─ autonomous-discovery-swarm  (parallel read-only research)
        │
        ├─ role skills (single-writer per stage)
        │     autonomous-product-lead → autonomous-product-designer →
        │     autonomous-technical-lead → autonomous-delivery-lead →
        │     autonomous-quality-lead
        │
        ├─ autonomous-micro-sweep      (bug/perf sweep between stages)
        │
        ├─ living-project-knowledge    (docs kept in sync throughout)
        │
        └─ validated-milestone-commit  (test-gated commit at the end)

support: lean-orchestrate, model-aware-orchestration
```

## Install / usage

These are [Copilot CLI skills](https://docs.github.com/copilot). To use them locally, symlink or copy the `skills/` contents into `~/.copilot/skills/`:

```bash
# symlink each skill (recommended, keeps this repo as source of truth)
for d in skills/*/; do
  name="$(basename "$d")"
  ln -s "$(pwd)/$d" "$HOME/.copilot/skills/$name"
done
```

or copy them if you prefer an independent snapshot:

```bash
cp -R skills/* ~/.copilot/skills/
```

Copilot CLI will pick up each `SKILL.md` (and its `references/`) automatically once present under `~/.copilot/skills/`.

## Status

This is a living system that evolves continuously as the skills are used and refined in practice. A `benchmarks/` section (task suites and before/after evidence for the loop and its role skills) is planned but not yet present.

## License

MIT — see `LICENSE`.
