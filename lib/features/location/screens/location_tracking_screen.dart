import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../providers/tracking_provider.dart';
import '../../../core/widgets/app_top_bar.dart';

class LocationTrackingScreen extends ConsumerWidget {
  const LocationTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingProvider);
    final trackingNotifier = ref.read(trackingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: const AppTopBar(title: 'Location Tracking'),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tracking Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        trackingState.isTracking ? Icons.gps_fixed : Icons.gps_off,
                        color: trackingState.isTracking ? AppColors.success : AppColors.error,
                        size: AppSizes.iconM,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        trackingState.isTracking ? 'Tracking Active' : 'Tracking Inactive',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: trackingState.isTracking ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    trackingState.isTracking
                        ? 'Your location is being tracked and sent to Traccar server every 30 seconds.'
                        : 'Location tracking is currently disabled.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingM),

            // Control Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Controls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  
                  // Start/Stop Tracking Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (trackingState.isTracking) {
                          trackingNotifier.stopTracking();
                        } else {
                          trackingNotifier.startTracking();
                        }
                      },
                      icon: Icon(
                        trackingState.isTracking ? Icons.stop : Icons.play_arrow,
                        color: AppColors.white,
                      ),
                      label: Text(
                        trackingState.isTracking ? 'Stop Tracking' : 'Start Tracking',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: trackingState.isTracking ? AppColors.error : AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.paddingS),
                  
                  // Send One-Time Location Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        trackingNotifier.sendOneTimeLocation();
                      },
                      icon: Icon(
                        Icons.my_location,
                        color: AppColors.primaryRed,
                      ),
                      label: Text(
                        'Send Current Location',
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryRed),
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.paddingS),
                  
                  // Get Latest Position Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        trackingNotifier.getLatestPosition();
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: AppColors.info,
                      ),
                      label: Text(
                        'Get Latest Position',
                        style: TextStyle(
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.info),
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingM),

            // Error Display
            if (trackingState.error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: AppSizes.iconS,
                    ),
                    const SizedBox(width: AppSizes.paddingS),
                    Expanded(
                      child: Text(
                        trackingState.error!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
            ],

            // Latest Position Display
            if (trackingState.lastPosition != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Position',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      'Latitude: ${trackingState.lastPosition!['latitude']?.toString() ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                    Text(
                      'Longitude: ${trackingState.lastPosition!['longitude']?.toString() ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                    Text(
                      'Timestamp: ${trackingState.lastPosition!['timestamp']?.toString() ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: AppSizes.iconS,
                      ),
                      SizedBox(width: AppSizes.paddingS),
                      Text(
                        'Traccar Integration',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.paddingS),
                  Text(
                    'This feature integrates with Traccar server for real-time location tracking. '
                    'Location data is sent every 30 seconds when tracking is active. '
                    'This can be used to track buses, delivery vehicles, or for emergency services.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
