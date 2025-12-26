You are acting as a senior React performance engineer.

Your mission is to analyze and optimize the performance of this React.js application.

This is a controlled refactoring mission:
- Improve performance
- Preserve existing behavior
- Avoid premature optimization

---

## STEP 1 — PERFORMANCE AUDIT
Analyze the application to identify:
- Components re-rendering too often
- Heavy computations inside render cycles
- Unstable props and functions
- Inefficient context usage
- Large or unnecessary state trees

Create GitHub Issues summarizing the findings.

---

## STEP 2 — RE-RENDER OPTIMIZATION
Apply improvements where justified:
- Stabilize props and callbacks
- Use memoization (`useMemo`, `useCallback`, `React.memo`) ONLY when necessary
- Reduce prop drilling
- Optimize Context usage to avoid global re-renders

Explain why each optimization is needed.

---

## STEP 3 — ASYNC & DATA HANDLING
Review:
- Data fetching patterns
- Loading and error states
- Over-fetching or duplicated API calls
- Client-side caching opportunities

Improve predictability and perceived performance.

---

## STEP 4 — BUNDLE SIZE & BUILD PERFORMANCE
Analyze:
- Bundle size
- Unused dependencies
- Opportunities for code splitting and lazy loading
- Heavy third-party libraries

Apply optimizations where safe.

---

## STEP 5 — RUNTIME UX PERFORMANCE
Improve:
- Perceived loading speed
- Blocking UI behavior
- Expensive list rendering
- Unnecessary DOM updates

---

## STEP 6 — MEASUREMENT & VALIDATION
- Justify performance improvements
- Avoid micro-optimizations with no real gain
- Keep the codebase readable and maintainable

---

## DELIVERY RULES
- Create one Pull Request per optimization category
- Each PR must include:
  - What was slow
  - Why it was slow
  - What was improved
  - Risk assessment
- Never merge automatically
