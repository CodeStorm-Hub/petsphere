---
name: sql-code-review
description: "Universal SQL code review checklist (security + maintainability). Use when reviewing Supabase migrations, policies, triggers, or app-generated SQL. Complements postgresql-code-review."
---

# SQL Code Review (universal)

Use this skill to review SQL for correctness, security, and maintainability.

## When to use

- Reviewing `supabase/migrations/**/*.sql`
- Adding RLS policies, triggers, or functions
- Investigating data exposure bugs

## Review checklist

### Security

- Look for overly-broad policies (e.g., `USING (true)` patterns).
- Confirm RLS is enabled where required.
- Avoid `SECURITY DEFINER` unless necessary, and if used:
  - lock down search_path
  - avoid dynamic SQL

### Correctness

- Ensure constraints (PK/FK/unique) match app invariants.
- Ensure timestamp types are appropriate (`timestamptz` when in doubt).

### Maintainability

- Prefer clear naming and comments in migrations.
- Keep functions small and testable.

### Performance

- Verify indexes exist for hot filters/sorts.
- Avoid N+1 query patterns in functions.

## Output

Return a structured report with:
- Findings (severity + rationale)
- Concrete SQL patch suggestions
- Any required follow-up tests/validation steps

## Source

Inspired by the awesome-copilot skill:
https://github.com/github/awesome-copilot/tree/main/skills/sql-code-review
