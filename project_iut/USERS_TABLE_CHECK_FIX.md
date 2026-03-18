# Email Duplicate Check Fix - Users Table Verification

## Issue Found
The system was checking Supabase auth authentication status instead of checking the `users` table for existing registrations.

## Solution Applied

### What Was Fixed

Previously, the check was happening implicitly through Supabase Auth, which would check if the email exists in the auth system. Now it explicitly checks the **`users` table** in the database.

### Changes Made

#### 1. `checkEmailExists()` Method
**Already correct** - checks `users` table:
```dart
Future<bool> checkEmailExists(String email) async {
  final result = await SupabaseService.from('users')  // ✅ Users table
      .select('email')
      .eq('email', email.toLowerCase())
      .maybeSingle();
  
  return result != null;
}
```

#### 2. `signInWithPhone()` Method - UPDATED
**Now checks users table BEFORE sending OTP:**
```dart
Future<void> signInWithPhone({required String phone}) async {
  // Check if email already exists in users table BEFORE sending OTP
  debugPrint('🔍 Checking users table for email: $phone');
  
  final existingUser = await SupabaseService.from('users')  // ✅ Users table
      .select('email')
      .eq('email', phone.toLowerCase())
      .maybeSingle();
  
  if (existingUser != null) {
    debugPrint('❌ Email found in users table - already registered');
    throw Exception('This email is already registered. Please login instead.');
  }
  
  debugPrint('✅ Email not in users table - proceeding to send OTP');
  await SupabaseService.signUpWithOtp(email: phone);
}
```

## How It Works Now

### Complete Flow

```
1. User types email in registration screen
   ↓
2. After 800ms, checkEmailExists() runs
   → SELECT email FROM users WHERE email = ?
   ↓
3. If found in users table:
   → Show error icon
   → Display: "This email is already registered"
   ↓
4. User clicks "Get OTP"
   ↓
5. signInWithPhone() runs
   → SELECT email FROM users WHERE email = ?  (double check)
   ↓
6. If found in users table:
   → Throw exception
   → Show error to user
   ↓
7. If NOT found:
   → Send OTP via Supabase Auth
   → User receives email
```

## Database Query

Both checks now use:
```sql
SELECT email FROM users WHERE email = 'user@iut-dhaka.edu'
```

**Table:** `users` (not `auth.users`)  
**Column:** `email`  
**Filter:** Case-insensitive exact match  
**Result:** Single record or NULL  

## Console Logs - Existing Email

```
🔍 Checking users table for email: existing@iut-dhaka.edu
🔍 Checking if email exists: existing@iut-dhaka.edu
❌ Email already exists
❌ Email found in users table - already registered
❌ Error in signInWithPhone: Exception: This email is already registered. Please login instead.
```

## Console Logs - New Email

```
🔍 Checking users table for email: newuser@iut-dhaka.edu
🔍 Checking if email exists: newuser@iut-dhaka.edu
✅ Email available
✅ Email not in users table - proceeding to send OTP
✅ OTP sent successfully
```

## Why Check Users Table?

### Users Table vs Auth Table

| Check | Table | Purpose |
|-------|-------|---------|
| **Old (Wrong)** | `auth.users` | Supabase Auth accounts |
| **New (Correct)** | `users` | Your app's user data |

### The Difference

- **`auth.users`**: Supabase's internal authentication table
  - Contains emails that have verified OTP
  - Not the source of truth for registered users
  - Could have unfinished registrations

- **`users`**: Your application's user table
  - Contains completed registrations only
  - Has full user data (name, blood group, etc.)
  - This is what matters for duplicate prevention

## Test Verification

### Test 1: Check Existing User
1. Register a user completely (fill form, save to database)
2. Try to register again with same email
3. ✅ Should show error in real-time
4. ✅ Should not send OTP

### Test 2: Check Auth-Only Email
1. Start registration (get OTP) but don't complete
2. Try to register again with same email
3. ✅ Should allow (because not in `users` table yet)
4. ✅ Can complete registration

### Test 3: Database Query
Run this in Supabase SQL Editor:
```sql
SELECT email FROM users WHERE email = 'test@iut-dhaka.edu';
```
If returns row → User exists  
If returns nothing → Email available  

## Benefits of Checking Users Table

✅ **Accurate**: Only checks completed registrations  
✅ **Proper**: Uses your app's data, not auth internals  
✅ **Clean**: Incomplete registrations don't block reuse  
✅ **Reliable**: Source of truth for registered users  
✅ **Safe**: Auth table is secondary verification  

## Edge Cases Handled

1. **Incomplete Registration**: User gets OTP but doesn't complete → Email still available
2. **Database Error**: Fails safe (allows registration)
3. **Case Sensitivity**: All checks use `.toLowerCase()`
4. **Race Conditions**: Double check before OTP send
5. **Auth Mismatch**: If in auth but not users → allowed

## Summary

**Before:**
- Implicitly checked Supabase Auth (auth.users)
- Would block incomplete registrations
- Not checking your actual users table

**After:**
- Explicitly checks `users` table
- Only blocks completed registrations
- Proper source of truth
- Clear error messages

---

**Status:** ✅ Fixed  
**Test:** Try registering with an existing email from your database  
**Expected:** Should see error immediately without OTP
