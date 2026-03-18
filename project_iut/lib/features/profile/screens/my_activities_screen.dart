import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/hover_button.dart';
import '../../blood_requests/screens/blood_requests_screen.dart';
import '../providers/profile_provider.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';

class MyActivitiesScreen extends ConsumerWidget {
  const MyActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(userStatsProvider);
    final donationsAsync = ref.watch(userDonationsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppTopBar(title: l10n.myActivities),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Overview
            _buildStatisticsOverview(context, statsAsync, l10n),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Donation History Section
            Text(
              l10n.donationHistory,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimaryColor(context),
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            // History List
            donationsAsync.when(
              data: (donations) {
                if (donations.isEmpty) {
                  return _buildEmptyState(context, l10n);
                }
                return Column(
                  children: donations.map((donation) => 
                    _buildDonationHistoryCard(context, donation, l10n)
                  ).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingXL),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingXL),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Text(
                        l10n.failedToLoadDonationHistory,
                        style: TextStyle(
                          color: AppColors.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsOverview(BuildContext context, AsyncValue<UserStats> statsAsync, AppLocalizations l10n) {
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
            l10n.yourImpactSummary,
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
          child: statsAsync.when(
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n.totalDonations,
                    '${stats.totalDonations}',
                    Icons.favorite,
                    AppColors.primaryRed,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: _buildStatItem(
                    l10n.livesSaved,
                    '${stats.livesSaved}',
                    Icons.people,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: _buildStatItem(
                    l10n.bloodVolume,
                    '${(stats.totalDonations * 0.5).toStringAsFixed(1)}L',
                    Icons.water_drop,
                    AppColors.info,
                  ),
                ),
              ],
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingL),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Text(
                  l10n.unableToLoadStatistics,
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                ),
              ),
            ),
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

  Widget _buildDonationHistoryCard(BuildContext context, DonationRecord donation, AppLocalizations l10n) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final donationDate = dateFormat.format(donation.donationDate);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      color: AppColors.getCardBackgroundColor(context),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
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
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: AppSizes.iconS,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  Flexible(
                    child: Text(
                      donation.hospitalName.isNotEmpty 
                        ? donation.hospitalName 
                        : l10n.bloodDonation,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimaryColor(context),
                      ),
                      overflow: TextOverflow.ellipsis,
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
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  l10n.completed,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
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
                donationDate,
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
              const Icon(
                Icons.water_drop,
                size: AppSizes.iconXS,
                color: AppColors.primaryRed,
              ),
              const SizedBox(width: AppSizes.paddingXS),
              Text(
                '${l10n.bloodType}: ${donation.bloodGroup}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${donation.unitsDonated * 500}ml',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          if (donation.notes != null && donation.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingS),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: AppSizes.iconXS,
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                  const SizedBox(width: AppSizes.paddingXS),
                  Expanded(
                    child: Text(
                      donation.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
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
            l10n.noDonationHistory,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            l10n.donationHistoryMessage,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BloodRequestsScreen(),
                ),
              );
            },
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: Center(
              child: Text(
                l10n.startDonating,
                style: const TextStyle(
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
}
