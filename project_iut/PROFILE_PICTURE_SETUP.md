# Profile Picture Setup Guide

This guide explains how to set up the profile picture functionality that has been implemented in the sign-up flow.

## Overview

The sign-up form now includes an **optional** profile picture upload feature. Users can:
- Take a photo with their camera
- Choose an existing photo from their gallery
- Remove a selected photo
- Skip adding a profile picture entirely

## What's Been Implemented

### 1. **Frontend Changes**

#### Added Package
- `image_picker: ^1.0.7` added to `pubspec.yaml`

#### Sign-up Screen (`lib/features/auth/screens/sign_up_screen.dart`)
- Profile picture UI section added at the top of the form
- Camera icon overlay for triggering image selection
- Bottom sheet with options: Camera, Gallery, Remove Photo, Cancel
- Image preview in circular avatar
- Automatic upload to Supabase Storage before account creation
- Profile picture URL stored in database with user data

#### Features
- **Image Compression**: Images are automatically resized to 1024x1024 and compressed to 85% quality
- **Error Handling**: Upload failures don't block account creation
- **User ID Naming**: Profile pictures are stored as `{user_id}/profile_{user_id}.jpg`
- **Overwrite Support**: Re-uploading replaces the existing photo

### 2. **Backend Changes**

#### Database Schema
The `users` table already includes:
```sql
profile_picture_url TEXT
```

This field stores the public URL of the uploaded profile picture.

#### Storage Bucket (Manual Setup Required)
You need to create a storage bucket named `profile-pictures` in Supabase.

## Required Setup Steps

### Step 1: Create Storage Bucket

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project: `egemeiipwqxsebikavow`
3. Navigate to **Storage** in the left sidebar
4. Click **New bucket**
5. Configure the bucket:
   - **Name**: `profile-pictures`
   - **Public bucket**: ✅ **Enable** (so profile pictures can be viewed publicly)
   - **File size limit**: 5 MB (recommended)
   - **Allowed MIME types**: `image/*`

6. Click **Create bucket**

### Step 2: Set Up Storage Policies

After creating the bucket, you need to set up Row Level Security (RLS) policies.

1. In the Storage section, click on the `profile-pictures` bucket
2. Go to **Policies** tab
3. Click **New policy**

#### Policy 1: Allow Authenticated Users to Upload

```sql
-- Allow authenticated users to upload their own profile pictures
CREATE POLICY "Users can upload their own profile picture"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-pictures' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

#### Policy 2: Allow Authenticated Users to Update

```sql
-- Allow authenticated users to update their own profile pictures
CREATE POLICY "Users can update their own profile picture"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-pictures' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

#### Policy 3: Allow Public Read Access

```sql
-- Allow anyone to view profile pictures
CREATE POLICY "Anyone can view profile pictures"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-pictures');
```

#### Policy 4: Allow Authenticated Users to Delete Their Own

```sql
-- Allow authenticated users to delete their own profile pictures
CREATE POLICY "Users can delete their own profile picture"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-pictures' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

### Step 3: Verify Setup

Run this query in the SQL Editor to verify the bucket exists:

```sql
SELECT * FROM storage.buckets WHERE id = 'profile-pictures';
```

Expected output:
```
id                | name              | public
------------------+-------------------+--------
profile-pictures  | profile-pictures  | true
```

## How It Works

### Sign-up Flow with Profile Picture

1. **User Registration**: User enters email → receives OTP → verifies email
2. **Profile Creation Screen**: 
   - User sees profile picture option at the top
   - Taps camera icon → chooses Camera or Gallery
   - Image appears in circular avatar preview
   - User fills out remaining form fields (name, phone, age, etc.)
3. **Submit**:
   - App gets the current authenticated user's ID (from OTP session)
   - If profile picture selected:
     - Image is uploaded to `profile-pictures/{user_id}/profile_{user_id}.jpg`
     - Public URL is retrieved from Supabase Storage
   - User data (including profile_picture_url) is inserted into database
   - Account is created with email/password
   - User is signed out and redirected to login
4. **Login**: User logs in with email/password credentials

### File Structure in Storage

```
profile-pictures/
├── {user_id_1}/
│   └── profile_{user_id_1}.jpg
├── {user_id_2}/
│   └── profile_{user_id_2}.jpg
└── ...
```

### Database Entry Example

```json
{
  "id": "user_id_here",
  "email": "student@iut-dhaka.edu",
  "name": "John Doe",
  "phone": "+8801712345678",
  "age": 21,
  "gender": "Male",
  "blood_group": "A+",
  "profile_picture_url": "https://egemeiipwqxsebikavow.supabase.co/storage/v1/object/public/profile-pictures/user_id_here/profile_user_id_here.jpg",
  "last_donation_date": "2024-01-15T00:00:00.000Z",
  "created_at": "2024-03-20T10:30:00.000Z"
}
```

## Testing

### Test the Profile Picture Upload

1. **Start the app** (make sure you've run `flutter pub get`)
2. **Go to Registration**: Enter a valid @iut-dhaka.edu email
3. **Verify OTP**: Enter the 6-digit code from your email
4. **Profile Creation**:
   - Tap the camera icon on the profile picture
   - Select "Take Photo" or "Choose from Gallery"
   - Select an image
   - Verify the image appears in the avatar circle
5. **Complete form** and submit
6. **Check Supabase**:
   - Go to Storage → profile-pictures
   - Verify your image is uploaded in `{user_id}/` folder
   - Go to Table Editor → users
   - Verify `profile_picture_url` column has the URL

### Test Optional Nature

1. Go through signup flow **without** selecting a profile picture
2. Verify account is created successfully
3. Check database: `profile_picture_url` should be `null`

## Troubleshooting

### Error: "Storage bucket 'profile-pictures' does not exist"

**Solution**: Create the bucket in Supabase Dashboard (see Step 1 above)

### Error: "new row violates row-level security policy"

**Solution**: Set up the storage policies (see Step 2 above)

### Profile picture not displaying in app

**Possible causes**:
1. **Bucket is not public**: Make sure "Public bucket" was enabled
2. **URL is incorrect**: Check the `profile_picture_url` in the database
3. **Network issue**: Check device internet connection

### Image upload fails silently

**Solution**: Check console logs for error messages starting with `⚠️ Failed to upload profile picture:`

### Profile picture appears stretched/distorted

This shouldn't happen as images are automatically resized to 1024x1024. If it does:
- Check the `imageQuality` and size parameters in `_pickImage()` method
- Verify the image file is not corrupted

## Platform-Specific Setup

### Android

Add permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

Already included in your project.

### iOS

Add permissions to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take profile pictures</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select profile pictures</string>
```

Already included in your project.

## Future Enhancements

Potential improvements for the profile picture feature:

1. **Image Cropping**: Allow users to crop the image before upload
2. **Multiple Formats**: Support PNG, WebP in addition to JPEG
3. **Thumbnail Generation**: Create smaller thumbnails for list views
4. **Edit Profile**: Allow users to change their profile picture after signup
5. **Default Avatars**: Provide default avatar options if user doesn't upload
6. **Validation**: Check file size and format before upload

## Summary

✅ **Completed**:
- Image picker integration (camera + gallery)
- Profile picture UI in sign-up screen
- Automatic upload to Supabase Storage
- Database field for profile_picture_url
- Error handling and optional upload

⚠️ **Manual Setup Required**:
- Create `profile-pictures` storage bucket in Supabase Dashboard
- Set up storage RLS policies for security

🎯 **Result**: Users can now optionally add a profile picture during sign-up, which is stored securely in Supabase Storage and linked to their account.
