import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';

class DonationSuccessScreen extends ConsumerWidget {
  final BloodRequestModel bloodRequest;
  final DateTime donationDate;
  final TimeOfDay donationTime;
  final String donationLocation;
  final String notes;

  const DonationSuccessScreen({
    super.key,
    required this.bloodRequest,
    required this.donationDate,
    required this.donationTime,
    required this.donationLocation,
    required this.notes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.getBorderColor(context),
      appBar: const AppTopBar(title: 'Donation Success'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.paddingXXL),

              // Success Animation/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.white,
                  size: 60,
                ),
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // Success Message
              const Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),

              Text(
                'Your donation request has been confirmed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextSecondaryColor(context),
                ),
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // Donation Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Info
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getBloodGroupColor(),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              bloodRequest.bloodGroup,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bloodRequest.patientName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                bloodRequest.hospitalName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.getTextSecondaryColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.paddingL),

                    Divider(color: AppColors.getBorderColor(context)),

                    const SizedBox(height: AppSizes.paddingL),

                    // Donation Details
                    const Text(
                      'Donation Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingM),

                    _buildDetailRow(
                      context,
                      Icons.calendar_today,
                      'Date',
                      '${donationDate.day}/${donationDate.month}/${donationDate.year}',
                    ),

                    const SizedBox(height: AppSizes.paddingS),

                    _buildDetailRow(
                      context,
                      Icons.access_time,
                      'Time',
                      donationTime.format(context),
                    ),

                    const SizedBox(height: AppSizes.paddingS),

                    _buildDetailRow(
                      context,
                      Icons.location_on,
                      'Location',
                      donationLocation,
                    ),

                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.paddingS),
                      _buildDetailRow(
                        context,
                        Icons.note,
                        'Notes',
                        notes,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // Important Information
              Container(
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
                          'Important Reminders',
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
                      '• Eat a healthy meal before donation\n'
                      '• Bring a valid ID with you\n'
                      '• Stay hydrated (drink plenty of water)\n'
                      '• Get adequate sleep the night before\n'
                      '• Avoid alcohol 24 hours before donation',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondaryColor(context),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingXXL),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to donation tracking or calendar
                        _showAddToCalendarDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                      ),
                      child: const Text(
                        'Add to Calendar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate back to home
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        side: const BorderSide(color: AppColors.primaryRed),
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.getTextSecondaryColor(context),
          size: AppSizes.iconS,
        ),
        const SizedBox(width: AppSizes.paddingS),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondaryColor(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getBloodGroupColor() {
    switch (bloodRequest.bloodGroup) {
      case 'A+':
      case 'A-':
        return AppColors.bloodGroupA;
      case 'B+':
      case 'B-':
        return AppColors.bloodGroupB;
      case 'AB+':
      case 'AB-':
        return AppColors.bloodGroupAB;
      case 'O+':
      case 'O-':
        return AppColors.bloodGroupO;
      default:
        return AppColors.primaryRed;
    }
  }

  void _showAddToCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Calendar'),
        content: const Text(
          'Would you like to add this donation appointment to your calendar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Donation appointment added to calendar'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
