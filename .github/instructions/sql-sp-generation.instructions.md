---
description: "SQL guidelines for Supabase migrations: naming, safety, RLS-by-default, and review checklist."
applyTo: "supabase/migrations/**/*.sql"
---

# SQL Development (Supabase migrations)

Apply these rules when creating or modifying files in `supabase/migrations/**`.

## Safety rules

- Prefer **idempotent** migrations when possible.
- Use explicit schemas (`public.table_name`) and explicit column lists.
- Avoid hardcoding environment-specific IDs.

## RLS-by-default

- For new tables in `public`, enable RLS and add policies.
- Index the access patterns you expect (especially `(user_id, created_at)` style queries).

## Style / maintainability

- Use consistent naming: `snake_case` for SQL identifiers.
- Keep migrations readable: logical sections with comments.
- Prefer `timestamptz` for user-facing timestamps.

## Review checklist (before merging)

- Does the migration run on a clean DB?
- Are indexes in place for hot queries?
- Is RLS enabled and policies correct?
- Are triggers/functions `security definer` only when truly needed?

## Source

Inspired by the awesome-copilot instruction:
https://github.com/github/awesome-copilot/blob/main/instructions/sql-sp-generation.instructions.md
