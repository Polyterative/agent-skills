Write a TSP heuristic solver in solver.py as `solve(points, deadline_s)`:
- `points`: list of (x, y) float tuples (Euclidean TSP, up to 3000 cities).
- `deadline_s`: wall-clock budget in seconds for THIS call; return before it expires.
- Return: a tour as a list of indices (a permutation of range(len(points))).

Pure Python stdlib only (no numpy). The grader runs each instance with a fixed time budget and scores your tour length against a strong reference tour (nearest-neighbor + 2-opt with neighbor lists + Or-opt). Scoring is linear per instance: reference length or better = full marks, plain nearest-neighbor length or worse = 0. Matching the reference requires an efficient local search — a naive O(n^2)-per-pass 2-opt will time out on the larger instances; neighbor-list pruning or equivalent is needed.

Requirements:
- Always return a valid permutation, even if the deadline forces an early exit.
- Determinism is not required; use the full budget productively.
- Do not import numpy/scipy or shell out.

Test your solver locally on random instances of several sizes (including n=2000+) before finishing; verify tour validity and that you respect the deadline.
