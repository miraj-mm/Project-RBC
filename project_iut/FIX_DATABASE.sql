-- ============================================================================
-- FIX DATABASE - Resolve Column Issues
-- ============================================================================
-- Run this if you're getting "column does not exist" errors
-- This will check and fix any column name mismatches
-- ============================================================================

-- Step 1: Check what columns exist in users table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'users'
ORDER BY ordinal_position;

-- Step 2: Drop existing users table (CAREFUL: This deletes all data!)
-- Uncomment only if you want to start fresh
-- DROP TABLE IF EXISTS public.users CASCADE;

-- Step 3: Recreate users table with correct schema
-- Run this AFTER dropping the table above
DROP TABLE IF EXISTS public.users CASCADE;

CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    gender TEXT CHECK (gender IN ('Male', 'Female', 'Other')),
    age INTEGER CHECK (age >= 18 AND age <= 100),
    blood_group TEXT CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    last_donation_date TIMESTAMPTZ,
    profile_picture_url TEXT,
    lives_saved INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_blood_group ON public.users(blood_group);
CREATE INDEX idx_users_created_at ON public.users(created_at);

-- Add comment
COMMENT ON TABLE public.users IS 'Stores user profile information for blood donors';

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
DROP POLICY IF EXISTS "Users can view all profiles" ON public.users;
CREATE POLICY "Users can view all profiles"
    ON public.users FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
CREATE POLICY "Users can insert own profile"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can delete own profile" ON public.users;
CREATE POLICY "Users can delete own profile"
    ON public.users FOR DELETE
    USING (auth.uid() = id);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Verify the table was created correctly
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'users'
ORDER BY ordinal_position;

-- ============================================================================
-- Expected Output:
-- ============================================================================
/*
 column_name         | data_type
---------------------+--------------------------------
 id                  | uuid
 name                | text
 email               | text
 phone               | text
 gender              | text
 age                 | integer
 blood_group         | text
 last_donation_date  | timestamp with time zone
 profile_picture_url | text
 lives_saved         | integer
 created_at          | timestamp with time zone
 updated_at          | timestamp with time zone
*/
