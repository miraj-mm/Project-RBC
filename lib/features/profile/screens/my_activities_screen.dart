import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/hover_button.dart';

class MyActivitiesScreen extends ConsumerWidget {
  const MyActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: const AppTopBar(title: 'My Activities'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Overview
            _buildStatisticsOverview(context),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Donation History Section
            Text(
              'Donation History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimaryColor(context),
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            // History List
            ..._getSampleDonations().map((donation) => 
              _buildDonationHistoryCard(donation)
            ).toList(),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Empty State or Load More
            if (_getSampleDonations().isEmpty)
              _buildEmptyState(context)
            else
              _buildLoadMoreButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title outside container
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingM,
            bottom: AppSizes.paddingS,
          ),
          child: Text(
            'Your Impact Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimaryColor(context),
              letterSpacing: 0.3,
            ),
          ),
        ),
        
        // Container with statistics
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
            children: [
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Donations',
                  '12',
                  Icons.favorite,
                  AppColors.primaryRed,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: _buildStatItem(
                  'Lives Saved',
                  '36',
                  Icons.people,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: _buildStatItem(
                  'Blood Volume',
                  '6.0L',
                  Icons.water_drop,
                  AppColors.info,
                ),
              ),
            ],
          ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Builder(builder: (context) => Container(
      padding: const EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppSizes.iconM,
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ));
  }

  Widget _buildDonationHistoryCard(Map<String, dynamic> donation) {
    return Builder(builder: (context) => Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: _getStatusColor(donation['status']).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(donation['status']),
                      color: _getStatusColor(donation['status']),
                      size: AppSizes.iconS,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  Text(
                    donation['location'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: AppSizes.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(donation['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  donation['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(donation['status']),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingS),
          
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: AppSizes.iconXS,
                color: AppColors.getTextSecondaryColor(context),
              ),
              const SizedBox(width: AppSizes.paddingXS),
              Text(
                donation['date'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextSecondaryColor(context),
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Icon(
                Icons.access_time,
                size: AppSizes.iconXS,
                color: AppColors.getTextSecondaryColor(context),
              ),
              const SizedBox(width: AppSizes.paddingXS),
              Text(
                donation['time'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingS),
          
          Row(
            children: [
              Icon(
                Icons.water_drop,
                size: AppSizes.iconXS,
                color: AppColors.primaryRed,
              ),
              const SizedBox(width: AppSizes.paddingXS),
              Text(
                'Blood Type: ${donation['bloodType']}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${donation['volume']}ml',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          if (donation['notes'] != null && donation['notes'].isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Notes: ${donation['notes']}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondaryColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    ));
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
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
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'No Donation History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            'Your donation history will appear here once you start donating blood.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingL),
          HoverButton(
            baseColor: AppColors.primaryRed,
            onPressed: () {
              Navigator.pop(context);
            },
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: const Center(
              child: Text(
                'Start Donating',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Builder(builder: (context) => HoverButton(
      baseColor: AppColors.getCardBackgroundColor(context),
      onPressed: () {
        // TODO: Implement load more functionality
      },
      padding: const EdgeInsets.all(AppSizes.paddingM),
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      border: Border.all(color: AppColors.getBorderColor(context)),
      child: Center(
        child: Text(
          'Load More',
          style: TextStyle(
            color: AppColors.getTextPrimaryColor(context),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ));
  }

  // Sample data - replace with actual API calls
  List<Map<String, dynamic>> _getSampleDonations() {
    return [
      {
        'id': '1',
        'location': 'IUT Blood Bank',
        'date': 'Oct 10, 2024',
        'time': '10:30 AM',
        'bloodType': 'O+',
        'volume': 500,
        'status': 'Completed',
        'notes': 'Successful donation, no complications',
      },
      {
        'id': '2',
        'location': 'Dhaka Medical College',
        'date': 'Sep 15, 2024',
        'time': '2:15 PM',
        'bloodType': 'O+',
        'volume': 500,
        'status': 'Completed',
        'notes': 'Emergency donation for accident victim',
      },
      {
        'id': '3',
        'location': 'City Hospital',
        'date': 'Aug 20, 2024',
        'time': '11:00 AM',
        'bloodType': 'O+',
        'volume': 450,
        'status': 'Completed',
        'notes': null,
      },
      {
        'id': '4',
        'location': 'Red Crescent Center',
        'date': 'Jul 25, 2024',
        'time': '9:45 AM',
        'bloodType': 'O+',
        'volume': 500,
        'status': 'Scheduled',
        'notes': 'Upcoming donation appointment',
      },
    ];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'scheduled':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'scheduled':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

