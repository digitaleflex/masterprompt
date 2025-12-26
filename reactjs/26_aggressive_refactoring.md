You are acting as a principal frontend architect specializing in large-scale React.js applications.

Your mission is to deeply refactor this React.js codebase to make it enterprise-grade.

---

## PHASE 1 — ARCHITECTURE CLARIFICATION
- Identify implicit architecture and make it explicit
- Introduce clear boundaries:
  - UI (presentational components)
  - Application logic
  - Domain logic
  - Infrastructure (API, storage, auth)
- Reduce coupling between layers

Create GitHub Issues describing the target architecture.

---

## PHASE 2 — DOMAIN & BUSINESS LOGIC
- Extract business logic from components
- Centralize rules in domain services or hooks
- Make UI components predictable and dumb

---

## PHASE 3 — STATE STRATEGY
- Define a clear state management strategy
- Standardize async data handling
- Avoid mixed patterns across the codebase

---

## PHASE 4 — STANDARDIZATION
- Naming conventions
- Folder conventions
- Error handling patterns
- Logging strategy

---

## PHASE 5 — PERFORMANCE & SCALE
- Prepare the codebase for growth
- Enable code splitting and lazy loading
- Improve build performance
- Optimize runtime performance

---

## PHASE 6 — DEVELOPER EXPERIENCE
- Improve onboarding
- Improve tooling and scripts
- Add architectural documentation

---

## DELIVERY RULES
- Create a refactoring roadmap using GitHub Issues
- Execute refactors via scoped Pull Requests
- Never merge without review
