# Profile Picture Quick Setup Checklist

Follow these steps to enable profile picture uploads in your app.

## ✅ Completed (Already Done)

- [x] Added `image_picker: ^1.0.7` to dependencies
- [x] Ran `flutter pub get`
- [x] Updated sign-up screen with profile picture UI
- [x] Implemented image selection (camera/gallery)
- [x] Added upload functionality to Supabase Storage
- [x] Updated database schema to include `profile_picture_url`
- [x] Updated UserModel to serialize profile picture URL
- [x] Updated auth provider to save profile picture URL

## ⚠️ Manual Setup Required

### Step 1: Create Storage Bucket (5 minutes)

1. Open Supabase Dashboard: https://supabase.com/dashboard
2. Select project: `egemeiipwqxsebikavow`
3. Click **Storage** in left sidebar
4. Click **New bucket** button
5. Enter bucket details:
   - **Name**: `profile-pictures`
   - **Public bucket**: ✅ **ENABLE THIS**
   - **File size limit**: `5242880` (5 MB)
   - **Allowed MIME types**: `image/*`
6. Click **Create bucket**

### Step 2: Set Up Storage Policies (2 minutes)

1. Open SQL Editor in Supabase Dashboard
2. Copy the contents of `SETUP_PROFILE_PICTURES_STORAGE.sql`
3. Paste into SQL Editor
4. Click **Run** or press `Ctrl + Enter`
5. Verify output shows 4 policies created

**Quick copy-paste SQL:**
```sql
-- 1. Upload policy
CREATE POLICY "Users can upload their own profile picture"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'profile-pictures' AND (storage.foldername(name))[1] = auth.uid()::text);

-- 2. Update policy
CREATE POLICY "Users can update their own profile picture"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'profile-pictures' AND (storage.foldername(name))[1] = auth.uid()::text);

-- 3. Public read policy
CREATE POLICY "Anyone can view profile pictures"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'profile-pictures');

-- 4. Delete policy
CREATE POLICY "Users can delete their own profile picture"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'profile-pictures' AND (storage.foldername(name))[1] = auth.uid()::text);
```

### Step 3: Verify Setup (1 minute)

Run this query in SQL Editor:

```sql
SELECT * FROM storage.buckets WHERE id = 'profile-pictures';
```

**Expected result:**
```
id               | name             | public
-----------------+------------------+--------
profile-pictures | profile-pictures | true
```

## 🧪 Testing (5 minutes)

### Test Profile Picture Upload

1. **Run the app**
   ```bash
   flutter run
   ```

2. **Go to Registration**
   - Enter email: `yourname@iut-dhaka.edu`
   - Click "Sign Up"

3. **Verify OTP**
   - Check email for 6-digit code
   - Enter code → Continue

4. **Upload Profile Picture**
   - Tap camera icon on profile picture
   - Select "Take Photo" or "Choose from Gallery"
   - Pick an image
   - ✅ Verify image appears in circular avatar

5. **Complete Sign-up**
   - Fill: Name, Password, Phone, Age, Gender, Blood Group
   - Agree to terms
   - Click "Sign Up"

6. **Verify in Supabase**
   - **Storage**: Go to Storage → profile-pictures → check for your user folder
   - **Database**: Go to Table Editor → users → verify `profile_picture_url` column has URL

### Test Optional Nature

1. Go through sign-up again
2. **Don't** select a profile picture
3. Complete sign-up
4. ✅ Verify account is created successfully
5. Check database: `profile_picture_url` should be `null`

## 🚨 Troubleshooting

### "Storage bucket 'profile-pictures' does not exist"
➡️ **Fix**: Complete Step 1 above

### "new row violates row-level security policy"
➡️ **Fix**: Complete Step 2 above (run the SQL policies)

### Profile picture not displaying
- Check bucket is **public** (Step 1, checkbox must be enabled)
- Verify URL in database looks correct
- Check device has internet connection

### Upload fails silently
- Check Flutter console for error messages
- Look for: `⚠️ Failed to upload profile picture:`
- Verify bucket and policies are set up correctly

## 📋 Status Check

After completing the manual steps, you should have:

- ✅ Storage bucket named `profile-pictures` (public)
- ✅ 4 RLS policies on `storage.objects`
- ✅ App running without errors
- ✅ Profile picture upload working in sign-up flow
- ✅ Images stored in `{user_id}/profile_{user_id}.jpg` format
- ✅ URLs saved to `users.profile_picture_url` column

## 📚 Reference Documents

- **PROFILE_PICTURE_SETUP.md**: Complete setup guide with details
- **SETUP_PROFILE_PICTURES_STORAGE.sql**: SQL script with policies
- **PROFILE_PICTURE_IMPLEMENTATION.md**: Technical implementation details
- **DATABASE_SETUP.sql**: Full database schema (includes profile_picture_url column)

## ⏱️ Total Setup Time

- **Manual Steps**: ~8 minutes
- **Testing**: ~5 minutes
- **Total**: ~13 minutes

## 🎯 Result

Once complete, users will be able to:
- ✅ Add profile picture during sign-up (optional)
- ✅ Take photo with camera
- ✅ Choose from gallery
- ✅ Preview image before submitting
- ✅ Remove selected image
- ✅ Skip if they don't want to add a picture

Profile pictures will be:
- ✅ Stored securely in Supabase Storage
- ✅ Automatically compressed (1024x1024 @ 85% quality)
- ✅ Publicly accessible (for display in app)
- ✅ Protected by RLS (users can only modify their own)

---

**Need Help?** See `PROFILE_PICTURE_SETUP.md` for detailed troubleshooting and additional information.
