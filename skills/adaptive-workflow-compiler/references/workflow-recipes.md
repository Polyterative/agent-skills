# Workflow Recipes

Recipes are stage patterns, not rigid pipelines. Compose and trim them according
to the task, effort classification, repository evidence, and risk.

## New feature

```text
ProblemFrame
-> UserNeedSet
-> OpportunityMap
-> StorySet
-> StoryMap/SelectedStory
-> TargetJourney
-> UserFlow
-> InformationArchitecture/NavigationModel when affected
-> StateMatrix
-> InteractionSpecification
-> TechnicalContract
-> AcceptanceTestPlan
-> SliceGraph
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Implementation
-> QualityEvidence
-> MilestoneRecord
```

## Redesign

```text
Baseline audit
-> ProblemFrame
-> Preserve inventory
-> CurrentJourney
-> SurfaceInventory
-> Current navigation and StateMatrix
-> UserNeedSet
-> StorySet
-> StoryMap
-> TargetJourney
-> Alternative DesignDirections
-> Selected DesignDirection
-> Target UserFlow
-> InformationArchitecture/NavigationModel
-> InteractionSpecification
-> Migration SliceGraph
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Incremental implementation
-> Production-path before/after visual, interaction-stability, and behavioral QA
-> MilestoneRecord
```

Redesign invariants:

- State what remains unchanged.
- Do not equate redesign with restyling.
- Compare current and target journeys.
- Cover navigation, hierarchy, interaction, copy, accessibility, and all states.
- Prefer incremental migration unless evidence supports replacement.

## Existing-flow improvement

```text
CurrentJourney/UserFlow
-> Friction and failure analysis
-> StorySet/StoryMap/SelectedStory
-> TargetJourney/UserFlow
-> StateMatrix delta
-> InteractionSpecification
-> TechnicalContract
-> AcceptanceTestPlan
-> Focused SliceGraph
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Focused implementation
-> Regression and visual QA
```

## Navigation or information architecture

```text
SurfaceInventory
-> Content/capability inventory
-> User-intent taxonomy
-> Current NavigationModel
-> Findability and context-loss analysis
-> UserNeedSet/StorySet/StoryMap
-> Target InformationArchitecture
-> Target NavigationModel
-> Transition/focus/restoration specification
-> Migration SliceGraph
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Navigation/IA implementation
-> Navigation, keyboard, accessibility, and snapshot QA
```

## Restoration of previous behavior

```text
Restoration request
-> Git/history/documentation archaeology
-> Historical BehaviorContract
-> Current regression/delta
-> User impact and acceptance criteria
-> PreserveInventory
-> Smallest restoration design
-> TechnicalContract
-> AcceptanceTestPlan
-> Focused SliceGraph
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Implementation
-> Historical parity and regression QA
```

Restore parity before redesigning. If the prior behavior cannot be recovered
from history or evidence, label the reconstruction inferred rather than
inventing a new placement or interaction silently.

## Bug or recovery

```text
Reproduction
-> ProblemFrame
-> Failure-state UserFlow
-> BehaviorContract or SelectedStory
-> Root cause
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Regression test
-> Repair
-> Recovery UX when user-visible
-> Runtime verification
-> MilestoneRecord
```

For a pure technical repair, the strategy gate is a compressed review of the
BehaviorContract, root cause, regression plan, scope, and tests. If user-visible
behavior changes, expand to the full story/design preparation chain before
READY.

## Refactor

```text
Architecture map
-> Pain/evidence
-> Preserved behavior and invariants
-> Characterization test plan
-> TechnicalContract
-> AcceptanceTestPlan
-> Refactor SliceGraph
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Characterization tests
-> Refactor implementation
-> Equivalence validation
-> Performance/regression check
-> MilestoneRecord
```

## Migration

```text
Current schema/contract
-> Target schema/contract
-> Compatibility and rollback
-> Migration states and failure recovery
-> Fixture and round-trip plan
-> Incremental SliceGraph
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Migration implementation
-> Upgrade/downgrade/corruption QA
```

## Performance or micro-optimization

```text
Representative scenario
-> Baseline
-> Hotspot evidence
-> Ranked hypotheses
-> Smallest safe experiment
-> BehaviorContract/TechnicalContract
-> AcceptanceTestPlan (regression test reproducing the defect)
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Implementation
-> Comparable measurement
-> Keep/revise/revert decision
-> Regression safeguards
```

Do not select a micro-optimization only because a pattern looks expensive.
Require a meaningful path and an evidence plan.

## Accessibility

```text
Affected journey and surfaces
-> UserNeedSet/StorySet when behavior changes
-> Semantic/focus/input audit
-> StateMatrix accessibility delta
-> InteractionSpecification
-> PreparationPacket
-> StrategyReadinessVerdict READY
-> Implementation
-> Automated and platform-supported accessibility QA
-> Visual checks for contrast, motion, and text expansion
```

## Research or evidence spike

```text
Question and decision it unlocks
-> Evidence plan
-> Safe experiment
-> Observations
-> Confidence and limitations
-> Decision/recommendation
-> Backlog or WorkflowManifest update
```

Research does not silently become production implementation.

## UI production-path gate

For redesign, navigation, or interactive UI work:

- Native snapshots are necessary but not sufficient.
- Establish whether the harness uses the production hosting/container path.
- Exercise repeated selection, disclosure, navigation, resizing, loading, and
  recovery.
- Treat unexpected movement, clipping, focus loss, or route/context loss as
  blocking.
