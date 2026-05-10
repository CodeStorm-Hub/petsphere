# Fixing PostgreSQL RLS Recursion Error on `pets` Table

**Error**: `infinite recursion detected in policy for relation "pets"`

---

## 🔴 Common Causes

### ❌ **Problem 1: Subquery References Same Table**

```sql
-- WRONG - Causes infinite recursion!
CREATE POLICY "can_view_pets" ON pets
FOR SELECT
USING (
  user_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM pets p 
    WHERE p.is_public_owner = true  -- ← References "pets" table inside policy
  )
);
```

**Why it fails**: When checking if a row can be viewed, the policy executes its EXISTS subquery, which triggers the policy again, creating infinite recursion.

---

### ❌ **Problem 2: Policy References Itself via JOIN**

```sql
-- WRONG - Causes infinite recursion!
CREATE POLICY "can_access_pet_data" ON pets
FOR SELECT
USING (
  user_id = auth.uid() OR
  id IN (
    SELECT p.id FROM pets p 
    WHERE p.is_public_owner = true  -- ← References "pets" again
  )
);
```

---

### ❌ **Problem 3: Circular Policy Dependencies**

```sql
-- WRONG - Policies referencing each other
CREATE POLICY "policy_a" ON pets FOR SELECT 
USING (user_id = auth.uid());

CREATE POLICY "policy_b" ON pets FOR SELECT 
USING (
  EXISTS (SELECT 1 FROM posts WHERE pet_id = pets.id)
);

-- Then posts policy references pets...creating circular dependency
```

---

## ✅ **Solution 1: Remove Subquery Reference**

**Fix the recursion by avoiding table self-reference**:

```sql
-- ✅ CORRECT - No subquery reference to same table
CREATE POLICY "can_view_pets" ON pets
FOR SELECT
USING (
  user_id = auth.uid()  -- User owns this pet
  OR is_public_owner = true  -- Or it's publicly listed
);
```

**Key**: Use simple column comparisons, not EXISTS/IN with subqueries on the same table.

---

## ✅ **Solution 2: Use SECURITY DEFINER for Complex Logic**

If you need complex logic, use a SECURITY DEFINER function:

```sql
-- Step 1: Create a helper function (runs as superuser, bypasses RLS)
CREATE OR REPLACE FUNCTION get_pet_ids_for_user(user_id uuid)
RETURNS SETOF uuid AS $$
  SELECT id FROM pets
  WHERE pets.user_id = $1
  OR pets.is_public_owner = true;
$$ LANGUAGE SQL SECURITY DEFINER;

-- Step 2: Use function in policy (doesn't trigger recursion)
CREATE POLICY "can_view_pets" ON pets
FOR SELECT
USING (
  user_id = auth.uid()
  OR is_public_owner = true
  OR id = ANY(get_pet_ids_for_user(auth.uid()))
);
```

**Why it works**: SECURITY DEFINER functions bypass RLS checks, preventing recursion.

---

## ✅ **Solution 3: Use CTE in Function Instead**

```sql
-- Create a secure function with CTE logic
CREATE OR REPLACE FUNCTION check_pet_access(pet_id uuid)
RETURNS boolean AS $$
  WITH user_pets AS (
    SELECT id FROM pets 
    WHERE user_id = auth.uid()
    UNION
    SELECT id FROM pets 
    WHERE is_public_owner = true
  )
  SELECT EXISTS (
    SELECT 1 FROM user_pets WHERE id = $1
  );
$$ LANGUAGE SQL SECURITY DEFINER;

-- Use in policy
CREATE POLICY "can_view_pets" ON pets
FOR SELECT
USING (check_pet_access(id));
```

---

## 🔧 **Complete Safe RLS Setup for `pets`**

### Step 1: Drop Existing Problematic Policies

```sql
-- Drop all existing policies first
DROP POLICY IF EXISTS "can_view_pets" ON pets;
DROP POLICY IF EXISTS "can_insert_pets" ON pets;
DROP POLICY IF EXISTS "can_update_pets" ON pets;
DROP POLICY IF EXISTS "can_delete_pets" ON pets;

-- Disable RLS temporarily while fixing
ALTER TABLE pets DISABLE ROW LEVEL SECURITY;
```

### Step 2: Create Safe Helper Function

```sql
CREATE OR REPLACE FUNCTION is_pet_owner(pet_id uuid)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM pets 
    WHERE id = $1 AND user_id = auth.uid()
  );
$$ LANGUAGE SQL SECURITY DEFINER;
```

### Step 3: Create Safe Policies

```sql
-- SELECT: Users can view their own pets + public pets
CREATE POLICY "select_pets" ON pets
FOR SELECT
USING (
  user_id = auth.uid()  -- Own pets
  OR is_public_owner = true  -- Public pets
);

-- INSERT: Users can only insert as themselves
CREATE POLICY "insert_pets" ON pets
FOR INSERT
WITH CHECK (
  user_id = auth.uid()
);

-- UPDATE: Users can only update their own pets
CREATE POLICY "update_pets" ON pets
FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- DELETE: Users can only delete their own pets
CREATE POLICY "delete_pets" ON pets
FOR DELETE
USING (user_id = auth.uid());
```

### Step 4: Re-enable RLS

```sql
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
```

---

## 🛡️ **RLS Policies for Related Tables**

### For `posts` (no recursion risk)

```sql
CREATE POLICY "can_view_posts" ON posts
FOR SELECT
USING (
  -- User owns the pet that created the post
  pet_id IN (
    SELECT id FROM pets WHERE user_id = auth.uid()
  )
  -- OR post is from a public pet
  OR pet_id IN (
    SELECT id FROM pets WHERE is_public_owner = true
  )
);

CREATE POLICY "can_insert_posts" ON posts
FOR INSERT
WITH CHECK (
  -- Can only post as pets you own
  pet_id IN (
    SELECT id FROM pets WHERE user_id = auth.uid()
  )
);
```

**Why this works**: The subquery doesn't reference `posts` itself, only `pets` from a different table.

### For `pet_care_logs`

```sql
CREATE POLICY "can_view_care_logs" ON pet_care_logs
FOR SELECT
USING (
  pet_id IN (
    SELECT id FROM pets WHERE user_id = auth.uid()
  )
);

CREATE POLICY "can_insert_care_logs" ON pet_care_logs
FOR INSERT
WITH CHECK (
  pet_id IN (
    SELECT id FROM pets WHERE user_id = auth.uid()
  )
);
```

### For `chat_threads`

```sql
CREATE POLICY "can_view_threads" ON chat_threads
FOR SELECT
USING (
  -- User owns one of the pets in the thread
  pet_id_1 IN (SELECT id FROM pets WHERE user_id = auth.uid())
  OR pet_id_2 IN (SELECT id FROM pets WHERE user_id = auth.uid())
);
```

---

## 📋 **Checklist to Avoid Recursion**

- ✅ **Don't reference the same table in subqueries** within the policy
- ✅ **Use SECURITY DEFINER functions** for complex logic
- ✅ **Use simple column comparisons** where possible (e.g., `user_id = auth.uid()`)
- ✅ **Reference OTHER tables** in subqueries (posts, care_logs, etc.)
- ✅ **Test incrementally**: Create one policy at a time
- ✅ **Check policy with simple SELECT first**: `SELECT * FROM pets LIMIT 1;`

---

## 🧪 **Testing Your Policies**

```sql
-- Test as authenticated user
SELECT * FROM pets;  -- Should only see own pets + public pets

-- Test as different user (in separate session)
-- Should see different results

-- Check if policies are active
SELECT schemaname, tablename, policyname, permissive, roles, qual, with_check
FROM pg_policies
WHERE tablename = 'pets';
```

---

## 🔴 **If You Still Get Recursion Error**

### 1. Check Policy Syntax

```sql
-- View all current policies
SELECT * FROM pg_policies WHERE tablename = 'pets';

-- Disable all policies temporarily
ALTER TABLE pets DISABLE ROW LEVEL SECURITY;

-- Test with RLS disabled
SELECT * FROM pets;  -- Should work

-- Re-enable and fix one policy at a time
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
```

### 2. Check for Triggers Causing Recursion

```sql
-- Look for triggers that might cause issues
SELECT trigger_name, event_object_table, action_statement
FROM information_schema.triggers
WHERE event_object_table = 'pets';
```

### 3. Use Simpler Policies First

```sql
-- Start with the simplest possible policy
ALTER TABLE pets DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "select_pets" ON pets;

-- Simplest: Owner only
CREATE POLICY "select_pets" ON pets
FOR SELECT
USING (user_id = auth.uid());

ALTER TABLE pets ENABLE ROW LEVEL SECURITY;

-- Test
SELECT * FROM pets;  -- Should only return your pets
```

---

## 📚 **Key Principles**

1. **RLS policies should NOT reference their own table in subqueries**
2. **Use SECURITY DEFINER functions for complex authorization logic**
3. **Test policies incrementally (one at a time)**
4. **Use Supabase Studio to inspect policies visually**
5. **Always have a superuser bypass for debugging**

---

## 🆘 **Emergency: Disable RLS Completely**

If policies are completely broken:

```sql
-- As superuser
ALTER TABLE pets DISABLE ROW LEVEL SECURITY;
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;
ALTER TABLE messages DISABLE ROW LEVEL SECURITY;
-- ... etc for all tables

-- Now fix policies one table at a time
```

---

**Last Updated**: 2026-05-09  
**PostgreSQL**: 17.6.1  
**Supabase RLS**: Latest
