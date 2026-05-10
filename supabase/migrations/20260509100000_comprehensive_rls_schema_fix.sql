-- =========================================================================
-- COMPREHENSIVE RLS AND SCHEMA FIX FOR PETSPHERE
-- =========================================================================
-- This migration fixes:
-- 1. Missing or broken user_owns_pet helper function
-- 2. Missing RLS policies on pets table (INSERT, UPDATE, DELETE, SELECT)
-- 3. Storage bucket RLS policies
-- 4. All related table policies using the helper function
-- =========================================================================

BEGIN;

-- ─────────────────────────────────────────────────────────
-- STEP 1: Create/Replace user_owns_pet helper function
-- ─────────────────────────────────────────────────────────
-- This function breaks RLS recursion by running with row_security=off

DROP FUNCTION IF EXISTS public.user_owns_pet(uuid, uuid);

CREATE FUNCTION public.user_owns_pet(pet_id uuid, user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET row_security = OFF
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.pets
    WHERE id = pet_id
      AND user_id = user_id
  )
$$;

GRANT EXECUTE ON FUNCTION public.user_owns_pet(uuid, uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────
-- STEP 2: Ensure pets table exists with RLS enabled
-- ─────────────────────────────────────────────────────────

-- Create pets table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.pets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  name text NOT NULL,
  type text NOT NULL,
  breed text,
  age_years integer,
  age_months integer,
  color text,
  bio text,
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX IF NOT EXISTS pets_user_id_idx ON public.pets (user_id);
CREATE INDEX IF NOT EXISTS pets_created_at_idx ON public.pets (created_at DESC);

-- ─────────────────────────────────────────────────────────
-- STEP 3: Drop all existing pets RLS policies
-- ─────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can view their own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can insert their own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can update their own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can delete their own pets" ON public.pets;
DROP POLICY IF EXISTS "Authenticated users can view all pets" ON public.pets;
DROP POLICY IF EXISTS "Users can create pets" ON public.pets;
DROP POLICY IF EXISTS "Users can insert pets" ON public.pets;

-- ─────────────────────────────────────────────────────────
-- STEP 4: Create new pets RLS policies using helper function
-- ─────────────────────────────────────────────────────────

-- SELECT: Users can see their own pets + all public pets
CREATE POLICY "Authenticated users can view pets"
ON public.pets FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()  -- Own pets
  OR true                -- Can view other pets (public)
);

-- INSERT: Users can create pets (must own them)
CREATE POLICY "Users can insert their own pets"
ON public.pets FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.uid()
);

-- UPDATE: Users can update their own pets
CREATE POLICY "Users can update their own pets"
ON public.pets FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- DELETE: Users can delete their own pets
CREATE POLICY "Users can delete their own pets"
ON public.pets FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- ─────────────────────────────────────────────────────────
-- STEP 5: Ensure posts table has correct RLS policies
-- ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id uuid NOT NULL REFERENCES public.pets (id) ON DELETE CASCADE,
  title text,
  content text NOT NULL,
  media_urls jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can view posts" ON public.posts;
DROP POLICY IF EXISTS "Users can insert posts for their own pets" ON public.posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON public.posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON public.posts;

CREATE POLICY "Authenticated users can view posts"
ON public.posts FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can insert posts for their own pets"
ON public.posts FOR INSERT
TO authenticated
WITH CHECK (
  user_owns_pet(pet_id, auth.uid())
);

CREATE POLICY "Users can update their own posts"
ON public.posts FOR UPDATE
TO authenticated
USING (user_owns_pet(pet_id, auth.uid()))
WITH CHECK (user_owns_pet(pet_id, auth.uid()));

CREATE POLICY "Users can delete their own posts"
ON public.posts FOR DELETE
TO authenticated
USING (user_owns_pet(pet_id, auth.uid()));

-- ─────────────────────────────────────────────────────────
-- STEP 6: Storage bucket policies for pet-images
-- ─────────────────────────────────────────────────────────

-- Create bucket if it doesn't exist (only possible via API, skip in SQL)

-- Drop all existing storage policies for pet-images
DROP POLICY IF EXISTS "Users can upload scoped pet images" ON storage.objects;
DROP POLICY IF EXISTS "Users can read scoped pet images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update scoped pet images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete scoped pet images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload pet images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can read pet images" ON storage.objects;

-- INSERT: Allow authenticated users to upload to pet-images bucket
CREATE POLICY "Users can upload to pet-images bucket"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'pet-images'
  AND (auth.uid()::text = split_part(name, '/', 1)
       OR auth.uid()::text = split_part(split_part(name, '/', 1), '_', 1))
);

-- SELECT: Allow authenticated users to read from pet-images
CREATE POLICY "Users can read from pet-images bucket"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'pet-images');

-- UPDATE: Allow authenticated users to update their own files
CREATE POLICY "Users can update files in pet-images bucket"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'pet-images' AND auth.uid()::text = split_part(name, '/', 1))
WITH CHECK (bucket_id = 'pet-images');

-- DELETE: Allow authenticated users to delete their own files
CREATE POLICY "Users can delete files from pet-images bucket"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'pet-images' AND auth.uid()::text = split_part(name, '/', 1));

-- ─────────────────────────────────────────────────────────
-- STEP 7: Ensure users table exists with minimal RLS
-- ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.users (
  id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  email text UNIQUE,
  full_name text,
  avatar_url text,
  bio text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view all profiles" ON public.users;

CREATE POLICY "Authenticated users can view profiles"
ON public.users FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can update their own profile"
ON public.users FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- ─────────────────────────────────────────────────────────
-- STEP 8: Additional helper table policies
-- ─────────────────────────────────────────────────────────

-- Post likes table
CREATE TABLE IF NOT EXISTS public.post_likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES public.posts (id) ON DELETE CASCADE,
  pet_id uuid NOT NULL REFERENCES public.pets (id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can like posts as their own pets" ON public.post_likes;
DROP POLICY IF EXISTS "Users can unlike posts as their own pets" ON public.post_likes;

CREATE POLICY "Authenticated users can view likes"
ON public.post_likes FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can like posts as their own pets"
ON public.post_likes FOR INSERT
TO authenticated
WITH CHECK (user_owns_pet(pet_id, auth.uid()));

CREATE POLICY "Users can unlike posts as their own pets"
ON public.post_likes FOR DELETE
TO authenticated
USING (user_owns_pet(pet_id, auth.uid()));

COMMIT;
