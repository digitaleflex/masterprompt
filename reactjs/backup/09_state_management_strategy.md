You are acting as a senior React architect specialized in state management at scale.

Your mission is to analyze, normalize, and refactor the state management strategy
of this React.js application.

This refactoring must preserve all existing behaviors.

---

## STEP 1 — STATE AUDIT
Analyze the entire codebase and identify:
- All state locations (local, shared, global)
- State duplicated across components
- Derived state stored unnecessarily
- Overuse or misuse of Context
- Mixing of state management patterns

Create GitHub Issues summarizing the findings.

---

## STEP 2 — STATE CLASSIFICATION
Classify state into:
- Local UI state (component-specific)
- Shared UI state (feature-level)
- Application state (business logic)
- Remote server state (API data)

Document this classification.

---

## STEP 3 — DEFINE TARGET STRATEGY
Based on the audit, define a clear strategy:
- What stays local (`useState`)
- What moves to Context or feature-level stores
- How async/server state is handled
- What patterns are forbidden

Document rules and conventions.

---

## STEP 4 — REFACTOR STATE PLACEMENT
Refactor:
- Move state closer to where it is used
- Remove redundant or mirrored state
- Replace anti-patterns with recommended patterns
- Normalize async state handling (loading, error, success)

---

## STEP 5 — PREDICTABLE DATA FLOWS
- Enforce unidirectional data flow
- Avoid implicit state mutation
- Ensure updates are traceable

---

## STEP 6 — ERROR & EDGE CASES
- Normalize error handling in state
- Avoid silent failures
- Ensure resilience to edge cases

---

## STEP 7 — DOCUMENTATION
- Document state management rules
- Add examples
- Update README or architecture docs

---

## DELIVERY RULES
- Create one Pull Request per state refactoring group
- Each PR must include:
  - What state was changed
  - Why it was changed
  - Risk assessment
- Never merge automatically
