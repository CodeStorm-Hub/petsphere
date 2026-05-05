-- SECURITY DEFINER functions still enforce RLS on underlying tables unless row_security is off.
-- Without this, pets SELECT policy -> user_owns_pet() / pet_is_owned_by_auth_user() -> SELECT pets
-- -> same policy -> PostgREST 42P17 infinite recursion.

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

CREATE OR REPLACE FUNCTION public.user_owns_pet(pet_id uuid, user_id uuid)
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
    WHERE p.id = pet_id
      AND p.user_id = user_owns_pet.user_id
  );
$$;

REVOKE ALL ON FUNCTION public.pet_is_owned_by_auth_user(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.pet_is_owned_by_auth_user(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.user_owns_pet(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.user_owns_pet(uuid, uuid) TO authenticated;