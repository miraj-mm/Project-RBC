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
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedLocation = '';
  bool _isAgreedToTerms = false;
  bool _isLoading = false;

  final List<String> _donationLocations = [
    'Dhaka Medical College Hospital',
    'Square Hospital',
    'Bangabandhu Sheikh Mujib Medical University',
    'Apollo Hospital',
    'United Hospital',
    'National Institute of Cardiovascular Diseases',
    'Holy Family Red Crescent Medical College Hospital',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: const AppTopBar(title: 'Confirm Donation'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.bloodRequest.hospitalName,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextSecondaryColor(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Units needed: ${widget.bloodRequest.unitsRequired}',
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
              const SizedBox(height: AppSizes.paddingL),
              // Donation Details Form
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.white,
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
                    const Text(
                      'Donation Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    // Preferred Date
                    const Text(
                      'Preferred Donation Date *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.getTextSecondaryColor(context),
                              size: AppSizes.iconS,
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Select donation date',
                              style: TextStyle(
                                color: _selectedDate != null
                                    ? AppColors.textPrimary
                                    : AppColors.getTextSecondaryColor(context),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    // Preferred Time
                    const Text(
                      'Preferred Time *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppColors.getTextSecondaryColor(context),
                              size: AppSizes.iconS,
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Text(
                              _selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : 'Select preferred time',
                              style: TextStyle(
                                color: _selectedTime != null
                                    ? AppColors.textPrimary
                                    : AppColors.getTextSecondaryColor(context),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    // Donation Location
                    const Text(
                      'Donation Location *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    DropdownButtonFormField<String>(
                      value: _selectedLocation.isEmpty ? null : _selectedLocation,
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value ?? '';
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Select donation location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          borderSide: const BorderSide(color: AppColors.inputBorder),
                        ),
                        contentPadding: const EdgeInsets.all(AppSizes.paddingM),
                      ),
                      items: _donationLocations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(
                            location,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    // Additional Notes
                    const Text(
                      'Additional Notes (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Any special requests or information...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          borderSide: const BorderSide(color: AppColors.inputBorder),
                        ),
                        contentPadding: const EdgeInsets.all(AppSizes.paddingM),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    // Terms and Conditions
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.white,
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
                        children: [
                          CheckboxListTile(
                            value: _isAgreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _isAgreedToTerms = value ?? false;
                              });
                            },
                            title: const Text(
                              'I agree to the terms and conditions',
                              style: TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              'I understand the blood donation process and consent to donate blood.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getTextSecondaryColor(context),
                              ),
                            ),
                            activeColor: AppColors.primaryRed,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canConfirm() ? _confirmDonation : null,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  bool _canConfirm() {
    return _selectedDate != null &&
           _selectedTime != null &&
           _selectedLocation.isNotEmpty &&
           _isAgreedToTerms &&
           !_isLoading;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _confirmDonation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DonationSuccessScreen(
              bloodRequest: widget.bloodRequest,
              donationDate: _selectedDate!,
              donationTime: _selectedTime!,
              donationLocation: _selectedLocation,
              notes: _notesController.text,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to confirm donation. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
