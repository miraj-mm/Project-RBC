# Supabase Setup Guide

This guide will help you set up Supabase for the RBC Project with email-based authentication.

## 1. Create Supabase Project

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Create a new project
3. Note down your project URL and anon key

## 2. Configure Email Authentication

### Enable Email Authentication
1. Go to **Authentication** > **Providers** in your Supabase dashboard
2. Enable **Email** provider
3. **Disable email confirmation** initially for testing, or keep it enabled for production
   - If enabled, users will need to verify their email before they can log in
4. Configure **Email Templates** (optional):
   - Confirmation email template
   - Password reset email template
   - You can customize the email templates to match your branding

### Email Domain Restriction (Optional)
For production, you may want to restrict signups to @iut-dhaka.edu emails only:

1. Go to **Authentication** > **URL Configuration**
2. Add your redirect URLs if needed
3. The app already validates @iut-dhaka.edu emails in the frontend

## 3. Create Database Tables

Run the following SQL in your Supabase SQL Editor (**SQL Editor** > **New Query**):

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table (extends auth.users)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  age INTEGER CHECK (age >= 18 AND age <= 65),
  gender TEXT CHECK (gender IN ('Male', 'Female', 'Other')),
  blood_group TEXT CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
  last_donation_date TIMESTAMP WITH TIME ZONE,
  location_latitude DOUBLE PRECISION,
  location_longitude DOUBLE PRECISION,
  address TEXT,
  is_available BOOLEAN DEFAULT true,
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create blood requests table
CREATE TABLE public.blood_requests (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  patient_name TEXT NOT NULL,
  blood_group TEXT NOT NULL CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
  units_needed INTEGER NOT NULL CHECK (units_needed > 0),
  hospital_name TEXT NOT NULL,
  hospital_address TEXT NOT NULL,
  contact_number TEXT NOT NULL,
  urgency_level TEXT NOT NULL CHECK (urgency_level IN ('Critical', 'Urgent', 'Normal')),
  additional_notes TEXT,
  required_by TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'fulfilled', 'cancelled')),
  location_latitude DOUBLE PRECISION,
  location_longitude DOUBLE PRECISION,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create donations table
CREATE TABLE public.donations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  donor_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  request_id UUID REFERENCES public.blood_requests(id) ON DELETE SET NULL,
  donation_date TIMESTAMP WITH TIME ZONE NOT NULL,
  blood_group TEXT NOT NULL,
  units_donated INTEGER NOT NULL CHECK (units_donated > 0),
  hospital_name TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create bus routes table (if needed for your bus feature)
CREATE TABLE public.bus_routes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  route_name TEXT NOT NULL,
  route_number TEXT UNIQUE NOT NULL,
  start_location TEXT NOT NULL,
  end_location TEXT NOT NULL,
  stops JSONB,
  schedule JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blood_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bus_routes ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view their own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Anyone can view public user profiles" ON public.users
  FOR SELECT USING (true);

-- RLS Policies for blood_requests table
CREATE POLICY "Anyone can view active blood requests" ON public.blood_requests
  FOR SELECT USING (status = 'active' OR auth.uid() = user_id);

CREATE POLICY "Users can create their own blood requests" ON public.blood_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own blood requests" ON public.blood_requests
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own blood requests" ON public.blood_requests
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for donations table
CREATE POLICY "Users can view their own donations" ON public.donations
  FOR SELECT USING (auth.uid() = donor_id);

CREATE POLICY "Users can create their own donations" ON public.donations
  FOR INSERT WITH CHECK (auth.uid() = donor_id);

-- RLS Policies for bus_routes table
CREATE POLICY "Anyone can view bus routes" ON public.bus_routes
  FOR SELECT USING (is_active = true);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_blood_group ON public.users(blood_group);
CREATE INDEX idx_blood_requests_status ON public.blood_requests(status);
CREATE INDEX idx_blood_requests_blood_group ON public.blood_requests(blood_group);
CREATE INDEX idx_blood_requests_created_at ON public.blood_requests(created_at DESC);
CREATE INDEX idx_donations_donor_id ON public.donations(donor_id);
CREATE INDEX idx_donations_request_id ON public.donations(request_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_blood_requests_updated_at
  BEFORE UPDATE ON public.blood_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bus_routes_updated_at
  BEFORE UPDATE ON public.bus_routes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create function to automatically create user profile after signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'User')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create user profile
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

## 4. Configure Email Settings (Production Only)

For production, you'll want to use a custom SMTP server:

1. Go to **Project Settings** > **Authentication**
2. Scroll to **SMTP Settings**
3. Configure your custom SMTP provider (e.g., SendGrid, AWS SES, etc.)

## 5. Update .env File

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Update the `.env` file with your Supabase credentials:
   ```bash
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   
   APP_NAME=DONOR
   APP_VERSION=1.0.0
   API_TIMEOUT=30000
   DEBUG_MODE=true
   ```

3. **IMPORTANT**: Never commit your `.env` file to version control!

## 6. Email Verification Flow

### With Email Confirmation Enabled:
1. User signs up with @iut-dhaka.edu email
2. User receives confirmation email
3. User clicks the link in the email to verify
4. User can now log in

### With Email Confirmation Disabled (Testing):
1. User signs up with @iut-dhaka.edu email
2. User is automatically verified
3. User can immediately log in

## 7. Password Reset Flow

1. User clicks "Forgot Password" on login screen
2. User enters their @iut-dhaka.edu email
3. User receives password reset email
4. User clicks the link in email
5. User is redirected to set new password

## 8. Testing

### Test User Signup:
1. Run the app
2. Navigate to Sign Up screen
3. Fill in the form with a valid @iut-dhaka.edu email
4. Submit the form
5. Check your email for verification (if enabled)

### Test Login:
1. After email verification (if enabled)
2. Navigate to Login screen
3. Enter email and password
4. Click Login

### Test Password Reset:
1. Navigate to Login screen
2. Click "Forgot Password"
3. Enter your email
4. Check your email for reset link

## 9. Email Domain Validation

The app validates that only @iut-dhaka.edu emails can sign up. This is enforced in:
- Frontend validation in `sign_up_screen.dart`
- Frontend validation in `login_screen.dart`
- Frontend validation in `forgot_password_screen.dart`
- Auth provider validation in `auth_provider.dart`

For additional security, you can also add a Postgres function to enforce this at the database level.

## 10. Common Issues

### Email not sending:
- Check Supabase email settings
- Verify email provider configuration
- Check spam folder
- Enable email confirmation in Supabase if disabled

### Login fails after signup:
- If email confirmation is enabled, user must verify email first
- Check that user exists in `auth.users` table
- Check that user profile was created in `public.users` table

### Can't reset password:
- Verify email exists in system
- Check Supabase email logs
- Ensure password reset is enabled in Supabase settings

## 11. Security Considerations

1. **Email Validation**: Only @iut-dhaka.edu emails are allowed
2. **Row Level Security**: Users can only access their own data
3. **Password Requirements**: Minimum 6 characters (enforced by Supabase)
4. **Email Verification**: Recommended for production
5. **Rate Limiting**: Supabase has built-in rate limiting for auth endpoints

## 12. Additional Features to Consider

1. **Two-Factor Authentication (2FA)**: Can be enabled in Supabase
2. **OAuth Providers**: Google, GitHub, etc. (if needed)
3. **Magic Links**: Passwordless authentication option
4. **Session Management**: Automatic token refresh is handled by Supabase
