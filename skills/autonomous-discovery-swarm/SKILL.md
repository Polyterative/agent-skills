---
name: autonomous-discovery-swarm
description: Run a low-cost, read-only swarm of up to 10 parallel gpt-5.6-luna research sessions to explore a repository/area from distinct angles before any classification or planning happens, then consolidate their findings into one DiscoveryDossier that feeds UNDERSTAND and adaptive-workflow-compiler. Use at the very start of autonomous-development-loop (and autonomous-micro-sweep) so higher-capability roles start from an assembled context instead of re-deriving it.
---

# Autonomous Discovery Swarm

Act as the loop's cheap, parallel reconnaissance layer. This skill runs
**before** effort classification and before role skills load. Its job is to
turn a raw area of interest into a compact, trustworthy
`DiscoveryDossier` so that `adaptive-workflow-compiler` and every downstream
role start from assembled context instead of spending expensive-model turns
rediscovering the repository.

This is strictly read-only reconnaissance: it never edits files, commits, or
makes product/design/technical decisions. It answers questions and maps
territory.

## When to use

- Automatically at the start of `autonomous-development-loop`, right after the
  Start contract's step 2 (inspect branch/working tree/history) and before
  `adaptive-workflow-compiler` classifies effort — whenever the area is broad,
  unfamiliar, or spans more than a small, well-known surface.
- Automatically at the start of `autonomous-micro-sweep`'s partitioning step,
  to find focus areas instead of guessing them.
- Standalone, when the user wants a fast research/context pass without
  committing to implementation.

Skip it only when the target is a single, precisely named file or function the
coordinator understands — spawning a swarm to answer a question you can answer
in one lookup is waste.

## Phase 1: SWARM (parallel, read-only)

### Two research lanes

Mirror product discovery: an internal audit lane
(what do we have, how does it behave) and an external research lane (what does
the domain expect, what is the state of the art). Allocate the swarm across
both lanes according to the problem:

- **Internal recon** — repository, behavior, tests, history, conventions (the
  angles listed below).
- **External research** — web research on domain and technical knowledge the
  repository cannot answer:
  - domain conventions and user expectations: how products in this domain
    typically solve the named problem, established UX patterns, terminology;
  - prior art and comparable products: how mature tools handle the same job,
    what users appear to like or complain about;
  - technical approaches: candidate algorithms, libraries, frameworks, or
    platform APIs for the likely solution, with maturity and licensing notes;
  - authoritative platform/API documentation and its constraints;
  - known pitfalls: common failure modes, performance traps, or security
    considerations others hit implementing similar solutions.

A mostly-internal task (small refactor area) may use zero external agents; a
new-domain feature may justify an even split. Decide per problem, still within
the 10-session cap.

### External research guardrails

- **Never include proprietary code, secrets, file contents, or identifying
  project details in search queries.** Query in terms of the general problem
  ("macOS menu bar app restore window focus pattern"), not the codebase.
- Prefer official documentation, standards, and authoritative sources over
  forums; when using community sources, mark them as such.
- Every external claim in the dossier carries its source URL, date or version
  relevance, and a fact-vs-opinion label.
- External findings inform the product/technical roles, never decisions: the
  swarm reports options and evidence; it does not pick the library or design.

### Partition into research angles

Break the area of interest into **distinct research angles**, sized to the
scope instead of defaulting to the cap: a narrow or partly-known area
warrants 3–4 angles; only a genuinely broad, unfamiliar, or multi-surface area
justifies approaching 10. Parallelism buys latency, not lower cost — every
session pays its own context, so do not spawn sessions the scope does not
justify. Angles need not be disjoint files (unlike `autonomous-micro-sweep`,
overlap is acceptable here since agents only read). Typical angles:

- repository/product shape: what does this app do, main entry points, module
  boundaries;
- existing behavior and known limitations for the specific area named;
- relevant tests, snapshots, and what they currently assert;
- recent related history: relevant commits, open TODOs, prior sessions on this
  area;
- architecture/data-flow for the affected surface;
- conventions and constraints: AGENTS.md-equivalent docs, lint/build/test
  wrappers, commit/push policy;
- UI/design system conventions if the area touches product surfaces;
- dependencies, external services, or platform constraints involved;
- one or two sharp open questions the coordinator most needs answered to plan
  correctly.

Fewer than 10 is fine when the area does not support that many distinct
angles — do not invent redundant angles merely to fill the cap.

### Kickoff contract (identical shape for every sub-agent)

Every discovery sub-agent receives:

1. One precise research angle or question set, plus the repository/path and
   any already-known constraints.
2. Explicit read-only boundary: no edits, no commits, no destructive commands,
   no running builds/tests unless needed to answer the question and safe
   per repository policy.
3. Instruction to explore precisely, not exhaustively — find the
   files, behaviors, or facts that answer its angle, then stop.
4. A required output shape: a short structured finding containing the
   question, the answer, supporting file paths/line references, confidence,
   and any new open question it surfaced.
5. **Verifiability anchor rule:** every claim in the finding must carry a
   checkable anchor — a `file:line` reference for internal findings, a source
   URL for external ones. A claim with no anchor must be labeled
   `speculative`. Swarm output without ground truth accumulates confidence,
   not truth; anchors are what make this swarm's output trustworthy at scale.

### Model policy (fixed, not delegated)

- Every discovery sub-agent runs on **gpt-5.6-luna, effort low or medium**.
  This phase trades depth for breadth and speed; do not
  escalate model or effort even when an angle looks hard — a sub-agent that
  cannot resolve its angle reports it as an open question with its confidence
  marked low instead of spending a stronger model to force an answer.
- This overrides `model-aware-orchestration`'s general model-routing guidance
  for this phase, just as `autonomous-micro-sweep` fixes its swarm phase to
  one cheap model.

### Parallel execution rule

Launch all selected sub-agents as real sub-agent calls in one batch of tool
invocations — never narrated inline, never sequential when batching works
(full delegation mechanics: `model-aware-orchestration` §Delegation
mechanics). Cap at 10 concurrent sessions per discovery pass; the
coordinator's context grows only by each structured finding, never the full
exploration transcript. If the environment cannot spawn a real sub-agent for
this phase, say so and fall back to a smaller, honestly-sequential research
plan instead of simulating the swarm inline.

## Phase 2: CONSOLIDATION (single session)

Run as one accountable pass after all discovery sub-agents complete.

1. Collect every sub-agent's structured finding.
2. **Spot-check anchors.** Verify a sample of anchors (open the cited
   file:line, or sanity-check the cited URL) before trusting findings —
   verification is cheap, regeneration is not. Findings whose anchors fail the
   spot-check are demoted to `speculative`. `speculative` claims never enter
   dossier sections that drive decisions (constraints, behavior, architecture
   map); at most they surface as open questions.
3. Resolve contradictions between findings (two agents disagreeing about the
   same fact) with a targeted follow-up check, not by picking one arbitrarily.
4. Deduplicate overlapping findings.
5. Assemble the `DiscoveryDossier`:
   - **cache key** — the repository HEAD commit hash (and area name) the
     dossier was built against;
   - repository/product shape summary;
   - current behavior and known limitations for the named area;
   - relevant files, tests, and architecture map;
   - relevant recent history and active work;
   - repository constraints (build/test/commit/push policy, conventions);
   - **DomainResearch** — external findings on domain conventions, user
     expectations, and prior art, each with source, recency, and
     fact-vs-opinion label;
   - **TechnicalApproaches** — candidate approaches/libraries/APIs with
     tradeoffs, maturity, constraints, and known pitfalls, presented as
     options for the technical lead, not as a decision;
   - assumptions and confidence levels;
   - open questions the swarm could not resolve, ranked by how much they block
     planning.
6. Hand the `DiscoveryDossier` to the next consumer:
   - inside `autonomous-development-loop`: feeds `UNDERSTAND` and
     `adaptive-workflow-compiler`'s effort classification, so the compiler
     scores breadth/risk/coordination from assembled evidence rather than a
     cold start;
   - inside `autonomous-micro-sweep`: feeds the swarm partitioning step
     directly, turning discovered surfaces into the up-to-10 disjoint focus
     areas for the bug-hunt swarm.
7. Do not let the dossier silently resolve genuine unknowns. Unresolved
   high-impact open questions must carry forward as explicit assumptions or
   blocked items in the `WorkflowManifest`, not get glossed over because the
   dossier looks complete.

## Dossier reuse (incremental discovery)

A `DiscoveryDossier` is a cache, not a ritual. Before launching a swarm,
check session state (and `living-project-knowledge` docs) for an existing
dossier covering the same repository and area:

- **HEAD unchanged** since the dossier's cache key → reuse it outright; no
  swarm.
- **HEAD moved** → run `git diff --stat <dossier_commit>..HEAD` and map the
  changed paths onto the dossier's angles. Re-run only the lanes whose
  surfaces changed (plus the recent-history lane, which is always stale);
  splice the fresh findings into the dossier and update its cache key.
  Sections built on unchanged surfaces carry over as-is, marked `carried
  over from <commit>`.
- **Different area, same repo** → carry over the repository-shape and
  constraints sections; swarm only the area-specific angles.

Full re-discovery is reserved for: no prior dossier, structural upheaval
(large diff touching most angles), or evidence the old dossier was wrong.
DomainResearch and TechnicalApproaches age by time rather than by commit —
re-verify external claims older than a few weeks before relying on them.

## Guardrails

- **Strictly read-only.** No sub-agent may edit files, run destructive
  commands, or commit. A discovery pass that produces any working-tree change
  has violated its contract.
- **Fixed cheap model.** No self-escalation within the swarm; low-confidence
  answers become open questions, not excuses to switch models.
- **Precise, not exhaustive.** Each sub-agent answers its angle and stops; it
  does not attempt to read the entire repository.
- **One consolidated dossier, not N raw transcripts.** Downstream roles consume
  the `DiscoveryDossier`, never the raw per-sub-agent output directly.
- **Cap at 10 parallel sessions** per pass.
- **Confidence is explicit.** Every dossier section states measured vs.
  observed vs. inferred vs. unknown, matching the discipline
  `autonomous-development-loop`'s UNDERSTAND stage requires.

## Relationship to the rest of the loop

- This skill produces input for `UNDERSTAND` and `adaptive-workflow-compiler`;
  it does not replace either. The compiler still classifies effort and builds
  the `WorkflowManifest`, but now starts from the dossier, not raw
  exploration.
- It does not replace `autonomous-product-lead`/`autonomous-technical-lead`
  discovery work — those roles still own product/technical judgment. The
  swarm only removes basic repository reconnaissance from their context
  budget.
- Treat the dossier as session-state material (like the `WorkflowManifest`)
  unless it contains durable facts worth keeping in
  `living-project-knowledge`.

## Completion report

At the end of a discovery pass, report:

- number of research angles and sub-agents used, all on gpt-5.6-luna;
- key findings feeding into UNDERSTAND/classification;
- unresolved open questions and their blocking impact;
- confidence levels;
- whether the dossier is enough to proceed to classification, or whether
  one more targeted follow-up (still cheap-model, still read-only) is needed
  first.
