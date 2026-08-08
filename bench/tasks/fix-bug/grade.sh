#!/usr/bin/env bash
# Score 0-100. Runs inside the task work dir.
score=0
# tests pass: 80 pts
if python3 test_stats.py >/dev/null 2>&1; then score=$((score + 80)); fi
# test file untouched: 20 pts
if git diff --quiet HEAD -- test_stats.py 2>/dev/null; then score=$((score + 20)); fi
echo "$score"
