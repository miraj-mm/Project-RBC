-- ============================================================================
-- PROFILE AND ACTIVITIES SQL QUERIES
-- ============================================================================
-- These queries are used by the profile provider to fetch and update user data

-- ============================================================================
-- 1. GET USER PROFILE
-- ============================================================================
-- Fetch complete user profile
SELECT 
    id,
    name,
    email,
    phone,
    gender,
    age,
    blood_group,
    last_donation_date,
    profile_picture_url,
    lives_saved,
    created_at,
    updated_at
FROM public.users
WHERE id = 'USER_ID_HERE';

-- ============================================================================
-- 2. UPDATE USER PROFILE
-- ============================================================================
-- Update user profile information
UPDATE public.users
SET 
    name = 'New Name',
    phone = '+8801XXXXXXXXX',
    gender = 'Male',  -- Male, Female, Other
    age = 25,
    blood_group = 'A+',  -- A+, A-, B+, B-, AB+, AB-, O+, O-
    last_donation_date = '2025-10-18T10:00:00Z',
    profile_picture_url = 'https://....',
    updated_at = NOW()
WHERE id = 'USER_ID_HERE';

-- ============================================================================
-- 3. GET USER STATISTICS
-- ============================================================================
-- Get lives saved from users table
SELECT lives_saved
FROM public.users
WHERE id = 'USER_ID_HERE';

-- Get donation count and total units
SELECT 
    COUNT(*) as total_donations,
    SUM(units_donated) as total_units,
    MAX(donation_date) as last_donation_date
FROM public.donations
WHERE donor_id = 'USER_ID_HERE';

-- Combined query for all stats
SELECT 
    u.lives_saved,
    COUNT(d.id) as total_donations,
    COALESCE(SUM(d.units_donated), 0) as total_units,
    MAX(d.donation_date) as last_donation_date
FROM public.users u
LEFT JOIN public.donations d ON u.id = d.donor_id
WHERE u.id = 'USER_ID_HERE'
GROUP BY u.id, u.lives_saved;

-- ============================================================================
-- 4. GET USER DONATION HISTORY (My Activities)
-- ============================================================================
-- Get all donations made by user
SELECT 
    d.id,
    d.donation_date,
    d.blood_group,
    d.units_donated,
    d.hospital_name,
    d.notes,
    d.request_id,
    d.created_at,
    br.patient_name,
    br.urgency
FROM public.donations d
LEFT JOIN public.blood_requests br ON d.request_id = br.id
WHERE d.donor_id = 'USER_ID_HERE'
ORDER BY d.donation_date DESC
LIMIT 50;

-- Get donations with request details
SELECT 
    d.*,
    br.patient_name,
    br.hospital_name as request_hospital,
    br.urgency,
    br.status as request_status
FROM public.donations d
LEFT JOIN public.blood_requests br ON d.request_id = br.id
WHERE d.donor_id = 'USER_ID_HERE'
ORDER BY d.donation_date DESC;

-- ============================================================================
-- 5. RECORD A DONATION
-- ============================================================================
-- Insert new donation record
INSERT INTO public.donations (
    donor_id,
    request_id,  -- Optional: if responding to specific request
    donation_date,
    blood_group,
    units_donated,
    hospital_name,
    notes
) VALUES (
    'USER_ID_HERE',
    'REQUEST_ID_HERE',  -- NULL if not responding to request
    NOW(),
    'A+',
    1,
    'Dhaka Medical College Hospital',
    'Regular donation'
);

-- Update user's lives_saved and last_donation_date
UPDATE public.users
SET 
    lives_saved = lives_saved + 1,  -- Increment by units donated
    last_donation_date = NOW(),
    updated_at = NOW()
WHERE id = 'USER_ID_HERE';

-- ============================================================================
-- 6. GET DONATION STATISTICS BY TIME PERIOD
-- ============================================================================
-- Donations in last 30 days
SELECT COUNT(*) as donations_this_month
FROM public.donations
WHERE donor_id = 'USER_ID_HERE'
AND donation_date >= NOW() - INTERVAL '30 days';

-- Donations in last year
SELECT COUNT(*) as donations_this_year
FROM public.donations
WHERE donor_id = 'USER_ID_HERE'
AND donation_date >= NOW() - INTERVAL '1 year';

-- Donations by month (last 12 months)
SELECT 
    DATE_TRUNC('month', donation_date) as month,
    COUNT(*) as donation_count,
    SUM(units_donated) as total_units
FROM public.donations
WHERE donor_id = 'USER_ID_HERE'
AND donation_date >= NOW() - INTERVAL '1 year'
GROUP BY DATE_TRUNC('month', donation_date)
ORDER BY month DESC;

-- ============================================================================
-- 7. GET USER'S BLOOD REQUESTS
-- ============================================================================
-- Get blood requests made by user
SELECT 
    id,
    patient_name,
    blood_group,
    units_needed,
    urgency,
    hospital_name,
    hospital_address,
    needed_by,
    status,
    created_at
FROM public.blood_requests
WHERE requester_id = 'USER_ID_HERE'
ORDER BY created_at DESC;

-- ============================================================================
-- 8. UPDATE PROFILE PICTURE
-- ============================================================================
-- Update profile picture URL
UPDATE public.users
SET 
    profile_picture_url = 'https://supabase-url/storage/v1/object/public/profile-pictures/image.jpg',
    updated_at = NOW()
WHERE id = 'USER_ID_HERE';

-- ============================================================================
-- 9. CHECK DONATION ELIGIBILITY
-- ============================================================================
-- Check if user can donate (last donation was at least 90 days ago)
SELECT 
    id,
    name,
    last_donation_date,
    CASE 
        WHEN last_donation_date IS NULL THEN true
        WHEN last_donation_date < NOW() - INTERVAL '90 days' THEN true
        ELSE false
    END as can_donate,
    CASE 
        WHEN last_donation_date IS NOT NULL 
        THEN EXTRACT(DAY FROM (NOW() - last_donation_date))::integer
        ELSE NULL
    END as days_since_last_donation
FROM public.users
WHERE id = 'USER_ID_HERE';

-- ============================================================================
-- 10. GET DONATION IMPACT SUMMARY
-- ============================================================================
-- Complete impact summary for profile screen
SELECT 
    u.name,
    u.blood_group,
    u.lives_saved,
    COUNT(DISTINCT d.id) as total_donations,
    COALESCE(SUM(d.units_donated), 0) as total_units_donated,
    MAX(d.donation_date) as last_donation_date,
    COUNT(DISTINCT d.request_id) as requests_fulfilled,
    CASE 
        WHEN MAX(d.donation_date) IS NULL THEN null
        WHEN MAX(d.donation_date) < NOW() - INTERVAL '90 days' THEN 'Eligible'
        ELSE 'Not Eligible'
    END as donation_eligibility
FROM public.users u
LEFT JOIN public.donations d ON u.id = d.donor_id
WHERE u.id = 'USER_ID_HERE'
GROUP BY u.id, u.name, u.blood_group, u.lives_saved;

-- ============================================================================
-- 11. GET RECENT ACTIVITIES (Combined)
-- ============================================================================
-- Get recent donations and requests in one query
(
    SELECT 
        'donation' as activity_type,
        d.id,
        d.donation_date as activity_date,
        d.hospital_name,
        d.blood_group,
        d.units_donated as units,
        'Donated blood' as description
    FROM public.donations d
    WHERE d.donor_id = 'USER_ID_HERE'
)
UNION ALL
(
    SELECT 
        'request' as activity_type,
        br.id,
        br.created_at as activity_date,
        br.hospital_name,
        br.blood_group,
        br.units_needed as units,
        'Requested blood for ' || br.patient_name as description
    FROM public.blood_requests br
    WHERE br.requester_id = 'USER_ID_HERE'
)
ORDER BY activity_date DESC
LIMIT 20;

-- ============================================================================
-- 12. DELETE PROFILE DATA (GDPR Compliance)
-- ============================================================================
-- Delete all user data (cascade will handle related records)
DELETE FROM public.users
WHERE id = 'USER_ID_HERE';
-- This will automatically delete:
-- - All donations (ON DELETE CASCADE)
-- - All blood requests (ON DELETE CASCADE)
-- - All notifications (ON DELETE CASCADE)

-- ============================================================================
-- NOTES:
-- ============================================================================
-- 1. Replace 'USER_ID_HERE' with actual user UUID
-- 2. Replace 'REQUEST_ID_HERE' with actual request UUID when applicable
-- 3. All dates are in ISO 8601 format (TIMESTAMPTZ)
-- 4. lives_saved counter is manually incremented when donation is recorded
-- 5. Profile pictures are stored in Supabase Storage bucket 'profile-pictures'
-- 6. Donation eligibility: 90 days gap between donations (WHO guideline)
