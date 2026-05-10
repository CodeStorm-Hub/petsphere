-- Advisor-driven follow-up fixes:
-- 1) Harden function search_path for SECURITY INVOKER helper
-- 2) Add missing FK-covering index
-- 3) Remove duplicate indexes reported by advisor
-- 4) Tighten waitlist insert policy to avoid WITH CHECK (true)

BEGIN;

-- 1) Harden function execution context
ALTER FUNCTION public.pet_is_owned_by_auth_user(uuid)
  SET search_path = public, pg_catalog;

-- 2) Add missing foreign-key covering index
CREATE INDEX IF NOT EXISTS idx_pet_care_badge_unlocks_badge_slug
  ON public.pet_care_badge_unlocks (badge_slug);

-- 3) Remove duplicate indexes (keep one canonical index per key)
DROP INDEX IF EXISTS public.idx_chat_threads_pet_id_1;
DROP INDEX IF EXISTS public.idx_chat_threads_pet_id_2;
DROP INDEX IF EXISTS public.idx_follows_follower;
DROP INDEX IF EXISTS public.idx_match_requests_receiver_pet_id;
DROP INDEX IF EXISTS public.idx_match_requests_sender_pet_id;
DROP INDEX IF EXISTS public.idx_pet_allergies_pet;
DROP INDEX IF EXISTS public.idx_pet_medications_pet;
DROP INDEX IF EXISTS public.idx_pet_parasite_pet;

-- 4) Tighten permissive waitlist INSERT policy
DROP POLICY IF EXISTS "Public can join waitlist" ON public.waitlist;

CREATE POLICY "Public can join waitlist"
  ON public.waitlist
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (
    email IS NOT NULL
    AND length(trim(email)) > 3
    AND position('@' IN email) > 1
  );

COMMIT;
