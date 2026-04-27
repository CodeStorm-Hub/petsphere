-- ---------------------------------------------------------------------------
-- H6: Prevent duplicate match requests and chat threads.
--
-- - match_requests: a sender/receiver pair should only have one open record.
-- - chat_threads: only one thread per pet pair, regardless of column order.
-- ---------------------------------------------------------------------------

CREATE UNIQUE INDEX IF NOT EXISTS idx_match_requests_unique_pair
  ON public.match_requests(sender_pet_id, receiver_pet_id);

-- Order-independent uniqueness for chat threads. We index on the lexicographic
-- min/max of the two pet ids so (A, B) and (B, A) collide.
CREATE UNIQUE INDEX IF NOT EXISTS idx_chat_threads_unique_pair
  ON public.chat_threads(
    LEAST(pet_id_1::text, pet_id_2::text),
    GREATEST(pet_id_1::text, pet_id_2::text)
  );

-- Optional: pet age sanity bounds. Wrap in DO block to avoid failure if the
-- column is not numeric in this environment.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'pets'
      AND column_name = 'age'
  ) THEN
    BEGIN
      ALTER TABLE public.pets
        ADD CONSTRAINT pets_age_non_negative
        CHECK (age IS NULL OR (age >= 0 AND age <= 100));
    EXCEPTION
      WHEN duplicate_object THEN NULL;
    END;
  END IF;
END $$;
