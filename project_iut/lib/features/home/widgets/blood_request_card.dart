import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/core.dart';
import '../../../core/widgets/hover_button.dart';
import '../../donation/screens/donation_eligibility_screen.dart';

class BloodRequestCard extends StatelessWidget {
  final BloodRequestModel bloodRequest;

  const BloodRequestCard({
    super.key,
    required this.bloodRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      color: isDarkMode ? AppColors.darkCard : AppColors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(
          color: _getUrgencyColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with urgency badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getUrgencyColor(),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  bloodRequest.priority == BloodRequestPriority.urgent || 
                  bloodRequest.priority == BloodRequestPriority.critical 
                      ? 'URGENT' : 'NORMAL',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _shareBloodRequest(context),
                    icon: Icon(
                      Icons.share,
                      color: AppColors.primaryRed,
                      size: AppSizes.iconS,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  IconButton(
                    onPressed: () => _copyToClipboard(context),
                    icon: Icon(
                      Icons.copy,
                      color: AppColors.primaryRed,
                      size: AppSizes.iconS,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingS),
          
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Blood Group: ${bloodRequest.bloodGroup}',
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
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Hospital Info
          Row(
            children: [
              Icon(
                Icons.local_hospital,
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                size: AppSizes.iconS,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: Text(
                  bloodRequest.hospitalName,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingS),
          
          // Location Info
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                size: AppSizes.iconS,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: Text(
                  bloodRequest.hospitalAddress,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingS),
          
          // Contact Info
          Row(
            children: [
              Icon(
                Icons.phone,
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                size: AppSizes.iconS,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: Text(
                  bloodRequest.contactNumber,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingS),
          
          // Required Date
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                size: AppSizes.iconS,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                'Required by: ${_formatDate(bloodRequest.requiredBy)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          if (bloodRequest.additionalNotes?.isNotEmpty == true) ...[
            const SizedBox(height: AppSizes.paddingS),
            Text(
              bloodRequest.additionalNotes!,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: HoverButton(
                  baseColor: AppColors.primaryRed,
                  hoverColor: AppColors.primaryRed.withOpacity(0.8),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonationEligibilityScreen(
                          bloodRequest: bloodRequest,
                        ),
                      ),
                    );
                  },
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  child: const Center(
                    child: Text(
                      'Donate Now',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: HoverButton(
                  baseColor: isDarkMode ? AppColors.darkCard : AppColors.white,
                  hoverColor: AppColors.primaryRed.withOpacity(0.05),
                  onPressed: () {
                    _showContactDialog(context);
                  },
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  border: const Border.fromBorderSide(BorderSide(color: AppColors.primaryRed)),
                  child: const Center(
                    child: Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryRed,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
    );
  }

  Color _getUrgencyColor() {
    return (bloodRequest.priority == BloodRequestPriority.urgent || 
            bloodRequest.priority == BloodRequestPriority.critical) 
           ? AppColors.error : AppColors.success;
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _generateShareText() {
    final isUrgent = bloodRequest.priority == BloodRequestPriority.urgent || 
                     bloodRequest.priority == BloodRequestPriority.critical;
    
    return '''
🚨 BLOOD DONATION REQUEST ${isUrgent ? '- URGENT' : ''}

Patient: ${bloodRequest.patientName}
Blood Group: ${bloodRequest.bloodGroup}
Units Required: ${bloodRequest.unitsRequired}

Hospital: ${bloodRequest.hospitalName}
Location: ${bloodRequest.hospitalAddress}
Required by: ${_formatDate(bloodRequest.requiredBy)}

Contact: ${bloodRequest.contactNumber}

${bloodRequest.additionalNotes?.isNotEmpty == true ? '\nNote: ${bloodRequest.additionalNotes}' : ''}

Please help save a life by donating blood! 🩸❤️

#BloodDonation #SaveLife #IUTBloodDonation
    '''.trim();
  }

  Future<void> _shareBloodRequest(BuildContext context) async {
    try {
      final text = _generateShareText();
      await Share.share(
        text,
        subject: '${(bloodRequest.priority == BloodRequestPriority.urgent || bloodRequest.priority == BloodRequestPriority.critical) ? 'URGENT ' : ''}Blood Donation Request - ${bloodRequest.bloodGroup}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    try {
      final text = _generateShareText();
      await Clipboard.setData(ClipboardData(text: text));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blood request details copied to clipboard!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to copy. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showContactDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.phone,
              color: AppColors.primaryRed,
            ),
            SizedBox(width: AppSizes.paddingS),
            Text('Contact'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact ${bloodRequest.patientName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  size: AppSizes.iconS,
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: Text(
                    bloodRequest.contactNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                Icon(
                  Icons.local_hospital,
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  size: AppSizes.iconS,
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: Text(
                    bloodRequest.hospitalName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          HoverButton(
            baseColor: AppColors.primaryRed,
            hoverColor: AppColors.primaryRed.withOpacity(0.8),
            onPressed: () {
              Navigator.of(context).pop();
              // Here you could add functionality to actually make a call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling ${bloodRequest.contactNumber}...'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            borderRadius: BorderRadius.circular(8),
            child: const Center(
              child: Text(
                'Call',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

