# Corrected Authentication Flow

## ✅ Updated Sign-Up Flow (Proper User Creation)

### The Correct Flow:
1. **Registration Screen** → User enters @iut-dhaka.edu email
2. **OTP Sent** → 6-digit code sent to email
3. **OTP Verification** → User enters code
4. **Sign Out** → User is signed out after verification
5. **Sign-Up/Profile Creation** → User fills in details (email pre-filled & locked)
6. **Account Created** → User profile is saved
7. **Sign Out Again** → Force logout
8. **Login Screen** → User must login with email + password

### Key Changes Made:

#### 1. OTP Verification Screen
- ✅ After successful OTP verification, user is **signed out**
- ✅ Email is passed to sign-up screen as `extra` parameter
- ✅ Redirects to sign-up page, not main page

#### 2. Sign-Up Screen
- ✅ Accepts `verifiedEmail` parameter from OTP verification
- ✅ Email field is **pre-filled** with verified email
- ✅ Email field is **read-only** (greyed out) if verified
- ✅ Shows green checkmark icon on verified email field
- ✅ After account creation, user is **signed out**
- ✅ Redirects to **login screen**, not location or main page
- ✅ Success message: "Account created successfully! Please login with your credentials."

#### 3. App Router
- ✅ Sign-up route accepts email parameter via `state.extra`

---

## Complete User Journey

### New User Registration:

```
Step 1: Registration Screen
├─ Input: student@iut-dhaka.edu
├─ Action: Click "Get OTP"
└─ Result: OTP sent to email

Step 2: OTP Verification Screen
├─ Input: 6-digit OTP code
├─ Action: Click "Proceed"
├─ Backend: Verify OTP → Sign Out
└─ Result: Redirect to Sign-Up with email parameter

Step 3: Sign-Up/Profile Creation Screen
├─ Email: student@iut-dhaka.edu ✓ (locked, greyed out)
├─ Input: Name, Password, Phone, Age, Gender, Blood Group, etc.
├─ Action: Accept terms → Click "Sign Up"
├─ Backend: Create account → Sign Out
└─ Result: Redirect to Login with success message

Step 4: Login Screen
├─ Input: student@iut-dhaka.edu + password
├─ Action: Click "Login"
└─ Result: Authenticated → Redirect to Main App
```

---

## Field States in Sign-Up Screen

### When Email is Pre-filled (from OTP):
- 📧 **Email Field**:
  - ✅ Pre-filled with verified email
  - 🔒 Read-only (cannot be edited)
  - 🎨 Grey background
  - ✓ Green checkmark icon
  - 📝 Secondary text color

### When Email is NOT Pre-filled:
- 📧 **Email Field**:
  - ❌ Empty
  - ✏️ Editable
  - ⚪ Normal background
  - ❌ No checkmark
  - 📝 Primary text color

---

## Visual Indicators

### Email Field When Verified:
```
┌─────────────────────────────────────────┐
│ 📧  student@iut-dhaka.edu           ✓   │ ← Grey background
└─────────────────────────────────────────┘
     ↑                                 ↑
   Locked                         Verified
```

### Email Field When Not Verified:
```
┌─────────────────────────────────────────┐
│ 📧  Enter your email address            │ ← White/dark background
└─────────────────────────────────────────┘
     ↑
   Editable
```

---

## Why This Flow?

### Problems with Previous Flow:
❌ OTP verification auto-logged user in
❌ Redirected directly to main app (skipped profile creation)
❌ No way to collect user details
❌ Email could be changed after verification

### Solutions Implemented:
✅ OTP verification signs out user after verification
✅ Forces user to complete profile
✅ Email is locked after verification
✅ User must login after account creation
✅ Proper validation of all required fields

---

## Technical Implementation

### OTP Verification → Sign-Up Flow:

```dart
// In otp_verification_screen.dart
await ref.read(authStateProvider.notifier).verifyOtp(...);
await ref.read(authStateProvider.notifier).signOut(); // Sign out!
context.push(AppRoutes.signUp, extra: widget.phoneNumber); // Pass email
```

### Sign-Up Screen Email Field:

```dart
// In sign_up_screen.dart
TextFormField(
  controller: _emailController,
  readOnly: widget.verifiedEmail != null, // Lock if verified
  filled: widget.verifiedEmail != null,   // Grey background
  fillColor: Colors.grey[200],            // Grey color
  suffixIcon: widget.verifiedEmail != null 
    ? Icon(Icons.check_circle, color: success) // Green check
    : null,
)
```

### Sign-Up → Login Flow:

```dart
// In sign_up_screen.dart
await ref.read(authStateProvider.notifier).signUpWithEmailPassword(...);
await ref.read(authStateProvider.notifier).signOut(); // Force logout!
context.go(AppRoutes.login); // Redirect to login
```

---

## Testing the Flow

### Test Steps:
1. ✅ Go to Registration → Enter email → Get OTP
2. ✅ Enter OTP → Verify → Check redirect to Sign-Up
3. ✅ Verify email is pre-filled and greyed out
4. ✅ Try to edit email (should be locked)
5. ✅ Fill in other fields → Submit
6. ✅ Check redirect to Login screen
7. ✅ Login with email + password
8. ✅ Verify access to main app

### Expected Behavior:
- ✅ Cannot edit verified email
- ✅ Email has grey background
- ✅ Email shows green checkmark
- ✅ After signup, redirected to login (not main app)
- ✅ Must login to access main app

---

## Database Flow

### After OTP Verification:
```
1. User record created in auth.users (via Supabase OTP)
2. Immediately signed out
3. User fills profile in Sign-Up screen
```

### After Profile Creation:
```
1. Full user record created in auth.users with password
2. Profile record created in public.users (via trigger)
3. User signed out again
4. User redirects to login
```

### After Login:
```
1. User authenticated with email + password
2. Session created
3. Access to main app granted
```

---

## Summary

The authentication flow is now properly implemented:

| Step | Screen | Action | Result |
|------|--------|--------|--------|
| 1 | Registration | Enter email → Get OTP | OTP sent |
| 2 | OTP Verification | Enter OTP → Verify | Sign out → Redirect |
| 3 | Sign-Up | Fill profile (email locked) → Submit | Account created → Sign out |
| 4 | Login | Email + Password → Login | Authenticated → Main app |

**Key Point**: User is **never** automatically logged in after registration. They must explicitly login after creating their account! 🔐
