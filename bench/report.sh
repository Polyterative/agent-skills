#!/usr/bin/env bash
# Summarize bench/results/runs.jsonl grouped by (skillset_commit, variant, model).
set -euo pipefail
FILE="$(dirname "${BASH_SOURCE[0]}")/results/runs.jsonl"
[[ -s "$FILE" ]] || { echo "no results yet — run bench/run.sh first"; exit 0; }

jq -rs '
  group_by(.skillset_commit + .variant + .model) | map({
    commit: .[0].skillset_commit, variant: .[0].variant, model: .[0].model,
    runs: length,
    avg_score: (map(.score) | add / length | round),
    tokens_in: (map(.input_tokens) | add),
    tokens_out: (map(.output_tokens) | add),
    credits: ((map(.credits) | add) * 100 | round / 100),
    wall_s: (map(.wall_seconds) | add),
    score_per_credit: (if (map(.credits)|add) > 0
      then ((map(.score)|add) / (map(.credits)|add) * 10 | round / 10) else null end)
  }) | (["commit","variant","model","runs","avg_score","tok_in","tok_out","credits","wall_s","score/credit"],
        (.[] | [.commit, .variant, .model, .runs, .avg_score, .tokens_in, .tokens_out, .credits, .wall_s, .score_per_credit]))
  | @tsv' "$FILE" | column -t -s $'\t'

echo
echo "Per-task latest:"
jq -rs '
  group_by(.task + .variant) | map(max_by(.ts))
  | (["task","variant","score","tok_in","tok_out","credits","wall_s"],
     (.[] | [.task, .variant, .score, .input_tokens, .output_tokens, (.credits*100|round/100), .wall_seconds]))
  | @tsv' "$FILE" | column -t -s $'\t'
