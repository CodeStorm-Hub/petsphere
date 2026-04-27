-- ---------------------------------------------------------------------------
-- H1: Match-request UPDATE must be restricted to the receiver pet's owner.
--
-- The previous policy let either the sender or receiver of a match request
-- flip the row to "matched", which means a sender could self-accept. Restrict
-- UPDATE so only the receiver pet's owner can change status, and limit the
-- terminal status values to the expected set.
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can update own match requests"
  ON public.match_requests;

DROP POLICY IF EXISTS "Only receiver can accept or decline match requests"
  ON public.match_requests;

CREATE POLICY "Only receiver can accept or decline match requests"
  ON public.match_requests
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.pets p
      WHERE p.id = match_requests.receiver_pet_id
        AND p.user_id = (SELECT auth.uid())
    )
  )
  WITH CHECK (
    status IN ('matched', 'rejected', 'pending')
  );
