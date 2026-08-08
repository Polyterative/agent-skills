Implement `next_run(expr, after)` in cronnext.py. Given a 5-field cron expression (minute hour day-of-month month day-of-week) and a `datetime.datetime` (naive), return the next datetime strictly after `after` at which the expression fires. Pure Python stdlib only; do not install or vendor any package.

Required semantics (classic vixie-cron):
- Fields support: `*`, numbers, comma lists, ranges `a-b`, steps `*/n` and `a-b/n`.
- Month names JAN-DEC and day names SUN-SAT (case-insensitive) in the month / day-of-week fields, usable in ranges too (e.g. `JUN-AUG`).
- Day-of-week: 0 and 7 both mean Sunday.
- The day-of-month / day-of-week union rule: if BOTH fields are restricted (neither is `*`), a day matches when EITHER field matches. If only one is restricted, only that one must match. Note: a field like `*/10` counts as restricted.
- Impossible dates roll forward correctly (e.g. `0 0 31 * *` skips 30-day months; `0 0 29 2 *` waits for a leap year).
- The result is strictly greater than `after` (seconds/microseconds of `after` may be nonzero; the result must have second=0, microsecond=0).

Write your own sanity tests and make sure they pass before finishing. Correctness on edge cases is what is being graded.
