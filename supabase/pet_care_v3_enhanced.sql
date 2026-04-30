-- =========================================================================
-- Pet Care V3: Enhanced gamification, activity tracking, treat tracking
-- Project: PetSphere
-- =========================================================================

-- ─────────────────────────────────────────────────────────
-- 1. Streak freeze support on pet_care_gamification
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.pet_care_gamification
  ADD COLUMN IF NOT EXISTS streak_freezes_available int NOT NULL DEFAULT 2,
  ADD COLUMN IF NOT EXISTS streak_freezes_used_this_week int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS streak_freeze_reset_on date;

-- ─────────────────────────────────────────────────────────
-- 2. Treat/snack tracking on pet_care_logs
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.pet_care_logs
  ADD COLUMN IF NOT EXISTS treats_count int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS treats_kcal int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS snack_fed bool NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS snack_kcal int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS snack_food text NOT NULL DEFAULT '';

-- ─────────────────────────────────────────────────────────
-- 3. Activity/exercise logs table
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pet_activity_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id uuid NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  log_date date NOT NULL DEFAULT CURRENT_DATE,
  activity_type text NOT NULL CHECK (activity_type IN (
    'walk', 'run', 'play', 'swim', 'training', 'grooming', 'social', 'free_roam', 'other'
  )),
  duration_minutes int NOT NULL DEFAULT 0,
  intensity text NOT NULL DEFAULT 'moderate' CHECK (intensity IN ('low', 'moderate', 'high')),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pet_activity_logs_pet_date
  ON public.pet_activity_logs (pet_id, log_date DESC);

-- RLS for pet_activity_logs
ALTER TABLE public.pet_activity_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "owner read activity_logs" ON public.pet_activity_logs FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner insert activity_logs" ON public.pet_activity_logs FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner update activity_logs" ON public.pet_activity_logs FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner delete activity_logs" ON public.pet_activity_logs FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));

-- ─────────────────────────────────────────────────────────
-- 4. New badge definitions
-- ─────────────────────────────────────────────────────────
INSERT INTO public.care_badge_definitions (slug, title, description, icon_emoji, sort_order) VALUES
  ('streak_14', 'Fortnight Force', '14 consecutive days of complete care', '💪', 25),
  ('health_hero', 'Health Hero', 'Log all vitals in a single week', '🩺', 35),
  ('nutrition_ninja', 'Nutrition Ninja', 'Track feeding for 7 consecutive days', '🥗', 40),
  ('hydration_station', 'Hydration Station', 'Meet water goals 7 days in a row', '💧', 45),
  ('perfect_week', 'Perfect Week', 'Complete all tasks Monday through Sunday', '🗓️', 50),
  ('vet_ready', 'Vet Ready', 'Schedule and complete a vet visit', '🏥', 55),
  ('weight_watcher', 'Weight Watcher', 'Log weight 4 weeks running', '⚖️', 60),
  ('dental_devotee', 'Dental Devotee', 'Log dental care 4 times in a month', '🦷', 65),
  ('mood_tracker', 'Mood Tracker', 'Log mood 7 consecutive days', '😊', 70),
  ('points_500', '500 Club', 'Earn 500 lifetime care points', '🌟', 75),
  ('multi_pet_master', 'Multi-Pet Master', 'Maintain streaks for 2+ pets simultaneously', '🎭', 80)
ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────
-- 5. Add gender + neutered to pets (for calorie calc)
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.pets
  ADD COLUMN IF NOT EXISTS gender text CHECK (gender IN ('male', 'female', 'unknown')),
  ADD COLUMN IF NOT EXISTS is_neutered boolean DEFAULT false;
