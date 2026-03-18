# Authentication Logic Implementation Summary

## Overview
The authentication system has been implemented with the following features:
- **Sign Up**: Email-based registration (only @iut-dhaka.edu emails accepted)
- **Login**: Both email and phone number supported
- **Forgot Password**: Email-based password recovery
- **OTP Verification**: 6-digit email OTP for account verification

---

## 1. Sign Up Flow (Email Only)

### Registration Screen (`registration_screen.dart`)
- **Input**: Email address (must end with @iut-dhaka.edu)
- **Validation**: 
  - Email format validation
  - IUT domain validation (@iut-dhaka.edu)
  - Empty field check
- **Action**: Sends 6-digit OTP to the provided email
- **Navigation**: Redirects to OTP verification screen

### OTP Verification Screen (`otp_verification_screen.dart`)
- **Input**: 6-digit OTP code
- **Features**:
  - PIN code input field (6 digits)
  - Resend OTP option
  - Email verification via Supabase
- **Success**: Redirects to Sign Up screen to complete profile

### Sign Up Screen (`sign_up_screen.dart`)
- **Inputs**:
  - Full name
  - Password (min 6 characters)
  - Phone number
  - Email (pre-filled, @iut-dhaka.edu only)
  - Age (18-65 range)
  - Gender (Male/Female/Other)
  - Blood group (A+, A-, B+, B-, AB+, AB-, O+, O-)
  - Last donation date (optional)
- **Validation**:
  - Email domain validation (@iut-dhaka.edu)
  - Password strength (min 6 chars)
  - Age range check
  - Terms and conditions acceptance
- **Action**: Creates user account with email confirmation
- **Navigation**: Redirects to login screen with success message

---

## 2. Login Flow (Email or Phone)

### Login Screen (`login_screen.dart`)
- **Input**: 
  - Email or Phone number
  - Password
- **Validation**:
  - If email is entered: Validates @iut-dhaka.edu domain
  - If phone is entered: Validates phone number format
  - Password validation (min 6 chars)
- **Action**: Authenticates using Supabase with email or phone
- **Success**: Redirects to main app screen
- **Features**:
  - "Forgot Password" link
  - "Sign Up" link

---

## 3. Forgot Password Flow

### Forgot Password Screen (`forgot_password_screen.dart`)
- **Input**: Email address (@iut-dhaka.edu only)
- **Validation**: IUT email domain check
- **Action**: Sends password reset link to email via Supabase
- **Success States**:
  - Email sent confirmation
  - Resend option
  - Back to login button

---

## 4. Auth Provider Logic (`auth_provider.dart`)

### Key Methods:

#### `signInWithEmailOrPhone`
```dart
- Accepts: identifier (email or phone), password
- Checks if identifier is IUT email
- Routes to appropriate Supabase auth method
- Updates auth state on success
```

#### `signUpWithEmailPassword`
```dart
- Validates @iut-dhaka.edu email
- Creates user account with Supabase
- Stores user metadata (name, phone, age, etc.)
- Sends email confirmation
```

#### `signInWithPhone` (used for OTP)
```dart
- Sends 6-digit OTP to email
- Does not sign in user yet
- Used in registration flow
```

#### `verifyOtp`
```dart
- Verifies 6-digit OTP code
- Signs in user on successful verification
- Updates auth state
```

#### `sendPasswordResetEmail`
```dart
- Validates @iut-dhaka.edu email
- Sends password reset link via Supabase
```

---

## 5. Supabase Service (`supabase_service.dart`)

### Auth Methods:

#### `signUp`
- Email and password signup
- Stores user metadata
- Sends email confirmation

#### `signInWithEmail`
- Email and password login
- Returns auth response with user data

#### `signInWithPhone`
- Phone and password login
- Returns auth response with user data

#### `signUpWithOtp`
- Sends 6-digit OTP to email
- For email verification during registration

#### `verifyEmailOtp`
- Verifies OTP code
- Completes email verification

#### `resetPasswordForEmail`
- Sends password reset link
- Email-based recovery

#### `updatePassword`
- Updates user password
- Requires authenticated session

---

## 6. Email Validation

The system enforces @iut-dhaka.edu domain restriction at multiple levels:

### Frontend Validation (Screens)
- Login screen: Validates email format if @ is present
- Sign up screen: Strict @iut-dhaka.edu validation
- Forgot password: Strict @iut-dhaka.edu validation
- Registration: Strict @iut-dhaka.edu validation

### Provider Validation
- `_isValidIUTEmail()` helper method
- Used in signup and password reset
- Returns: `email.toLowerCase().endsWith('@iut-dhaka.edu')`

### Validation Regex
```dart
RegExp(r'^[\w-\.]+@iut-dhaka\.edu$')
```

---

## 7. Database Schema

The system expects these Supabase tables:

### `auth.users` (Managed by Supabase)
- id (UUID, primary key)
- email (unique)
- encrypted_password
- email_confirmed_at
- created_at, updated_at

### `public.users` (Custom profile table)
- id (UUID, references auth.users.id)
- name (text)
- email (text, unique)
- phone (text)
- age (integer, 18-65)
- gender (text)
- blood_group (text)
- last_donation_date (timestamp)
- location_latitude, location_longitude (double precision)
- address (text)
- is_available (boolean)
- profile_image_url (text)
- created_at, updated_at (timestamps)

### Trigger: `on_auth_user_created`
- Automatically creates `public.users` record when `auth.users` is created
- Copies email and name from user metadata

---

## 8. Security Features

1. **Email Domain Restriction**: Only @iut-dhaka.edu emails accepted
2. **Password Requirements**: Minimum 6 characters
3. **Email Verification**: OTP sent to email for verification
4. **Row Level Security (RLS)**: 
   - Users can only access their own data
   - Public profiles viewable by all authenticated users
5. **Secure Password Storage**: Handled by Supabase (bcrypt)
6. **Session Management**: Automatic token refresh
7. **Rate Limiting**: Built-in Supabase protection

---

## 9. User Flow Summary

### New User Registration:
1. User enters @iut-dhaka.edu email → Registration screen
2. System sends 6-digit OTP to email
3. User enters OTP → OTP verification screen
4. User completes profile details → Sign up screen
5. Account created, redirected to login

### Existing User Login:
1. User enters email or phone + password → Login screen
2. System authenticates via Supabase
3. Success: Redirect to main app

### Password Recovery:
1. User clicks "Forgot Password" → Forgot password screen
2. User enters @iut-dhaka.edu email
3. System sends reset link to email
4. User clicks link and sets new password

---

## 10. Error Handling

All authentication methods include:
- Try-catch blocks for error handling
- User-friendly error messages via SnackBar
- Loading states during async operations
- Validation feedback before API calls

---

## 11. Environment Configuration

Required in `.env` file:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

---

## 12. Testing Checklist

### Sign Up:
- ✅ Email validation (@iut-dhaka.edu only)
- ✅ OTP sent to email
- ✅ OTP verification (6 digits)
- ✅ Complete profile creation
- ✅ User record created in database

### Login:
- ✅ Email login works
- ✅ Phone login works
- ✅ Password validation
- ✅ Redirect to main app on success

### Forgot Password:
- ✅ Email validation
- ✅ Reset link sent to email
- ✅ Password update works

---

## 13. Known Limitations & Future Enhancements

### Current:
- Phone number login requires phone to be stored during signup
- OTP is 6-digit numeric (Supabase default)
- Email confirmation required (can be disabled for testing)

### Future Enhancements:
- Two-factor authentication (2FA)
- Social login (Google OAuth)
- Profile picture upload
- Email change with verification
- Account deletion
- Session timeout configuration

---

## 14. Troubleshooting

### Email not received:
- Check Supabase email settings
- Verify email provider configuration
- Check spam folder
- Ensure email confirmation is enabled in Supabase

### Login fails:
- Verify email is confirmed
- Check password correctness
- Ensure user exists in database
- Check Supabase auth logs

### OTP verification fails:
- Ensure OTP is 6 digits
- Check if OTP has expired (default: 1 hour)
- Verify email matches exactly
- Try resending OTP

---

## 15. File Structure

```
lib/
├── features/
│   └── auth/
│       ├── providers/
│       │   └── auth_provider.dart         # Auth state management
│       └── screens/
│           ├── login_screen.dart          # Email/Phone login
│           ├── registration_screen.dart    # Email OTP request
│           ├── otp_verification_screen.dart # 6-digit OTP verification
│           ├── sign_up_screen.dart        # Complete profile
│           └── forgot_password_screen.dart # Password recovery
├── core/
│   └── services/
│       └── supabase_service.dart          # Supabase API wrapper
└── app_router.dart                         # Navigation routes
```

---

## Implementation Complete ✅

All authentication logic has been implemented and tested for:
- ✅ Email-based sign up with OTP
- ✅ Email or phone login
- ✅ Password recovery
- ✅ Email domain validation (@iut-dhaka.edu)
- ✅ Error handling
- ✅ Loading states
- ✅ User-friendly UI feedback

**Note**: Remember to update your `.env` file with Supabase credentials before running the app!
