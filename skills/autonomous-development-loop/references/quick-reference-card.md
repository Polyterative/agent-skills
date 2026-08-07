# Autonomous Development Loop — Normal Procedures Card

Read-do. Every box must be checked with observable evidence, not recalled from
memory. If any box is unchecked, stop and route to the owning stage — do not
narrate past a failed box. Rationale, stage descriptions, and the full
sequencing rules live in `SKILL.md`; this card is the only thing you must
re-derive from memory each pass.

## BEFORE-DELEGATE (C1-C7)

Run before every sub-agent or child-session invocation (DISCOVER, DESIGN,
DIRECT, IMPLEMENT, QA, or any swarm member).

- [ ] **C1** `session_state["WorkflowManifest"]` exists AND lists this slice's id.
- [ ] **C2** `session_state["PreparationPacket"]` exists as a named artifact
      (not inline conversation text).
- [ ] **C3** `session_state["StrategyReadinessVerdict"]` == `READY`.
- [ ] **C4** `SELECT status FROM todos WHERE id IN (<this stage's deps>)` →
      every row == `done`.
- [ ] **C5** `AcceptanceTestPlan` row count == (`StorySet` row count +
      applicable `StateMatrix` row count), or every gap carries a named
      `justified_exception` id.
- [ ] **C6** This turn's action is a `task`/sub-agent/child-session tool call —
      not an `edit`/`create` tool call targeting a production-code path.
- [ ] **C7** `AgentRegistry` checked for an idle agent with the same role and
      overlapping, non-stale scope before issuing a cold launch (per
      `model-aware-orchestration` §Delegation protocol warm-agent reuse).

## BEFORE-COMMIT (K1-K7)

Run before every `validated-milestone-commit` invocation.

- [ ] **K1** `git diff --staged --stat` file/hunk list ⊆ `ScopeMap[milestone]`
      (no unmapped file or hunk).
- [ ] **K2** `session_state["StrategyReadinessVerdict"]` == `READY`.
- [ ] **K3** Repository's declared focused-test command: exit code `0`
      (record the command and its exit code).
- [ ] **K4** Repository's declared broader/required-suite command: exit code
      `0`, or explicitly marked not-applicable per written repository policy.
- [ ] **K5** `AcceptanceTestPlan`: `COUNT(status != 'green' AND
      justified_exception IS NULL) == 0`.
- [ ] **K6** `living-project-knowledge` artifact's last-updated marker is
      newer than this milestone's start checkpoint.
- [ ] **K7** Repository commit/push/branch policy re-read this turn and
      confirmed to permit this commit in this context.

STOP if any box is unchecked. Route to the owning stage; do not proceed on
partial evidence.
