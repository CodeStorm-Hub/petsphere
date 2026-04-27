-- ---------------------------------------------------------------------------
-- M10: Remove the client-side INSERT policy on notifications.
--
-- Notifications are inserted by trigger functions only (match accepted, new
-- message, new like/comment). Allowing the client to INSERT means anyone
-- could fabricate notifications for any user.
--
-- Also: rewrite the read/update/delete policies to use the cached form
-- `(SELECT auth.uid())` instead of `auth.uid()`. The Supabase docs note
-- that the cached form is dramatically faster on large tables because the
-- planner can hoist it out of the row scan.
-- ---------------------------------------------------------------------------

-- Drop any pre-existing INSERT policy for end-users
DROP POLICY IF EXISTS "Users can insert notifications" ON public.notifications;
DROP POLICY IF EXISTS "Authenticated users can insert notifications"
  ON public.notifications;

-- Read your own notifications
DROP POLICY IF EXISTS "Users can read own notifications" ON public.notifications;
CREATE POLICY "Users can read own notifications"
  ON public.notifications
  FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- Mark your own notifications as read
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
CREATE POLICY "Users can update own notifications"
  ON public.notifications
  FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- Delete your own notifications
DROP POLICY IF EXISTS "Users can delete own notifications" ON public.notifications;
CREATE POLICY "Users can delete own notifications"
  ON public.notifications
  FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));
