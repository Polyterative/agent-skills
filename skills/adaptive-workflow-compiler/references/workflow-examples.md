# Workflow Examples

These examples demonstrate compilation. They are patterns, not project facts.

## Example 1: Small bug fix

Input:

> Fix a menu item that remains enabled while no document is selected.

Classification:

- Breadth 0.
- Novelty 0.
- Technical risk 0.
- Validation 1.
- Coordination 0.
- Total 1: LOW.

Compiled workflow:

```text
Current behavior
-> BehaviorContract
-> Expected state rule
-> StrategyReadinessVerdict READY
-> Focused implementation
-> Unit/view-state test
-> Runtime check if required
-> QualityVerdict
-> One fix commit
```

Skipped: opportunity mapping, alternative designs, navigation redesign, and
performance work. The compressed READY gate checks behavior, scope, regression
test, and validation in minutes; it is not a ceremonial full product exercise.

## Example 2: New onboarding capability

Input:

> Improve first-run permission recovery.

Classification:

- Breadth 1.
- Novelty 1.
- Technical risk 1.
- Validation 1.
- Coordination 1.
- Total 5: MEDIUM.

Artifact chain (MEDIUM substitutes merged contracts per
`references/artifact-contracts.md`):

```text
ProblemFrame
-> UserNeedSet
-> StorySet
-> StoryMap/SelectedStory
-> FlowDelta
-> InteractionContract
-> TechnicalContract
-> AcceptanceTestPlan
-> PreparationPacket (TraceabilityMatrix and SliceGraph embedded)
-> StrategyReadinessVerdict READY
-> QualityEvidence
```

Possible slices:

1. Readiness and recovery domain model.
2. Recovery actions and permission recheck.
3. Onboarding UI, accessibility, and snapshots.

## Example 3: Application redesign

Input:

> Redesign the settings experience without making the default view busier.

Classification:

- Breadth 2.
- Novelty 2.
- Technical risk 1.
- Validation 2.
- Coordination 2.
- Total 9: HIGH.

Compiled workflow:

```text
Baseline screenshots/snapshots
-> CurrentJourney
-> SurfaceInventory
-> Preserve inventory
-> Friction analysis
-> Current NavigationModel
-> UserNeedSet
-> 12-30 StorySet
-> StoryMap and selected release slice
-> TargetJourney
-> Two or three DesignDirections
-> Direction selection
-> Target InformationArchitecture
-> Target NavigationModel
-> StateMatrix
-> InteractionSpecification
-> TechnicalContract
-> AcceptanceTestPlan
-> Incremental migration SliceGraph
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Implementation
-> Production-path before/after and layout-stability review
-> Accessibility/runtime/regression QA
```

Quality may return REPLAN if the redesign is polished but worsens the primary
journey or violates the preserve inventory.

## Example 4: Performance improvement

Input:

> Remove micro-stutter from continuous scrolling.

Classification:

- Breadth 1.
- Novelty 1.
- Technical risk 1.
- Validation 2.
- Coordination 1.
- Total 6: MEDIUM.

Compiled workflow:

```text
Representative interaction
-> Baseline measurement/observation
-> Input and display update-path map
-> Hotspot hypothesis
-> TechnicalContract
-> AcceptanceTestPlan
-> PreparationPacket
-> StrategyReadinessVerdict READY (compressed)
-> Focused optimization
-> Comparable measurement
-> Behavior and gesture-phase regression QA
-> Keep/revise/revert
```

## Example 5: Full-pass iteration

Pass 1 completes implementation, but final QA finds that the selected flow
solves permission recovery only after the user reaches an advanced diagnostics
surface. The code works, but the original user need is not met.

Verdict:

```text
REPLAN
owner: product/design
reason: target journey is wrong
```

The coordinator starts pass 2:

```text
UNDERSTAND with pass-1 evidence
-> recompile workflow
-> supersede TargetJourney v1
-> create TargetJourney v2
-> revise slices
-> implement and validate
```

If pass 2 still fails the core journey, the coordinator does not begin pass 3.
It asks once whether to continue, including the remaining gap and recommended
next approach.

## Example 6: Restore previous menu behavior

Input:

> Put back the widget history range selector we had before.

Compiled preparation:

```text
Git/history archaeology
-> Historical BehaviorContract
-> Confirm prior top-level menu placement and choices
-> Current delta
-> One restoration story
-> TechnicalContract
-> AcceptanceTestPlan
-> Focused SliceGraph
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Implementation
-> Historical parity tests and installed-app check
```

The loop must not invent a new submenu placement before recovering the previous
behavior.
