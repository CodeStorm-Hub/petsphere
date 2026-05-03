-- ============================================================================
-- PetFolio Waitlist Table
-- Stores waitlist signups from the landing page
-- ============================================================================

-- Create the waitlist table
CREATE TABLE IF NOT EXISTS public.waitlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    pet_type TEXT,
    position INTEGER NOT NULL DEFAULT 1,
    referral_code TEXT UNIQUE DEFAULT encode(gen_random_bytes(6), 'hex'),
    referred_by TEXT REFERENCES public.waitlist(referral_code),
    email_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_waitlist_email ON public.waitlist(email);
CREATE INDEX IF NOT EXISTS idx_waitlist_referral_code ON public.waitlist(referral_code);
CREATE INDEX IF NOT EXISTS idx_waitlist_created_at ON public.waitlist(created_at DESC);

-- Function to auto-assign position number
CREATE OR REPLACE FUNCTION assign_waitlist_position()
RETURNS TRIGGER AS $$
BEGIN
    NEW.position := COALESCE((SELECT MAX(position) FROM public.waitlist), 0) + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to assign position on insert
DROP TRIGGER IF EXISTS trigger_assign_waitlist_position ON public.waitlist;
CREATE TRIGGER trigger_assign_waitlist_position
    BEFORE INSERT ON public.waitlist
    FOR EACH ROW
    EXECUTE FUNCTION assign_waitlist_position();

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_waitlist_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_waitlist_timestamp ON public.waitlist;
CREATE TRIGGER trigger_update_waitlist_timestamp
    BEFORE UPDATE ON public.waitlist
    FOR EACH ROW
    EXECUTE FUNCTION update_waitlist_timestamp();

-- Enable RLS
ALTER TABLE public.waitlist ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous inserts (for waitlist signup)
CREATE POLICY "Allow anonymous waitlist signup" ON public.waitlist
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Policy: Allow reading own entry by email (for duplicate checking)
CREATE POLICY "Allow reading waitlist count" ON public.waitlist
    FOR SELECT
    TO anon
    USING (true);

-- Grant permissions
GRANT INSERT, SELECT ON public.waitlist TO anon;
GRANT ALL ON public.waitlist TO authenticated;
GRANT ALL ON public.waitlist TO service_role;

COMMENT ON TABLE public.waitlist IS 'Stores PetFolio beta waitlist signups';
COMMENT ON COLUMN public.waitlist.position IS 'Position in the waitlist queue';
COMMENT ON COLUMN public.waitlist.referral_code IS 'Unique referral code for sharing';
COMMENT ON COLUMN public.waitlist.referred_by IS 'Referral code of the person who referred this signup';
COMMENT ON COLUMN public.waitlist.email_sent IS 'Whether confirmation email was sent';
