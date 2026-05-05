-- =========================================================================
-- Pet Care Feature: Tables, indexes, RLS, seed data
-- Run via: supabase db push  (or paste into Supabase SQL Editor)
-- =========================================================================

-- ─────────────────────────────────────────────────────────
-- 0. Extend pets with care defaults & current weight
-- ─────────────────────────────────────────────────────────
ALTER TABLE public.pets
  ADD COLUMN IF NOT EXISTS daily_calorie_goal int,
  ADD COLUMN IF NOT EXISTS daily_water_goal_cups int,
  ADD COLUMN IF NOT EXISTS weight_lbs numeric(6, 2);

-- Reasonable defaults (cat-sized fallback). UI lets owners override per-pet.
UPDATE public.pets
SET daily_calorie_goal = COALESCE(daily_calorie_goal, 500),
    daily_water_goal_cups = COALESCE(daily_water_goal_cups, 8)
WHERE daily_calorie_goal IS NULL OR daily_water_goal_cups IS NULL;

-- ─────────────────────────────────────────────────────────
-- 1. pet_care_logs  — one row per (pet, date)
--    Stores: feeding toggles, water cups, mood, daily checklist items, goals
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pet_care_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id uuid NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  log_date date NOT NULL DEFAULT CURRENT_DATE,
  -- Feeding
  breakfast_fed boolean NOT NULL DEFAULT false,
  dinner_fed boolean NOT NULL DEFAULT false,
  breakfast_kcal int NOT NULL DEFAULT 250,
  dinner_kcal int NOT NULL DEFAULT 250,
  breakfast_food text NOT NULL DEFAULT 'Dry Kibble - 1 cup',
  dinner_food text NOT NULL DEFAULT 'Wet Food - 1/2 can',
  -- Water
  water_cups int NOT NULL DEFAULT 0,
  -- Daily checklist (array of {key, title, subtitle, icon, done})
  tasks jsonb NOT NULL DEFAULT '[
    {"key":"walk","title":"Morning Walk","subtitle":"30 minutes","icon":"pets","done":false},
    {"key":"med","title":"Give Medication","subtitle":"Heartworm pill","icon":"medical_services","done":false},
    {"key":"brush","title":"Brush Coat","subtitle":"Keep it shiny","icon":"brush","done":false}
  ]'::jsonb,
  -- Mood
  mood text,
  -- Goals snapshot (for historical fidelity)
  daily_calorie_goal int NOT NULL DEFAULT 500,
  daily_water_goal_cups int NOT NULL DEFAULT 8,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (pet_id, log_date)
);

CREATE INDEX IF NOT EXISTS idx_pet_care_logs_pet_date
  ON public.pet_care_logs (pet_id, log_date DESC);

-- Auto-bump updated_at
CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS pet_care_logs_touch ON public.pet_care_logs;
CREATE TRIGGER pet_care_logs_touch
BEFORE UPDATE ON public.pet_care_logs
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- ─────────────────────────────────────────────────────────
-- 2. pet_weight_logs  — historical weight measurements
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pet_weight_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id uuid NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  log_date date NOT NULL DEFAULT CURRENT_DATE,
  weight_lbs numeric(6, 2) NOT NULL,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (pet_id, log_date)
);

CREATE INDEX IF NOT EXISTS idx_pet_weight_logs_pet_date
  ON public.pet_weight_logs (pet_id, log_date DESC);

-- ─────────────────────────────────────────────────────────
-- 3. pet_vet_appointments
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pet_vet_appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id uuid NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  title text NOT NULL,
  doctor text,
  scheduled_at timestamptz NOT NULL,
  notes text,
  status text NOT NULL DEFAULT 'scheduled'
    CHECK (status IN ('scheduled', 'completed', 'cancelled')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pet_vet_appointments_pet_when
  ON public.pet_vet_appointments (pet_id, scheduled_at);

-- ─────────────────────────────────────────────────────────
-- 4. pet_vaccinations
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pet_vaccinations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id uuid NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  vaccine_name text NOT NULL,
  status text NOT NULL DEFAULT 'scheduled'
    CHECK (status IN ('scheduled', 'completed')),
  scheduled_for date,
  completed_on date,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pet_vaccinations_pet
  ON public.pet_vaccinations (pet_id, status, scheduled_for);

-- ─────────────────────────────────────────────────────────
-- 5. pet_symptoms  — discrete symptom observations with severity
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pet_symptoms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id uuid NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  observed_at timestamptz NOT NULL DEFAULT now(),
  symptom_type text NOT NULL,
  severity text NOT NULL DEFAULT 'mild' CHECK (severity IN ('mild', 'moderate', 'severe')),
  notes text,
  resolved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pet_symptoms_pet_time
  ON public.pet_symptoms (pet_id, observed_at DESC);

-- =========================================================================
-- ROW LEVEL SECURITY
-- =========================================================================
ALTER TABLE public.pet_care_logs        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pet_weight_logs      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pet_vet_appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pet_vaccinations     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pet_symptoms         ENABLE ROW LEVEL SECURITY;

-- pet_symptoms
DROP POLICY IF EXISTS "Owner can read pet_symptoms"   ON public.pet_symptoms;
DROP POLICY IF EXISTS "Owner can insert pet_symptoms" ON public.pet_symptoms;
DROP POLICY IF EXISTS "Owner can update pet_symptoms" ON public.pet_symptoms;
DROP POLICY IF EXISTS "Owner can delete pet_symptoms" ON public.pet_symptoms;

CREATE POLICY "Owner can read pet_symptoms"
ON public.pet_symptoms FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_symptoms.pet_id AND p.user_id = auth.uid()));

CREATE POLICY "Owner can insert pet_symptoms"
ON public.pet_symptoms FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_symptoms.pet_id AND p.user_id = auth.uid()));

CREATE POLICY "Owner can update pet_symptoms"
ON public.pet_symptoms FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_symptoms.pet_id AND p.user_id = auth.uid()))
WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_symptoms.pet_id AND p.user_id = auth.uid()));

CREATE POLICY "Owner can delete pet_symptoms"
ON public.pet_symptoms FOR DELETE TO authenticated
USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_symptoms.pet_id AND p.user_id = auth.uid()));

-- Reusable predicate: the authenticated user must own the pet referenced.
-- Wrapped per-table because PostgREST doesn't share predicates.

-- pet_care_logs ----------------------------------------------------
DROP POLICY IF EXISTS "Owner can read pet_care_logs"   ON public.pet_care_logs;
DROP POLICY IF EXISTS "Owner can insert pet_care_logs" ON public.pet_care_logs;
DROP POLICY IF EXISTS "Owner can update pet_care_logs" ON public.pet_care_logs;
DROP POLICY IF EXISTS "Owner can delete pet_care_logs" ON public.pet_care_logs;

CREATE POLICY "Owner can read pet_care_logs"
ON public.pet_care_logs FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_care_logs.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can insert pet_care_logs"
ON public.pet_care_logs FOR INSERT TO authenticated
WITH CHECK (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_care_logs.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can update pet_care_logs"
ON public.pet_care_logs FOR UPDATE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_care_logs.pet_id AND p.user_id = auth.uid()
))
WITH CHECK (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_care_logs.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can delete pet_care_logs"
ON public.pet_care_logs FOR DELETE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_care_logs.pet_id AND p.user_id = auth.uid()
));

-- pet_weight_logs --------------------------------------------------
DROP POLICY IF EXISTS "Owner can read pet_weight_logs"   ON public.pet_weight_logs;
DROP POLICY IF EXISTS "Owner can insert pet_weight_logs" ON public.pet_weight_logs;
DROP POLICY IF EXISTS "Owner can update pet_weight_logs" ON public.pet_weight_logs;
DROP POLICY IF EXISTS "Owner can delete pet_weight_logs" ON public.pet_weight_logs;

CREATE POLICY "Owner can read pet_weight_logs"
ON public.pet_weight_logs FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_weight_logs.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can insert pet_weight_logs"
ON public.pet_weight_logs FOR INSERT TO authenticated
WITH CHECK (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_weight_logs.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can update pet_weight_logs"
ON public.pet_weight_logs FOR UPDATE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_weight_logs.pet_id AND p.user_id = auth.uid()
))
WITH CHECK (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_weight_logs.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can delete pet_weight_logs"
ON public.pet_weight_logs FOR DELETE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_weight_logs.pet_id AND p.user_id = auth.uid()
));

-- pet_vet_appointments --------------------------------------------
DROP POLICY IF EXISTS "Owner can read pet_vet_appointments"   ON public.pet_vet_appointments;
DROP POLICY IF EXISTS "Owner can insert pet_vet_appointments" ON public.pet_vet_appointments;
DROP POLICY IF EXISTS "Owner can update pet_vet_appointments" ON public.pet_vet_appointments;
DROP POLICY IF EXISTS "Owner can delete pet_vet_appointments" ON public.pet_vet_appointments;

CREATE POLICY "Owner can read pet_vet_appointments"
ON public.pet_vet_appointments FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_vet_appointments.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can insert pet_vet_appointments"
ON public.pet_vet_appointments FOR INSERT TO authenticated
WITH CHECK (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_vet_appointments.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can update pet_vet_appointments"
ON public.pet_vet_appointments FOR UPDATE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_vet_appointments.pet_id AND p.user_id = auth.uid()
))
WITH CHECK (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_vet_appointments.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can delete pet_vet_appointments"
ON public.pet_vet_appointments FOR DELETE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_vet_appointments.pet_id AND p.user_id = auth.uid()
));

-- pet_vaccinations -------------------------------------------------
DROP POLICY IF EXISTS "Owner can read pet_vaccinations"   ON public.pet_vaccinations;
DROP POLICY IF EXISTS "Owner can insert pet_vaccinations" ON public.pet_vaccinations;
DROP POLICY IF EXISTS "Owner can update pet_vaccinations" ON public.pet_vaccinations;
DROP POLICY IF EXISTS "Owner can delete pet_vaccinations" ON public.pet_vaccinations;

CREATE POLICY "Owner can read pet_vaccinations"
ON public.pet_vaccinations FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_vaccinations.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can insert pet_vaccinations"
ON public.pet_vaccinations FOR INSERT TO authenticated
WITH CHECK (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_vaccinations.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can update pet_vaccinations"
ON public.pet_vaccinations FOR UPDATE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_vaccinations.pet_id AND p.user_id = auth.uid()
))
WITH CHECK (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_vaccinations.pet_id AND p.user_id = auth.uid()
));

CREATE POLICY "Owner can delete pet_vaccinations"
ON public.pet_vaccinations FOR DELETE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.pets p
  WHERE p.id = pet_vaccinations.pet_id AND p.user_id = auth.uid()
));

-- =========================================================================
-- SEED DATA — only inserts if rows are missing for the first pet
-- (no-op for projects with existing data)
-- =========================================================================
DO $$
DECLARE
  seed_pet uuid;
BEGIN
  SELECT id INTO seed_pet FROM public.pets ORDER BY created_at LIMIT 1;
  IF seed_pet IS NULL THEN
    RAISE NOTICE 'No pets found — skipping seed.';
    RETURN;
  END IF;

  -- 5-day streak of completed care logs for the chosen pet
  INSERT INTO public.pet_care_logs (
    pet_id, log_date, breakfast_fed, dinner_fed,
    water_cups, mood,
    tasks
  )
  SELECT seed_pet,
         CURRENT_DATE - i,
         true,
         true,
         8,
         CASE i % 4 WHEN 0 THEN 'Happy' WHEN 1 THEN 'Playful' WHEN 2 THEN 'Sleepy' ELSE 'Happy' END,
         '[
            {"key":"walk","title":"Morning Walk","subtitle":"30 minutes","icon":"pets","done":true},
            {"key":"med","title":"Give Medication","subtitle":"Heartworm pill","icon":"medical_services","done":true},
            {"key":"brush","title":"Brush Coat","subtitle":"Keep it shiny","icon":"brush","done":true}
          ]'::jsonb
  FROM generate_series(1, 5) AS i
  ON CONFLICT (pet_id, log_date) DO NOTHING;

  -- 7 days of weight history (gentle climb, +0.2lbs delta vs prior day)
  INSERT INTO public.pet_weight_logs (pet_id, log_date, weight_lbs)
  SELECT seed_pet, CURRENT_DATE - i, 42.5 - (i * 0.2)
  FROM generate_series(0, 6) AS i
  ON CONFLICT (pet_id, log_date) DO NOTHING;

  -- One upcoming vet appointment
  INSERT INTO public.pet_vet_appointments (pet_id, title, doctor, scheduled_at, notes)
  VALUES (seed_pet, 'Annual Checkup', 'Dr. Smith', now() + interval '14 days', 'Bring vaccination records.')
  ON CONFLICT DO NOTHING;

  -- Two vaccinations: one completed, one scheduled
  INSERT INTO public.pet_vaccinations (pet_id, vaccine_name, status, completed_on)
  VALUES (seed_pet, 'Rabies', 'completed', CURRENT_DATE - interval '90 days')
  ON CONFLICT DO NOTHING;

  INSERT INTO public.pet_vaccinations (pet_id, vaccine_name, status, scheduled_for)
  VALUES (seed_pet, 'Bordetella', 'scheduled', CURRENT_DATE + interval '30 days')
  ON CONFLICT DO NOTHING;
END $$;
