-- Fix public.pets SELECT RLS recursion.
--
-- The previous pets_select_authenticated policy queried public.pets from inside
-- a public.pets policy. Postgres re-applies RLS to that nested read, which can
-- raise: "infinite recursion detected in policy for relation \"pets\"".

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

REVOKE ALL ON FUNCTION public.user_owns_pet(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.user_owns_pet(uuid, uuid) TO authenticated;

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
