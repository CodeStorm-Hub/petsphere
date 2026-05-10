-- =========================================================================
-- Core Table Row Level Security (RLS) Policies
-- =========================================================================

-- ─────────────────────────────────────────────────────────
-- PETS TABLE
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view pets" ON public.pets;
CREATE POLICY "Anyone can view pets"
ON public.pets FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Users can insert their own pets" ON public.pets;
CREATE POLICY "Users can insert their own pets"
ON public.pets FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own pets" ON public.pets;
CREATE POLICY "Users can update their own pets"
ON public.pets FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own pets" ON public.pets;
CREATE POLICY "Users can delete their own pets"
ON public.pets FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────
-- PROFILES TABLE
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view profiles" ON public.profiles;
CREATE POLICY "Anyone can view profiles"
ON public.profiles FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile"
ON public.profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- ─────────────────────────────────────────────────────────
-- POSTS TABLE
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view posts" ON public.posts;
CREATE POLICY "Anyone can view posts"
ON public.posts FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Users can insert posts for their own pets" ON public.posts;
CREATE POLICY "Users can insert posts for their own pets"
ON public.posts FOR INSERT
TO authenticated
WITH CHECK (
  user_owns_pet(posts.pet_id, (SELECT auth.uid()))
);

DROP POLICY IF EXISTS "Users can delete their own posts" ON public.posts;
CREATE POLICY "Users can delete their own posts"
ON public.posts FOR DELETE
TO authenticated
USING (
  user_owns_pet(posts.pet_id, (SELECT auth.uid()))
);

DROP POLICY IF EXISTS "Users can update their own posts" ON public.posts;
CREATE POLICY "Users can update their own posts"
ON public.posts FOR UPDATE
TO authenticated
USING (
  user_owns_pet(posts.pet_id, (SELECT auth.uid()))
)
WITH CHECK (
  user_owns_pet(posts.pet_id, (SELECT auth.uid()))
);

-- ─────────────────────────────────────────────────────────
-- POST LIKES TABLE
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view likes" ON public.post_likes;
CREATE POLICY "Anyone can view likes"
ON public.post_likes FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Users can like posts as their own pets" ON public.post_likes;
CREATE POLICY "Users can like posts as their own pets"
ON public.post_likes FOR INSERT
TO authenticated
WITH CHECK (
  user_owns_pet(post_likes.pet_id, (SELECT auth.uid()))
);

DROP POLICY IF EXISTS "Users can unlike posts as their own pets" ON public.post_likes;
CREATE POLICY "Users can unlike posts as their own pets"
ON public.post_likes FOR DELETE
TO authenticated
USING (
  user_owns_pet(post_likes.pet_id, (SELECT auth.uid()))
);

-- ─────────────────────────────────────────────────────────
-- COMMENTS TABLE
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view comments" ON public.comments;
CREATE POLICY "Anyone can view comments"
ON public.comments FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Users can comment as their own pets" ON public.comments;
CREATE POLICY "Users can comment as their own pets"
ON public.comments FOR INSERT
TO authenticated
WITH CHECK (
  user_owns_pet(comments.pet_id, (SELECT auth.uid()))
);

-- ─────────────────────────────────────────────────────────
-- MATCH REQUESTS TABLE
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.match_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view match requests related to their pets" ON public.match_requests;
CREATE POLICY "Users can view match requests related to their pets"
ON public.match_requests FOR SELECT
TO authenticated
USING (
  user_owns_pet(match_requests.sender_pet_id, (SELECT auth.uid()))
  OR user_owns_pet(match_requests.receiver_pet_id, (SELECT auth.uid()))
);

DROP POLICY IF EXISTS "Users can send match requests from their own pets" ON public.match_requests;
CREATE POLICY "Users can send match requests from their own pets"
ON public.match_requests FOR INSERT
TO authenticated
WITH CHECK (
  user_owns_pet(match_requests.sender_pet_id, (SELECT auth.uid()))
);

DROP POLICY IF EXISTS "Users can update match requests for their own pets" ON public.match_requests;
CREATE POLICY "Users can update match requests for their own pets"
ON public.match_requests FOR UPDATE
TO authenticated
USING (
  user_owns_pet(match_requests.sender_pet_id, (SELECT auth.uid()))
  OR user_owns_pet(match_requests.receiver_pet_id, (SELECT auth.uid()))
);

-- ─────────────────────────────────────────────────────────
-- CHAT THREADS & MESSAGES
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.chat_threads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view threads their pets are in" ON public.chat_threads;
CREATE POLICY "Users can view threads their pets are in"
ON public.chat_threads FOR SELECT
TO authenticated
USING (
  user_owns_pet(chat_threads.pet_id_1, (SELECT auth.uid()))
  OR user_owns_pet(chat_threads.pet_id_2, (SELECT auth.uid()))
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view messages in their threads" ON public.messages;
CREATE POLICY "Users can view messages in their threads"
ON public.messages FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.chat_threads t
    WHERE t.id = messages.thread_id
    AND (
      user_owns_pet(t.pet_id_1, (SELECT auth.uid()))
      OR user_owns_pet(t.pet_id_2, (SELECT auth.uid()))
    )
  )
);

DROP POLICY IF EXISTS "Users can send messages as their pets" ON public.messages;
CREATE POLICY "Users can send messages as their pets"
ON public.messages FOR INSERT
TO authenticated
WITH CHECK (
  user_owns_pet(messages.sender_pet_id, (SELECT auth.uid()))
);
