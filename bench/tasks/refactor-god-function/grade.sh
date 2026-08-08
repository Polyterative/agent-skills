#!/usr/bin/env bash
# Score 0-100. Runs inside the task work dir.
score=0

# behavior preserved: 30 pts
if python3 test_report.py >/dev/null 2>&1; then score=$((score + 30)); fi

# structural checks: 60 pts
python3 - <<'EOF' >/dev/null 2>&1 && score=$((score + 60))
import ast, sys
src = open("report.py").read()
tree = ast.parse(src)
funcs = [n for n in ast.walk(tree) if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef))]
assert len(funcs) >= 4, "expected decomposition into >=4 functions"
for f in funcs:
    length = (f.end_lineno or f.lineno) - f.lineno + 1
    assert length <= 15, f"{f.name} is {length} lines"
names = {f.name for f in funcs}
assert "process" in names, "process entry point missing"
proc = next(f for f in funcs if f.name == "process")
assert len(proc.args.args) == 1, "process signature changed"
EOF

# test file untouched: 10 pts
if git diff --quiet HEAD -- test_report.py 2>/dev/null; then score=$((score + 10)); fi

echo "$score"
