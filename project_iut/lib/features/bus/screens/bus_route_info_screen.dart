import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';

class BusRouteInfoScreen extends StatefulWidget {
  const BusRouteInfoScreen({Key? key}) : super(key: key);

  @override
  State<BusRouteInfoScreen> createState() => _BusRouteInfoScreenState();
}

class _BusRouteInfoScreenState extends State<BusRouteInfoScreen> {
  // Example bus location (should be fetched from Traccar API)
  LatLng busLocation = const LatLng(23.8103, 90.4125); // Dhaka coordinates

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Bus Route Info'),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: busLocation,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('bus'),
                  position: busLocation,
                  infoWindow: const InfoWindow(title: 'Bus Location'),
                ),
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Bus Status: Running', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Current Location: Dhaka'),
                SizedBox(height: 8),
                Text('Last Updated: Just now'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
