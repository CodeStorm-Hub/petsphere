-- =========================================================================
-- Health Tab V2: Extended health tables, alterations, RLS, and seed data
-- Project: PetSphere · foubokcqaxyqgjhtgzsx
-- =========================================================================

-- ─────────────────────────────────────────────────────────
-- SECTION 1: New tables
-- ─────────────────────────────────────────────────────────

-- 1a. pet_medications — active/past medications per pet
CREATE TABLE IF NOT EXISTS public.pet_medications (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id        uuid        NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  name          text        NOT NULL,
  dose          text,                       -- e.g. "10mg", "1 pill"
  frequency     text        NOT NULL DEFAULT 'once_daily'
                              CHECK (frequency IN (
                                'once_daily','twice_daily','three_times_daily',
                                'weekly','as_needed','other'
                              )),
  times_of_day  text[]      DEFAULT '{}',   -- e.g. ['08:00','20:00']
  start_date    date        NOT NULL DEFAULT CURRENT_DATE,
  end_date      date,                       -- null = ongoing
  purpose       text,
  notes         text,
  status        text        NOT NULL DEFAULT 'active'
                              CHECK (status IN ('active','paused','completed')),
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pet_medications_pet
  ON public.pet_medications (pet_id, status);

-- 1b. pet_medication_doses — log each dose given or skipped
CREATE TABLE IF NOT EXISTS public.pet_medication_doses (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  medication_id   uuid        NOT NULL REFERENCES public.pet_medications(id) ON DELETE CASCADE,
  pet_id          uuid        NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  scheduled_for   timestamptz NOT NULL,
  given_at        timestamptz,              -- null = not yet given / skipped
  skipped         boolean     NOT NULL DEFAULT false,
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pet_med_doses_med
  ON public.pet_medication_doses (medication_id, scheduled_for DESC);

CREATE INDEX IF NOT EXISTS idx_pet_med_doses_pet
  ON public.pet_medication_doses (pet_id, scheduled_for DESC);

-- 1c. pet_allergies
CREATE TABLE IF NOT EXISTS public.pet_allergies (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id        uuid        NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  allergen      text        NOT NULL,
  allergen_type text        NOT NULL DEFAULT 'food'
                              CHECK (allergen_type IN (
                                'food','environmental','drug','insect','other'
                              )),
  severity      text        NOT NULL DEFAULT 'mild'
                              CHECK (severity IN (
                                'mild','moderate','severe','life_threatening'
                              )),
  reaction      text,
  diagnosed_on  date,
  is_active     boolean     NOT NULL DEFAULT true,
  notes         text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pet_allergies_pet
  ON public.pet_allergies (pet_id, is_active);

-- 1d. pet_parasite_prevention
CREATE TABLE IF NOT EXISTS public.pet_parasite_prevention (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id          uuid        NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  product_name    text        NOT NULL,
  product_type    text        NOT NULL
                                CHECK (product_type IN (
                                  'flea','tick','flea_tick','heartworm',
                                  'dewormer','other'
                                )),
  administered_on date        NOT NULL DEFAULT CURRENT_DATE,
  next_due_date   date,
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pet_parasite_pet
  ON public.pet_parasite_prevention (pet_id, administered_on DESC);

-- 1e. pet_dental_logs
CREATE TABLE IF NOT EXISTS public.pet_dental_logs (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id        uuid        NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  log_date      date        NOT NULL DEFAULT CURRENT_DATE,
  cleaning_type text        NOT NULL
                              CHECK (cleaning_type IN (
                                'home_brushing','dental_chew',
                                'professional_cleaning','water_additive'
                              )),
  notes         text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pet_dental_pet
  ON public.pet_dental_logs (pet_id, log_date DESC);

-- ─────────────────────────────────────────────────────────
-- SECTION 2: Alter existing tables
-- ─────────────────────────────────────────────────────────

-- 2a. pet_vet_appointments — add appointment type, location, cost
ALTER TABLE public.pet_vet_appointments
  ADD COLUMN IF NOT EXISTS appointment_type text DEFAULT 'routine'
    CHECK (appointment_type IN (
      'routine','emergency','specialist','dental','surgery','follow_up'
    )),
  ADD COLUMN IF NOT EXISTS location text,
  ADD COLUMN IF NOT EXISTS cost     numeric(8,2);

-- 2b. pet_vaccinations — add next due, administered_by, batch
ALTER TABLE public.pet_vaccinations
  ADD COLUMN IF NOT EXISTS next_due_date    date,
  ADD COLUMN IF NOT EXISTS administered_by  text,
  ADD COLUMN IF NOT EXISTS batch_number     text;

-- 2c. pet_weight_logs — add BCS and unit
ALTER TABLE public.pet_weight_logs
  ADD COLUMN IF NOT EXISTS bcs_score int CHECK (bcs_score BETWEEN 1 AND 9),
  ADD COLUMN IF NOT EXISTS unit      text NOT NULL DEFAULT 'lbs'
    CHECK (unit IN ('lbs','kg'));

-- ─────────────────────────────────────────────────────────
-- SECTION 3: Shared trigger for updated_at (idempotent)
-- ─────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.touch_updated_at_health()
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

CREATE OR REPLACE TRIGGER trg_pet_medications_updated_at
  BEFORE UPDATE ON public.pet_medications
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at_health();

-- ─────────────────────────────────────────────────────────
-- SECTION 4: Row Level Security
-- ─────────────────────────────────────────────────────────

ALTER TABLE public.pet_medications       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pet_medication_doses  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pet_allergies         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pet_parasite_prevention ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pet_dental_logs       ENABLE ROW LEVEL SECURITY;

-- Helper predicate (inlined in each policy for clarity):
--   EXISTS (SELECT 1 FROM public.pets p WHERE p.id = <table>.pet_id AND p.user_id = (SELECT auth.uid()))

-- pet_medications
CREATE POLICY "owner read medications"   ON public.pet_medications FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner insert medications" ON public.pet_medications FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner update medications" ON public.pet_medications FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner delete medications" ON public.pet_medications FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));

-- pet_medication_doses
CREATE POLICY "owner read med doses"   ON public.pet_medication_doses FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner insert med doses" ON public.pet_medication_doses FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner update med doses" ON public.pet_medication_doses FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner delete med doses" ON public.pet_medication_doses FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));

-- pet_allergies
CREATE POLICY "owner read allergies"   ON public.pet_allergies FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner insert allergies" ON public.pet_allergies FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner update allergies" ON public.pet_allergies FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner delete allergies" ON public.pet_allergies FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));

-- pet_parasite_prevention
CREATE POLICY "owner read parasite"   ON public.pet_parasite_prevention FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner insert parasite" ON public.pet_parasite_prevention FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner update parasite" ON public.pet_parasite_prevention FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner delete parasite" ON public.pet_parasite_prevention FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));

-- pet_dental_logs
CREATE POLICY "owner read dental"   ON public.pet_dental_logs FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner insert dental" ON public.pet_dental_logs FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner update dental" ON public.pet_dental_logs FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));
CREATE POLICY "owner delete dental" ON public.pet_dental_logs FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.pets p WHERE p.id = pet_id AND p.user_id = (SELECT auth.uid())));

-- ─────────────────────────────────────────────────────────
-- SECTION 5: Seed data (gated on first pet in the DB)
-- ─────────────────────────────────────────────────────────

DO $$
DECLARE
  v_pet_id uuid;
  v_med_id uuid;
BEGIN
  SELECT id INTO v_pet_id
  FROM public.pets
  ORDER BY created_at ASC
  LIMIT 1;

  IF v_pet_id IS NULL THEN
    RAISE NOTICE 'No pets found – skipping health seed data.';
    RETURN;
  END IF;

  -- Medication: Apoquel
  INSERT INTO public.pet_medications
    (pet_id, name, dose, frequency, times_of_day, start_date, purpose, status)
  VALUES
    (v_pet_id, 'Apoquel', '16mg', 'once_daily', ARRAY['08:00'], CURRENT_DATE - 14,
     'Allergy/itch relief', 'active')
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_med_id;

  IF v_med_id IS NOT NULL THEN
    -- Log today's dose as given
    INSERT INTO public.pet_medication_doses
      (medication_id, pet_id, scheduled_for, given_at, skipped)
    VALUES
      (v_med_id, v_pet_id,
       now()::date + interval '8 hours',
       now()::date + interval '8 hours 2 minutes',
       false)
    ON CONFLICT DO NOTHING;
  END IF;

  -- Medication: Heartgard
  INSERT INTO public.pet_medications
    (pet_id, name, dose, frequency, times_of_day, start_date, purpose, status)
  VALUES
    (v_pet_id, 'Heartgard Plus', '1 chew', 'monthly', ARRAY[''],
     CURRENT_DATE - 60, 'Heartworm prevention', 'active')
  ON CONFLICT DO NOTHING;

  -- Allergy: Chicken
  INSERT INTO public.pet_allergies
    (pet_id, allergen, allergen_type, severity, reaction, diagnosed_on, is_active)
  VALUES
    (v_pet_id, 'Chicken', 'food', 'moderate',
     'Skin rash and ear infections', CURRENT_DATE - 180, true)
  ON CONFLICT DO NOTHING;

  -- Allergy: Grass Pollen
  INSERT INTO public.pet_allergies
    (pet_id, allergen, allergen_type, severity, reaction, is_active)
  VALUES
    (v_pet_id, 'Grass Pollen', 'environmental', 'mild',
     'Seasonal itching', true)
  ON CONFLICT DO NOTHING;

  -- Parasite: Flea & Tick (overdue)
  INSERT INTO public.pet_parasite_prevention
    (pet_id, product_name, product_type, administered_on, next_due_date)
  VALUES
    (v_pet_id, 'NexGard', 'flea_tick',
     CURRENT_DATE - 38, CURRENT_DATE - 8)
  ON CONFLICT DO NOTHING;

  -- Parasite: Heartworm
  INSERT INTO public.pet_parasite_prevention
    (pet_id, product_name, product_type, administered_on, next_due_date)
  VALUES
    (v_pet_id, 'Heartgard Plus', 'heartworm',
     CURRENT_DATE - 22, CURRENT_DATE + 8)
  ON CONFLICT DO NOTHING;

  -- Dental: home brushing yesterday
  INSERT INTO public.pet_dental_logs (pet_id, log_date, cleaning_type)
  VALUES (v_pet_id, CURRENT_DATE - 1, 'home_brushing')
  ON CONFLICT DO NOTHING;

  -- Dental: professional cleaning 3 months ago
  INSERT INTO public.pet_dental_logs (pet_id, log_date, cleaning_type, notes)
  VALUES (v_pet_id, CURRENT_DATE - 90, 'professional_cleaning',
          'Stage 1 tartar buildup, no extractions needed')
  ON CONFLICT DO NOTHING;

  -- Update vet appointment with new columns
  UPDATE public.pet_vet_appointments
  SET appointment_type = 'routine',
      location = 'PetCare Clinic',
      cost = 85.00
  WHERE pet_id = v_pet_id
    AND appointment_type IS NULL;

  -- Update BCS on most recent weight log
  UPDATE public.pet_weight_logs
  SET bcs_score = 6, unit = 'lbs'
  WHERE pet_id = v_pet_id
    AND bcs_score IS NULL
  ORDER BY log_date DESC
  LIMIT 1;

END $$;
