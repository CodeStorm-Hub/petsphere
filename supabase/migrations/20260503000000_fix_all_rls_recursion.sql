-- Fix infinite recursion by using a SECURITY DEFINER function owned by postgres.

CREATE OR REPLACE FUNCTION public.user_owns_pet(pet_id uuid, user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.pets p
    WHERE p.id = pet_id
      AND p.user_id = user_owns_pet.user_id
  );
$$;

-- Ensure the function runs as postgres so it completely bypasses RLS
ALTER FUNCTION public.user_owns_pet(uuid, uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION public.user_owns_pet(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.user_owns_pet(uuid, uuid) TO authenticated;

-- 1. Fix the pets policy itself to prevent direct recursion
DROP POLICY IF EXISTS "pets_select_authenticated" ON public.pets;
DROP POLICY IF EXISTS "Anyone can view pets" ON public.pets;

CREATE POLICY "pets_select_authenticated"
ON public.pets FOR SELECT
TO authenticated
USING (
  user_id = (SELECT auth.uid())
  OR COALESCE(is_breeding_listed, false) = true
  OR EXISTS (
    SELECT 1
    FROM public.chat_threads t
    WHERE (t.pet_id_1 = pets.id OR t.pet_id_2 = pets.id)
      AND (
        public.user_owns_pet(t.pet_id_1, (SELECT auth.uid()))
        OR public.user_owns_pet(t.pet_id_2, (SELECT auth.uid()))
      )
  )
  OR EXISTS (SELECT 1 FROM public.posts po WHERE po.pet_id = pets.id)
  OR EXISTS (
    SELECT 1
    FROM public.stories st
    WHERE st.pet_id = pets.id
      AND st.expires_at > now()
  )
  OR EXISTS (
    SELECT 1
    FROM public.match_requests mr
    WHERE (mr.sender_pet_id = pets.id OR mr.receiver_pet_id = pets.id)
      AND (
        public.user_owns_pet(mr.sender_pet_id, (SELECT auth.uid()))
        OR public.user_owns_pet(mr.receiver_pet_id, (SELECT auth.uid()))
      )
  )
  OR EXISTS (
    SELECT 1
    FROM public.follows f
    WHERE f.followed_pet_id = pets.id
      AND f.follower_user_id = (SELECT auth.uid())
  )
  OR EXISTS (
    SELECT 1
    FROM public.follows f
    WHERE f.followed_user_id = pets.user_id
      AND f.follower_user_id = (SELECT auth.uid())
  )
);

-- 2. chat_threads
DROP POLICY IF EXISTS "Users can view threads their pets are in" ON public.chat_threads;
CREATE POLICY "Users can view threads their pets are in"
ON public.chat_threads FOR SELECT
TO authenticated
USING (
  public.user_owns_pet(pet_id_1, (SELECT auth.uid())) OR
  public.user_owns_pet(pet_id_2, (SELECT auth.uid()))
);

-- 3. match_requests
DROP POLICY IF EXISTS "Users can view match requests related to their pets" ON public.match_requests;
CREATE POLICY "Users can view match requests related to their pets"
ON public.match_requests FOR SELECT
TO authenticated
USING (
  public.user_owns_pet(sender_pet_id, (SELECT auth.uid())) OR
  public.user_owns_pet(receiver_pet_id, (SELECT auth.uid()))
);

DROP POLICY IF EXISTS "Users can update match requests for their own pets" ON public.match_requests;
CREATE POLICY "Users can update match requests for their own pets"
ON public.match_requests FOR UPDATE
TO authenticated
USING (
  public.user_owns_pet(sender_pet_id, (SELECT auth.uid())) OR
  public.user_owns_pet(receiver_pet_id, (SELECT auth.uid()))
);

DROP POLICY IF EXISTS "Users can send match requests from their own pets" ON public.match_requests;
CREATE POLICY "Users can send match requests from their own pets"
ON public.match_requests FOR INSERT
TO authenticated
WITH CHECK (
  public.user_owns_pet(sender_pet_id, (SELECT auth.uid()))
);

-- 4. messages
DROP POLICY IF EXISTS "Users can view messages in their threads" ON public.messages;
CREATE POLICY "Users can view messages in their threads"
ON public.messages FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.chat_threads t
    WHERE t.id = messages.thread_id
    AND (
      public.user_owns_pet(t.pet_id_1, (SELECT auth.uid())) OR
      public.user_owns_pet(t.pet_id_2, (SELECT auth.uid()))
    )
  )
);

DROP POLICY IF EXISTS "Users can send messages as their pets" ON public.messages;
CREATE POLICY "Users can send messages as their pets"
ON public.messages FOR INSERT
TO authenticated
WITH CHECK (
  public.user_owns_pet(sender_pet_id, (SELECT auth.uid()))
);

-- 5. posts
DROP POLICY IF EXISTS "Users can insert posts for their own pets" ON public.posts;
CREATE POLICY "Users can insert posts for their own pets"
ON public.posts FOR INSERT
TO authenticated
WITH CHECK (
  public.user_owns_pet(pet_id, (SELECT auth.uid()))
);

DROP POLICY IF EXISTS "Users can delete their own posts" ON public.posts;
CREATE POLICY "Users can delete their own posts"
ON public.posts FOR DELETE
TO authenticated
USING (
  public.user_owns_pet(pet_id, (SELECT auth.uid()))
);

-- 6. post_likes
DROP POLICY IF EXISTS "Users can like posts as their own pets" ON public.post_likes;
CREATE POLICY "Users can like posts as their own pets"
ON public.post_likes FOR INSERT
TO authenticated
WITH CHECK (
  public.user_owns_pet(pet_id, (SELECT auth.uid()))
);

DROP POLICY IF EXISTS "Users can unlike posts as their own pets" ON public.post_likes;
CREATE POLICY "Users can unlike posts as their own pets"
ON public.post_likes FOR DELETE
TO authenticated
USING (
  public.user_owns_pet(pet_id, (SELECT auth.uid()))
);

-- 7. comments
DROP POLICY IF EXISTS "Users can comment as their own pets" ON public.comments;
CREATE POLICY "Users can comment as their own pets"
ON public.comments FOR INSERT
TO authenticated
WITH CHECK (
  public.user_owns_pet(pet_id, (SELECT auth.uid()))
);

-- 8. stories
DROP POLICY IF EXISTS "Users can insert stories for their own pets" ON public.stories;
CREATE POLICY "Users can insert stories for their own pets"
ON public.stories FOR INSERT
TO authenticated
WITH CHECK (
  public.user_owns_pet(pet_id, (SELECT auth.uid()))
);

DROP POLICY IF EXISTS "Users can delete their own stories" ON public.stories;
CREATE POLICY "Users can delete their own stories"
ON public.stories FOR DELETE
TO authenticated
USING (
  public.user_owns_pet(pet_id, (SELECT auth.uid()))
);

