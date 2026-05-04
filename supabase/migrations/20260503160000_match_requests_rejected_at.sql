-- When a breeding request is declined, record rejection time for discovery cooldown.
ALTER TABLE public.match_requests
  ADD COLUMN IF NOT EXISTS rejected_at TIMESTAMPTZ;

-- Historical rows: approximate rejection time with created_at (conservative cooldown).
UPDATE public.match_requests
SET rejected_at = created_at
WHERE status = 'rejected'
  AND rejected_at IS NULL
  AND created_at IS NOT NULL;

COMMENT ON COLUMN public.match_requests.rejected_at IS
  'Timestamp when the request was rejected; discovery hides the sender for this receiver owner for 7 days.';
