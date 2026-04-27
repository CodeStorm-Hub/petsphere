-- ---------------------------------------------------------------------------
-- Drop duplicate triggers that cause N×duplicate notifications.
-- Identified in COMPREHENSIVE_AUDIT.md and IMPROVEMENT_PLAN.md (issue C1).
--
-- Match request acceptance: keep `trg_match_accepted_side_effects` and
-- `trg_notify_match_accepted` only.
--
-- New message: keep `trg_notify_new_message` only.
--
-- Run this migration on the live Supabase project after verifying the
-- surviving triggers exist with the expected function bodies.
-- ---------------------------------------------------------------------------

DROP TRIGGER IF EXISTS on_match_request_accepted ON public.match_requests;
DROP TRIGGER IF EXISTS trg_match_accepted_notifications ON public.match_requests;
DROP TRIGGER IF EXISTS trg_notify_on_new_message ON public.messages;
