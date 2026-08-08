#!/usr/bin/env python3
"""Generate comparison charts from bench/results/runs.jsonl.

No third-party dependencies (pure stdlib) — keeps the benchmark harness
lightweight. Emits SVG files (GitHub renders SVG inline in README.md) into
bench/results/charts/.

Usage: python3 bench/make_charts.py
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RUNS_FILE = os.path.join(HERE, "results", "runs.jsonl")
OUT_DIR = os.path.join(HERE, "results", "charts")

MODEL_COLORS = {
    "claude-sonnet-5": "#c1440e",
    "gpt-5.6-luna": "#2e7d32",
    "claude-haiku-4.5": "#5b6ee1",
}
DEFAULT_COLORS = ["#c1440e", "#2e7d32", "#5b6ee1", "#b8860b", "#8e44ad", "#16a085"]


def load_runs():
    runs = []
    with open(RUNS_FILE) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            row = json.loads(line)
            if row.get("invalid"):
                continue
            runs.append(row)
    return runs


def color_for(model, seen):
    if model in MODEL_COLORS:
        return MODEL_COLORS[model]
    idx = seen.setdefault(model, len(seen))
    return DEFAULT_COLORS[idx % len(DEFAULT_COLORS)]


def svg_header(w, h):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
        f'viewBox="0 0 {w} {h}" font-family="Helvetica, Arial, sans-serif">\n'
        f'<rect width="{w}" height="{h}" fill="#ffffff"/>\n'
    )


def wrap_text(text, max_chars):
    words = text.split(" ")
    lines, cur = [], ""
    for word in words:
        candidate = f"{cur} {word}".strip()
        if len(candidate) > max_chars and cur:
            lines.append(cur)
            cur = word
        else:
            cur = candidate
    if cur:
        lines.append(cur)
    return lines


def bar_chart(path, title, subtitle, labels, values, unit="", color_map=None, fmt="{:.0f}",
              axis_label=None, fixed_max=None):
    """subtitle: explains exactly what is being measured (e.g. how the score is computed)
    so the chart is readable without external context; wrapped to fit the canvas width.
    fixed_max: if set (e.g. 100 for a 0-100 score axis), gridlines/scale use this instead
    of scaling to the tallest bar, so bar length is comparable across chart regenerations."""
    w = 660
    subtitle_lines = wrap_text(subtitle, 95) if subtitle else []
    axis_lines = wrap_text(axis_label, 95) if axis_label else []
    top_pad = 34 + 16 * len(subtitle_lines) + 12
    margin_left = 190
    margin_right = 70
    plot_w = w - margin_left - margin_right
    data_max = max(values) if values else 1
    max_val = fixed_max if fixed_max is not None else (data_max * 1.15 if data_max > 0 else 1)
    bar_h = 26
    gap = 14
    top = top_pad
    bottom_pad = 24 + 16 * len(axis_lines) + 6
    h = top + len(labels) * (bar_h + gap) - gap + 24 + bottom_pad

    svg = [svg_header(w, h)]
    svg.append(f'<text x="{w/2}" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">{title}</text>')
    for i, line in enumerate(subtitle_lines):
        svg.append(f'<text x="{w/2}" y="{40 + i*16}" text-anchor="middle" font-size="12" fill="#666">{line}</text>')

    plot_bottom = top + len(labels) * (bar_h + gap) - gap
    # gridlines + x-axis scale so absolute bar length is readable, not just the printed number
    n_ticks = 5
    for i in range(n_ticks + 1):
        gv = max_val * i / n_ticks
        gx = margin_left + (gv / max_val) * plot_w if max_val else margin_left
        svg.append(f'<line x1="{gx:.1f}" y1="{top - 8}" x2="{gx:.1f}" y2="{plot_bottom + 6}" stroke="#f0f0f0"/>')
        svg.append(f'<text x="{gx:.1f}" y="{plot_bottom + 22}" text-anchor="middle" font-size="10" fill="#999">{gv:.0f}</text>')

    for i, (label, val) in enumerate(zip(labels, values)):
        y = top + i * (bar_h + gap)
        bw = 0 if max_val == 0 else (val / max_val) * plot_w
        color = color_map[i] if color_map else "#c1440e"
        svg.append(f'<text x="{margin_left - 10}" y="{y + bar_h/2 + 5}" text-anchor="end" font-size="13" fill="#333">{label}</text>')
        svg.append(f'<rect x="{margin_left}" y="{y}" width="{bw:.1f}" height="{bar_h}" rx="4" fill="{color}"/>')
        svg.append(f'<text x="{margin_left + bw + 8}" y="{y + bar_h/2 + 5}" font-size="13" font-weight="bold" fill="#1a1a1a">{fmt.format(val)}{unit}</text>')

    svg.append(f'<line x1="{margin_left}" y1="{top - 10}" x2="{margin_left}" y2="{plot_bottom + 6}" stroke="#ccc"/>')
    axis_y0 = plot_bottom + 46
    for i, line in enumerate(axis_lines):
        svg.append(f'<text x="{margin_left + plot_w/2}" y="{axis_y0 + i*16}" text-anchor="middle" font-size="11" fill="#666">{line}</text>')
    svg.append('</svg>')
    with open(path, "w") as f:
        f.write("\n".join(svg))


def scatter_chart(path, title, subtitle, points, models_order):
    """points: list of (model, score, credits, task)."""
    w = 780
    margin_l, margin_r = 60, 220
    plot_w = w - margin_l - margin_r
    subtitle_lines = wrap_text(subtitle, 78) if subtitle else []
    margin_t = 30 + 16 * len(subtitle_lines) + 14
    margin_b = 60
    plot_h = 380
    h = margin_t + plot_h + margin_b

    credits = [max(p[2], 0.05) for p in points]
    min_c, max_c = min(credits), max(credits)
    log_min, log_max = math.log10(min_c), math.log10(max_c)
    if log_max == log_min:
        log_max += 1

    def x_of(c):
        c = max(c, 0.05)
        lc = math.log10(c)
        return margin_l + (lc - log_min) / (log_max - log_min) * plot_w

    def y_of(score):
        return margin_t + plot_h - (score / 100) * plot_h

    seen = {}
    svg = [svg_header(w, h)]
    svg.append(f'<text x="{w/2}" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">{title}</text>')
    for i, line in enumerate(subtitle_lines):
        svg.append(f'<text x="{w/2}" y="{40 + i*16}" text-anchor="middle" font-size="12" fill="#666">{line}</text>')
    svg.append(f'<text x="{margin_l + plot_w/2}" y="{h-15}" text-anchor="middle" font-size="13" fill="#333">credits spent (log scale) — further left is cheaper</text>')
    svg.append(f'<text x="15" y="{margin_t + plot_h/2}" text-anchor="middle" font-size="13" fill="#333" transform="rotate(-90 15 {margin_t + plot_h/2})">score (0 = failed grading, 100 = matched reference exactly)</text>')

    # axes + gridlines
    svg.append(f'<line x1="{margin_l}" y1="{margin_t}" x2="{margin_l}" y2="{margin_t+plot_h}" stroke="#ccc"/>')
    svg.append(f'<line x1="{margin_l}" y1="{margin_t+plot_h}" x2="{margin_l+plot_w}" y2="{margin_t+plot_h}" stroke="#ccc"/>')
    for s in (0, 25, 50, 75, 100):
        y = y_of(s)
        svg.append(f'<line x1="{margin_l}" y1="{y}" x2="{margin_l+plot_w}" y2="{y}" stroke="#eee"/>')
        svg.append(f'<text x="{margin_l-8}" y="{y+4}" text-anchor="end" font-size="11" fill="#666">{s}</text>')

    exp_min, exp_max = math.floor(log_min), math.ceil(log_max)
    for e in range(exp_min, exp_max + 1):
        val = 10 ** e
        x = x_of(val)
        if margin_l <= x <= margin_l + plot_w:
            svg.append(f'<line x1="{x}" y1="{margin_t}" x2="{x}" y2="{margin_t+plot_h}" stroke="#f2f2f2"/>')
            svg.append(f'<text x="{x}" y="{margin_t+plot_h+16}" text-anchor="middle" font-size="11" fill="#666">{val:g}</text>')

    for model, score, cr, task in points:
        color = color_for(model, seen)
        x, y = x_of(cr), y_of(score)
        svg.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="5.5" fill="{color}" fill-opacity="0.75" stroke="#fff" stroke-width="1"><title>{model} · {task} · score {score} · {cr:.2f} credits</title></circle>')

    legend_x = margin_l + plot_w + 20
    legend_y = margin_t + 10
    for i, model in enumerate(models_order):
        y = legend_y + i * 22
        svg.append(f'<circle cx="{legend_x}" cy="{y}" r="6" fill="{color_for(model, seen)}"/>')
        svg.append(f'<text x="{legend_x+12}" y="{y+4}" font-size="12" fill="#1a1a1a">{model}</text>')

    svg.append('</svg>')
    with open(path, "w") as f:
        f.write("\n".join(svg))


def main():
    runs = load_runs()
    if not runs:
        print("no valid runs found in runs.jsonl", file=sys.stderr)
        return 1
    os.makedirs(OUT_DIR, exist_ok=True)

    models = sorted({r["model"] for r in runs})

    # Aggregate per model (across all tasks/variants/commits recorded so far).
    agg = {}
    for r in runs:
        m = r["model"]
        a = agg.setdefault(m, {"scores": [], "credits": [], "n": 0})
        a["scores"].append(r["score"])
        a["credits"].append(r["credits"])
        a["n"] += 1

    seen = {}

    n_tasks = len({r["task"] for r in runs})
    task_names = ", ".join(sorted({r["task"] for r in runs}))

    models_by_score = sorted(models, key=lambda m: -(sum(agg[m]["scores"]) / len(agg[m]["scores"])))
    avg_scores = [sum(agg[m]["scores"]) / len(agg[m]["scores"]) for m in models_by_score]
    bar_chart(
        os.path.join(OUT_DIR, "avg_score_by_model.svg"),
        "Average score by model",
        f"Mean of each run's grade.sh score (0-100), averaged across {n_tasks} tasks: {task_names}",
        [f"{m} (n={agg[m]['n']})" for m in models_by_score],
        avg_scores,
        color_map=[color_for(m, seen) for m in models_by_score],
        fmt="{:.1f}",
        axis_label="avg score, 0 = fails grading criteria \u2192 100 = matches reference/hidden tests exactly",
        fixed_max=100,
    )

    models_by_eff = sorted(models, key=lambda m: -(sum(agg[m]["scores"]) / sum(agg[m]["credits"]) if sum(agg[m]["credits"]) > 0 else 0))
    eff = [
        (sum(agg[m]["scores"]) / sum(agg[m]["credits"])) if sum(agg[m]["credits"]) > 0 else 0
        for m in models_by_eff
    ]
    bar_chart(
        os.path.join(OUT_DIR, "score_per_credit_by_model.svg"),
        "Efficiency: score per credit spent",
        "(sum of grade.sh scores) / (sum of AI credits) across all runs \u2014 higher means more score earned per credit",
        models_by_eff,
        eff,
        color_map=[color_for(m, seen) for m in models_by_eff],
        fmt="{:.1f}",
        axis_label="score points per 1 AI credit spent",
    )

    total_credits = sorted(models, key=lambda m: sum(agg[m]["credits"]))
    bar_chart(
        os.path.join(OUT_DIR, "total_credits_by_model.svg"),
        "Total credits spent",
        "Sum of AI credits (total_nano_aiu / 1e9 from Copilot's session store) across every recorded run for that model",
        total_credits,
        [sum(agg[m]["credits"]) for m in total_credits],
        color_map=[color_for(m, seen) for m in total_credits],
        fmt="{:.1f}",
        axis_label="AI credits (lower = cheaper)",
    )

    points = [(r["model"], r["score"], max(r["credits"], 0.01), r["task"]) for r in runs]
    scatter_chart(
        os.path.join(OUT_DIR, "score_vs_credits.svg"),
        "Score vs. cost per run",
        f"Every recorded run across {n_tasks} tasks/all skill-set commits. Each dot = one run's grade.sh score vs. AI credits spent. Top-left = best (high score, low cost).",
        points,
        models,
    )

    print(f"wrote 4 charts to {OUT_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
