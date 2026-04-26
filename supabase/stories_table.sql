-- Stories expire after 24 hours and reuse the existing post-media storage bucket.
CREATE TABLE IF NOT EXISTS public.stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id UUID NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  media_url TEXT NOT NULL,
  caption TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '24 hours')
);

CREATE INDEX IF NOT EXISTS idx_stories_expires_at
ON public.stories (expires_at DESC);

CREATE INDEX IF NOT EXISTS idx_stories_pet_created
ON public.stories (pet_id, created_at DESC);

ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can view active stories" ON public.stories;
CREATE POLICY "Authenticated users can view active stories"
ON public.stories FOR SELECT
TO authenticated
USING (expires_at > now());

DROP POLICY IF EXISTS "Users can insert stories for their own pets" ON public.stories;
CREATE POLICY "Users can insert stories for their own pets"
ON public.stories FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.pets
    WHERE pets.id = stories.pet_id
    AND pets.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Users can delete their own stories" ON public.stories;
CREATE POLICY "Users can delete their own stories"
ON public.stories FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.pets
    WHERE pets.id = stories.pet_id
    AND pets.user_id = auth.uid()
  )
);

-- Tell PostgREST/Supabase API to refresh its schema cache immediately.
NOTIFY pgrst, 'reload schema';
