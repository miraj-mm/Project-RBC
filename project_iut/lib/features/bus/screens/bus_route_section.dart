import 'package:flutter/material.dart';
import '../../../core/core.dart';
import 'bus_route_info_screen.dart';
import 'bus_route_card.dart';

class BusRouteSection extends StatelessWidget {
  const BusRouteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title with padding to align with blood donation section
        Padding(
          padding: EdgeInsets.only(
            left: 20, // 16px (container padding) + 4px (text padding) = 20px total
            bottom: AppSizes.paddingS,
          ),
          child: Text(
            'IUT Bus Route',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.getTextPrimaryColor(context),
              letterSpacing: 0.3,
            ),
          ),
        ),
        // Bus route cards with proper spacing to match blood donation section
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSizes.paddingS),
                child: BusRouteCard(
                  busName: 'Bus 1',
                  status: 'Running',
                  nearestStation: 'Tongi',
                  color: Colors.red,
                  icon: Icons.directions_bus,
                  onViewMap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BusRouteInfoScreen()),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: AppSizes.paddingS),
                child: BusRouteCard(
                  busName: 'Bus 2',
                  status: 'Stopped',
                  nearestStation: 'Uttara',
                  color: Colors.blue,
                  icon: Icons.directions_bus_filled,
                  onViewMap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BusRouteInfoScreen()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
