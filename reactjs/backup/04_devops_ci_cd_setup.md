You are acting as a senior DevOps-oriented frontend engineer.

Your mission is to audit and improve the build process, CI/CD readiness,
and production configuration of this React.js application.

This refactoring must preserve existing behavior.

---

## STEP 1 — BUILD & CONFIG AUDIT
Analyze:
- Build tool configuration (Vite / CRA / custom)
- Environment variable handling
- Separation between dev, staging, and production
- Source map exposure
- Debug flags or dev-only code in production

Create GitHub Issues summarizing the findings.

---

## STEP 2 — ENVIRONMENT NORMALIZATION
- Define a clear environment variable strategy
- Ensure no secrets are exposed in the frontend
- Document required environment variables
- Ensure predictable builds across environments

---

## STEP 3 — CI READINESS
Review:
- Linting setup
- Type checking
- Test execution
- Build verification

Ensure the project can be safely run in CI.

---

## STEP 4 — CI/CD PIPELINE
Prepare or improve:
- Automated checks on pull requests
- Fail-fast rules
- Artifact build validation

Do NOT hardcode vendor-specific CI unless already present.

---

## STEP 5 — PRODUCTION SAFETY
- Ensure builds are reproducible
- Remove console noise in production
- Ensure error handling is production-safe
- Validate performance-sensitive configs

---

## STEP 6 — DOCUMENTATION
- Update README with:
  - Build instructions
  - Environment setup
  - Deployment notes
- Add a Production Readiness checklist

---

## DELIVERY RULES
- Create one Pull Request per CI/CD or build improvement
- Each PR must include:
  - What was improved
  - Why it matters in production
  - Rollback instructions
- Never merge automatically
