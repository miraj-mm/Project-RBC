-- ============================================
-- PROFILE PICTURES STORAGE SETUP
-- ============================================
-- This script sets up the storage bucket and policies for profile pictures.
-- Run this in Supabase SQL Editor after creating the bucket in the Dashboard.

-- Note: You MUST first create the bucket manually in Supabase Dashboard:
-- 1. Go to Storage section
-- 2. Click "New bucket"
-- 3. Name: profile-pictures
-- 4. Public bucket: ENABLED
-- 5. File size limit: 5 MB
-- 6. Allowed MIME types: image/*

-- ============================================
-- STORAGE POLICIES
-- ============================================

-- 1. Allow authenticated users to upload their own profile pictures
CREATE POLICY "Users can upload their own profile picture"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-pictures' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 2. Allow authenticated users to update their own profile pictures
CREATE POLICY "Users can update their own profile picture"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-pictures' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 3. Allow anyone to view profile pictures (public read access)
CREATE POLICY "Anyone can view profile pictures"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-pictures');

-- 4. Allow authenticated users to delete their own profile pictures
CREATE POLICY "Users can delete their own profile picture"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-pictures' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================
-- VERIFICATION
-- ============================================

-- Check if bucket exists
SELECT 
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets 
WHERE id = 'profile-pictures';

-- Expected output:
-- id               | name             | public | file_size_limit | allowed_mime_types
-- -----------------+------------------+--------+-----------------+-------------------
-- profile-pictures | profile-pictures | true   | 5242880         | {image/*}

-- Check policies are created
SELECT 
  policyname,
  cmd,
  qual
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname LIKE '%profile picture%';

-- Expected output: 4 policies
-- 1. Users can upload their own profile picture (INSERT)
-- 2. Users can update their own profile picture (UPDATE)
-- 3. Anyone can view profile pictures (SELECT)
-- 4. Users can delete their own profile picture (DELETE)

-- ============================================
-- USAGE NOTES
-- ============================================

-- File Structure:
-- profile-pictures/
--   {user_id}/
--     profile_{user_id}.jpg

-- Example URLs:
-- https://egemeiipwqxsebikavow.supabase.co/storage/v1/object/public/profile-pictures/{user_id}/profile_{user_id}.jpg

-- The app automatically:
-- 1. Gets the authenticated user's ID
-- 2. Uploads image to: {user_id}/profile_{user_id}.jpg
-- 3. Retrieves the public URL
-- 4. Stores URL in users.profile_picture_url column
