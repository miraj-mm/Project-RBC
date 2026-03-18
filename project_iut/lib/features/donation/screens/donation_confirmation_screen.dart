import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import 'donation_success_screen.dart';
import '../../../core/widgets/app_top_bar.dart';

class DonationConfirmationScreen extends ConsumerStatefulWidget {
  final BloodRequestModel bloodRequest;
  final Map<String, bool?> eligibilityAnswers;

  const DonationConfirmationScreen({
    super.key,
    required this.bloodRequest,
    required this.eligibilityAnswers,
  });

  @override
  ConsumerState<DonationConfirmationScreen> createState() => _DonationConfirmationScreenState();
}

class _DonationConfirmationScreenState extends ConsumerState<DonationConfirmationScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: const AppTopBar(title: 'Confirm Donation'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.paddingXXL),

              // Success Icon
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

              // Congratulations Message
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),

              Text(
                'Thank you for stepping up to save a life',
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
                              widget.bloodRequest.bloodGroup,
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
                                widget.bloodRequest.patientName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                widget.bloodRequest.hospitalName,
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
                      'Required By',
                      '${widget.bloodRequest.requiredBy.day}/${widget.bloodRequest.requiredBy.month}/${widget.bloodRequest.requiredBy.year}',
                    ),

                    const SizedBox(height: AppSizes.paddingS),

                    _buildDetailRow(
                      context,
                      Icons.access_time,
                      'Time',
                      TimeOfDay.fromDateTime(widget.bloodRequest.requiredBy).format(context),
                    ),

                    const SizedBox(height: AppSizes.paddingS),

                    _buildDetailRow(
                      context,
                      Icons.location_on,
                      'Location',
                      widget.bloodRequest.hospitalAddress,
                    ),

                    const SizedBox(height: AppSizes.paddingS),

                    _buildDetailRow(
                      context,
                      Icons.bloodtype,
                      'Units Needed',
                      '${widget.bloodRequest.unitsRequired}',
                    ),
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

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Confirm Donation',
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
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    side: const BorderSide(color: AppColors.primaryRed),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
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
          width: 100,
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
    switch (widget.bloodRequest.bloodGroup) {
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

  Future<void> _confirmDonation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final donorId = SupabaseService.currentUser?.id;
      if (donorId == null) {
        throw Exception('User not authenticated');
      }

      print('DEBUG: Confirming donation for request: ${widget.bloodRequest.id}');
      print('DEBUG: Requester ID: ${widget.bloodRequest.requesterId}');

      // Get donor details
      final donorResponse = await SupabaseService.from('users')
          .select('name, phone, blood_group')
          .eq('id', donorId)
          .single();

      final donorName = donorResponse['name'] as String? ?? 'Anonymous Donor';
      final donorPhone = donorResponse['phone'] as String? ?? '';
      final donorBloodGroup = donorResponse['blood_group'] as String? ?? widget.bloodRequest.bloodGroup;

      print('DEBUG: Donor name: $donorName, phone: $donorPhone');

      // Insert donation record
      await SupabaseService.from('donations').insert({
        'donor_id': donorId,
        'request_id': widget.bloodRequest.id,
        'donation_date': widget.bloodRequest.requiredBy.toIso8601String(),
        'blood_group': donorBloodGroup,
        'units_donated': widget.bloodRequest.unitsRequired,
        'hospital_name': widget.bloodRequest.hospitalName,
        'notes': widget.bloodRequest.additionalNotes,
      });

      print('DEBUG: Donation record inserted');

      // Create notification for the requester
      final notificationData = {
        'user_id': widget.bloodRequest.requesterId,
        'title': 'Donor Found!',
        'message': '$donorName has confirmed to donate ${widget.bloodRequest.bloodGroup} blood for ${widget.bloodRequest.patientName}. Contact: $donorPhone',
        'type': 'donation_received',
        'related_id': widget.bloodRequest.id,
        'is_read': false,
      };

      print('DEBUG: Creating notification with data: $notificationData');

      final notificationResult = await SupabaseService.from('notifications').insert(notificationData).select();

      print('DEBUG: Notification created: $notificationResult');

      // Wait a moment for database to process
      await Future.delayed(const Duration(milliseconds: 800));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation confirmed! Requester will be notified.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate to success screen
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DonationSuccessScreen(
              bloodRequest: widget.bloodRequest,
              donationDate: widget.bloodRequest.requiredBy,
              donationTime: TimeOfDay.fromDateTime(widget.bloodRequest.requiredBy),
              donationLocation: widget.bloodRequest.hospitalAddress,
              notes: widget.bloodRequest.additionalNotes ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      print('DEBUG ERROR: Failed to confirm donation: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm donation: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
