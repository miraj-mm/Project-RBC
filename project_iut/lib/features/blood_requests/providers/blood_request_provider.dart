import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../services/notification_service.dart';

// Blood Request State
class BloodRequestState {
  final List<BloodRequestModel> requests;
  final bool isLoading;
  final String? error;

  const BloodRequestState({
    this.requests = const [],
    this.isLoading = false,
    this.error,
  });

  BloodRequestState copyWith({
    List<BloodRequestModel>? requests,
    bool? isLoading,
    String? error,
  }) {
    return BloodRequestState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Blood Request Notifier
class BloodRequestNotifier extends StateNotifier<BloodRequestState> {
  BloodRequestNotifier() : super(const BloodRequestState()) {
    _loadBloodRequests();
  }

  // Load blood requests from storage/database
  Future<void> _loadBloodRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
    final response = await SupabaseService.from('blood_requests')
      .select('id, requester_id, requester_name, requester_phone, patient_name, blood_group, units_needed, urgency, hospital_name, hospital_address, location_lat, location_lng, needed_by, additional_notes, status, created_at, updated_at')
      .order('created_at', ascending: false);

    final requests = (response as List<dynamic>)
      .map((e) => BloodRequestModel.fromJson(e as Map<String, dynamic>))
      .toList();

      state = state.copyWith(requests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Create new blood request
  Future<void> createBloodRequest(BloodRequestModel request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Insert and return created row
    final inserted = await SupabaseService.from('blood_requests')
      .insert(request.toJsonForInsert())
      .select()
      .single();

  final created = BloodRequestModel.fromJson(inserted);

      // Update local state
      final updatedRequests = [created, ...state.requests];
      state = state.copyWith(requests: updatedRequests, isLoading: false);

      // Send notifications to eligible donors
      await _notifyEligibleDonors(created);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Update blood request status
  Future<void> updateRequestStatus(String requestId, BloodRequestStatus status) async {
    try {
      await SupabaseService.from('blood_requests')
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      final updatedRequests = state.requests.map((request) {
        if (request.id == requestId) {
          return request.copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
        }
        return request;
      }).toList();

      state = state.copyWith(requests: updatedRequests);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Delete blood request
  Future<void> deleteRequest(String requestId) async {
    try {
      await SupabaseService.from('blood_requests')
          .delete()
          .eq('id', requestId);

      final updatedRequests = state.requests
          .where((request) => request.id != requestId)
          .toList();

      state = state.copyWith(requests: updatedRequests);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Get requests by blood group
  List<BloodRequestModel> getRequestsByBloodGroup(String bloodGroup) {
    return state.requests
        .where((request) => 
            request.bloodGroup == bloodGroup && 
            request.status == BloodRequestStatus.active)
        .toList();
  }

  // Get urgent requests
  List<BloodRequestModel> getUrgentRequests() {
    return state.requests
        .where((request) => 
            request.priority == BloodRequestPriority.urgent ||
            request.priority == BloodRequestPriority.critical)
        .where((request) => request.status == BloodRequestStatus.active)
        .toList();
  }

  // Get user's requests
  List<BloodRequestModel> getUserRequests(String userId) {
    return state.requests
        .where((request) => request.requesterId == userId)
        .toList();
  }

  // Search requests
  List<BloodRequestModel> searchRequests(String query) {
    final lowercaseQuery = query.toLowerCase();
    return state.requests
        .where((request) =>
            request.patientName.toLowerCase().contains(lowercaseQuery) ||
            request.hospitalName.toLowerCase().contains(lowercaseQuery) ||
            request.medicalCondition.toLowerCase().contains(lowercaseQuery) ||
            request.bloodGroup.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Refresh requests
  Future<void> refreshRequests() async {
    await _loadBloodRequests();
  }

  // Notify eligible donors
  Future<void> _notifyEligibleDonors(BloodRequestModel request) async {
    try {
      // TODO: Implement actual notification logic with Supabase
      // This would:
      // 1. Find donors with compatible blood groups
      // 2. Filter by location proximity
      // 3. Send push notifications
      // 4. Send SMS/email notifications
      
      // For now, simulate notification sending
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock notification service call
      final notificationService = NotificationService();
      await notificationService.sendBloodRequestNotification(
        title: 'New Blood Request',
        body: '${request.patientName} needs ${request.unitsRequired} unit(s) of ${request.bloodGroup} blood',
        data: {
          'type': 'blood_request',
          'request_id': request.id,
          'blood_group': request.bloodGroup,
          'priority': request.priority.toString(),
        },
      );
      
    } catch (e) {
      // Log error but don't throw to not interrupt the main flow
      print('Failed to notify donors: $e');
    }
  }

  // Check if user can edit request
  bool canEditRequest(BloodRequestModel request, String currentUserId) {
    return request.requesterId == currentUserId && 
           request.status == BloodRequestStatus.active;
  }

  // Check if request is expired
  bool isRequestExpired(BloodRequestModel request) {
    return DateTime.now().isAfter(request.requiredBy);
  }

  // Get active requests count
  int get activeRequestsCount {
    return state.requests
        .where((request) => request.status == BloodRequestStatus.active)
        .length;
  }

  // Get fulfilled requests count
  int get fulfilledRequestsCount {
    return state.requests
        .where((request) => request.status == BloodRequestStatus.fulfilled)
        .length;
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final bloodRequestProvider = StateNotifierProvider<BloodRequestNotifier, BloodRequestState>((ref) {
  return BloodRequestNotifier();
});

// Computed providers
final activeBloodRequestsProvider = Provider<List<BloodRequestModel>>((ref) {
  final state = ref.watch(bloodRequestProvider);
  return state.requests
      .where((request) => request.status == BloodRequestStatus.active)
      .toList();
});

final urgentBloodRequestsProvider = Provider<List<BloodRequestModel>>((ref) {
  final state = ref.watch(bloodRequestProvider);
  return state.requests
      .where((request) => 
          (request.priority == BloodRequestPriority.urgent ||
           request.priority == BloodRequestPriority.critical) &&
          request.status == BloodRequestStatus.active)
      .toList();
});

// Blood group specific providers
final bloodGroupRequestsProvider = Provider.family<List<BloodRequestModel>, String>((ref, bloodGroup) {
  final state = ref.watch(bloodRequestProvider);
  return state.requests
      .where((request) => 
          request.bloodGroup == bloodGroup && 
          request.status == BloodRequestStatus.active)
      .toList();
});

// User's requests provider
final userBloodRequestsProvider = Provider.family<List<BloodRequestModel>, String>((ref, userId) {
  final state = ref.watch(bloodRequestProvider);
  return state.requests
      .where((request) => request.requesterId == userId)
      .toList();
});