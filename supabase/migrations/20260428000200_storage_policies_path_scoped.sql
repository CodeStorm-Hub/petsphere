-- ---------------------------------------------------------------------------
-- H2: Storage UPDATE/DELETE policies must be scoped to the owner.
--
-- Earlier policies let any authenticated user overwrite or delete any object
-- in the `pet-images` and `post-media` buckets. Replace with path-scoped
-- policies that require the first folder of the object name to match the
-- caller's auth.uid().
--
-- This migration assumes the upload code writes objects under a path of
-- the form `<auth_uid>/<...>`. If older objects exist at the bucket root,
-- they will not match the new policies — re-upload or migrate them with a
-- background job before relying on the new rules.
-- ---------------------------------------------------------------------------

-- pet-images
DROP POLICY IF EXISTS "Authenticated users can update pet images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete pet images" ON storage.objects;
DROP POLICY IF EXISTS "pet-images: allow auth update" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own pet images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own pet images" ON storage.objects;

CREATE POLICY "Users can update own pet images"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'pet-images'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  )
  WITH CHECK (
    bucket_id = 'pet-images'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

CREATE POLICY "Users can delete own pet images"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'pet-images'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

-- post-media
DROP POLICY IF EXISTS "Users can update own post media" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own post media" ON storage.objects;

CREATE POLICY "Users can update own post media"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'post-media'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  )
  WITH CHECK (
    bucket_id = 'post-media'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

CREATE POLICY "Users can delete own post media"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'post-media'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

-- avatars
DROP POLICY IF EXISTS "Users can update own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own avatar" ON storage.objects;

CREATE POLICY "Users can update own avatar"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  )
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );

CREATE POLICY "Users can delete own avatar"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
  );
