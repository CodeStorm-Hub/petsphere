-- =========================================================================
-- FIX: RLS Infinite Recursion by Using SECURITY DEFINER Functions
-- =========================================================================
-- Issue: Direct EXISTS (SELECT 1 FROM public.pets ...) in RLS policies
--        caused infinite recursion (PostgreSQL 42P17 error) because the
--        subquery itself triggered RLS checks on the same table.
--
-- Solution: Replace all direct subqueries with calls to SECURITY DEFINER
--          helper functions that have row_security disabled, breaking the
--          recursion cycle while maintaining security.
--
-- Functions Used:
-- - user_owns_pet(pet_id uuid, user_id uuid)
--   Returns TRUE if the user owns the pet. Executes with row_security=off
--   to avoid triggering RLS checks on the pets table.
--
-- Migration Date: 2026-05-09
-- =========================================================================

BEGIN;

-- ─────────────────────────────────────────────────────────
-- POSTS TABLE - Fix INSERT, UPDATE, DELETE policies
-- ─────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can insert posts for their own pets" ON public.posts;
CREATE POLICY "Users can insert posts for their own pets"
ON public.posts FOR INSERT
TO authenticated
WITH CHECK (
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

DROP POLICY IF EXISTS "Users can delete their own posts" ON public.posts;
CREATE POLICY "Users can delete their own posts"
ON public.posts FOR DELETE
TO authenticated
USING (
  user_owns_pet(posts.pet_id, (SELECT auth.uid()))
);

-- ─────────────────────────────────────────────────────────
-- POST_LIKES TABLE - Fix INSERT, DELETE policies
-- ─────────────────────────────────────────────────────────

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
-- COMMENTS TABLE - Fix INSERT policy
-- ─────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can comment as their own pets" ON public.comments;
CREATE POLICY "Users can comment as their own pets"
ON public.comments FOR INSERT
TO authenticated
WITH CHECK (
  user_owns_pet(comments.pet_id, (SELECT auth.uid()))
);

-- ─────────────────────────────────────────────────────────
-- MATCH_REQUESTS TABLE - Fix SELECT, INSERT, UPDATE policies
-- ─────────────────────────────────────────────────────────

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
-- CHAT_THREADS TABLE - Fix SELECT policy
-- ─────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can view threads their pets are in" ON public.chat_threads;
CREATE POLICY "Users can view threads their pets are in"
ON public.chat_threads FOR SELECT
TO authenticated
USING (
  user_owns_pet(chat_threads.pet_id_1, (SELECT auth.uid()))
  OR user_owns_pet(chat_threads.pet_id_2, (SELECT auth.uid()))
);

-- ─────────────────────────────────────────────────────────
-- MESSAGES TABLE - Fix SELECT, INSERT policies
-- ─────────────────────────────────────────────────────────

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

COMMIT;
