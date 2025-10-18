import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/core.dart';
import '../../../core/widgets/app_top_bar.dart';

class BusRouteInfoScreen extends StatefulWidget {
  const BusRouteInfoScreen({super.key});

  @override
  State<BusRouteInfoScreen> createState() => _BusRouteInfoScreenState();
}

class _BusRouteInfoScreenState extends State<BusRouteInfoScreen> {
  // Example bus location (should be fetched from Traccar API)
  LatLng busLocation = const LatLng(23.8103, 90.4125); // Dhaka coordinates
  GoogleMapController? _mapController;
  Brightness? _lastBrightness;

  static const String _darkMapStyle = '[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1e1e1e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#383838"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}]';

  static const String _lightMapStyle = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-apply map style when theme changes
    final brightness = Theme.of(context).brightness;
    if (_lastBrightness != brightness) {
      _lastBrightness = brightness;
      _applyMapStyle();
    }
  }

  Future<void> _applyMapStyle() async {
    if (_mapController == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await _mapController!.setMapStyle(isDark ? _darkMapStyle : _lightMapStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Bus Route Info'),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                _applyMapStyle();
              },
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
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              border: Border(top: BorderSide(color: AppColors.getBorderColor(context))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bus Status: Running',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Location: Dhaka',
                  style: TextStyle(color: AppColors.getTextSecondaryColor(context)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: Just now',
                  style: TextStyle(color: AppColors.getTextSecondaryColor(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
