---
name: controlled-language-authoring
description: Use whenever writing or editing skill files, agent kickoff prompts, agent-facing documentation, or similar structured agent-facing instructions. Do not trigger for routine chat replies.
---

# Controlled-Language Authoring

Write agent-facing text so models of different capability can parse the task,
constraints, and expected result with minimal ambiguity and token waste. This
skill is inspired by controlled-language principles, but it is not a copy of
ASD-STE100 and does not require its fixed vocabulary. See
model-aware-orchestration §Message protocol for the canonical constraint-ID
and verdict mechanics.

## Writing rules

1. **W1 — Put the action first.** Start an instruction with a direct imperative.
   Bad: "You should make sure that the tests are run." Good: "Run the tests."

2. **W2 — Give one instruction per sentence.** Split actions that can fail or
   be validated separately. Bad: "Read the file and edit it and run tests."
   Good: "Read the file. Edit it. Run the tests."

3. **W3 — Prefer active voice.** Name the agent or tool that performs the work.
   Bad: "The change should be reviewed by the quality lead." Good: "Ask the quality lead to review the change."

4. **W4 — Use one term for one concept.** Choose a canonical term and reuse it.
   Bad: "skill, playbook, or capability file." Good: "skill file."

5. **W5 — Define local terms once.** Use a small project glossary for names that
   carry special meaning. Bad: "Use the normal gate." Good: "Use the StrategyReadinessVerdict gate."

6. **W6 — Keep sentences short.** Target no more than 20 words for instructions
   and 25 words for descriptions, adapted from published ASD-STE100 sentence-length
   limits. Bad: "After you inspect the files, which may reveal several possible paths, select the one that best..." Good: "Inspect the files. Select one path."

7. **W7 — Replace abstract nouns with concrete verbs.** State the observable
   operation. Bad: "Perform an evaluation of the diff." Good: "Review the diff."

8. **W8 — Remove hedging and filler.** State required behavior with RFC 2119
   keywords when force matters. Bad: "You may want to perhaps check..." Good: "MUST check..."

9. **W9 — Make conditions explicit.** Put the condition before the action and
   name the failure outcome. Bad: "Continue if needed." Good: "If the focused test fails, fix the change before continuing."

10. **W10 — Avoid ambiguous gerunds.** Use a finite verb when a word could name
    either an action or a subject. Bad: "Before testing the migration..." Good: "Before you test the migration..."

11. **W11 — Limit noun clusters.** Use a preposition or a short definition when
    stacked nouns hide relationships. Bad: "agent kickoff prompt quality gate." Good: "quality gate for the agent kickoff prompt."

12. **W12 — Keep lists parallel.** Start sibling items with the same grammatical
    form. Bad: "Read the brief; tests; and documenting results." Good: "Read the brief; run tests; document results."

13. **W13 — Separate requirements from rationale.** Put the required action first
    and the reason second. Bad: "Because context is expensive, you should..." Good: "Reuse the existing context. This reduces token waste."

14. **W14 — Preserve closed vocabularies.** Keep verdicts, status values, and
    constraint IDs exact. Bad: "Return complete or partly done." Good: "Return DONE or PARTIAL."

15. **W15 — Make references resolvable.** Name a file, section, identifier, or
    exact command. Bad: "Follow the project rules." Good: "Read `AGENTS.md` before editing."

16. **W16 — Avoid negative constructions.** State the positive condition instead
    of a double negative. Bad: "Do not skip validation unless not required." Good: "Run validation. Skip it only when the repo marks it not-applicable."

## When NOT to compress

Precision beats brevity when a shorter sentence would hide scope, ordering,
exceptions, safety boundaries, ownership, failure behavior, or acceptance
criteria. Keep a longer sentence only when splitting it would lose that
relationship. Prefer a short definition, table, or numbered sequence instead
of dense prose.

## Worked example

Before: "It would probably be a good idea for the agent to go ahead and take a
look at the config files, and if it happens to notice anything that seems like
it might not be quite right, it should think about maybe flagging it, unless
of course that seems unnecessary." After: "Inspect the config files. If a
value looks wrong, flag it. Do not flag values that match the documented
defaults."

## Self-check

- Does every action use an imperative verb?
- Does each sentence contain at most one independently testable instruction?
- Are the same concepts named with the same terms?
- Are instructions at most 20 words and descriptions at most 25 words?
- Did I remove hedging, filler, ambiguous gerunds, and unnecessary nominalizations?
- Are conditions, failure outcomes, verdicts, and constraint IDs explicit?
- Are list items parallel and noun clusters easy to parse?
- Did I preserve precision instead of compressing an important exception?
- Did I state positive conditions instead of negative or double-negative constructions?
