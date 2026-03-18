-- ============================================================================
-- DATABASE SETUP FOR PROJECT-RBC (Blood Donation App)
-- ============================================================================
-- This file contains all SQL commands to set up the database schema,
-- tables, indexes, Row Level Security (RLS) policies, and triggers.
-- 
-- Run these commands in your Supabase SQL Editor in order.
-- ============================================================================

-- ============================================================================
-- 1. ENABLE REQUIRED EXTENSIONS
-- ============================================================================

-- Enable UUID generation (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgcrypto for encryption functions (if needed)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ============================================================================
-- 2. CREATE USERS TABLE
-- ============================================================================

-- Drop table if exists (CAREFUL: This will delete all data!)
-- DROP TABLE IF EXISTS public.users CASCADE;

CREATE TABLE IF NOT EXISTS public.users (
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

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_blood_group ON public.users(blood_group);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at);

-- Add comment to table
COMMENT ON TABLE public.users IS 'Stores user profile information for blood donors';


-- ============================================================================
-- 3. CREATE BLOOD_REQUESTS TABLE
-- ============================================================================

-- Drop table if exists (CAREFUL: This will delete all data!)
-- DROP TABLE IF EXISTS public.blood_requests CASCADE;

CREATE TABLE IF NOT EXISTS public.blood_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    requester_name TEXT NOT NULL,
    requester_phone TEXT NOT NULL,
    patient_name TEXT NOT NULL,
    blood_group TEXT NOT NULL CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    units_needed INTEGER NOT NULL CHECK (units_needed > 0),
    urgency TEXT NOT NULL CHECK (urgency IN ('Low', 'Medium', 'High', 'Critical')),
    hospital_name TEXT NOT NULL,
    hospital_address TEXT NOT NULL,
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
    needed_by TIMESTAMPTZ NOT NULL,
    additional_notes TEXT,
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Fulfilled', 'Cancelled', 'Expired')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_blood_requests_requester ON public.blood_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_blood_requests_blood_group ON public.blood_requests(blood_group);
CREATE INDEX IF NOT EXISTS idx_blood_requests_status ON public.blood_requests(status);
CREATE INDEX IF NOT EXISTS idx_blood_requests_urgency ON public.blood_requests(urgency);
CREATE INDEX IF NOT EXISTS idx_blood_requests_created_at ON public.blood_requests(created_at DESC);

-- Add comment to table
COMMENT ON TABLE public.blood_requests IS 'Stores blood donation requests from users';


-- ============================================================================
-- 4. CREATE DONATIONS TABLE
-- ============================================================================

-- Drop table if exists (CAREFUL: This will delete all data!)
-- DROP TABLE IF EXISTS public.donations CASCADE;

CREATE TABLE IF NOT EXISTS public.donations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    donor_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    request_id UUID REFERENCES public.blood_requests(id) ON DELETE SET NULL,
    donation_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    blood_group TEXT NOT NULL CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    units_donated INTEGER NOT NULL CHECK (units_donated > 0),
    hospital_name TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_donations_donor ON public.donations(donor_id);
CREATE INDEX IF NOT EXISTS idx_donations_request ON public.donations(request_id);
CREATE INDEX IF NOT EXISTS idx_donations_date ON public.donations(donation_date DESC);

-- Add comment to table
COMMENT ON TABLE public.donations IS 'Records of blood donations made by users';


-- ============================================================================
-- 5. CREATE BUS_ROUTES TABLE
-- ============================================================================

-- Drop table if exists (CAREFUL: This will delete all data!)
-- DROP TABLE IF EXISTS public.bus_routes CASCADE;

CREATE TABLE IF NOT EXISTS public.bus_routes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    route_name TEXT NOT NULL,
    route_number TEXT UNIQUE NOT NULL,
    starting_point TEXT NOT NULL,
    destination TEXT NOT NULL,
    stops TEXT[], -- Array of stop names
    schedule JSONB, -- Flexible schedule data
    fare DECIMAL(10, 2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_bus_routes_number ON public.bus_routes(route_number);
CREATE INDEX IF NOT EXISTS idx_bus_routes_active ON public.bus_routes(is_active);

-- Add comment to table
COMMENT ON TABLE public.bus_routes IS 'Bus routes information for IUT campus transportation';


-- ============================================================================
-- 6. CREATE NOTIFICATIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('blood_request', 'donation_received', 'reminder', 'system')),
    related_id UUID, -- ID of related blood request or donation
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON public.notifications(created_at DESC);

-- Add comment to table
COMMENT ON TABLE public.notifications IS 'User notifications for blood requests and donations';


-- ============================================================================
-- 7. CREATE STORAGE BUCKET FOR PROFILE PICTURES
-- ============================================================================

-- Note: Storage buckets must be created via Supabase Dashboard or using the management API
-- Go to: Storage > Create new bucket > Name: "profile-pictures" > Public: true

/*
MANUAL STEP - Run this in Supabase Dashboard > Storage > Policies:

1. Create bucket "profile-pictures" (if not exists)
2. Make it PUBLIC for read access
3. Add policy for authenticated users to upload:

CREATE POLICY "Users can upload own profile picture"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-pictures' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update own profile picture"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-pictures' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Anyone can view profile pictures"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-pictures');

CREATE POLICY "Users can delete own profile picture"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-pictures' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
*/


-- ============================================================================
-- 8. CREATE TRIGGERS FOR UPDATED_AT
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to users table
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to blood_requests table
DROP TRIGGER IF EXISTS update_blood_requests_updated_at ON public.blood_requests;
CREATE TRIGGER update_blood_requests_updated_at
    BEFORE UPDATE ON public.blood_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to bus_routes table
DROP TRIGGER IF EXISTS update_bus_routes_updated_at ON public.bus_routes;
CREATE TRIGGER update_bus_routes_updated_at
    BEFORE UPDATE ON public.bus_routes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


-- ============================================================================
-- 9. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blood_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bus_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- USERS TABLE POLICIES
-- ============================================================================

-- Allow users to read all profiles (needed to find donors)
DROP POLICY IF EXISTS "Users can view all profiles" ON public.users;
CREATE POLICY "Users can view all profiles"
    ON public.users FOR SELECT
    USING (true);

-- Allow users to insert their own profile
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
CREATE POLICY "Users can insert own profile"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Allow users to update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- Allow users to delete their own profile
DROP POLICY IF EXISTS "Users can delete own profile" ON public.users;
CREATE POLICY "Users can delete own profile"
    ON public.users FOR DELETE
    USING (auth.uid() = id);


-- ============================================================================
-- BLOOD_REQUESTS TABLE POLICIES
-- ============================================================================

-- Allow all authenticated users to view blood requests
DROP POLICY IF EXISTS "Anyone can view blood requests" ON public.blood_requests;
CREATE POLICY "Anyone can view blood requests"
    ON public.blood_requests FOR SELECT
    USING (auth.role() = 'authenticated');

-- Allow users to create blood requests
DROP POLICY IF EXISTS "Users can create blood requests" ON public.blood_requests;
CREATE POLICY "Users can create blood requests"
    ON public.blood_requests FOR INSERT
    WITH CHECK (auth.uid() = requester_id);

-- Allow users to update their own blood requests
DROP POLICY IF EXISTS "Users can update own requests" ON public.blood_requests;
CREATE POLICY "Users can update own requests"
    ON public.blood_requests FOR UPDATE
    USING (auth.uid() = requester_id);

-- Allow users to delete their own blood requests
DROP POLICY IF EXISTS "Users can delete own requests" ON public.blood_requests;
CREATE POLICY "Users can delete own requests"
    ON public.blood_requests FOR DELETE
    USING (auth.uid() = requester_id);


-- ============================================================================
-- DONATIONS TABLE POLICIES
-- ============================================================================

-- Allow all authenticated users to view donations
DROP POLICY IF EXISTS "Anyone can view donations" ON public.donations;
CREATE POLICY "Anyone can view donations"
    ON public.donations FOR SELECT
    USING (auth.role() = 'authenticated');

-- Allow users to create their own donation records
DROP POLICY IF EXISTS "Users can create own donations" ON public.donations;
CREATE POLICY "Users can create own donations"
    ON public.donations FOR INSERT
    WITH CHECK (auth.uid() = donor_id);

-- Allow users to update their own donations
DROP POLICY IF EXISTS "Users can update own donations" ON public.donations;
CREATE POLICY "Users can update own donations"
    ON public.donations FOR UPDATE
    USING (auth.uid() = donor_id);

-- Allow users to delete their own donations
DROP POLICY IF EXISTS "Users can delete own donations" ON public.donations;
CREATE POLICY "Users can delete own donations"
    ON public.donations FOR DELETE
    USING (auth.uid() = donor_id);


-- ============================================================================
-- BUS_ROUTES TABLE POLICIES
-- ============================================================================

-- Allow all authenticated users to view bus routes
DROP POLICY IF EXISTS "Anyone can view bus routes" ON public.bus_routes;
CREATE POLICY "Anyone can view bus routes"
    ON public.bus_routes FOR SELECT
    USING (auth.role() = 'authenticated');

-- Only allow admin/service role to modify bus routes (optional - uncomment if needed)
-- DROP POLICY IF EXISTS "Only admins can modify bus routes" ON public.bus_routes;
-- CREATE POLICY "Only admins can modify bus routes"
--     ON public.bus_routes FOR ALL
--     USING (auth.jwt() ->> 'role' = 'admin');


-- ============================================================================
-- NOTIFICATIONS TABLE POLICIES
-- ============================================================================

-- Users can only see their own notifications
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
CREATE POLICY "Users can view own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

-- System can insert notifications (using service role)
DROP POLICY IF EXISTS "System can create notifications" ON public.notifications;
CREATE POLICY "System can create notifications"
    ON public.notifications FOR INSERT
    WITH CHECK (true);

-- Users can update their own notifications (mark as read)
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id);

-- Users can delete their own notifications
DROP POLICY IF EXISTS "Users can delete own notifications" ON public.notifications;
CREATE POLICY "Users can delete own notifications"
    ON public.notifications FOR DELETE
    USING (auth.uid() = user_id);


-- ============================================================================
-- 10. SAMPLE DATA (OPTIONAL - FOR TESTING)
-- ============================================================================

-- Insert sample bus routes (uncomment to use)
/*
INSERT INTO public.bus_routes (route_name, route_number, starting_point, destination, stops, fare, schedule) VALUES
('IUT to Kumira', 'IUT-01', 'IUT Campus', 'Kumira', ARRAY['IUT Gate', 'College Gate', 'Barabkunda', 'Kumira'], 20.00, '{"weekdays": ["7:00 AM", "2:00 PM", "5:00 PM"], "weekends": ["9:00 AM", "4:00 PM"]}'::jsonb),
('IUT to Chittagong', 'IUT-02', 'IUT Campus', 'Chittagong City', ARRAY['IUT Gate', 'CRB', 'GEC', 'Agrabad'], 50.00, '{"weekdays": ["8:00 AM", "3:00 PM", "6:00 PM"], "weekends": ["10:00 AM", "5:00 PM"]}'::jsonb);
*/


-- ============================================================================
-- 11. HELPFUL QUERIES FOR VERIFICATION
-- ============================================================================

-- Check if tables exist
/*
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;
*/

-- Check RLS status
/*
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
*/

-- Check policies on a table
/*
SELECT * FROM pg_policies WHERE tablename = 'users';
*/

-- Count records in each table
/*
SELECT 
    'users' as table_name, COUNT(*) as count FROM public.users
UNION ALL
SELECT 'blood_requests', COUNT(*) FROM public.blood_requests
UNION ALL
SELECT 'donations', COUNT(*) FROM public.donations
UNION ALL
SELECT 'bus_routes', COUNT(*) FROM public.bus_routes
UNION ALL
SELECT 'notifications', COUNT(*) FROM public.notifications;
*/


-- ============================================================================
-- 12. SUPABASE AUTH SETTINGS (Configure in Dashboard)
-- ============================================================================

/*
IMPORTANT: Configure these in Supabase Dashboard > Authentication > Providers:

1. EMAIL PROVIDER:
   - Enable Email provider
   - Disable "Confirm email" (we use OTP instead)
   - Enable "Secure email change"
   
2. PHONE PROVIDER:
   - DISABLE Phone provider (not used in this app)
   
3. EMAIL TEMPLATES:
   - Customize "Magic Link" template for OTP emails
   - Set proper email sender name: "IUT Blood Donor"
   
4. URL CONFIGURATION:
   - Site URL: http://localhost:51159 (for development)
   - Redirect URLs: Add your production URL when deploying
   
5. RATE LIMITING:
   - Keep default settings or adjust based on needs
*/


-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================

-- Your database is now ready for the Project-RBC app.
-- 
-- Next steps:
-- 1. Verify all tables were created: Run the table check query above
-- 2. Verify RLS is enabled: Run the RLS status query above
-- 3. Configure Supabase Auth settings in Dashboard (see section 11)
-- 4. Test signup flow: Register a new user
-- 5. Test login flow: Login with registered user
-- 6. Check data: Query users table to see if data was inserted
-- 
-- ============================================================================
