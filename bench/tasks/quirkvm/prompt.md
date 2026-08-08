Implement an interpreter for QuirkVM, a small invented stack machine, in quirkvm.py as `run(program: str) -> list[str]`. Pure Python stdlib only. The spec below is exact and complete — read it carefully; every detail is graded against hidden test programs. Your intuitions from ordinary VMs WILL be wrong here; follow the letter of the spec.

## Machine state
- A value stack, maximum depth 8 (see PUSH overflow rule).
- Four registers A, B, C, D, initialized to 0.
- An error flag E, initially clear.
- An output list of strings.

## Values
All values are integers in [-2048, 2047] (12-bit two's complement). Two distinct out-of-range behaviors exist:
- "wrap": value wraps modulo 4096 into [-2048, 2047].
- "saturate": value clamps to -2048 or 2047.

## Program format
One instruction per line. Fields separated by whitespace. Blank lines are skipped. Instructions:

- `PUSH n` — push literal n (guaranteed in range). If the stack already holds 8 values, the OLDEST value (bottom of stack) is discarded first, then n is pushed. This does NOT set E.
- `POP` — discard top. On empty stack: set E, do nothing else.
- `DUP` — duplicate top (PUSH overflow rule applies). On empty stack: set E.
- `SWAP` — swap top two. If fewer than 2 values: set E.
- `ADD` — pop b, then a; push wrap(a+b). If fewer than 2 values: set E and pop nothing.
- `SUB` — pop b, then a; push wrap(a-b). Same underflow rule.
- `MUL` — pop b, then a; push saturate(a*b). Same underflow rule. (Note: MUL saturates, ADD/SUB wrap.)
- `DIV` — pop b, then a. If b == 0: push 0 AND set E. Else push floor division a // b (Python floor semantics, i.e. -7 // 2 == -4). Same underflow rule.
- `NEG` — negate top in place with wrap (so NEG on -2048 gives -2048). On empty stack: set E.
- `LOAD r` — push the value of register r (PUSH overflow rule applies).
- `STOR r` — pop top into register r. On empty stack: set E (register unchanged).
- `PRINT` — if E is set: append "ERR" to output and CLEAR E (do not pop). Else if the stack is empty: append "ERR" (E stays clear). Else pop the top and append its decimal string.
- `REP n ... END` — repetition block, may nest (max nesting in tests: 2). If n > 0: execute the block body n times, in order. If n <= 0: execute the block body ONCE with its items in REVERSE order — the reversal applies at the item level: a nested REP block counts as one item (it is executed with its own normal rule, not internally reversed), but the items of the reversed body run in reverse sequence. n == 0 therefore still executes the body once, reversed.

## Termination
After the last instruction, append these three lines to the output, exactly:
1. `S:` followed by the stack from bottom to top, space-separated, with a leading space before the first value — or exactly `S:` (no trailing space) if the stack is empty. Example: `S: 3 2`.
2. `R: <A> <B> <C> <D>` (single spaces).
3. `E: 0` or `E: 1` for the final error-flag state.

Return the full output list (prints followed by the three state lines).

## Worked examples
- `PUSH 2000\nPUSH 500\nADD\nPRINT` returns `["-1596", "S:", "R: 0 0 0 0", "E: 0"]` (2500 wraps to -1596).
- `PUSH 3\nREP -2\nPUSH 1\nPUSH 2\nSUB\nEND\nPRINT\nPRINT` returns `["ERR", "1", "S: 3 2", "R: 0 0 0 0", "E: 0"]`. Why: the REP body runs once, reversed: SUB, PUSH 2, PUSH 1. SUB on a 1-deep stack sets E and pops nothing. The first PRINT reports ERR and clears E (no pop); the second PRINT pops and prints 1, leaving [3, 2].
- `PUSH 5\nPUSH 0\nDIV\nPRINT\nPRINT` returns `["ERR", "0", "S:", "R: 0 0 0 0", "E: 0"]` (DIV by zero pushed 0 and set E; first PRINT consumes the flag as ERR without popping; second PRINT pops the 0).

Write thorough tests of your own covering every rule above and make sure they pass before finishing.
