#!/usr/bin/env bash
# Score 0-100: tour quality vs reference on hidden instances.
# Per instance: frac = clamp((nn_len - got_len) / (nn_len - ref_len), 0, 1),
# then score = 100 * frac^4 — the power curve makes the last stretch toward the
# reference dominate, so a naive unpruned 2-opt lands mid-range instead of ~90.
# Invalid tours or deadline violations score 0 for that instance.
GRADER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" python3 - <<'EOF'
import json, math, os, time

instances = json.load(open(os.path.join(os.environ["GRADER_DIR"], "instances.json")))

try:
    from solver import solve
except Exception:
    print(0); raise SystemExit

BUDGETS = {100: 5, 300: 10, 600: 15, 1000: 20, 2000: 30, 3000: 40}

def tour_len(pts, tour):
    n = len(tour)
    return sum(math.dist(pts[tour[i]], pts[tour[(i + 1) % n]]) for i in range(n))

scores = []
for inst in instances:
    pts = [tuple(p) for p in inst["points"]]
    n = len(pts)
    budget = BUDGETS.get(n, 20)
    t0 = time.time()
    try:
        tour = solve(pts, budget)
    except Exception:
        scores.append(0.0); continue
    elapsed = time.time() - t0
    if elapsed > budget + 2:          # small grace for return overhead
        scores.append(0.0); continue
    if not isinstance(tour, (list, tuple)) or sorted(tour) != list(range(n)):
        scores.append(0.0); continue
    L = tour_len(pts, list(tour))
    nn, ref = inst["nn_len"], inst["ref_len"]
    frac = (nn - L) / (nn - ref) if nn > ref else 1.0
    scores.append(max(0.0, min(1.0, frac)) ** 4)

print(round(100 * sum(scores) / len(scores)))
EOF
