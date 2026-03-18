# Database Setup Guide for Project-RBC

## Quick Start

### Step 1: Access Supabase SQL Editor
1. Go to your Supabase project dashboard
2. Click on **SQL Editor** in the left sidebar
3. Click **New Query**

### Step 2: Run the Setup Script
1. Open the `DATABASE_SETUP.sql` file from this project
2. Copy the entire contents
3. Paste into Supabase SQL Editor
4. Click **RUN** button

### Step 3: Verify Setup
Run this verification query in SQL Editor:
```sql
-- Check if all tables were created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

You should see:
- ✅ blood_requests
- ✅ bus_routes
- ✅ donations
- ✅ notifications
- ✅ users

### Step 4: Configure Supabase Auth Settings

#### In Supabase Dashboard > Authentication > Providers:

**1. Email Provider:**
- ✅ **Enable** Email provider
- ❌ **Disable** "Confirm email" (we use OTP verification instead)
- ✅ **Enable** "Secure email change"

**2. Phone Provider:**
- ❌ **Disable** Phone provider (not used in this app)

**3. Email Templates** (Optional):
- Go to **Email Templates** tab
- Customize the "Magic Link" template for OTP emails
- Set sender name: "IUT Blood Donor"

### Step 5: Test the Setup

1. **Hot restart your Flutter app**
2. **Test Signup:**
   - Register with: `test@iut-dhaka.edu`
   - Check your email for OTP
   - Complete profile
   - Check console for: `💾 Inserting user data into database...`

3. **Verify in Database:**
   ```sql
   SELECT * FROM public.users LIMIT 5;
   ```

4. **Test Login:**
   - Login with the email and password you just created
   - Should successfully authenticate

5. **Test Logout:**
   - Click logout button
   - Should redirect to login screen

---

## Table Structure Overview

### users
- Stores user profiles
- Links to `auth.users` via `id` (UUID)
- Contains: name, email, phone, gender, age, blood_group, etc.
- **Unique constraint on email** prevents duplicate signups

### blood_requests
- Blood donation requests from users
- References users table via `requester_id`
- Tracks status: Active, Fulfilled, Cancelled, Expired

### donations
- Records of completed blood donations
- Links donors to requests
- Tracks donation history

### bus_routes
- IUT campus bus route information
- Schedule stored as JSONB for flexibility

### notifications
- User notifications
- Push notifications for blood requests

---

## Security Features

### Row Level Security (RLS) Enabled on All Tables

**users table:**
- ✅ Anyone can view profiles (to find donors)
- ✅ Users can only modify their own profile
- ❌ Email uniqueness enforced by database

**blood_requests table:**
- ✅ Anyone can view requests (to respond to needs)
- ✅ Users can only modify their own requests

**donations table:**
- ✅ Anyone can view donation history
- ✅ Users can only create/modify their own donations

---

## Common Issues & Solutions

### Issue: "relation 'users' does not exist"
**Solution:** Run the DATABASE_SETUP.sql script in Supabase SQL Editor

### Issue: "duplicate key value violates unique constraint"
**Solution:** User already exists. The app now checks for duplicates before signup!

### Issue: "permission denied for table users"
**Solution:** RLS policies not set up correctly. Re-run the RLS section of setup script

### Issue: "null value in column 'id' violates not-null constraint"
**Solution:** User not authenticated during signup. Must verify OTP first.

---

## Database Maintenance

### Check User Count
```sql
SELECT COUNT(*) as total_users FROM public.users;
```

### Check Recent Blood Requests
```sql
SELECT * FROM public.blood_requests 
WHERE status = 'Active' 
ORDER BY created_at DESC 
LIMIT 10;
```

### Check Recent Donations
```sql
SELECT d.*, u.name as donor_name 
FROM public.donations d
JOIN public.users u ON d.donor_id = u.id
ORDER BY d.donation_date DESC
LIMIT 10;
```

### Find Users by Blood Group
```sql
SELECT name, email, blood_group, last_donation_date
FROM public.users
WHERE blood_group = 'O+'
ORDER BY last_donation_date ASC NULLS FIRST;
```

---

## Next Steps

1. ✅ Run DATABASE_SETUP.sql
2. ✅ Configure Auth settings in Dashboard
3. ✅ Test complete signup/login flow
4. ✅ Verify data appears in tables
5. 🚀 Start building features!

---

## Support

If you encounter issues:
1. Check Supabase logs: Dashboard > Database > Logs
2. Check app console for detailed error messages
3. Verify RLS policies: `SELECT * FROM pg_policies WHERE schemaname = 'public';`
4. Check auth user: `SELECT * FROM auth.users LIMIT 5;`
