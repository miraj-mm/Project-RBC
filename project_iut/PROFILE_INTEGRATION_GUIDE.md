# Profile & Activities Implementation Guide

## Overview

This guide explains how to integrate profile data, user statistics, and activity tracking in your blood donation app.

---

## Database Schema

### Users Table
```sql
users (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  gender TEXT,
  age INTEGER,
  blood_group TEXT,
  last_donation_date TIMESTAMPTZ,
  profile_picture_url TEXT,
  lives_saved INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
```

### Donations Table
```sql
donations (
  id UUID PRIMARY KEY,
  donor_id UUID REFERENCES users(id),
  request_id UUID REFERENCES blood_requests(id),
  donation_date TIMESTAMPTZ NOT NULL,
  blood_group TEXT NOT NULL,
  units_donated INTEGER NOT NULL,
  hospital_name TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ
)
```

### Blood Requests Table
```sql
blood_requests (
  id UUID PRIMARY KEY,
  requester_id UUID REFERENCES users(id),
  patient_name TEXT NOT NULL,
  blood_group TEXT NOT NULL,
  units_needed INTEGER NOT NULL,
  urgency TEXT NOT NULL,
  hospital_name TEXT NOT NULL,
  status TEXT DEFAULT 'Active',
  needed_by TIMESTAMPTZ,
  created_at TIMESTAMPTZ
)
```

---

## Profile Provider

### Location
`lib/features/profile/providers/profile_provider.dart`

### Providers Available

1. **userProfileProvider** - Current user profile data
2. **userStatsProvider** - Lives saved, donations count, etc.
3. **userDonationsProvider** - Donation history

### Usage in Screens

```dart
// 1. Import the provider
import '../providers/profile_provider.dart';

// 2. Watch profile data
final profileAsync = ref.watch(userProfileProvider);

profileAsync.when(
  data: (user) {
    // Display user.name, user.email, user.bloodGroup, etc.
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);

// 3. Watch statistics
final statsAsync = ref.watch(userStatsProvider);

statsAsync.when(
  data: (stats) {
    // Display stats.livesSaved, stats.totalDonations, etc.
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);

// 4. Watch donations
final donationsAsync = ref.watch(userDonationsProvider);

donationsAsync.when(
  data: (donations) {
    // Display list of donations
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

---

## Profile Screen Integration

### Current Implementation
The profile screen (`profile_screen.dart`) currently uses hardcoded data from `currentHomeUserProvider`.

### Update Steps

1. **Replace provider import**:
```dart
// OLD
import '../../home/providers/home_user_provider.dart';

// NEW
import '../providers/profile_provider.dart';
```

2. **Watch the new provider**:
```dart
// OLD
final user = ref.watch(currentHomeUserProvider);

// NEW
final profileAsync = ref.watch(userProfileProvider);
final statsAsync = ref.watch(userStatsProvider);
```

3. **Handle async state**:
```dart
return profileAsync.when(
  data: (user) {
    if (user == null) return Center(child: Text('No user data'));
    
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(context, user, isDarkMode),
          _buildStatisticsSection(context, user, statsAsync, isDarkMode),
          // ... rest of UI
        ],
      ),
    );
  },
  loading: () => Center(child: CircularProgressIndicator()),
  error: (error, stack) => Center(child: Text('Error: $error')),
);
```

4. **Update statistics section**:
```dart
Widget _buildStatisticsSection(BuildContext context, UserModel user, AsyncValue<UserStats> statsAsync, bool isDarkMode) {
  return statsAsync.when(
    data: (stats) {
      return Container(
        child: Column(
          children: [
            _buildStatCard(context, 'Lives Saved', '${stats.livesSaved}', Icons.favorite, AppColors.primaryRed, isDarkMode),
            _buildStatCard(context, 'Total Donations', '${stats.totalDonations}', Icons.bloodtype, AppColors.info, isDarkMode),
            if (stats.lastDonationDate != null)
              _buildStatCard(context, 'Last Donation', _formatDate(stats.lastDonationDate!), Icons.calendar_today, AppColors.success, isDarkMode),
          ],
        ),
      );
    },
    loading: () => CircularProgressIndicator(),
    error: (_, __) => Text('Unable to load stats'),
  );
}
```

---

## Edit Profile Screen Integration

### Update Steps

1. **Load current data on init**:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadCurrentProfile();
  });
}

void _loadCurrentProfile() {
  final profile = ref.read(userProfileProvider).value;
  if (profile != null) {
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';
    _selectedBloodGroup = profile.bloodGroup ?? 'A+';
    _selectedGender = profile.gender ?? 'Male';
    // ... load other fields
  }
}
```

2. **Save profile updates**:
```dart
Future<void> _saveProfile() async {
  if (!(_formKey.currentState?.validate() ?? false)) return;
  
  setState(() => _isLoading = true);
  
  try {
    final currentProfile = ref.read(userProfileProvider).value;
    if (currentProfile == null) throw Exception('No profile loaded');
    
    // Create updated user model
    final updatedUser = currentProfile.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
      age: _selectedAge,
      blood_group: _selectedBloodGroup,
      // ... other fields
    );
    
    // Save to database
    await ref.read(userProfileProvider.notifier).updateProfile(updatedUser);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

3. **Update profile picture**:
```dart
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

Future<void> _changeProfilePicture() async {
  try {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (image == null) return;
    
    setState(() => _isLoading = true);
    
    // Read image bytes
    final Uint8List bytes = await image.readAsBytes();
    
    // Upload to Supabase
    final url = await ref.read(userProfileProvider.notifier)
        .updateProfilePicture(image.path, bytes);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile picture updated!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading picture: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## My Activities Screen

### Implementation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../../../core/core.dart';

class MyActivitiesScreen extends ConsumerWidget {
  const MyActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(userDonationsProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('My Activities')),
      body: donationsAsync.when(
        data: (donations) {
          if (donations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bloodtype, size: 64, color: AppColors.grey),
                  SizedBox(height: 16),
                  Text('No donations yet'),
                  SizedBox(height: 8),
                  Text('Your donation history will appear here'),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryRed,
                    child: Icon(Icons.bloodtype, color: Colors.white),
                  ),
                  title: Text(
                    '${donation.bloodGroup} - ${donation.unitsDonated} unit(s)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(donation.hospitalName),
                      Text(
                        _formatDate(donation.donationDate),
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      if (donation.notes != null) ...[
                        SizedBox(height: 4),
                        Text(
                          donation.notes!,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show donation details
                    _showDonationDetails(context, donation);
                  },
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              SizedBox(height: 16),
              Text('Error loading activities'),
              Text(error.toString(), style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  void _showDonationDetails(BuildContext context, DonationRecord donation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Donation Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Date:', _formatDate(donation.donationDate)),
            _detailRow('Blood Group:', donation.bloodGroup),
            _detailRow('Units:', '${donation.unitsDonated}'),
            _detailRow('Hospital:', donation.hospitalName),
            if (donation.notes != null)
              _detailRow('Notes:', donation.notes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
```

---

## Your Impact Section

### Data Sources

**Lives Saved**: `users.lives_saved` - Updated when donation is recorded  
**Total Donations**: Count of records in `donations` table  
**Total Units**: Sum of `donations.units_donated`  
**Last Donation**: Max of `donations.donation_date`

### Update Logic

When a user records a donation:
```dart
await ref.read(userProfileProvider.notifier).recordDonation(
  bloodGroup: 'A+',
  unitsDonated: 1,
  hospitalName: 'Dhaka Medical College Hospital',
  requestId: requestId, // Optional
  notes: 'Regular donation',
);

// This automatically:
// 1. Inserts record in donations table
// 2. Increments lives_saved in users table
// 3. Updates last_donation_date in users table
// 4. Refreshes profile provider
```

---

## SQL Queries Reference

See `PROFILE_QUERIES.sql` for complete SQL query reference.

### Key Queries:

1. **Get Profile**: `SELECT * FROM users WHERE id = ?`
2. **Update Profile**: `UPDATE users SET name=?, phone=?, ... WHERE id = ?`
3. **Get Stats**: `SELECT COUNT(*), SUM(units_donated) FROM donations WHERE donor_id = ?`
4. **Get Donations**: `SELECT * FROM donations WHERE donor_id = ? ORDER BY donation_date DESC`
5. **Record Donation**: `INSERT INTO donations (...) VALUES (...)`
6. **Update Lives Saved**: `UPDATE users SET lives_saved = lives_saved + ? WHERE id = ?`

---

## Dependencies Required

Add to `pubspec.yaml`:
```yaml
dependencies:
  image_picker: ^1.0.4  # For profile picture upload
```

Run:
```bash
flutter pub get
```

---

## Testing Checklist

### Profile Screen
- [ ] User data loads from database
- [ ] Profile picture displays if exists
- [ ] Lives saved shows correct count
- [ ] Last donation date displays correctly
- [ ] Loading state shows while fetching
- [ ] Error state handles failures gracefully

### Edit Profile
- [ ] Current data pre-fills form fields
- [ ] Can update name, phone, blood group, etc.
- [ ] Changes save to database
- [ ] Success message shows on save
- [ ] Error message shows on failure
- [ ] Profile screen updates after save

### My Activities
- [ ] Donations list loads from database
- [ ] Shows empty state if no donations
- [ ] Displays donation details correctly
- [ ] Can tap to see full details
- [ ] Loading state shows while fetching
- [ ] Error state handles failures

### Profile Picture
- [ ] Can select image from gallery
- [ ] Image uploads to Supabase Storage
- [ ] URL saves to database
- [ ] Profile screen shows new picture
- [ ] Loading indicator during upload
- [ ] Error handling for upload failures

---

## Common Issues & Solutions

### Issue: Profile not loading
**Solution**: Check if user is authenticated: `SupabaseService.currentUser?.id`

### Issue: Stats showing 0
**Solution**: Ensure donations table has records for the user

### Issue: Profile picture not uploading
**Solution**: 
1. Check if Storage bucket 'profile-pictures' exists in Supabase
2. Check bucket permissions (public read access)
3. Verify file size is under limit

### Issue: Changes not saving
**Solution**: Check database RLS policies allow updates for authenticated users

---

## Next Steps

1. ✅ Create `profile_provider.dart` - Done
2. ⏳ Update `profile_screen.dart` to use new provider
3. ⏳ Update `edit_profile_screen.dart` to save to database
4. ⏳ Implement `my_activities_screen.dart` with donations list
5. ⏳ Add profile picture upload functionality
6. ⏳ Test complete flow

---

**Status**: ✅ Provider Created, Ready for Integration  
**Last Updated**: October 18, 2025
