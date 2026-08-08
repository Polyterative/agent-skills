# Skill-set benchmark

Measures the **effectiveness and resource cost** of the skill set in this repo when run
through Copilot CLI. Every run is tagged with the repo commit, so you can compare skill-set
versions over time, and A/B skills-on vs skills-off.

## How it works

- Each task in `tasks/<name>/` has a `prompt.md`, an optional `fixture/` starting repo, and
  a deterministic `grade.sh` that prints a 0–100 score.
- `run.sh` copies the fixture to a temp dir, runs `copilot -p` non-interactively with a
  pinned session UUID, grades the outcome, then reads exact usage (input/output tokens,
  AI credits, request count, turns) for that session from Copilot's local
  `session-store.db`.
- Results append to `results/runs.jsonl`; `report.sh` summarizes by
  (skill-set commit, variant, model).

## Usage

```bash
# full suite, skills-on (your real ~/.copilot with this repo's skills symlinked)
bench/run.sh --model claude-sonnet-4.6

# baseline without any skills (isolated COPILOT_HOME, auth via `gh auth token`)
bench/run.sh --model claude-sonnet-4.6 --variant skills-off

# single task, cheap model, custom label
bench/run.sh --task fix-bug --model claude-haiku-4.5 --label smoke

# summary table
bench/report.sh
```

## Metrics per run

| field | source |
|---|---|
| `score` (0–100) | task `grade.sh` (tests pass, hidden acceptance checks, structural rules, files untouched) |
| `input_tokens` / `output_tokens` / `cache_read_tokens` | `assistant_usage_events` in session store |
| `credits` | `total_nano_aiu / 1e9` (real AI credit cost) |
| `turns` / `requests` | session store |
| `wall_seconds`, `exit_code` | runner |
| `skillset_commit` + `skillset_dirty` | `git rev-parse` of this repo |

`report.sh` also derives **score per credit** — the headline efficiency number.

## Tasks

| task | axis | key checks |
|---|---|---|
| `fix-bug` | debugging | provided tests pass, test file untouched |
| `slugify-feature` | feature + self-written tests | hidden acceptance checks, agent's own tests pass, existing code untouched |
| `refactor-god-function` | refactoring discipline | behavior preserved, AST check: ≥4 functions, ≤15 lines each, signature stable |

## Adding a task

```
tasks/my-task/
  prompt.md    # what the agent is asked to do
  fixture/     # starting files (committed as git baseline in the workdir)
  grade.sh     # runs in the workdir, prints integer 0-100 on stdout
```

Guidelines: make grading deterministic (tests, hidden asserts, AST/structure checks,
`git diff --quiet` for files that must not change). Verify the untouched fixture scores
low before trusting the task.

## Interpreting results

- **skills-on vs skills-off at equal score** → skills overhead; expected on trivial tasks.
  Skills should pay off on tasks matching their domain (add such tasks to test specific skills).
- **Same variant across commits** → regression tracking for skill-set changes.
- Model nondeterminism is real: run each configuration 3+ times before drawing conclusions
  (`for i in 1 2 3; do bench/run.sh ...; done`).
