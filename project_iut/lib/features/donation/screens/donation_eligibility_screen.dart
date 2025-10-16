import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/hover_button.dart';
import 'donation_confirmation_screen.dart';
import '../../../core/widgets/app_top_bar.dart';

class DonationEligibilityScreen extends ConsumerStatefulWidget {
  final BloodRequestModel bloodRequest;

  const DonationEligibilityScreen({
    super.key,
    required this.bloodRequest,
  });

  @override
  ConsumerState<DonationEligibilityScreen> createState() => _DonationEligibilityScreenState();
}

class _DonationEligibilityScreenState extends ConsumerState<DonationEligibilityScreen> {
  final Map<String, bool?> _answers = {};
  final _formKey = GlobalKey<FormState>();
  
  // Eligibility questions
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'age',
      'question': 'Are you between 18-65 years old?',
      'required': true,
      'eliminatory': true,
    },
    {
      'id': 'weight',
      'question': 'Do you weigh at least 50kg (110 lbs)?',
      'required': true,
      'eliminatory': true,
    },
    {
      'id': 'health',
      'question': 'Are you feeling well and healthy today?',
      'required': true,
      'eliminatory': true,
    },
    {
      'id': 'medication',
      'question': 'Are you currently taking any medication (excluding vitamins and birth control)?',
      'required': true,
      'eliminatory': false,
    },
    {
      'id': 'alcohol',
      'question': 'Have you consumed alcohol in the last 24 hours?',
      'required': true,
      'eliminatory': true,
    },
    {
      'id': 'sleep',
      'question': 'Did you get at least 6 hours of sleep last night?',
      'required': true,
      'eliminatory': true,
    },
    {
      'id': 'donation',
      'question': 'Has it been at least 8 weeks since your last blood donation?',
      'required': true,
      'eliminatory': true,
    },
    {
      'id': 'tattoo',
      'question': 'Have you gotten a tattoo or piercing in the last 6 months?',
      'required': true,
      'eliminatory': true,
    },
    {
      'id': 'travel',
      'question': 'Have you traveled to a malaria-endemic area in the last year?',
      'required': true,
      'eliminatory': false,
    },
    {
      'id': 'surgery',
      'question': 'Have you had any major surgery in the last 6 months?',
      'required': true,
      'eliminatory': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: const AppTopBar(title: 'Donation Eligibility'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Card
            Container(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkCard : AppColors.white,
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
                    'Donating for:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getBloodGroupColor(),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.bloodRequest.bloodGroup,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            widget.bloodRequest.hospitalName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Instructions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: AppSizes.iconS,
                ),
                SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: Text(
                    'Please answer all questions honestly. Your responses help ensure safe blood donation for both you and the recipient.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Questions Form
          Form(
              key: _formKey,
              child: Column(
                children: _questions.map((question) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.darkCard : AppColors.white,
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
                          question['question'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text('Yes', style: TextStyle(fontSize: 12, color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                                value: true,
                                groupValue: _answers[question['id']],
                                onChanged: (value) {
                                  setState(() {
                                    _answers[question['id']] = value;
                                  });
                                },
                                activeColor: AppColors.primaryRed,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text('No', style: TextStyle(fontSize: 12, color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                                value: false,
                                groupValue: _answers[question['id']],
                                onChanged: (value) {
                                  setState(() {
                                    _answers[question['id']] = value;
                                  });
                                },
                                activeColor: AppColors.primaryRed,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: HoverButton(
                baseColor: _getAnsweredCount() == _questions.length 
                  ? AppColors.primaryRed 
                  : AppColors.primaryRed.withOpacity(0.5),
                hoverColor: _getAnsweredCount() == _questions.length 
                  ? AppColors.primaryRed.withOpacity(0.8)
                  : AppColors.primaryRed.withOpacity(0.5),
                onPressed: _getAnsweredCount() == _questions.length ? _checkEligibility : () {},
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                child: Center(
                  child: Text(
                    'Continue (${_getAnsweredCount()}/${_questions.length})',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
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

  int _getAnsweredCount() {
    return _answers.values.where((answer) => answer != null).length;
  }

  void _checkEligibility() {
    bool isEligible = true;
    List<String> issues = [];

    for (final question in _questions) {
      final answer = _answers[question['id']];
      final isEliminatory = question['eliminatory'] as bool;
      
      if (isEliminatory) {
        // For eliminatory questions, check specific logic
        switch (question['id']) {
          case 'age':
          case 'weight':
          case 'health':
          case 'sleep':
          case 'donation':
            if (answer != true) {
              isEligible = false;
              issues.add(question['question']);
            }
            break;
          case 'alcohol':
          case 'tattoo':
          case 'surgery':
            if (answer == true) {
              isEligible = false;
              issues.add(question['question']);
            }
            break;
        }
      }
    }

    if (isEligible) {
      _proceedToDonation();
    } else {
      _showIneligibilityDialog(issues);
    }
  }

  void _proceedToDonation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationConfirmationScreen(
          bloodRequest: widget.bloodRequest,
          eligibilityAnswers: _answers,
        ),
      ),
    );
  }

  void _showIneligibilityDialog(List<String> issues) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning,
              color: AppColors.warning,
            ),
            SizedBox(width: AppSizes.paddingS),
            Text('Not Eligible'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Based on your responses, you may not be eligible to donate blood at this time.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Please consult with medical professionals for guidance.',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
