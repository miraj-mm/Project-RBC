import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/widgets/hover_button.dart';
import '../../blood_requests/screens/blood_requests_screen.dart';
import '../../blood_requests/screens/create_blood_request_screen.dart';

class BloodDonationSection extends StatelessWidget {
  final int normalRequests;
  final int urgentRequests;
  final int criticalRequests;
  const BloodDonationSection({
    super.key,
    this.normalRequests = 0,
    this.urgentRequests = 0,
    this.criticalRequests = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title outside container
        Padding(
          padding: const EdgeInsets.only(
            left: 20, // Match the bus route section padding
            bottom: AppSizes.paddingS,
          ),
          child: Text(
            AppStrings.iutBloodDonation,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimaryColor(context),
              letterSpacing: 0.3,
            ),
          ),
        ),
        
        // Container with content
        Card(
          color: AppColors.getCardBackgroundColor(context),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          
          // Want to be a donor button
          SizedBox(
            width: double.infinity,
            child: HoverButton(
              baseColor: AppColors.primaryRed,
              hoverColor: AppColors.primaryRed.withOpacity(0.9),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BloodRequestsScreen(),
                  ),
                );
              },
              padding: const EdgeInsets.all(AppSizes.paddingM),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bloodtype,
                      color: AppColors.primaryRed,
                      size: AppSizes.iconM,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  const Expanded(
                    child: Text(
                      AppStrings.wantToBeADonor,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.white,
                    size: AppSizes.iconS,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Request for blood button
          SizedBox(
            width: double.infinity,
            child: HoverButton(
              baseColor: AppColors.getCardBackgroundColor(context),
              hoverColor: AppColors.primaryRed.withOpacity(0.05),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateBloodRequestScreen(),
                  ),
                );
              },
              padding: const EdgeInsets.all(AppSizes.paddingM),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              border: Border.all(
                color: AppColors.primaryRed,
                width: 1,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bloodtype,
                      color: AppColors.white,
                      size: AppSizes.iconM,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  const Expanded(
                    child: Text(
                      AppStrings.requestForBlood,
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryRed,
                    size: AppSizes.iconS,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Request categories row
          Row(
            children: [
              Expanded(
                child: _buildRequestCard(
                  'Normal Requests',
                  normalRequests.toString(),
                  Colors.red.shade400,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: _buildRequestCard(
                  'Urgent Requests',
                  urgentRequests.toString(),
                  Colors.red,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: _buildRequestCard(
                  'Critical Requests',
                  criticalRequests.toString(),
                  Colors.red.shade700,
                ),
              ),
            ],
          ),
          ],
        ),
            ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            count,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}