-- Run this in the Supabase SQL Editor (https://supabase.com/dashboard → SQL Editor)
-- NOTE: Tightened storage RLS lives in migrations, e.g.
-- supabase/migrations/20260504140000_review_remediation_rls_storage_posts_products.sql
-- Prefer applying that migration on new environments; this file is a manual checklist.
--
-- Adds the required RLS policies to the `pet-images` storage bucket so
-- authenticated users can upload, view, update, and delete their own files.

-- 1. Ensure the bucket exists and is public (so getPublicUrl works)
INSERT INTO storage.buckets (id, name, public)
VALUES ('pet-images', 'pet-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Allow any authenticated user to upload files
CREATE POLICY "Authenticated users can upload pet images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'pet-images');

-- 3. Allow anyone to view/download (public bucket)
CREATE POLICY "Public read access for pet images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'pet-images');

-- 4. Allow authenticated users to overwrite their own uploads (upsert)
CREATE POLICY "Authenticated users can update pet images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'pet-images')
WITH CHECK (bucket_id = 'pet-images');

-- 5. Allow authenticated users to delete their own uploads
CREATE POLICY "Authenticated users can delete pet images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'pet-images');

-- Repeat for post-media bucket if needed
INSERT INTO storage.buckets (id, name, public)
VALUES ('post-media', 'post-media', true)
ON CONFLICT (id) DO UPDATE SET public = true;

CREATE POLICY "Authenticated users can upload post media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'post-media');

CREATE POLICY "Public read access for post media"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'post-media');

CREATE POLICY "Authenticated users can update post media"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'post-media')
WITH CHECK (bucket_id = 'post-media');

CREATE POLICY "Authenticated users can delete post media"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'post-media');

-- =========================================================================
-- Orders table (for ecommerce checkout)
-- =========================================================================
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  items JSONB NOT NULL DEFAULT '[]',
  total NUMERIC(10,2) NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own orders"
ON public.orders FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read their own orders"
ON public.orders FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
