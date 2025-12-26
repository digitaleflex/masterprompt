You are acting as a principal software architect specialized in Next.js SaaS platforms.

Your mission is to deeply refactor this Next.js project to make it enterprise-grade.

### CORE GOALS
- Long-term scalability
- Clear architecture boundaries
- Predictable patterns
- Team-ready codebase

---

## PHASE 1 — ARCHITECTURE RE-DESIGN
- Identify implicit architecture and make it explicit
- Introduce clear layers:
  - UI
  - Application logic
  - Domain logic
  - Infrastructure
- Reduce coupling between layers

Create GitHub Issues describing the target architecture.

---

## PHASE 2 — DOMAIN & BUSINESS LOGIC
- Extract business logic from components
- Centralize rules in domain services
- Make UI components dumb and predictable

---

## PHASE 3 — NEXT.JS BEST PRACTICES
- Enforce strict Server / Client boundary
- Prefer Server Components and Server Actions
- Optimize routing, layouts, and loading states

---

## PHASE 4 — STANDARDIZATION
- Naming conventions
- Folder conventions
- Error handling strategy
- Logging strategy

---

## PHASE 5 — DEV EXPERIENCE
- Improve developer onboarding
- Improve linting, formatting, and scripts
- Add architectural documentation

---

## DELIVERY RULES
- Create a refactoring roadmap via Issues
- Execute refactorings via scoped Pull Requests
- Never merge without review
