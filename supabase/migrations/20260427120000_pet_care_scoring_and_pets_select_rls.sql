-- Pet care idempotent daily scoring + tighter pets SELECT (see docs/pet-care-research.md Implementation notes)
-- Safe to re-run: IF NOT EXISTS / DROP POLICY IF EXISTS

ALTER TABLE public.pet_care_gamification
  ADD COLUMN IF NOT EXISTS daily_point_award_date date,
  ADD COLUMN IF NOT EXISTS daily_point_award_accrued int NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.pet_care_gamification.daily_point_award_date IS
  'Calendar day for which daily_point_award_accrued is valid; client resets on date change.';
COMMENT ON COLUMN public.pet_care_gamification.daily_point_award_accrued IS
  'Points already applied toward total for that day (idempotent cap; no clawback on uncheck).';

DROP POLICY IF EXISTS "Anyone can view pets" ON public.pets;

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
      EXISTS (SELECT 1 FROM public.pets p WHERE p.id = t.pet_id_1 AND p.user_id = auth.uid())
      OR EXISTS (SELECT 1 FROM public.pets p WHERE p.id = t.pet_id_2 AND p.user_id = auth.uid())
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
      EXISTS (SELECT 1 FROM public.pets p WHERE p.id = mr.sender_pet_id AND p.user_id = auth.uid())
      OR EXISTS (SELECT 1 FROM public.pets p WHERE p.id = mr.receiver_pet_id AND p.user_id = auth.uid())
    )
  )
  OR EXISTS (SELECT 1 FROM public.follows f WHERE f.followed_pet_id = pets.id AND f.follower_user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM public.follows f WHERE f.followed_user_id = pets.user_id AND f.follower_user_id = auth.uid())
);
