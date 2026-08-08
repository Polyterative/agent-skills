Implement `unified_diff(a, b, n=3)` in udiff.py. Given two lists of strings (lines without newlines) it must return a list of strings: a unified diff exactly matching the output format of GNU diff / python difflib with `fromfile="a.txt"`, `tofile="b.txt"`, and `lineterm=""`.

Hard requirements — output must byte-for-byte match the canonical format:
- If the inputs are equal, return an empty list (no headers).
- Otherwise the first two lines are exactly `--- a.txt` and `+++ b.txt`.
- Hunk headers use the format `@@ -start,count +start,count @@`, where a count of 1 omits the `,count` part (e.g. `@@ -4 +4 @@`), and a zero-length range uses the line number BEFORE the insertion point with count 0 (e.g. `@@ -0,0 +1,2 @@` when prepending to an empty file).
- Lines are prefixed with a space (context), `-` (only in a), `+` (only in b). Use a longest-common-subsequence / matching-blocks approach so the diff is minimal in the difflib sense.
- Changes closer than 2*n context lines to each other are merged into a single hunk; context is truncated at file boundaries.
- `n` may be any value >= 0, including 0 (no context lines).

Constraint: you may NOT import or use difflib (or any other diff library). Implement the matching yourself using only basic stdlib. Write your own sanity tests covering several n values and edge cases, and make sure they pass before finishing. Grading compares your output byte-for-byte against the canonical implementation on hidden cases.
