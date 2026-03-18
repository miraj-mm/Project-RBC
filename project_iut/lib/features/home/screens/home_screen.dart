import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../bus/screens/bus_route_section.dart';
import '../widgets/blood_donation_section.dart';
import '../widgets/dynamic_profile_section.dart';
import '../../location/widgets/location_feature_card.dart';
import '../../blood_requests/providers/blood_request_provider.dart';
import '../../../core/widgets/app_top_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: const AppTopBar(
        title: AppStrings.home,
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: AppSizes.paddingM,
          bottom: AppSizes.paddingM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic User Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: const DynamicProfileSection(),
            ),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Bus Route Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: const BusRouteSection(),
            ),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Blood Donation Section
            Consumer(
              builder: (context, ref, child) {
                final bloodRequestState = ref.watch(bloodRequestProvider);
                final normalCount = bloodRequestState.requests.where((r) => r.priority == BloodRequestPriority.normal).length;
                final urgentCount = bloodRequestState.requests.where((r) => r.priority == BloodRequestPriority.urgent).length;
                final criticalCount = bloodRequestState.requests.where((r) => r.priority == BloodRequestPriority.critical).length;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: BloodDonationSection(
                    normalRequests: normalCount,
                    urgentRequests: urgentCount,
                    criticalRequests: criticalCount,
                  ),
                );
              },
            ),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Location Services Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: const LocationFeatureCard(),
            ),
            
            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

}