# Supabase Backend Configuration

This directory contains all Supabase configuration, migrations, and database setup files for PetSphere.

## Directory Structure

```
supabase/
├── config.toml                    # Supabase CLI configuration
├── .env.local.example            # Environment variables template
├── migrations/                    # Version-controlled schema migrations
│   ├── 20260427120000_*.sql
│   ├── 20260503000000_*.sql
│   └── ...
├── functions/                     # Edge functions (PostgreSQL functions)
├── seed.sql                       # (Optional) seed data for development
├── MIGRATIONS.md                  # Migration workflow documentation
└── README.md                      # This file
```

## Quick Reference

### Local Development

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Start local Supabase
supabase start

# Link to cloud project
supabase link --project-ref foubokcqaxyqgjhtgzsx

# Pull cloud schema
supabase db pull

# Reset local DB with all migrations
supabase db reset

# Make changes and create migration
supabase db pull  # Auto-creates new migration

# Push to production
supabase db push --linked
```

### Important URLs (Local)

- **Database:** `postgresql://postgres:postgres@localhost:54322/postgres`
- **API:** `http://localhost:54321`
- **Studio:** `http://localhost:54323` (Admin interface)

### Important URLs (Production)

- **API URL:** `https://foubokcqaxyqgjhtgzsx.supabase.co`
- **Studio:** `https://app.supabase.com/project/foubokcqaxyqgjhtgzsx`

---

## Understanding Migrations

All schema changes are captured as SQL migration files in `migrations/`. This ensures:

✅ **Reproducibility:** Fresh clone can reconstruct entire schema  
✅ **Auditability:** Every change tracked in git history  
✅ **Safety:** Can review diffs before pushing to production  
✅ **Rollback:** Restore from backup if migration fails  

**See `MIGRATIONS.md` for detailed workflow.**

---

## Setup Steps for New Developers

### 1. Get Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Windows (with Scoop)
scoop install supabase

# Or visit https://supabase.com/docs/guides/cli
```

### 2. Start Local Database

```bash
cd petsphere
supabase start

# First time: creates containers and initializes DB
# Subsequent: resumes containers
```

### 3. Link to Cloud Project

```bash
supabase link --project-ref foubokcqaxyqgjhtgzsx
# Enter database password when prompted (from Supabase dashboard)
```

### 4. Pull Production Schema

```bash
supabase db pull
# Creates migration file with current cloud schema
```

### 5. Verify Local Setup

```bash
supabase db reset
# Applies all migrations, initializes local DB

# Should see:
# ✓ Migrations applied
# ✓ DB ready at postgresql://postgres:postgres@localhost:54322/postgres
```

### 6. Run App

```bash
flutter run
# App connects to local Supabase at http://localhost:54321
```

---

## Environment Variables

Create `.env.local` from `.env.local.example`:

```bash
cp supabase/.env.local.example supabase/.env.local
```

**For local development:** Uses local Supabase defaults (localhost:54321)

**For production:** Use cloud credentials from Supabase dashboard  
Settings → API → Project URL & API Keys

---

## Database Schema

The complete production schema is versioned through migrations. To inspect:

```bash
# List all tables
supabase db tables

# View table schema
supabase db schema get -t pets

# See RLS policies
supabase db policies list
```

**Primary tables:**
- `profiles` — User accounts
- `pets` — Pet profiles
- `posts`, `stories`, `comments` — Social feed
- `pet_care_logs`, `pet_care_gamification` — Care tracking
- `pet_health_*` — Health records (medications, allergies, etc.)
- `match_requests`, `matches` — Pet discovery/dating
- `chat_threads`, `messages` — Messaging
- `notifications` — In-app notifications
- `products`, `orders` — Marketplace
- `follows` — Follow relationships

See `docs/01_CODEBASE_ARCHITECTURE_REVIEW.md` for schema details.

---

## Making Schema Changes

### Scenario 1: Local Development

1. Start Supabase locally: `supabase start`
2. Make changes in Studio: `http://localhost:54323`
3. Create migration: `supabase db pull`
4. Commit: `git add supabase/migrations/...`

### Scenario 2: Adding a New Table

```sql
-- supabase/migrations/20260505120000_add_user_roles_table.sql
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'moderator', 'user')),
  granted_at TIMESTAMP DEFAULT now(),
  UNIQUE(user_id, role)
);

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see their own roles"
  ON public.user_roles FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Only admins can assign roles"
  ON public.user_roles FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );
```

Then:

```bash
supabase db reset  # Apply locally
flutter run        # Test
git add supabase/migrations/20260505120000_add_user_roles_table.sql
git commit -m "Add user roles table"
```

### Scenario 3: Breaking Changes

Document in migration:

```sql
-- BREAKING CHANGE: Removes deprecated products.old_field column
-- Client impact: Update ProductModel to remove oldField property
-- Timeline: Must ship by 2026-06-01

ALTER TABLE public.products DROP COLUMN old_field;
```

Then notify team with migration details.

---

## RLS (Row Level Security) Policies

All tables have RLS enabled. Policies are in migrations. To understand access control:

```bash
# List all policies
supabase db policies list

# View specific table's policies
supabase db schema get -t pets
```

**Key principle:** User can only access their own data unless explicitly shared.

Example: User can only view their own pets:

```sql
CREATE POLICY "Users see their own pets"
  ON public.pets FOR SELECT
  USING (user_id = auth.uid());
```

---

## Testing Migrations

Before pushing to production:

```bash
# 1. Reset local DB (clean state)
supabase db reset

# 2. Test app thoroughly
flutter run

# 3. Verify data integrity
supabase db query "SELECT COUNT(*) FROM pets;"

# 4. Check auth works
# Login/logout flow, permissions, etc.

# 5. Review migration file
cat supabase/migrations/YYYYMMDDHHMMSS_description.sql

# 6. Push when confident
supabase db push --linked
```

---

## Common Issues

**Issue:** `supabase start` fails with port conflicts

**Solution:**
```bash
# Use different ports
docker ps  # Find containers on ports 54321-54327
docker stop <container_id>  # Stop conflicting containers
supabase start
```

---

**Issue:** Local DB is out of sync with migrations

**Solution:**
```bash
supabase db reset
# Removes all tables and reapplies migrations from scratch
```

---

**Issue:** Can't connect to cloud project

**Solution:**
```bash
# Re-link to project
supabase unlink
supabase link --project-ref foubokcqaxyqgjhtgzsx
# Enter password when prompted
```

---

## Resources

- [Supabase CLI Docs](https://supabase.com/docs/guides/cli)
- [Migrations Guide](https://supabase.com/docs/guides/migrations)
- [RLS Examples](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

---

**Status:** ✅ Production-ready migrations workflow  
**Last Updated:** May 5, 2026
