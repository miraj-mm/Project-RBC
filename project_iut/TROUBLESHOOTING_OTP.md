# Troubleshooting: "Failed to send OTP" Error

## Error Message:
```
Failed to send OTP: AuthRetryableFetchException(message: ClientException: Failed to fetch, uri=https://egemeiipwqxsebikavow.supabase.co/auth/v1/otp?, statusCode: null)
```

## Root Cause:
The app is trying to send an email OTP via Supabase, but the request is failing. This is typically caused by:
1. Email authentication not enabled in Supabase
2. Email provider not configured
3. CORS issues (if running on web)
4. Network connectivity issues

---

## Solution Steps:

### Step 1: Enable Email Authentication in Supabase ✅

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project: `egemeiipwqxsebikavow`
3. Navigate to **Authentication** → **Providers**
4. Find **Email** provider
5. Click to expand it
6. Toggle **"Enable Email provider"** to ON
7. Save changes

### Step 2: Configure Email Settings 📧

Still in **Authentication** → **Providers** → **Email**:

#### For Testing (Recommended):
- ✅ Enable "Confirm email" → **OFF** (for quick testing)
- ✅ Enable "Secure email change" → **OFF** (optional)

#### For Production:
- ✅ Enable "Confirm email" → **ON**
- ✅ Enable "Secure email change" → **ON**

### Step 3: Check Email Template (Optional) 📝

1. Go to **Authentication** → **Email Templates**
2. Check **"Confirm signup"** template
3. Verify the template looks correct
4. Click **"Send test email"** to test

### Step 4: Verify Supabase URL Configuration 🔗

Check your `.env` file has the correct URL:

```env
SUPABASE_URL=https://egemeiipwqxsebikavow.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

✅ Your URL is correct!

### Step 5: Check Network/CORS (Web Platform) 🌐

If running on **Chrome/Web**:

1. Open Chrome DevTools (F12)
2. Go to **Network** tab
3. Try sending OTP again
4. Look for the `/auth/v1/otp` request
5. Check the response for errors

**CORS Fix** (if needed):
- Supabase automatically handles CORS for web
- Make sure you're using the correct anon key
- Check if your project has any custom CORS settings

### Step 6: Test Email Provider 📨

In Supabase Dashboard:
1. Go to **Authentication** → **Users**
2. Click **"Invite user"**
3. Enter a test email
4. Click **"Send invite"**
5. Check if you receive the email

If you **don't receive the email**:
- Check spam folder
- Verify email provider is configured
- Check Supabase logs for errors

---

## Alternative: Use Supabase Studio for Testing

### Quick Test in Supabase:
1. Go to **SQL Editor** in Supabase
2. Run this query:
```sql
SELECT auth.send_magic_link('student@iut-dhaka.edu');
```
3. Check if email is sent

---

## Code-Level Debugging

### Add More Logging:

Update `registration_screen.dart` to show detailed errors:

```dart
try {
  await ref.read(authStateProvider.notifier).signInWithPhone(
    phone: _emailController.text.trim()
  );
  // Success
} catch (e, stackTrace) {
  print('Full error: $e');
  print('Stack trace: $stackTrace');
  
  // Show detailed error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: ${e.toString()}'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 10),
    ),
  );
}
```

---

## Common Error Messages & Solutions:

### "Email provider is disabled"
**Fix:** Enable Email provider in Authentication → Providers

### "Invalid email"
**Fix:** Make sure email ends with @iut-dhaka.edu

### "Rate limit exceeded"
**Fix:** Wait a few minutes, Supabase limits OTP sends

### "Network error" / "Failed to fetch"
**Fix:** 
- Check internet connection
- Verify Supabase project is active
- Check if Supabase is experiencing downtime

### "CORS error" (Web only)
**Fix:**
- Verify the Supabase URL in .env matches your project
- Make sure anon key is correct
- Check browser console for specific CORS error

---

## Quick Verification Checklist:

- [ ] Supabase project is active and accessible
- [ ] Email provider is **enabled** in Supabase
- [ ] `.env` file has correct SUPABASE_URL
- [ ] `.env` file has correct SUPABASE_ANON_KEY
- [ ] App was restarted after `.env` changes
- [ ] Email address ends with @iut-dhaka.edu
- [ ] Internet connection is working
- [ ] No firewall blocking Supabase

---

## Test with a Different Method:

### Option 1: Direct Signup (Skip OTP for Testing)

Temporarily skip the OTP flow and go directly to signup:

```dart
// In registration_screen.dart
void _handleGetOTP() async {
  if (_formKey.currentState?.validate() ?? false) {
    // Skip OTP for testing
    context.push(AppRoutes.signUp, extra: _emailController.text.trim());
  }
}
```

### Option 2: Use Password-Based Signup

Instead of OTP, use direct email/password signup:

```dart
await supabase.auth.signUp(
  email: email,
  password: password,
);
```

---

## Still Not Working?

### Check Supabase Logs:
1. Go to Supabase Dashboard
2. Navigate to **Authentication** → **Logs**
3. Look for failed OTP attempts
4. Check error messages

### Check Supabase Status:
- Visit [Supabase Status Page](https://status.supabase.com)
- Verify all services are operational

### Contact Support:
- If everything is configured correctly but still failing
- Join [Supabase Discord](https://discord.supabase.com)
- Check [Supabase GitHub Issues](https://github.com/supabase/supabase/issues)

---

## Expected Behavior After Fix:

1. User enters email: `student@iut-dhaka.edu`
2. Clicks "Get OTP"
3. Request sent to: `https://egemeiipwqxsebikavow.supabase.co/auth/v1/otp`
4. Supabase sends 6-digit OTP to email
5. User checks email inbox (or spam)
6. User enters OTP code
7. Verification successful ✅

---

## Next Steps:

1. ✅ Enable Email provider in Supabase (MOST IMPORTANT)
2. ✅ Restart your Flutter app
3. ✅ Try sending OTP again
4. ✅ Check email (and spam folder)
5. ✅ Enter OTP code
6. ✅ Complete registration

If you still get errors after enabling the Email provider, check the Supabase logs for more details!
