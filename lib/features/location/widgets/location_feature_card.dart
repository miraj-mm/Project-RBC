import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/hover_button.dart';
import '../screens/location_input_screen.dart';

class LocationFeatureCard extends ConsumerWidget {
  const LocationFeatureCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title outside container
        Padding(
          padding: const EdgeInsets.only(
            left: 20, // Match other section padding
            bottom: AppSizes.paddingS,
          ),
          child: Text(
            'Location Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimaryColor(context),
              letterSpacing: 0.3,
            ),
          ),
        ),
        
        // Container with content
        Container(
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
            'Set your location to find nearby bus routes and blood donation centers.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondaryColor(context),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Features List
          const _FeatureItem(
            icon: Icons.search,
            text: 'Search with Google Places',
          ),
          const SizedBox(height: AppSizes.paddingS),
          const _FeatureItem(
            icon: Icons.my_location,
            text: 'Use current GPS location',
          ),
          const SizedBox(height: AppSizes.paddingS),
          const _FeatureItem(
            icon: Icons.link,
            text: 'Generate shareable maps link',
          ),
          const SizedBox(height: AppSizes.paddingS),
          const _FeatureItem(
            icon: Icons.verified,
            text: 'Address validation',
          ),
          
          const SizedBox(height: AppSizes.paddingL),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: HoverButton(
              baseColor: AppColors.primaryRed,
              hoverColor: AppColors.primaryRed.withOpacity(0.8),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationInputScreen(),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingM,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_searching, color: AppColors.white),
                  SizedBox(width: 8),
                  Text(
                    'Set Location',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.success,
        ),
        const SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondaryColor(context),
            ),
          ),
        ),
      ],
    );
  }
}

