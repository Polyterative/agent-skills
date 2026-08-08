---
name: readme-abstraction-ladder
description: Write or restructure a README (or similar top-level project document) as an abstraction ladder — one italic tagline, then strictly increasing detail from a plain-English pitch through concrete usage examples, concept, problems solved, components, and architecture, using color-coded and legend-carrying diagrams. Use when asked to write, rewrite, restructure, or improve a README's structure, clarity, or diagrams, or when asked to write project documentation "the way I like it."
---

# README Abstraction Ladder

Write project documentation so a first-time reader understands the point in
one sentence, forms a mental model in one diagram, sees themselves using it
in the next section, and only then reaches implementation detail. Every
section must add more detail than the one before it. Never put a mechanical
detail above a conceptual one.

## Section order (non-negotiable)

Order top to bottom, low detail to high detail. Do not reorder for
alphabetical, importance, or category reasons — reorder only by information
density.

1. **Title.**
2. **Tagline.** One italic sentence, no blockquote marker, no jargon. State
   what the thing is, then what it does. Example shape: "A \[category] that
   \[does X]: \[one-line mechanism]."
3. **Top-level diagram.** 3-6 nodes, `flowchart LR`. Show the shape of the
   whole system in one glance: input, main transform, output. Follow with one
   sentence that names the diagram's flow in words, not just symbols.
4. **Example triggers or usage.** 2-4 real, concrete examples before any
   concept or theory. Redact identifying specifics (project names, client
   names) but keep exact phrasing that shows real usage. Quote the actual
   trigger text; do not paraphrase it into cleaner language. Follow each
   example with one sentence on how the system routes or handles it.
5. **Concept.** Explain the underlying idea and any known patterns it mirrors.
   State the optimization target explicitly if the system trades one
   property against another (for example, quality vs. token cost). If
   autonomy or some other design push produced a side benefit that was not
   the original goal, name it as an explicit "emergent effect," not as a
   planned feature.
6. **Problems this solves.** Ground every claimed benefit in the actual
   source material — skill files, code comments, commit messages, or design
   docs already in the repository. Quote verbatim, cite the file, and name
   the concrete failure mode before naming the fix. Do not assert a benefit
   that cannot be traced to an existing line of text or code.
7. **Components.** Enumerate the parts. Group by role, not alphabetically.
   One line per component: name, then what it does, in that order.
8. **Architecture.** The most detailed section. Numbered structural rules,
   a detailed diagram, and compact legend tables (not prose legends).
9. **Install / mechanics.** Copy-pasteable commands last, because they are
   the most detail-dense and least conceptually interesting content.
10. **Status, license, or other closing mechanics.**

## Diagram rules

- Prefer Mermaid `flowchart` blocks; they render inline in supporting
  editors.
- Use `flowchart LR` for the top-level glance diagram — left-to-right reads
  as "input becomes output," which is the correct framing for a first
  glance. Reserve `flowchart TD` for a detailed diagram with more than one
  branch level or a parallel/support layer, where a vertical layout has room
  to show cross-cutting dashed edges without crossing the main flow.
- Color-code nodes by the dimension the reader most needs (for example: who
  executes it, what it costs, or what stage it belongs to), not by
  aesthetics. Use `classDef` plus `class` assignments so the mapping is
  explicit in the diagram source, not left to default theme colors.
- Give every color and every distinct edge style (solid vs. dashed) a
  one-line meaning in a compact Markdown table directly under the diagram.
  Never explain a diagram's legend in a paragraph when a table says the same
  thing in less space.
- Follow every diagram with one short paragraph that states the reading
  order and the one or two rules a viewer could miss (for example, which
  arrows are blocking gates versus parallel/non-blocking calls).

## Example triggers section rules

- Pull real trigger phrasing from project history when available (commit
  messages, past prompts, session logs) rather than inventing idealized
  examples.
- Generalize away identifying specifics — project names, people, internal
  systems — but do not smooth out real phrasing, typos, or the shape of how
  a real user actually asked for the work.
- Order examples from least to most structured input (fully open-ended
  first, explicit-skill-and-constraints last, or similar), so the section
  itself demonstrates that the system accepts a range of input precision.
- After each quoted example, add one sentence connecting the trigger's
  properties (named skill or not, named effort or not, scoped or open) to
  how the system routes it. Do not just quote and move on.

## Problems-this-solves rules

- Research the actual source material before writing this section. If
  citing rules or guardrails from other files in the same repository,
  quote them exactly and give a resolvable reference (file name, or file
  and line number).
- State the failure mode first, in concrete terms a reader recognizes
  ("two agents writing the same file," not "coordination issues"), then the
  mechanism that prevents it.
- Keep each item to one problem and one fix. Do not combine two unrelated
  failure modes in a single bullet.

## Self-check before finishing

- Does detail strictly increase from top to bottom, with no mechanical
  detail above a conceptual section?
- Is the tagline one italic sentence with no markdown blockquote syntax?
- Does the top diagram have 6 nodes or fewer and read left-to-right?
- Are example triggers quoted verbatim (redacted only for identifying
  specifics), not paraphrased?
- Does every "problem solved" claim trace to a quoted, cited source rather
  than an assumed benefit?
- Does every diagram have a compact table legend instead of a prose legend?
- Is any claimed benefit that emerged as a side effect of another goal
  labeled explicitly as emergent, not as an original design target?
