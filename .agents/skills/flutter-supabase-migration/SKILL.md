---
name: flutter-supabase-migration
description: Scaffold and manage Supabase database migrations for PetSphere
disable-model-invocation: false
user-invocable: true
---

# Flutter Supabase Migration Helper

Generate migration files, review schema changes, and manage PostgreSQL schema evolution for PetSphere's Supabase backend.

## Quick Usage

```bash
/flutter-supabase-migration --action create --table users --fields "name:text, email:text:unique"
```

## What This Does

- **Create**: Scaffold new migration files with SQL templates
- **Review**: Analyze schema changes for RLS policies and indexes
- **Validate**: Check migration syntax and Supabase compatibility
- **Rollback**: Generate rollback scripts

## Common Workflows

### Create a New Table Migration

```bash
/flutter-supabase-migration --action create --table pet_health_metrics \
  --fields "pet_id:uuid:fk(pets),metric_type:text,value:float,recorded_at:timestamp"
```

Generates migration file with:
- Table creation with proper types and constraints
- RLS policy stubs (to be configured)
- Index recommendations
- Timestamp audit columns

### Add a Column to Existing Table

```bash
/flutter-supabase-migration --action add-column --table pets \
  --column "care_goals:jsonb" --default "'{}'::jsonb"
```

### Generate RLS Policy Template

```bash
/flutter-supabase-migration --action rls --table pets --policy "users own pets"
```

## Migration File Location

Migrations are stored in: `supabase/migrations/`

Each file is named: `TIMESTAMP_description.sql`

Example:
```
supabase/migrations/20260508120000_create_pet_health_metrics.sql
```

## Important Notes

- Always review generated migrations before applying
- Test migrations on a development branch first: `supabase db push --local`
- Include RLS policies for data isolation
- Add indexes for performance-critical queries
- Document schema changes in AGENTS.md after merge

## Reference

- [Supabase Migrations Docs](https://supabase.com/docs/guides/migrations/using-cli)
- [PostgreSQL Data Types](https://www.postgresql.org/docs/current/datatype.html)
- [RLS Best Practices](https://supabase.com/docs/guides/auth/row-level-security)
