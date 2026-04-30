-- Optional post metadata used by the composer.
ALTER TABLE public.posts
ADD COLUMN IF NOT EXISTS location TEXT DEFAULT '',
ADD COLUMN IF NOT EXISTS tagged_pet_ids UUID[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS tagged_pet_names TEXT[] DEFAULT '{}';

-- Tell PostgREST/Supabase API to refresh its schema cache immediately.
NOTIFY pgrst, 'reload schema';
