# Quick Start Guide - Authentication Setup

## Step 1: Update Environment Variables

Edit your `.env` file with your Supabase credentials:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
APP_NAME=DONOR
APP_VERSION=1.0.0
API_TIMEOUT=30000
DEBUG_MODE=true
```

**Get these values from**: [Supabase Dashboard](https://app.supabase.com) → Your Project → Settings → API

---

## Step 2: Create Database Tables

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the SQL from `SUPABASE_SETUP.md` (section 3)
5. Click **Run**

This will create:
- `users` table
- `blood_requests` table
- `donations` table
- `bus_routes` table
- Row Level Security policies
- Triggers for auto-profile creation

---

## Step 3: Configure Email Authentication

1. Go to **Authentication** → **Providers**
2. Enable **Email** provider
3. (Optional) Disable "Confirm email" for testing
4. (Optional) Customize email templates

---

## Step 4: Test the Authentication Flow

### Test Sign Up:
1. Run the app: `flutter run`
2. Click "Sign Up"
3. Enter an email ending with `@iut-dhaka.edu`
4. Click "Get OTP"
5. Check your email for 6-digit OTP
6. Enter OTP and complete profile
7. Submit to create account

### Test Login:
1. On login screen, enter:
   - Email: `your-email@iut-dhaka.edu` OR
   - Phone: `your-phone-number`
2. Enter your password
3. Click "Login"
4. Should redirect to main app

### Test Forgot Password:
1. Click "Forgot Password" on login screen
2. Enter your `@iut-dhaka.edu` email
3. Check email for reset link
4. Click link and set new password

---

## Authentication Features

### ✅ Implemented:
- [x] Email-based sign up (must be @iut-dhaka.edu)
- [x] 6-digit OTP verification via email
- [x] Login with email or phone number
- [x] Password-based authentication
- [x] Forgot password (email recovery)
- [x] Email domain validation
- [x] User profile creation
- [x] Session management
- [x] Error handling
- [x] Loading states

### 🔐 Security:
- Email domain restriction (@iut-dhaka.edu only)
- Password minimum 6 characters
- Email verification via OTP
- Row Level Security in database
- Secure password hashing (Supabase bcrypt)
- Automatic session refresh

---

## Common Issues & Solutions

### ❌ "Supabase not initialized" error
**Solution**: Make sure `.env` file exists and contains valid SUPABASE_URL and SUPABASE_ANON_KEY

### ❌ "Only @iut-dhaka.edu emails allowed" error
**Solution**: Use an email that ends with @iut-dhaka.edu (e.g., student123@iut-dhaka.edu)

### ❌ Email not received
**Solution**: 
- Check spam folder
- Verify email provider settings in Supabase
- Check Supabase logs for errors
- Ensure email confirmation is enabled

### ❌ OTP verification fails
**Solution**:
- OTP must be exactly 6 digits
- OTP expires after 1 hour
- Make sure email matches exactly
- Try resending OTP

### ❌ Login fails after signup
**Solution**:
- If email confirmation is enabled, verify email first
- Check that user exists in database
- Verify password is correct
- Check Supabase auth logs

### ❌ Phone login not working
**Solution**:
- Ensure phone number was entered during signup
- Phone should be stored in `users` table
- Supabase must support phone auth (may need SMS provider)

---

## File Locations

### Configuration:
- `.env` - Environment variables (UPDATE THIS!)
- `SUPABASE_SETUP.md` - Database setup guide
- `AUTH_IMPLEMENTATION.md` - Complete implementation details

### Code Files:
- `lib/features/auth/providers/auth_provider.dart` - Auth logic
- `lib/features/auth/screens/login_screen.dart` - Login UI
- `lib/features/auth/screens/registration_screen.dart` - OTP request UI
- `lib/features/auth/screens/otp_verification_screen.dart` - OTP input UI
- `lib/features/auth/screens/sign_up_screen.dart` - Profile creation UI
- `lib/features/auth/screens/forgot_password_screen.dart` - Password reset UI
- `lib/core/services/supabase_service.dart` - Supabase API wrapper

---

## Next Steps

After authentication is working:

1. ✅ Update your `.env` file with real Supabase credentials
2. ✅ Test all authentication flows
3. ✅ Customize email templates in Supabase (optional)
4. ✅ Set up custom SMTP for production emails (optional)
5. ✅ Enable email confirmation for production
6. ✅ Add additional user profile fields if needed
7. ✅ Implement blood request features
8. ✅ Add location tracking
9. ✅ Set up push notifications

---

## Support

If you encounter any issues:

1. Check `AUTH_IMPLEMENTATION.md` for detailed documentation
2. Review `SUPABASE_SETUP.md` for database setup
3. Check Supabase Dashboard → Authentication → Logs
4. Verify `.env` file configuration
5. Ensure database tables are created correctly

---

## Summary

**Sign Up**: Email → OTP → Complete Profile
**Login**: Email/Phone + Password
**Forgot Password**: Email → Reset Link

All flows use @iut-dhaka.edu email validation! 🎓
