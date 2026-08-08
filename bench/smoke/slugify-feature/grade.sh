#!/usr/bin/env bash
# Score 0-100. Runs inside the task work dir.
score=0

# hidden acceptance checks: 60 pts (12 each)
run() { python3 -c "$1" >/dev/null 2>&1; }
run 'from util import slugify; assert slugify("Hello, World!") == "hello-world"' && score=$((score+12))
run 'from util import slugify; assert slugify("Crème Brûlée") == "creme-brulee"' && score=$((score+12))
run 'from util import slugify; assert slugify("a  --  b") == "a-b"' && score=$((score+12))
run 'from util import slugify; assert slugify("!!wow!!") == "wow"' && score=$((score+12))
run 'from util import slugify; assert slugify("Already-Slugged") == "already-slugged"' && score=$((score+12))

# agent-written tests exist and pass: 30 pts
if [ -f test_util.py ] && python3 -m unittest test_util >/dev/null 2>&1; then
  score=$((score+30))
fi

# existing function untouched: 10 pts
run 'from util import truncate; assert truncate("abc", 5) == "abc"' && score=$((score+10))

echo "$score"
