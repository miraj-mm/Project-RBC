import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/traccar_service.dart';

// Provider for tracking status
final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier();
});

class TrackingState {
  final bool isTracking;
  final String? error;
  final Map<String, dynamic>? lastPosition;

  TrackingState({
    this.isTracking = false,
    this.error,
    this.lastPosition,
  });

  TrackingState copyWith({
    bool? isTracking,
    String? error,
    Map<String, dynamic>? lastPosition,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      error: error,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  TrackingNotifier() : super(TrackingState());

  Future<void> startTracking() async {
    try {
      state = state.copyWith(error: null);
      await TraccarService.startTracking();
      state = state.copyWith(isTracking: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void stopTracking() {
    TraccarService.stopTracking();
    state = state.copyWith(isTracking: false);
  }

  Future<void> sendOneTimeLocation() async {
    try {
      state = state.copyWith(error: null);
      await TraccarService.sendOneTimeLocation();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> getLatestPosition() async {
    try {
      final position = await TraccarService.getLatestPosition();
      state = state.copyWith(lastPosition: position);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Map<String, dynamic> getTrackingStatus() {
    return TraccarService.getTrackingStatus();
  }
}