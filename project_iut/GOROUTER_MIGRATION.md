# GoRouter Migration Guide

This document explains how to migrate from the old `Navigator` API to GoRouter in the app.

## What Changed

1. **Created `app_router.dart`** - Centralized routing configuration with:
   - Route definitions with constants in `AppRoutes` class
   - Authentication redirect logic
   - Type-safe navigation
   - 404 error handling

2. **Updated `main.dart`** - Changed from `MaterialApp` to `MaterialApp.router`

## How to Navigate

### Old Way (Navigator)
```dart
// Push
Navigator.pushNamed(context, '/login');

// Push with arguments
Navigator.pushNamed(
  context,
  '/otp-verification',
  arguments: phoneNumber,
);

// Replace
Navigator.pushReplacementNamed(context, '/main');

// Push and remove until
Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
```

### New Way (GoRouter)
```dart
import 'package:go_router/go_router.dart';
import '../../app_router.dart'; // Import AppRoutes

// Push
context.push(AppRoutes.login);
// or
context.pushNamed('login');

// Push with arguments (pass as extra)
context.push(AppRoutes.otpVerification, extra: phoneNumber);

// Replace (go removes all previous routes)
context.go(AppRoutes.main);

// Push replacement
context.pushReplacement(AppRoutes.main);

// Go back
context.pop();
```

## Route Definitions

All routes are defined in `app_router.dart`:

- `AppRoutes.splash` - `/`
- `AppRoutes.login` - `/login`
- `AppRoutes.registration` - `/registration`
- `AppRoutes.otpVerification` - `/otp-verification`
- `AppRoutes.signUp` - `/sign-up`
- `AppRoutes.location` - `/location`
- `AppRoutes.main` - `/main`
- `AppRoutes.bloodRequests` - `/blood-requests`
- `AppRoutes.createBloodRequest` - `/create-blood-request`
- `AppRoutes.profile` - `/profile`
- `AppRoutes.editProfile` - `/edit-profile`
- `AppRoutes.busRoute` - `/bus-route`

## Authentication Flow

GoRouter automatically handles authentication redirects:
- If not authenticated → redirects to `/login`
- If authenticated and on auth screen → redirects to `/main`
- Splash screen is always accessible

## Files to Update

Search for these patterns and replace them:

### Pattern 1: Simple navigation
```dart
// OLD
Navigator.of(context).pushNamed('/login');

// NEW
context.push(AppRoutes.login);
```

### Pattern 2: Navigation with MaterialPageRoute
```dart
// OLD
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
);

// NEW
context.push(AppRoutes.editProfile);
```

### Pattern 3: Replacement navigation
```dart
// OLD
Navigator.of(context).pushReplacementNamed('/main');

// NEW
context.go(AppRoutes.main);
```

### Pattern 4: Navigation with arguments
```dart
// OLD
Navigator.of(context).pushNamed(
  '/otp-verification',
  arguments: phoneNumber,
);

// NEW
context.push(AppRoutes.otpVerification, extra: phoneNumber);
```

### Pattern 5: Push and remove all
```dart
// OLD
Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);

// NEW
context.go(AppRoutes.main);
```

## Quick Find & Replace

Search in your IDE for these patterns:
1. `Navigator.pushNamed` → `context.push`
2. `Navigator.pushReplacementNamed` → `context.go` or `context.pushReplacement`
3. `Navigator.push(context, MaterialPageRoute` → `context.push`
4. `Navigator.of(context).pop()` → `context.pop()`

## Benefits of GoRouter

1. **Type Safety** - Using `AppRoutes` constants prevents typos
2. **Deep Linking** - Automatic support for web URLs
3. **Authentication** - Built-in redirect logic
4. **Error Handling** - Custom 404 page
5. **Nested Navigation** - Support for tab bars and drawer navigation
6. **Back Button** - Better handling of browser/Android back button

## Next Steps

Update navigation calls in these files (in priority order):

1. `lib/features/auth/screens/` - All auth screens
2. `lib/features/home/` - Home and navigation
3. `lib/features/blood_requests/` - Blood request flows
4. `lib/features/profile/` - Profile navigation
5. `lib/features/bus/` - Bus route navigation
6. `lib/features/donation/` - Donation flows
