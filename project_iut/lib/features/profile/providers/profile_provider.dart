import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';

/// Provider for current user profile data
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>((ref) {
  return UserProfileNotifier();
});

/// Provider for user statistics (lives saved, donations count)
final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  final userId = SupabaseService.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');
  
  final notifier = UserProfileNotifier();
  return notifier.getUserStats(userId);
});

/// Provider for user donation history
final userDonationsProvider = FutureProvider.autoDispose<List<DonationRecord>>((ref) async {
  final userId = SupabaseService.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');
  
  final notifier = UserProfileNotifier();
  return notifier.getUserDonations(userId);
});

class UserStats {
  final int livesSaved;
  final int totalDonations;
  final DateTime? lastDonationDate;
  final double totalUnits;
  
  UserStats({
    required this.livesSaved,
    required this.totalDonations,
    this.lastDonationDate,
    required this.totalUnits,
  });
}

class DonationRecord {
  final String id;
  final DateTime donationDate;
  final String bloodGroup;
  final int unitsDonated;
  final String hospitalName;
  final String? notes;
  final String? requestId;
  
  DonationRecord({
    required this.id,
    required this.donationDate,
    required this.bloodGroup,
    required this.unitsDonated,
    required this.hospitalName,
    this.notes,
    this.requestId,
  });
  
  factory DonationRecord.fromJson(Map<String, dynamic> json) {
    return DonationRecord(
      id: json['id'],
      donationDate: DateTime.parse(json['donation_date']),
      bloodGroup: json['blood_group'],
      unitsDonated: json['units_donated'],
      hospitalName: json['hospital_name'],
      notes: json['notes'],
      requestId: json['request_id'],
    );
  }
}

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  UserProfileNotifier() : super(const AsyncValue.loading()) {
    loadUserProfile();
  }

  /// Load user profile from database
  Future<void> loadUserProfile() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        state = const AsyncValue.data(null);
        return;
      }

      debugPrint('📥 Loading user profile for: $userId');

      final response = await SupabaseService.from('users')
          .select()
          .eq('id', userId)
          .single();

      debugPrint('✅ Profile loaded: ${response['email']}');

      final user = UserModel.fromJson(response);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      debugPrint('❌ Error loading profile: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Get user statistics from donations table
  Future<UserStats> getUserStats(String userId) async {
    try {
      debugPrint('📊 Fetching user stats for: $userId');

      // Get user's lives_saved from users table
      final userResponse = await SupabaseService.from('users')
          .select('lives_saved')
          .eq('id', userId)
          .single();

      final livesSaved = userResponse['lives_saved'] ?? 0;

      // Get donation statistics
      final donationsResponse = await SupabaseService.from('donations')
          .select('donation_date, units_donated')
          .eq('donor_id', userId)
          .order('donation_date', ascending: false);

      final donations = donationsResponse as List;
      final totalDonations = donations.length;
      final totalUnits = donations.fold<double>(
        0.0,
        (sum, donation) => sum + (donation['units_donated'] ?? 0),
      );

      DateTime? lastDonationDate;
      if (donations.isNotEmpty) {
        lastDonationDate = DateTime.parse(donations.first['donation_date']);
      }

      debugPrint('✅ Stats: $totalDonations donations, $totalUnits units, $livesSaved lives saved');

      return UserStats(
        livesSaved: livesSaved,
        totalDonations: totalDonations,
        lastDonationDate: lastDonationDate,
        totalUnits: totalUnits,
      );
    } catch (e) {
      debugPrint('❌ Error fetching stats: $e');
      return UserStats(
        livesSaved: 0,
        totalDonations: 0,
        lastDonationDate: null,
        totalUnits: 0,
      );
    }
  }

  /// Get user donation history
  Future<List<DonationRecord>> getUserDonations(String userId) async {
    try {
      debugPrint('📜 Fetching donation history for: $userId');

      final response = await SupabaseService.from('donations')
          .select()
          .eq('donor_id', userId)
          .order('donation_date', ascending: false)
          .limit(50); // Last 50 donations

      final donations = (response as List)
          .map((json) => DonationRecord.fromJson(json))
          .toList();

      debugPrint('✅ Found ${donations.length} donations');
      return donations;
    } catch (e) {
      debugPrint('❌ Error fetching donations: $e');
      return [];
    }
  }

  /// Update user profile
  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      debugPrint('💾 Updating profile for: $userId');

      final updateData = {
        'name': updatedUser.name,
        'phone': updatedUser.phone,
        'gender': updatedUser.gender,
        'age': updatedUser.age,
        'blood_group': updatedUser.bloodGroup,
        'last_donation_date': updatedUser.lastDonationDate?.toIso8601String(),
        'profile_picture_url': updatedUser.profilePictureUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await SupabaseService.from('users')
          .update(updateData)
          .eq('id', userId);

      debugPrint('✅ Profile updated successfully');

      // Reload profile to get latest data
      await loadUserProfile();
    } catch (e, stack) {
      debugPrint('❌ Error updating profile: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update profile picture
  Future<String> updateProfilePicture(String filePath, Uint8List fileBytes) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      debugPrint('📸 Uploading profile picture for: $userId');

      // Upload to Supabase Storage
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'profile-pictures/$fileName';

      await SupabaseService.storage
          .from('profile-pictures')
          .uploadBinary(path, fileBytes);

      // Get public URL
      final publicUrl = SupabaseService.storage
          .from('profile-pictures')
          .getPublicUrl(path);

      debugPrint('✅ Picture uploaded: $publicUrl');

      // Update user profile with new URL
      await SupabaseService.from('users')
          .update({
            'profile_picture_url': publicUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Reload profile
      await loadUserProfile();

      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error uploading picture: $e');
      rethrow;
    }
  }

  /// Record a donation (updates lives_saved counter)
  Future<void> recordDonation({
    required String bloodGroup,
    required int unitsDonated,
    required String hospitalName,
    String? requestId,
    String? notes,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      debugPrint('💉 Recording donation for: $userId');

      // Insert donation record
      await SupabaseService.from('donations').insert({
        'donor_id': userId,
        'request_id': requestId,
        'donation_date': DateTime.now().toIso8601String(),
        'blood_group': bloodGroup,
        'units_donated': unitsDonated,
        'hospital_name': hospitalName,
        'notes': notes,
      });

      // Update lives_saved counter (1 unit = 1 life saved)
      final currentStats = await getUserStats(userId);
      final newLivesSaved = currentStats.livesSaved + unitsDonated;

      await SupabaseService.from('users')
          .update({
            'lives_saved': newLivesSaved,
            'last_donation_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      debugPrint('✅ Donation recorded, lives saved: $newLivesSaved');

      // Reload profile
      await loadUserProfile();
    } catch (e) {
      debugPrint('❌ Error recording donation: $e');
      rethrow;
    }
  }
}
