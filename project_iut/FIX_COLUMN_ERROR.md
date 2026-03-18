# Fix "Column Does Not Exist" Error

## Problem
You're getting: `ERROR: 42703: column "blood_group" does not exist`

This happens when:
1. The database table was created with different column names
2. The table structure doesn't match what the app expects
3. Previous incomplete migrations left the database in a bad state

---

## Solution

### Step 1: Check Current Table Structure

Run this in **Supabase SQL Editor**:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'users'
ORDER BY ordinal_position;
```

**Expected Output:**
```
column_name         | data_type
--------------------+---------------------------
id                  | uuid
name                | text
email               | text
phone               | text
gender              | text
age                 | integer
blood_group         | text        <-- This should exist!
last_donation_date  | timestamp with time zone
lives_saved         | integer
created_at          | timestamp with time zone
updated_at          | timestamp with time zone
```

---

### Step 2: Fix the Database

**Option A: Fresh Start (Recommended if no important data)**

Run the entire `FIX_DATABASE.sql` file in Supabase SQL Editor. This will:
1. Drop the existing users table
2. Recreate it with the correct schema
3. Set up all indexes, triggers, and RLS policies

**Option B: Add Missing Column (If you have existing data)**

```sql
-- Add blood_group column if it doesn't exist
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS blood_group TEXT 
CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'));

-- Add index
CREATE INDEX IF NOT EXISTS idx_users_blood_group ON public.users(blood_group);
```

---

### Step 3: Verify the Fix

```sql
-- Check that blood_group column exists
SELECT column_name 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'users'
  AND column_name = 'blood_group';
```

Should return:
```
 column_name 
-------------
 blood_group
```

---

### Step 4: Test in Your App

1. **Hot restart** your Flutter app
2. **Register a new user**:
   - Email: test@iut-dhaka.edu
   - Fill all fields including blood group
   - Submit

3. **Check console** for:
   ```
   💾 Inserting user data into database...
   ✅ User data inserted into database!
   ```

4. **Verify in database**:
   ```sql
   SELECT id, name, email, blood_group, created_at 
   FROM public.users 
   ORDER BY created_at DESC 
   LIMIT 5;
   ```

---

## What Was Fixed

1. ✅ **UserModel.toJson()** - Now only includes columns that exist in database
2. ✅ **FIX_DATABASE.sql** - Complete script to recreate users table correctly
3. ✅ **Column naming** - Consistent use of `blood_group` (snake_case)

---

## Common Issues

### Issue: "permission denied for table users"
**Fix:** RLS policies not set up. Run the RLS section of FIX_DATABASE.sql

### Issue: "null value in column 'blood_group' violates not-null constraint"
**Fix:** blood_group is optional (nullable). This shouldn't happen. Check the table was created correctly.

### Issue: "duplicate key value violates unique constraint"
**Fix:** Email already exists. This is correct behavior - the duplicate check is working!

---

## Prevention

To avoid this in the future:

1. Always run complete DATABASE_SETUP.sql on new Supabase projects
2. Don't manually create/modify tables - use the provided SQL scripts
3. Keep UserModel.toJson() in sync with database schema
4. Use version control for database migrations

---

## Next Steps

After fixing:
1. ✅ Run FIX_DATABASE.sql
2. ✅ Verify all columns exist
3. ✅ Hot restart Flutter app
4. ✅ Test complete signup flow
5. ✅ Verify data in database

You should now be able to sign up successfully! 🎉
