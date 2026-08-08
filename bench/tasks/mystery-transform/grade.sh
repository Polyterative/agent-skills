#!/usr/bin/env bash
# Score 0-100: exact-match accuracy on 50 held-out examples of the secret transformation.
GRADER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" python3 - <<'EOF'
import json, os, signal

def timeout(sig, frame): raise TimeoutError
signal.signal(signal.SIGALRM, timeout)

held = json.load(open(os.path.join(os.environ["GRADER_DIR"], "held.json")))

try:
    from transform import transform
except Exception:
    print(0); raise SystemExit

ok = 0
for a, b in held:
    try:
        signal.alarm(5)
        if transform(a) == b: ok += 1
    except Exception:
        pass
    finally:
        signal.alarm(0)
print(round(100 * ok / len(held)))
EOF
