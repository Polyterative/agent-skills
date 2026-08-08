#!/usr/bin/env bash
# Skill-set benchmark runner for Copilot CLI.
#
# Runs each task in bench/tasks/ non-interactively with a pinned session ID,
# grades the result deterministically, and reads exact resource consumption
# (tokens, AI credits, wall time, turns) back from the Copilot session store.
#
# Usage:
#   bench/run.sh [--variant skills-on|skills-off] [--model MODEL] [--task NAME] [--label TEXT]
#
# Variants:
#   skills-on  (default)  uses your real ~/.copilot home, i.e. the skill set
#                         currently symlinked from this repo.
#   skills-off            uses an isolated COPILOT_HOME with no skills at all,
#                         authenticated via `gh auth token`.
#
# Results are appended as JSON lines to bench/results/runs.jsonl, tagged with
# the current git commit of this repo (= the skill-set version under test).
# Summarize with bench/report.sh.

set -euo pipefail

BENCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$BENCH_DIR")"
TASKS_DIR="$BENCH_DIR/tasks"
RESULTS_FILE="$BENCH_DIR/results/runs.jsonl"

VARIANT="skills-on"
MODEL="${BENCH_MODEL:-claude-sonnet-4.6}"
ONLY_TASK=""
LABEL=""
MAX_CREDITS="${BENCH_MAX_CREDITS:-30}"   # hard AI-credit cap per run (CLI minimum: 30)
RUN_TIMEOUT="${BENCH_TIMEOUT:-600}"      # hard wall-clock cap per run (seconds)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --variant) VARIANT="$2"; shift 2 ;;
    --model)   MODEL="$2";   shift 2 ;;
    --task)    ONLY_TASK="$2"; shift 2 ;;
    --tasks-dir) TASKS_DIR="$BENCH_DIR/$2"; shift 2 ;;
    --label)   LABEL="$2";   shift 2 ;;
    --max-credits) MAX_CREDITS="$2"; shift 2 ;;
    --timeout) RUN_TIMEOUT="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

command -v sqlite3 >/dev/null || { echo "sqlite3 required" >&2; exit 1; }
command -v copilot >/dev/null || { echo "copilot CLI required" >&2; exit 1; }
command -v timeout >/dev/null || { echo "GNU timeout required (brew install coreutils)" >&2; exit 1; }

SKILLSET_COMMIT="$(git -C "$REPO_DIR" rev-parse --short HEAD)"
SKILLSET_DIRTY="$(git -C "$REPO_DIR" status --porcelain | grep -q . && echo true || echo false)"

# Resolve COPILOT_HOME per variant.
if [[ "$VARIANT" == "skills-off" ]]; then
  BENCH_HOME="${BENCH_OFF_HOME:-/tmp/copilot-bench-home}"
  mkdir -p "$BENCH_HOME"
  export COPILOT_HOME="$BENCH_HOME"
  export COPILOT_GITHUB_TOKEN="${COPILOT_GITHUB_TOKEN:-$(gh auth token)}"
  STORE="$BENCH_HOME/session-store.db"
else
  STORE="${COPILOT_HOME:-$HOME/.copilot}/session-store.db"
fi

mkdir -p "$BENCH_DIR/results"

# Disable every MCP server configured in the active COPILOT_HOME: bench agents
# must not see notion/supabase/etc. tool surfaces.
MCP_DISABLE_ARGS=()
MCP_CFG="${COPILOT_HOME:-$HOME/.copilot}/mcp-config.json"
if [[ -f "$MCP_CFG" ]]; then
  while IFS= read -r srv; do
    MCP_DISABLE_ARGS+=(--disable-mcp-server "$srv")
  done < <(jq -r '.mcpServers // {} | keys[]' "$MCP_CFG" 2>/dev/null)
fi

run_task() {
  local task="$1"
  local task_dir="$TASKS_DIR/$task"
  [[ -f "$task_dir/prompt.md" && -x "$task_dir/grade.sh" ]] || {
    echo "skip $task: needs prompt.md and executable grade.sh" >&2; return 0; }

  local sid work
  sid="$(uuidgen | tr 'A-Z' 'a-z')"
  work="$(mktemp -d "/tmp/bench-$task-XXXXXX")"
  if [[ -d "$task_dir/fixture" ]]; then
    cp -R "$task_dir/fixture/." "$work/"
  fi
  git -C "$work" init -q && git -C "$work" add -A && git -C "$work" -c user.email=bench@local -c user.name=bench commit -qm fixture

  echo "── $task  [$VARIANT/$MODEL]  session=$sid" >&2

  local start end status
  start=$(date +%s)
  set +e
  # Containment: MCP servers disabled entirely, web denied, paths limited to
  # the temp workdir, hard credit + wall-clock caps, no remote control/export.
  # Note: do NOT use --available-tools with guessed names — tool names vary and
  # a wrong list silently leaves the agent read-only (observed: solver scored 0
  # because the model had no write tool). shell+write allowances suppress prompts.
  ( cd "$work" && exec timeout --kill-after=15 "$RUN_TIMEOUT" \
      copilot -p "$(cat "$task_dir/prompt.md")" \
      --allow-tool 'shell' --allow-tool 'write' \
      --disable-builtin-mcps "${MCP_DISABLE_ARGS[@]}" --deny-url='*' \
      --no-remote-export \
      --max-ai-credits "$MAX_CREDITS" \
      --session-id "$sid" --model "$MODEL" \
      --log-level none --no-auto-update -s \
      > "$work/.bench-output.txt" 2>&1 )
  status=$?
  set -e
  end=$(date +%s)
  local wall=$((end - start))

  # Grade: grade.sh runs inside the work dir, prints a 0-100 score on stdout.
  local score
  set +e
  score="$(cd "$work" && "$task_dir/grade.sh" 2>"$work/.bench-grade-err.txt")"
  set -e
  [[ "$score" =~ ^[0-9]+$ ]] || score=0

  sleep 1  # let the CLI flush usage rows

  local usage
  usage="$(sqlite3 -json "$STORE" "
    SELECT COALESCE(SUM(input_tokens),0)  AS input_tokens,
           COALESCE(SUM(output_tokens),0) AS output_tokens,
           COALESCE(SUM(cache_read_tokens),0) AS cache_read_tokens,
           COALESCE(SUM(total_nano_aiu),0)/1e9 AS credits,
           COUNT(*) AS requests,
           COALESCE(MAX(turn_index),0)+1 AS turns
    FROM assistant_usage_events WHERE session_id='$sid';" | tr -d '[]')"
  [[ -n "$usage" ]] || usage='{"input_tokens":0,"output_tokens":0,"cache_read_tokens":0,"credits":0,"requests":0,"turns":0}'

  jq -cn \
    --arg ts "$(date -u +%FT%TZ)" \
    --arg task "$task" --arg variant "$VARIANT" --arg model "$MODEL" \
    --arg commit "$SKILLSET_COMMIT" --argjson dirty "$SKILLSET_DIRTY" \
    --arg sid "$sid" --arg label "$LABEL" --arg work "$work" \
    --argjson score "$score" --argjson wall "$wall" --argjson exit "$status" \
    --argjson usage "$usage" \
    '{ts:$ts, task:$task, variant:$variant, model:$model,
      skillset_commit:$commit, skillset_dirty:$dirty, label:$label,
      session_id:$sid, score:$score, wall_seconds:$wall, exit_code:$exit,
      workdir:$work} + $usage' >> "$RESULTS_FILE"

  echo "   score=$score  wall=${wall}s  $(echo "$usage" | jq -r '"in=\(.input_tokens) out=\(.output_tokens) credits=\(.credits) turns=\(.turns)"')" >&2
}

if [[ -n "$ONLY_TASK" ]]; then
  run_task "$ONLY_TASK"
else
  for d in "$TASKS_DIR"/*/; do
    run_task "$(basename "$d")"
  done
fi

echo "results → $RESULTS_FILE" >&2
