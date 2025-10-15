import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/core.dart';
import 'auth_provider.dart';

// User profile provider
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref ref;

  UserProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      // Fetch user profile from database
      final response = await SupabaseService.from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        final userModel = UserModel.fromJson(response);
        state = AsyncValue.data(userModel);
      } else {
        // Create new user profile if doesn't exist
        await _createUserProfile(user);
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      final now = DateTime.now();
      final userModel = UserModel(
        id: user.id,
        name: user.userMetadata?['name'] ?? 'User',
        email: user.email ?? '',
        phone: user.phone,
        gender: user.userMetadata?['gender'],
        age: user.userMetadata?['age'],
        bloodGroup: user.userMetadata?['blood_group'],
        lastDonationDate: user.userMetadata?['last_donation_date'] != null
            ? DateTime.parse(user.userMetadata!['last_donation_date'])
            : null,
        livesSaved: 0,
        createdAt: now,
        updatedAt: now,
      );

      await SupabaseService.from('users').insert(userModel.toJson());
      state = AsyncValue.data(userModel);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      state = const AsyncValue.loading();

      final updatedData = updatedUser.copyWith(
        updatedAt: DateTime.now(),
      );

      await SupabaseService.from('users')
          .update(updatedData.toJson())
          .eq('id', updatedUser.id);

      state = AsyncValue.data(updatedData);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> updateLivesSaved(int increment) async {
    try {
      final currentUser = state.value;
      if (currentUser == null) return;

      final updatedUser = currentUser.copyWith(
        livesSaved: currentUser.livesSaved + increment,
        updatedAt: DateTime.now(),
      );

      await updateProfile(updatedUser);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  void refresh() {
    _loadUserProfile();
  }
}