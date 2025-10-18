# Email Duplicate Prevention - Complete Solution

## Problem
OTP was being sent to already registered emails because:
1. Supabase's `signInWithOtp` can send OTP to existing users (by design)
2. Email column in `users` table didn't have UNIQUE constraint
3. Checking logic was not strict enough

## Solution Implemented

### 1. Database Level Protection
**File: `MAKE_EMAIL_UNIQUE.sql`**

Run this SQL in your Supabase SQL Editor:

```sql
-- Remove any existing duplicates
DELETE FROM users a
USING users b
WHERE a.id > b.id 
AND a.email = b.email;

-- Add UNIQUE constraint
ALTER TABLE users 
ADD CONSTRAINT users_email_unique UNIQUE (email);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
```

This ensures:
- ✅ Database rejects duplicate emails at insertion
- ✅ Faster email lookups with index
- ✅ Data integrity enforced at DB level

### 2. Application Level Checks
**File: `lib/features/auth/providers/auth_provider.dart`**

#### Strict Email Checking Flow:

```
User enters email → Clicks "Get OTP"
    ↓
1. Check users table with strict query
   - SELECT id, email FROM users WHERE email = ? LIMIT 1
   - If found → BLOCK with error message ❌
   - If not found → Continue ✓
    ↓
2. Send OTP to Supabase
   - shouldCreateUser: false
   - If email exists in Auth → Supabase rejects ❌
   - If email is new → OTP sent ✓
    ↓
3. Handle Errors
   - Parse error messages
   - Show user-friendly messages
```

#### Key Changes:

**`checkEmailExists()` - Real-time validation**
```dart
// Uses .limit(1) for strict checking
// Returns true if ANY row found
// Fail-safe: Returns true on error (blocks registration)
```

**`signInWithPhone()` - OTP sending**
```dart
// 1. Strict database query with detailed logging
// 2. shouldCreateUser: false in Supabase
// 3. Comprehensive error handling
// 4. Multiple error message patterns detected
```

**`signUpWithOtp()` - Supabase service**
```dart
// Changed: shouldCreateUser: false
// This makes Supabase reject existing emails
```

### 3. Visual Feedback
**File: `lib/features/auth/screens/registration_screen.dart`**

- Real-time email checking with 800ms debounce
- Visual indicators: Spinner → Checkmark/Error icon
- Error messages in form validator
- Snackbar notifications on button press
- All async operations protected with `mounted` checks

## Testing Checklist

### Test Case 1: New Email
1. Enter new @iut-dhaka.edu email
2. Wait 800ms → See green checkmark ✓
3. Click "Get OTP"
4. **Expected:** "OTP sent to your email!" ✅
5. Check email for OTP code

### Test Case 2: Existing Email (Complete Registration)
1. Enter email that completed full registration
2. Wait 800ms → See red error icon ❌
3. Click "Get OTP"
4. **Expected:** "Email already registered. Please login instead." ❌
5. **Verify:** NO OTP sent to email

### Test Case 3: Existing Email (Incomplete Registration)
1. Enter email that only verified OTP but didn't complete signup
2. Wait 800ms → See green checkmark ✓ (not in users table)
3. Click "Get OTP"
4. **Expected:** Supabase rejects → "Email already registered" ❌
5. **Verify:** NO OTP sent

### Test Case 4: Invalid Email Format
1. Enter non-IUT email (e.g., gmail.com)
2. **Expected:** Validator shows "Please use your IUT email" ❌
3. Button shows disabled state

### Test Case 5: Database Unique Constraint
1. Try to manually insert duplicate email via SQL
2. **Expected:** Database rejects with constraint violation ❌

## Console Output (Debug Logs)

### Successful New Registration:
```
🔍 [DB Check] Checking users table for email: new@iut-dhaka.edu
✅ [DB Check] Email available in users table
🔍 [STRICT CHECK] Checking users table for email: new@iut-dhaka.edu
📊 [STRICT CHECK] Query response: []
✅ [STRICT CHECK] Email not found in users table - email is available
📧 [OTP] Sending OTP to: new@iut-dhaka.edu
📧 [Supabase] Sending OTP to: new@iut-dhaka.edu
✅ [Supabase] OTP sent successfully
✅ [OTP] OTP sent successfully
✅ [COMPLETE] OTP flow completed successfully
```

### Blocked Duplicate Email:
```
🔍 [DB Check] Checking users table for email: existing@iut-dhaka.edu
❌ [DB Check] Email already exists in users table
🔍 [STRICT CHECK] Checking users table for email: existing@iut-dhaka.edu
📊 [STRICT CHECK] Query response: [{id: xxx, email: existing@iut-dhaka.edu}]
❌ [STRICT CHECK] Email found in users table!
   Existing user: {id: xxx, email: existing@iut-dhaka.edu}
❌ [ERROR] Error in signInWithPhone: Exception: This email is already registered. Please login instead.
```

## Security Considerations

1. **Database Constraint**: Primary defense - prevents duplicates at DB level
2. **Application Check**: Secondary defense - better UX with immediate feedback
3. **Supabase Auth**: Tertiary defense - catches incomplete registrations
4. **Fail-Safe Logic**: On query errors, blocks registration (secure default)

## Migration Steps

1. **Backup Database**: 
   ```sql
   -- Backup users table
   CREATE TABLE users_backup AS SELECT * FROM users;
   ```

2. **Run SQL Script**: Execute `MAKE_EMAIL_UNIQUE.sql`

3. **Hot Reload App**: Changes are already in code

4. **Test All Cases**: Follow testing checklist above

5. **Monitor Logs**: Check console for debug output

## Error Messages

| Scenario | User Message | Action |
|----------|-------------|--------|
| Email in users table | "Email already registered. Please login instead." | Redirect to login |
| Email in Auth only | "Email already registered. Please login instead." | Redirect to login |
| Database error | "Unable to verify email. Please try again." | Retry |
| Network error | "Network error. Please check your connection." | Check connection |
| Invalid format | "Please use your IUT email (@iut-dhaka.edu)" | Fix email |

## Rollback Plan

If issues occur:

1. **Remove Constraint**:
   ```sql
   ALTER TABLE users DROP CONSTRAINT users_email_unique;
   ```

2. **Revert Code**:
   ```bash
   git checkout HEAD~1 -- lib/features/auth/providers/auth_provider.dart
   git checkout HEAD~1 -- lib/core/services/supabase_service.dart
   ```

3. **Restore shouldCreateUser**:
   Change back to `shouldCreateUser: true` in `supabase_service.dart`

## Success Criteria

✅ No OTP sent to existing emails  
✅ Clear error messages shown  
✅ Real-time feedback works  
✅ Database constraint active  
✅ No widget disposal errors  
✅ Proper logging for debugging  

---

**Last Updated**: October 17, 2025  
**Status**: ✅ Ready for Testing
