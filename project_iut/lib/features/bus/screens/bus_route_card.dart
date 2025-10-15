import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/widgets/hover_button.dart';

class BusRouteCard extends StatelessWidget {
  final String busName;
  final String status;
  final String nearestStation;
  final VoidCallback onViewMap;
  final Color color;
  final IconData icon;

  const BusRouteCard({
    Key? key,
    required this.busName,
    required this.status,
    required this.nearestStation,
    required this.onViewMap,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: Container(
        width: double.infinity,
        height: 220,
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 48),
            Text(busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, color: status == 'Running' ? Colors.green : Colors.grey, size: 14),
                const SizedBox(width: 6),
                Text(status, style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('Nearest: $nearestStation', 
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: HoverButton(
                baseColor: color,
                onPressed: onViewMap,
                padding: const EdgeInsets.symmetric(vertical: 8),
                borderRadius: BorderRadius.circular(10),
                child: const Center(
                  child: Text(
                    'View on Map', 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 12,
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
}
