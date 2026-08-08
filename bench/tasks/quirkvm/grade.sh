#!/usr/bin/env bash
# Score 0-100: 60 hidden random programs, graded per output line against the
# reference interpreter. Score = program-level average of per-line accuracy,
# with full-program exact matches earning the last 20% (guards against
# near-miss inflation).
GRADER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" python3 - <<'EOF'
import json, os, signal

def timeout(sig, frame): raise TimeoutError
signal.signal(signal.SIGALRM, timeout)

cases = json.load(open(os.path.join(os.environ["GRADER_DIR"], "cases.json")))

try:
    from quirkvm import run
except Exception:
    print(0); raise SystemExit

line_frac_sum, exact = 0.0, 0
for prog, expected in cases:
    got = None
    try:
        signal.alarm(5)
        got = [str(x) for x in run(prog)]
    except Exception:
        got = []
    finally:
        signal.alarm(0)
    if got == expected:
        exact += 1
        line_frac_sum += 1.0
        continue
    m = sum(1 for g, e in zip(got, expected) if g == e)
    denom = max(len(expected), len(got), 1)
    line_frac_sum += m / denom

n = len(cases)
score = 80 * (line_frac_sum / n) + 20 * (exact / n)
print(round(score))
EOF
