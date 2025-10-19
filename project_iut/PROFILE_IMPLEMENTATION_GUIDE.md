// Profile Provider Implementation Guide
// This file shows how to use the profile provider in your screens

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

// ============================================================================
// 1. DISPLAY USER PROFILE DATA
// ============================================================================

class ProfileScreenExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user profile
    final profileAsync = ref.watch(userProfileProvider);
    
    return profileAsync.when(
      data: (user) {
        if (user == null) return Text('No user data');
        
        return Column(
          children: [
            // Display user info
            Text('Name: ${user.name}'),
            Text('Email: ${user.email}'),
            Text('Blood Group: ${user.bloodGroup}'),
            Text('Lives Saved: ${user.livesSaved}'),
            
            // Display profile picture
            if (user.profilePictureUrl != null)
              Image.network(user.profilePictureUrl!),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// ============================================================================
// 2. DISPLAY USER STATISTICS
// ============================================================================

class StatisticsExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user stats
    final statsAsync = ref.watch(userStatsProvider);
    
    return statsAsync.when(
      data: (stats) {
        return Column(
          children: [
            Text('Lives Saved: ${stats.livesSaved}'),
            Text('Total Donations: ${stats.totalDonations}'),
            Text('Total Units: ${stats.totalUnits}'),
            if (stats.lastDonationDate != null)
              Text('Last Donation: ${stats.lastDonationDate}'),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// ============================================================================
// 3. DISPLAY DONATION HISTORY (My Activities)
// ============================================================================

class MyActivitiesExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch donations
    final donationsAsync = ref.watch(userDonationsProvider);
    
    return donationsAsync.when(
      data: (donations) {
        if (donations.isEmpty) {
          return Text('No donations yet');
        }
        
        return ListView.builder(
          itemCount: donations.length,
          itemBuilder: (context, index) {
            final donation = donations[index];
            return ListTile(
              leading: Icon(Icons.bloodtype),
              title: Text('${donation.bloodGroup} - ${donation.unitsDonated} units'),
              subtitle: Text('${donation.hospitalName}\n${donation.donationDate}'),
              trailing: Text(donation.bloodGroup),
            );
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// ============================================================================
// 4. EDIT PROFILE
// ============================================================================

class EditProfileExample extends ConsumerStatefulWidget {
  @override
  ConsumerState<EditProfileExample> createState() => _EditProfileExampleState();
}

class _EditProfileExampleState extends ConsumerState<EditProfileExample> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedBloodGroup = 'A+';
  String _selectedGender = 'Male';
  int _age = 25;
  
  @override
  void initState() {
    super.initState();
    // Load current data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        _nameController.text = profile.name;
        _phoneController.text = profile.phone ?? '';
        _selectedBloodGroup = profile.bloodGroup ?? 'A+';
        _selectedGender = profile.gender ?? 'Male';
        _age = profile.age ?? 25;
      }
    });
  }
  
  Future<void> _saveProfile() async {
    try {
      final currentProfile = ref.read(userProfileProvider).value;
      if (currentProfile == null) return;
      
      // Create updated user model
      final updatedUser = currentProfile.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        bloodGroup: _selectedBloodGroup,
        gender: _selectedGender,
        age: _age,
      );
      
      // Save to database
      await ref.read(userProfileProvider.notifier).updateProfile(updatedUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(labelText: 'Phone'),
        ),
        DropdownButton<String>(
          value: _selectedBloodGroup,
          items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
              .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
              .toList(),
          onChanged: (value) => setState(() => _selectedBloodGroup = value!),
        ),
        DropdownButton<String>(
          value: _selectedGender,
          items: ['Male', 'Female', 'Other']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (value) => setState(() => _selectedGender = value!),
        ),
        ElevatedButton(
          onPressed: _saveProfile,
          child: Text('Save Profile'),
        ),
      ],
    );
  }
}

// ============================================================================
// 5. RECORD A DONATION
// ============================================================================

class RecordDonationExample extends ConsumerWidget {
  Future<void> _recordDonation(WidgetRef ref) async {
    try {
      await ref.read(userProfileProvider.notifier).recordDonation(
        bloodGroup: 'A+',
        unitsDonated: 1,
        hospitalName: 'Dhaka Medical College Hospital',
        requestId: null, // Optional: if responding to a request
        notes: 'Regular donation',
      );
      
      // Refresh stats and donations
      ref.invalidate(userStatsProvider);
      ref.invalidate(userDonationsProvider);
      
      print('Donation recorded successfully!');
    } catch (e) {
      print('Error recording donation: $e');
    }
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _recordDonation(ref),
      child: Text('Record Donation'),
    );
  }
}

// ============================================================================
// 6. UPDATE PROFILE PICTURE
// ============================================================================

import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class UpdateProfilePictureExample extends ConsumerWidget {
  Future<void> _uploadProfilePicture(WidgetRef ref, BuildContext context) async {
    try {
      // Pick image
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;
      
      // Read bytes
      final Uint8List bytes = await image.readAsBytes();
      
      // Upload
      final url = await ref.read(userProfileProvider.notifier)
          .updateProfilePicture(image.path, bytes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _uploadProfilePicture(ref, context),
      child: Text('Change Profile Picture'),
    );
  }
}

// ============================================================================
// 7. REFRESH DATA
// ============================================================================

class RefreshDataExample extends ConsumerWidget {
  void _refreshAll(WidgetRef ref) {
    // Refresh profile
    ref.read(userProfileProvider.notifier).loadUserProfile();
    
    // Refresh stats
    ref.invalidate(userStatsProvider);
    
    // Refresh donations
    ref.invalidate(userDonationsProvider);
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _refreshAll(ref),
      child: Text('Refresh Data'),
    );
  }
}

// ============================================================================
// 8. COMPLETE PROFILE SCREEN EXAMPLE
// ============================================================================

class CompleteProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(userStatsProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            profileAsync.when(
              data: (user) => user != null ? ProfileHeader(user: user) : SizedBox(),
              loading: () => CircularProgressIndicator(),
              error: (_, __) => Text('Error loading profile'),
            ),
            
            // Statistics
            statsAsync.when(
              data: (stats) => StatisticsCard(stats: stats),
              loading: () => CircularProgressIndicator(),
              error: (_, __) => Text('Error loading stats'),
            ),
            
            // Edit Profile Button
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen()),
              ),
              child: Text('Edit Profile'),
            ),
            
            // My Activities Button
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyActivitiesScreen()),
              ),
              child: Text('My Activities'),
            ),
          ],
        ),
      ),
    );
  }
}
