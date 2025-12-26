# Prompt 2 - App Router Misuse Detection

You are auditing a Next.js App Router codebase.

Identify:
- Client Components that should be Server Components
- Overuse of "use client"
- Invalid side-effects in Server Components
- Improper data fetching inside Client Components
- Route segments and layouts misuse

For each issue:
- Explain why it is problematic
- Classify severity (critical / moderate / minor)
- Propose a concrete refactoring path