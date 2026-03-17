import 'package:flutter/material.dart';
import '../../../core/core.dart';

class BusRouteSection extends StatelessWidget {
  const BusRouteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            AppStrings.iutBusRoute,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          
          // Bus Route Cards
          Row(
            children: [
              Expanded(
                child: _buildBusCard('Bus1', AppStrings.running, true),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: _buildBusCard('Bus1', AppStrings.running, true),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.primaryRed,
                size: AppSizes.iconS,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: Text(
                  AppStrings.newesStation,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard(String busName, String status, bool isRunning) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus,
              color: AppColors.primaryRed,
              size: AppSizes.iconM,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            busName,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isRunning ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                status,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}