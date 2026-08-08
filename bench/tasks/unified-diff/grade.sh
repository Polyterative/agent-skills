#!/usr/bin/env bash
# Score 0-100: hidden cases compared byte-for-byte against difflib ground truth (weighted).
python3 - <<'EOF'
import json

CASES = json.loads(r'''
[
 [["one","two","three"],["one","TWO","three"],3,["--- a.txt","+++ b.txt","@@ -1,3 +1,3 @@"," one","-two","+TWO"," three"],1],
 [["a","b"],["a","b","c"],3,["--- a.txt","+++ b.txt","@@ -1,2 +1,3 @@"," a"," b","+c"],1],
 [["b","c"],["a","b","c"],3,["--- a.txt","+++ b.txt","@@ -1,2 +1,3 @@","+a"," b"," c"],1],
 [["a","b","c","d"],["a","d"],3,["--- a.txt","+++ b.txt","@@ -1,4 +1,2 @@"," a","-b","-c"," d"],1],
 [["x","y"],["x","y"],3,[],2],
 [[],["a","b"],3,["--- a.txt","+++ b.txt","@@ -0,0 +1,2 @@","+a","+b"],3],
 [["a","b"],[],3,["--- a.txt","+++ b.txt","@@ -1,2 +0,0 @@","-a","-b"],3],
 [["line1","line2","line3","line4","line5","line6","line7","line8","line9","line10","line11","line12","line13","line14","line15","line16","line17","line18","line19","line20"],
  ["line1","line2","CHANGED","line4","line5","line6","line7","line8","line9","line10","line11","line12","line13","line14","line15","line16","CHANGED","line18","line19","line20"],3,
  ["--- a.txt","+++ b.txt","@@ -1,6 +1,6 @@"," line1"," line2","-line3","+CHANGED"," line4"," line5"," line6","@@ -14,7 +14,7 @@"," line14"," line15"," line16","-line17","+CHANGED"," line18"," line19"," line20"],4],
 [["l1","l2","l3","l4","l5","l6","l7","l8","l9","l10","l11","l12"],
  ["l1","l2","l3","X","l5","l6","l7","l8","X","l10","l11","l12"],3,
  ["--- a.txt","+++ b.txt","@@ -1,12 +1,12 @@"," l1"," l2"," l3","-l4","+X"," l5"," l6"," l7"," l8","-l9","+X"," l10"," l11"," l12"],4],
 [["first","a","b","c","d","e","last"],["FIRST","a","b","c","d","e","LAST"],3,
  ["--- a.txt","+++ b.txt","@@ -1,7 +1,7 @@","-first","+FIRST"," a"," b"," c"," d"," e","-last","+LAST"],3],
 [["line1","line2","line3","line4","line5","line6","line7","line8","line9","line10"],
  ["line1","line2","line3","line4","MOD","line6","line7","line8","line9","line10"],1,
  ["--- a.txt","+++ b.txt","@@ -4,3 +4,3 @@"," line4","-line5","+MOD"," line6"],3],
 [["k1","k2","k3","k4","k5","k6","k7"],["k1","k2","k3","Z","k5","k6","k7"],0,
  ["--- a.txt","+++ b.txt","@@ -4 +4 @@","-k4","+Z"],5],
 [["a","b","c","d","e","f","g","h"],["a","b","c","d","NEW","e","f","g","h"],1,
  ["--- a.txt","+++ b.txt","@@ -4,2 +4,3 @@"," d","+NEW"," e"],4]
]
''')

import ast, sys
tree = ast.parse(open("udiff.py").read())
for n in ast.walk(tree):
    mods = []
    if isinstance(n, ast.Import): mods = [a.name.split(".")[0] for a in n.names]
    if isinstance(n, ast.ImportFrom) and n.module: mods = [n.module.split(".")[0]]
    for m in mods:
        if m in {"difflib"} or m not in sys.stdlib_module_names:
            print(0); raise SystemExit

try:
    from udiff import unified_diff
except Exception:
    print(0); raise SystemExit

got_w, tot_w = 0, 0
for a, b, n, expected, w in CASES:
    tot_w += w
    try:
        if list(unified_diff(a, b, n)) == expected:
            got_w += w
    except Exception:
        pass
print(round(100 * got_w / tot_w))
EOF
