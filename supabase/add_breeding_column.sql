-- Add is_breeding_listed column to pets table
ALTER TABLE public.pets ADD COLUMN IF NOT EXISTS is_breeding_listed BOOLEAN DEFAULT FALSE;

-- Update RLS policies for the new column (covered by existing policies since it's just a column update)
