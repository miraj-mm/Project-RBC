# Updated Authentication Flow - With Duplicate Email Prevention

## Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    REGISTRATION FLOW                             │
└─────────────────────────────────────────────────────────────────┘

1. USER ENTERS EMAIL (@iut-dhaka.edu)
   ↓
2. VALIDATE EMAIL DOMAIN
   ↓ (if valid)
3. SEND OTP TO EMAIL
   → Supabase: auth.signInWithOtp(email)
   → Creates temporary auth session
   ↓
4. USER RECEIVES OTP EMAIL
   ↓
5. USER ENTERS 6-DIGIT OTP
   ↓
6. VERIFY OTP
   → Supabase: auth.verifyOTP(email, token)
   → ✅ User is now authenticated
   ↓
7. NAVIGATE TO PROFILE CREATION
   → Router allows authenticated users on /sign-up
   ↓
8. USER FILLS PROFILE DATA
   - Name, Phone, Age, Gender, Blood Group, Last Donation
   - Email field is READ-ONLY (pre-filled, verified)
   - Create Password
   ↓
9. SUBMIT PROFILE
   ↓
10. CHECK FOR DUPLICATE EMAIL ★ NEW! ★
    → Query: SELECT email FROM users WHERE email = ?
    ├─ IF EXISTS: ❌ Throw "Email already registered"
    └─ IF NOT EXISTS: ✅ Continue
    ↓
11. UPDATE AUTH PASSWORD
    → Supabase: auth.updateUser(password)
    ↓
12. INSERT USER DATA INTO DATABASE
    → Supabase: from('users').insert({
        id, name, email, phone, gender, age, 
        blood_group, last_donation_date, lives_saved, 
        created_at, updated_at
      })
    ↓
13. SIGN OUT USER
    → Force manual login with credentials
    ↓
14. REDIRECT TO LOGIN
    → Show success message
    ↓
15. USER LOGS IN
    → Email + Password authentication
    ↓
16. SUCCESS! → Main App

```

---

## Console Output During Signup

### Successful Signup:
```
📝 Starting signup for: student@iut-dhaka.edu
🔍 Checking if email already exists...
✅ Email is available
🔑 Updating user password...
📋 Updating user metadata...
💾 Inserting user data into database...
✅ User data inserted into database!
🚪 Signing out user...
✅ Signup complete, user signed out
```

### Duplicate Email Detected:
```
📝 Starting signup for: student@iut-dhaka.edu
🔍 Checking if email already exists...
❌ Email already registered!
❌ Signup error: Exception: This email is already registered. Please login instead.
```

---

## Login Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                       LOGIN FLOW                                 │
└─────────────────────────────────────────────────────────────────┘

1. USER ENTERS EMAIL & PASSWORD
   ↓
2. VALIDATE EMAIL DOMAIN (@iut-dhaka.edu)
   ↓
3. CALL LOGIN API
   → Supabase: auth.signInWithPassword(email, password)
   ↓
4. CHECK CREDENTIALS
   ├─ IF INVALID: ❌ Show error
   └─ IF VALID: ✅ Set auth state
   ↓
5. ROUTER AUTO-REDIRECTS TO /main
   → Router listens to auth state changes
   ↓
6. SUCCESS! → Main App
```

### Console Output During Login:
```
🔐 Attempting login with: student@iut-dhaka.edu
🔍 Attempting login with identifier: student@iut-dhaka.edu
📧 Logging in with email
✅ Login successful! User: student@iut-dhaka.edu
✅ Login successful, navigating to main...
[GoRouter] going to /main
```

---

## Logout Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      LOGOUT FLOW                                 │
└─────────────────────────────────────────────────────────────────┘

1. USER CLICKS LOGOUT BUTTON
   ↓
2. SHOW CONFIRMATION DIALOG
   ↓
3. USER CONFIRMS
   ↓
4. CLOSE DIALOG
   ↓
5. WAIT 300ms (animation delay)
   ↓
6. CALL SIGN OUT
   → Supabase: auth.signOut()
   → Clear local session
   ↓
7. AUTH STATE CHANGES
   → Router listens to auth state
   ↓
8. ROUTER AUTO-REDIRECTS TO /login
   ↓
9. SUCCESS! → Login Screen
```

### Console Output During Logout:
```
🚪 Logout button pressed
🔓 Calling signOut...
[supabase.auth] Signing out user with scope: SignOutScope.local
✅ Sign out complete
🔄 Navigating to login...
[GoRouter] going to /login
```

---

## Key Features

### 1. Duplicate Email Prevention ✅
- **Database Level:** UNIQUE constraint on `users.email`
- **Application Level:** Query check before insertion
- **User Experience:** Clear error message if email exists

### 2. Auth State Listening ✅
- **Router Refresh:** `AuthStateNotifier` listens to Supabase auth changes
- **Automatic Navigation:** No manual navigation needed for most cases
- **Backup Navigation:** Explicit navigation as fallback

### 3. Database Integration ✅
- **User Data Persistence:** Profile saved to `users` table
- **Auth Link:** `users.id` references `auth.users.id`
- **Row Level Security:** Users can only modify their own data

---

## Error Scenarios

### Scenario 1: Duplicate Email During Signup
```
User tries to signup with: existing@iut-dhaka.edu
↓
Check database: SELECT email FROM users WHERE email = 'existing@iut-dhaka.edu'
↓
Result: FOUND
↓
Throw Exception: "This email is already registered. Please login instead."
↓
Show SnackBar with error message
```

### Scenario 2: Invalid Email Domain
```
User enters: student@gmail.com
↓
Validate: !email.endsWith('@iut-dhaka.edu')
↓
Show Error: "Please use your IUT email (@iut-dhaka.edu)"
```

### Scenario 3: Wrong Password During Login
```
User enters: wrong_password
↓
Supabase: auth.signInWithPassword(email, wrong_password)
↓
Result: AuthApiException(message: Invalid login credentials, statusCode: 400)
↓
Show Error: "Login failed: Invalid login credentials"
```

---

## Database Checks

### Check if User Exists (Before Signup):
```sql
SELECT email FROM public.users 
WHERE email = 'student@iut-dhaka.edu';
```

### Verify User Was Inserted (After Signup):
```sql
SELECT id, name, email, blood_group, created_at 
FROM public.users 
WHERE email = 'student@iut-dhaka.edu';
```

### Check Auth User:
```sql
SELECT id, email, created_at, confirmed_at 
FROM auth.users 
WHERE email = 'student@iut-dhaka.edu';
```

---

## Testing Checklist

- [ ] Register new user with @iut-dhaka.edu email
- [ ] Try to register again with same email (should fail)
- [ ] Login with correct credentials
- [ ] Login with wrong password (should fail)
- [ ] Login with non-IUT email (should fail)
- [ ] Logout successfully
- [ ] Verify user data in database
- [ ] Check duplicate email is prevented
- [ ] Test router navigation on auth changes

---

## Implementation Files

1. **Auth Provider:** `lib/features/auth/providers/auth_provider.dart`
   - `signUpWithEmailPassword()` - Now checks for duplicates
   - `signInWithEmailOrPhone()` - Email-only login
   - `signOut()` - Clear session

2. **Router:** `lib/app_router.dart`
   - `AuthStateNotifier` - Listens to auth changes
   - `refreshListenable` - Auto-refresh router

3. **Database Setup:** `DATABASE_SETUP.sql`
   - Table definitions
   - RLS policies
   - Triggers and indexes

4. **Screens:**
   - `registration_screen.dart` - Email entry + OTP
   - `otp_verification_screen.dart` - OTP verification
   - `sign_up_screen.dart` - Profile creation
   - `login_screen.dart` - Email + password login
   - `profile_screen.dart` - Logout button

---

## Summary

✅ **Duplicate Prevention:** Email uniqueness enforced at database and application level
✅ **Complete Auth Flow:** Registration → OTP → Profile → Login → Logout
✅ **Database Integration:** User data properly stored in `users` table
✅ **Security:** RLS policies protect user data
✅ **User Experience:** Clear error messages and smooth navigation

**You're all set! 🎉**
