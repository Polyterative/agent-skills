---
name: model-aware-orchestration
description: Coordinate sub-agents and project sessions efficiently by selecting models for the task, preserving useful context, and delegating only independent work.
---

# Model-Aware Orchestration

Use this skill whenever you are coordinating sub-agents, child sessions, parallel
workstreams, or a task that might be split across repositories or branches.

## Primary rule

Optimize for a correct, integrated result with the fewest unnecessary context
resets. Do not waste tokens merely because they are available, but spend them
when additional reasoning materially improves first-pass correctness or reduces
expensive rework. Balance latency, token use, coordination, duplicate
investigation, and lost context. Do not create a new session merely to continue
a coherent feature, debugging thread, or implementation already in progress.

Before delegating, decide whether the task truly benefits from a separate
context:

- Keep it with the current agent when it depends on the current debugging
  history, shared design decisions, or the same small set of files.
- Delegate when the work is independently verifiable, needs a separate branch
  or repository, or can run in parallel without overlapping edits.
- Never delegate the same investigation or file area to multiple agents unless
  the user explicitly requests independent review perspectives.
- Prefer one capable agent with complete context over several shallow agents
  with partial context.

## Delegation mechanics (mandatory)

"Invoke role X" or "invoke skill Y" never means narrating that role inline in
the coordinator's own turn. It means literally spawning a bounded sub-agent
with its own fresh context window, using the actual delegation primitive the
environment provides (a sub-agent/task call, or a child project session for
cross-repo or PR-sized work), and receiving back only a compact deliverable.

Apply this test before writing any role work directly into the current
context: **if a stage is supposed to start from a clean context, it must run
in a process that actually has a clean context.** Reading a skill file and then
acting as that role in the same turn does not reset context, does not bound
token growth, and defeats the entire purpose of a swarm or a role boundary.

Concretely:

- Only the coordinator's own integration, decision, and gate work
  (classification, gate verdicts, conflict resolution, final commit framing)
  may run inline in the coordinator's context.
- Every stage the compiled workflow marks as a separate role, and every swarm
  member in `autonomous-discovery-swarm` or `autonomous-micro-sweep`, must run
  as an actual sub-agent invocation:
  - a sub-agent call for in-repo, same-session-scope work (background mode for
    anything the coordinator can review after the fact; sync mode only for
    something small enough to block on);
  - a genuine child project session for cross-repo work, a separate PR-sized
    change, or work the user should be able to inspect independently.
- Launch every disjoint, parallel-eligible piece of a swarm in the same batch
  of calls, not sequentially and not narrated as if parallel.
- The coordinator's context should accumulate only compact artifacts: manifests,
  contracts, dossiers, findings, verdicts, commit records. It must never
  accumulate the full working transcript of a delegated role — that defeats the
  context reset the delegation was for.
- If the current environment cannot spawn a real sub-agent or child session for
  a stage that requires one (no delegation tool available), do not simulate
  parallelism or a fresh-context role by acting it out inline. State that
  limitation explicitly and fall back to a smaller, honestly-sequential plan
  instead of pretending the reset happened.

Before delegating, check the observable proxy for context growth: does the
coordinator's next message quote or re-derive the sub-agent's raw tool-call
log or file contents verbatim, rather than a compact deliverable (findings,
dossier, report) at or under the Channel-economy budget below? If yes, the
reset exists on paper only — tighten the deliverable extraction; do not
re-read and re-reason over the sub-agent's full transcript token-for-token.

## Model routing

Select the model according to the required quality, acceptable latency, and
dominant kind of reasoning. Do not use one model by habit, and do not increase
model capability merely because tokens are free.

### Operating profiles

| Need | Model and effort | Guidance |
| --- | --- | --- |
| Good quality, very fast, low waste | GPT-5.6 Terra, medium for fully specified mechanical work or high for normal coding | Lowest default execution tier. Escalate after evidence of cross-file complexity, uncertain behavior, or failed validation rather than preemptively. |
| Very good quality, efficient, latency not critical | GPT-5.6 Sol, high | Default for sustained implementation, debugging, tests, and repository-aware changes. This is the normal agentic-coding route. |
| Maximum coding quality, long wait acceptable | GPT-5.6 Sol, max | Use for difficult architecture, deep root-cause analysis, risky migrations, cross-cutting refactors, or tasks where a shallow first attempt would cause substantial rework. |
| High quality immediately, premium token use acceptable | Claude Opus 4.8 Fast, xhigh | Use for urgent difficult reviews, time-sensitive debugging, or a strong rapid second opinion. Prefer Sol max instead when absolute coding quality matters more than wall-clock latency. |

### Specialist overrides

| Work | Preferred model and effort | Guidance |
| --- | --- | --- |
| UI/UX, interaction design, product wording, visual hierarchy, and design-system judgment | Claude Sonnet 5, medium or high | Ask for concrete implementation and acceptance criteria, not a vague aesthetic pass. Use high when interaction behavior or product tradeoffs are unresolved. |
| Divergent ideation, several product/design directions, naming, creative exploration, or unusually long autonomous discovery | Claude Fable 5, high or xhigh | Use when breadth, originality, and proactive exploration matter. Do not make it the default for routine implementation or bug fixing. |
| Simple lookup, status check, narrow test, or mechanical command | GPT-5.6 Terra, medium, or a faster lightweight model | Do not give it ownership of design decisions or nontrivial edits. |

### Reasoning and token policy

- Use medium when the outcome, files, and implementation approach are already
  clear.
- Use high as the default for agentic coding, debugging, and repository-aware
  implementation.
- Use xhigh for prolonged autonomy, adversarial review, or difficult work with
  important unresolved constraints.
- Use max only when failure or rework is more expensive than the additional
  latency and tokens. Do not use max for routine execution.
- Prefer a stronger prompt, explicit acceptance criteria, and targeted context
  before increasing effort.
- Keep the same capable model through a coherent task. Do not repeatedly switch
  models to save small amounts of tokens if doing so loses useful context.
- If speed is the binding constraint, choose a faster serving mode rather than
  lowering reasoning until the task becomes unreliable.

Model selection is a hypothesis, not a status signal. If an agent is making
unproductive assumptions, missing constraints, or repeatedly failing validation,
change the prompt, context, or model deliberately. Do not retry the same vague
task with several models.

### Escalation ladder

**Exemption first:** swarm-phase skills that fix their model
(`autonomous-discovery-swarm`, `autonomous-micro-sweep`) never escalate —
their agents demote unresolved items to findings. The ladder below applies
only to routed, non-swarm delegation.

Treat capability tiers as a cascade with early exit. For delegable work whose
difficulty is uncertain, start at the cheapest tier that could plausibly
succeed (Luna/Terra), and escalate exactly one tier at a time only on an
explicit signal:

- failed required validation;
- self-reported low confidence on the core answer;
- two consecutive unproductive turns on the same obstacle;
- discovery that the task crosses more files or constraints than briefed.

**Self-consistency before escalation.** When the task has a cheap deterministic
verifier (compiler, tests, schema, a checkable query result), try 2–3
independent attempts at the *same* tier first and let the verifier pick the
winner — this is often cheaper than escalating and matches the strongest
evidence in the routing literature (self-consistency + cascades). Escalate only
if the attempts disagree and the verifier cannot discriminate, or all fail.
For work with no ground truth (open-ended writing, judgment calls), skip this:
parallel attempts on unverifiable work add cost and confidence, not truth —
escalate tier directly instead.

Never escalate preemptively "to be safe", and never skip more than one tier
without evidence. Record every escalation (from-tier, to-tier, trigger) in
session state so routing rules can be tuned later from real outcomes.

## Long-context management

Choose long context separately from model choice. It is useful with any model
when retaining prior information is cheaper and safer than repeatedly
rediscovering it.

Use a long-context tier when the agent must reason across a large code surface,
a lengthy debugging history, multiple specifications or artifacts, an extended
implementation plan, or several dependent decisions made earlier in the same
thread. Long context is especially valuable for preserving constraints and
preventing duplicate exploration during sustained work.

Do not enable it by reflex for a narrow, self-contained task. It does not
replace a clear prompt, focused file selection, or an explicit decision record.
When delegating, include only the context necessary to own the task: the
current goal, relevant decisions, interfaces, constraints, and prior findings.
Summarize completed phases and carry that summary forward rather than pasting
unfiltered transcripts or unrelated code.

If the agent repeatedly reopens settled questions, asks for facts already
established, or loses an important cross-file constraint, preserve the thread
or move the next phase to long context. If it is distracted by stale or
irrelevant material, tighten the brief instead.

## Delegation protocol

**Warm agents before cold launches.** A background sub-agent that finished its
turn stays idle with its full conversation context intact and can be woken
with a follow-up message. That context — explored files, build behavior,
constraints already understood — is paid-for capital; relaunching a fresh
agent for the same role and scope re-pays it. Before launching any sub-agent,
check for an existing idle agent with the same role and an overlapping scope
and send it a follow-up instead. Typical wins: the delivery lead across
consecutive slices of one scope, the quality lead across a QA pass and its
repair loop, swarm researchers re-queried to deepen a specific finding.

Reuse has staleness limits:

- Reuse only if the agent's scope is unchanged since it last worked — verify
  with `git diff --stat` (or equivalent) against the commit it last saw. If
  the scope changed, either send a delta brief ("since your last turn, X and
  Y changed: …") or launch fresh; never let an agent act on a stale picture
  silently.
- Retire an agent after roughly 2–3 substantial tasks: accumulated context
  starts to distract more than it helps. Fresh launch beats a bloated
  veteran.
- Reuse never crosses role boundaries (don't turn an idle researcher into a
  writer) and never crosses repositories.

For every **new** child agent or session, provide a standalone kickoff that
includes:

1. The precise outcome and why it matters.
2. Repository, branch, relevant files, and known constraints.
3. Boundaries: files or concerns it owns, and work it must not overlap.
4. Acceptance criteria and the validation it must run.
5. Required handoff: concise findings, changed files, validation result, and
   unresolved risks.

### Message protocol (kickoffs and reports)

- **Kickoffs number hard constraints** (`C1, C2, ...`) using RFC 2119 force:
  MUST is non-negotiable; SHOULD may be deviated from only with a stated
  reason; MAY is discretion. Untagged wishes are not enforceable.
- **Reports open with the verdict**, line 1: `DONE | PARTIAL | BLOCKED |
  DECLINED` plus the scope it covers, then `CONSTRAINTS: C1 ok, C2 ok, ...` —
  every ID acknowledged or NACK'd with a reason. A report missing a
  constraint ID is treated as a silent violation, not an omission. Never
  open with process narrative.
- **No hedging.** The only valid responses to a request are COMMIT (with
  scope and exclusions), DECLINE (with the blocker), or QUERY naming the
  exact ambiguous item and pausing that item. "I'll try" is not a response.
  QUERY and DECLINE are correct outcomes, scored better than a wrong COMMIT.
  A report with unconfirmed assumptions is PARTIAL, never DONE.
- **Channel economy.** Facts that belong in a named artifact go in the
  artifact; the report carries the pointer plus what changed, ≤ 40 lines of
  prose plus one evidence block. Follow-ups to warm agents send only the
  delta since `last_commit_seen`, never a re-brief; "same for Y" is allowed
  only when the antecedent is named and involved no judgment call.

Use parallel work only for disjoint ownership. If work has a dependency, run the
upstream contract or research first, then give downstream agents the confirmed
interface and branch.

A repository single-writer policy ("only one agent may modify files at a
time") constrains the **concurrency** of writers, never **who** the writer is.
Satisfy it by keeping at most one writing sub-agent active while everything
else stays read-only — not by pulling implementation into the coordinator.
"Since only one agent may write, I'll do it myself" is a delegation failure,
not a compliance strategy. Named invalid justifications for self-implementation
or inline role work: "time constraints", "the repo is single-writer",
"sub-agents here are read-only", "it is faster inline", "the change is small".
Inline artifact production is permitted only where the compiled manifest
explicitly allows it (the LOW-effort compressed chain), never for MEDIUM or
HIGH work.

Single-writer applies per working tree, not per repository. Parallel writing
is safe only when each writer has its own isolated worktree/branch and a
declared file scope disjoint from every other writer's; a shared working tree
never admits two writers, even with disjoint source files (builds, indexes,
and the git index race). Parallel branches are integrated serially by one
integrator: rebase or ff-merge one branch onto main, validate, then take the
next. Before integrating, check the branch diff against its declared scope;
out-of-scope diffs integrate last or are rejected.

**No orphaned worktrees.** Delegated work performed in a worktree is not
finished when the sub-session commits — it is finished when the commit is on
the main branch and the worktree and temporary branch are gone. The
coordinator owns this: track every worktree it (or a child session) creates,
integrate each one before closing the task, and verify with
`git worktree list` / `git branch` that nothing is left behind. Never report
a task complete, or end a session, with work stranded in an unintegrated
worktree. Worktree removal is always performed by the integrator from the
main checkout (`git -C <main> worktree remove ...`), never by an agent
running inside that worktree: removing your own working directory destroys
your session's execution environment mid-task (observed failure mode — the
session loses all shell access and cannot even finish its commit).

Model note for writing sessions: fast hunt-tier models (e.g. Luna) are
reliable for read-only research and content drafting, but have proven
unreliable at multi-step procedural git compliance (branch discipline,
worktree cleanup, exact command sequences). Route any delegated task whose
success depends on following git/process constraints precisely to a
Sonnet-class model at low effort or above.

The coordinator owns integration: compare results against the original goal,
resolve conflicts, ensure interfaces agree, and verify the combined outcome.
Do not present a collection of agent outputs as a completed result.

## Session hygiene

- Reuse an active session when it owns the same feature or failure.
- Start a new session for a separate PR-sized change, a separate repository, or
  a true alternative approach.
- Keep exploration separate from execution only when the exploration is broad
  enough to distract from implementation.
- Finish, summarize, and archive completed child work so future managers do not
  duplicate it.

## Decision checklist

Before spawning work, answer:

1. Is this independent enough to justify a context reset?
2. What model best matches the task's dominant reasoning?
3. Are ownership boundaries and acceptance criteria explicit?
4. Is parallelism safe, or is there an upstream dependency?
5. Who will integrate and verify the final result?

If any answer is unclear, clarify or keep the work in the current session
instead of creating speculative agents.
