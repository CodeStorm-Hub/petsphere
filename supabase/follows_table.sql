-- =========================================================================
-- Follows table — supports both owner follows and individual pet follows
-- =========================================================================
-- Design:
--   • followed_user_id set → owner follow (implicitly follows all their pets)
--   • followed_pet_id set → individual pet follow (only that pet)
--   • Exactly one of the two must be set (enforced by CHECK constraint)

CREATE TABLE IF NOT EXISTS public.follows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  followed_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  followed_pet_id  UUID REFERENCES public.pets(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT follow_target CHECK (
    (followed_user_id IS NOT NULL AND followed_pet_id IS NULL) OR
    (followed_user_id IS NULL AND followed_pet_id IS NOT NULL)
  )
);

-- Prevent duplicate follows
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_user_follow
  ON public.follows(follower_user_id, followed_user_id)
  WHERE followed_user_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_pet_follow
  ON public.follows(follower_user_id, followed_pet_id)
  WHERE followed_pet_id IS NOT NULL;

-- Lookup indexes
CREATE INDEX IF NOT EXISTS idx_follows_follower
  ON public.follows(follower_user_id);

CREATE INDEX IF NOT EXISTS idx_follows_followed_user
  ON public.follows(followed_user_id)
  WHERE followed_user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_follows_followed_pet
  ON public.follows(followed_pet_id)
  WHERE followed_pet_id IS NOT NULL;

-- Row Level Security
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view follows"
ON public.follows FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can create their own follows"
ON public.follows FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = follower_user_id);

CREATE POLICY "Users can delete their own follows"
ON public.follows FOR DELETE
TO authenticated
USING (auth.uid() = follower_user_id);
