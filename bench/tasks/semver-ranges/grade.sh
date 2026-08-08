#!/usr/bin/env bash
# Score 0-100: fraction of hidden node-semver ground-truth cases passed (weighted).
python3 - <<'EOF'
import json

CASES = [  # [version, range, expected, weight]
    ["1.2.3","1.2.3",True,1],["1.2.3","=1.2.3",True,1],["1.2.4",">1.2.3",True,1],
    ["1.2.3",">=1.2.3",True,1],["1.2.2","<1.2.3",True,1],["1.2.3","<=1.2.3",True,1],
    ["2.0.0",">1.2.3 <3.0.0",True,1],
    ["1.2.9","~1.2.3",True,1],["1.3.0","~1.2.3",False,2],["1.9.9","^1.2.3",True,1],
    ["2.0.0","^1.2.3",False,2],["0.2.5","^0.2.3",True,2],["0.3.0","^0.2.3",False,4],
    ["0.0.3","^0.0.3",True,2],["0.0.4","^0.0.3",False,4],
    ["1.2.3","~1.2",True,2],["1.3.0","~1",True,2],["0.2.3","~0.2",True,2],
    ["1.2.3","1.2.x",True,1],["1.3.0","1.2.x",False,2],["1.4.7","1.x",True,1],
    ["2.0.0","1.x",False,2],["3.1.4","*",True,1],["1.2.3","",True,2],["1.2.0","1.2",True,2],
    ["1.5.0","1.2.3 - 2.3.4",True,2],["2.3.5","1.2.3 - 2.3.4",False,4],
    ["2.3.4","1.2.3 - 2.3",True,3],["2.4.0","1.2.3 - 2.3",False,5],["1.2.3","1.2 - 2.3.4",True,3],
    ["1.2.3","<1.0.0 || >=1.2.0",True,1],["1.1.0","<1.0.0 || >=1.2.0",False,2],
    ["1.2.3-alpha",">=1.0.0",False,7],["1.2.3-alpha",">=1.2.3-0",True,4],
    ["1.2.3-beta.2",">=1.2.3-beta.1",True,3],["1.2.4-alpha",">=1.2.3-beta",False,7],
    ["1.2.3-alpha","^1.2.3-alpha",True,3],["1.2.4-alpha","^1.2.3-alpha",False,7],
    ["1.2.3-beta.11",">1.2.3-beta.2",True,3],["1.2.3-beta.2.x",">1.2.3-beta.2",True,4],
    ["1.0.0-alpha.1",">1.0.0-alpha",True,3],["1.0.0-rc.1","<1.0.0",False,7],
    ["1.0.0-alpha","*",False,7],["2.0.0-alpha","^1.2.3 || ^2.0.0-alpha",True,3],
    ["1.2.3-alpha.7","1.2.3-alpha.3 - 1.2.3-beta",True,4],
    ["1.0.0-beta","~1.0.0-alpha",True,3],["1.0.1-alpha","~1.0.0-alpha",False,7],
    ["1.2.3+build.5","1.2.3",True,2],["1.2.3+build.5",">1.2.3",False,5],
    ["1.2.3+b1","=1.2.3+b2",True,3],["1.2.3","v1.2.3",True,2],
]

# reject non-stdlib imports
import ast, sys
tree = ast.parse(open("semver.py").read())
for n in ast.walk(tree):
    mods = []
    if isinstance(n, ast.Import): mods = [a.name.split(".")[0] for a in n.names]
    if isinstance(n, ast.ImportFrom) and n.module: mods = [n.module.split(".")[0]]
    for m in mods:
        if m not in sys.stdlib_module_names:
            print(0); raise SystemExit

try:
    from semver import satisfies
except Exception:
    print(0); raise SystemExit

got_w, tot_w = 0, 0
for v, r, exp, w in CASES:
    tot_w += w
    try:
        if bool(satisfies(v, r)) == exp:
            got_w += w
    except Exception:
        pass
# normalize above-chance: constant-answer strategies score ~0
print(round(max(0.0, (got_w / tot_w - 0.5) * 200)))
EOF
