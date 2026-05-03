-- Fix PostgREST 42P17 "infinite recursion detected in policy for relation pets".
-- pets_select_authenticated referenced public.pets inside EXISTS subqueries, which
-- re-evaluated the same SELECT policy. SECURITY DEFINER must SET row_security = off
-- so the pets table read does not re-enter RLS.

CREATE OR REPLACE FUNCTION public.pet_is_owned_by_auth_user(pet_uuid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.pets p
    WHERE p.id = pet_uuid
      AND p.user_id = (SELECT auth.uid())
  );
$$;

REVOKE ALL ON FUNCTION public.pet_is_owned_by_auth_user(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.pet_is_owned_by_auth_user(uuid) TO authenticated;

DROP POLICY IF EXISTS "pets_select_authenticated" ON public.pets;

CREATE POLICY "pets_select_authenticated"
ON public.pets FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
  OR COALESCE(is_breeding_listed, false) = true
  OR EXISTS (
    SELECT 1 FROM public.chat_threads t
    WHERE (t.pet_id_1 = pets.id OR t.pet_id_2 = pets.id)
    AND (
      public.pet_is_owned_by_auth_user(t.pet_id_1)
      OR public.pet_is_owned_by_auth_user(t.pet_id_2)
    )
  )
  OR EXISTS (SELECT 1 FROM public.posts po WHERE po.pet_id = pets.id)
  OR EXISTS (
    SELECT 1 FROM public.stories st
    WHERE st.pet_id = pets.id AND st.expires_at > now()
  )
  OR EXISTS (
    SELECT 1 FROM public.match_requests mr
    WHERE (mr.sender_pet_id = pets.id OR mr.receiver_pet_id = pets.id)
    AND (
      public.pet_is_owned_by_auth_user(mr.sender_pet_id)
      OR public.pet_is_owned_by_auth_user(mr.receiver_pet_id)
    )
  )
  OR EXISTS (SELECT 1 FROM public.follows f WHERE f.followed_pet_id = pets.id AND f.follower_user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM public.follows f WHERE f.followed_user_id = pets.user_id AND f.follower_user_id = auth.uid())
);