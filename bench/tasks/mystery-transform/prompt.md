train.json contains 30 input/output pairs of a deterministic secret transformation applied to space-separated token sequences (lowercase words and non-negative integers).

Your job: reverse-engineer the transformation and implement it in transform.py as `transform(s: str) -> str`. Pure Python stdlib only.

You are graded on HELD-OUT examples of the same transformation, so a solution that merely memorizes train.json scores 0. The transformation is a fixed composition of several simple rules (each rule concerns things like casing, suffixes, numeric arithmetic, token positions, or sequence order). All rules are deterministic and total — no randomness, no external knowledge.

Method matters: derive hypotheses from the training pairs, verify EVERY training pair reproduces exactly (`python3 -c "import json; from transform import transform; d=json.load(open('train.json')); print(sum(transform(a)==b for a,b in d), '/', len(d))"`), and be suspicious of rules that fit most-but-not-all examples — the composition order of the rules matters.
