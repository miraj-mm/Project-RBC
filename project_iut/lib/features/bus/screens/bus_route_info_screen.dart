import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/core.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/station_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/station.dart';
import '../../../core/services/location_service.dart';


class BusRouteInfoScreen extends StatefulWidget {
  const BusRouteInfoScreen({super.key});

  @override
  State<BusRouteInfoScreen> createState() => _BusRouteInfoScreenState();
}

class _BusRouteInfoScreenState extends State<BusRouteInfoScreen> {
  // Example bus location (should be fetched from Traccar API)
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  LocationResult? _currentPosition;
  SupabaseClient? _supabase;
  bool _isLoading = true;
  String? _errorMessage;

  final StationService _stationService = StationService();
  List<Station> _stations = [];
  bool _showStations = true;

  @override
  void initState() {
    super.initState();
    print('UserDashboard: initState called');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      _supabase = Supabase.instance.client;
      print('UserDashboard: Supabase client obtained');

      await _stationService.initialize();
      print('UserDashboard: Station service initialized');

      await Future.wait([_getCurrentLocation(), _loadStations()]);

      // Ensure bus table exists and has 'bus_name' column
      final response = await _supabase!
          .from('buses')
          .select()
          .limit(1); // Just check if table is accessible

      if (response.isNotEmpty) {
        await _listenForDriverLocation();
      } else {
        print(
          'UserDashboard: No "buses" table or data found. Skipping driver location listener.',
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('UserDashboard ERROR: Initialization failed - $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStations() async {
    try {
      print('UserDashboard: Loading stations...');
      _stations = await _stationService.fetchStations();
      print('UserDashboard: Loaded ${_stations.length} stations');

      _updateStationMarkers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${_stations.length} stations'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('UserDashboard ERROR: Failed to load stations - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load stations: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _updateStationMarkers() {
    setState(() {
      _markers.removeWhere(
        (marker) => marker.markerId.value.startsWith('station_'),
      );
      if (_showStations) {
        Set<Marker> stationMarkers = _stationService.createStationMarkers(
          _stations,
          onTap: (station) {
            print('UserDashboard: Station tapped - ${station.name}');
            _showStationInfo(station);
          },
        );
        _markers.addAll(stationMarkers);
        print('UserDashboard: Added ${stationMarkers.length} station markers');
      } else {
        print('UserDashboard: Removed station markers');
      }
    });
  }

  void _showStationInfo(Station station) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(station.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Coordinates:'),
            Text('Lat: ${station.latitude.toStringAsFixed(6)}'),
            Text('Lng: ${station.longitude.toStringAsFixed(6)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _openInMaps(station);
            },
            icon: const Icon(Icons.map),
            label: const Text('Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _moveToStation(station);
            },
            child: const Text('Go to Location'),
          ),
        ],
      ),
    );
  }

  void _moveToStation(Station station) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: station.location, zoom: 16),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      print('UserDashboard: Getting current location...');
      LocationService locationService = LocationService();
      _currentPosition = await LocationService.getCurrentLocation();

      if (_currentPosition != null) {
        print(
          'UserDashboard: Location obtained - Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}',
        );

        setState(() {
          _markers.removeWhere(
            (marker) => marker.markerId.value == 'current_location',
          ); // Ensure only one current location marker
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(
                _currentPosition!.latitude ?? 0.0,
                _currentPosition!.longitude ?? 0.0,
              ),
              infoWindow: const InfoWindow(title: 'My Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          );
        });

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _currentPosition!.latitude ?? 0.0,
                _currentPosition!.longitude ?? 0.0,
              ),
              zoom: 14,
            ),
          ),
        );
      }
    } catch (e) {
      print('UserDashboard ERROR: Failed to get location - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _listenForDriverLocation() async {
    if (_supabase == null) {
      print('UserDashboard ERROR: Supabase client is null');
      return;
    }

    try {
      print('UserDashboard: Setting up real-time listener for Driver 1');

      _supabase!
          .from('buses')
          .stream(primaryKey: ['bus_name'])
          .eq('bus_name', 'Driver 1')
          .listen(
            (List<Map<String, dynamic>> data) {
              print(
                'UserDashboard: Received update from Supabase - ${data.length} records',
              );

              if (data.isNotEmpty) {
                final busLocation = data.first;
                print('UserDashboard: Bus data - $busLocation');

                if (busLocation.containsKey('latitude') &&
                    busLocation.containsKey('longitude')) {
                  double latitude = (busLocation['latitude'] as num).toDouble();
                  double longitude = (busLocation['longitude'] as num)
                      .toDouble();

                  print(
                    'UserDashboard: Driver location - Lat: $latitude, Lng: $longitude',
                  );

                  setState(() {
                    _markers.removeWhere(
                      (marker) => marker.markerId.value == 'driver_location',
                    );

                    _markers.add(
                      Marker(
                        markerId: const MarkerId('driver_location'),
                        position: LatLng(latitude, longitude),
                        infoWindow: const InfoWindow(
                          title: 'Driver 1 Location',
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    );
                  });
                }
              }
            },
            onError: (error) {
              print('UserDashboard ERROR: Stream error - $error');
            },
          );
    } catch (e) {
      print('UserDashboard ERROR: Failed to set up listener - $e');
    }
  }

  void _toggleStations() {
    setState(() {
      _showStations = !_showStations;
    });
    _updateStationMarkers();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Dashboard'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading user dashboard...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Dashboard'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _initialize();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Icon(_showStations ? Icons.location_on : Icons.location_off),
            onPressed: _toggleStations,
            tooltip: _showStations ? 'Hide Stations' : 'Show Stations',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getCurrentLocation();
              _loadStations();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            key: const ValueKey('user_map'), // Add a unique key here
            initialCameraPosition: const CameraPosition(
              target: LatLng(23.8103, 90.4125),
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              print('UserDashboard: Map created');
              mapController = controller;

              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude ?? 0.0,
                        _currentPosition!.longitude ?? 0.0,
                      ),
                      zoom: 14,
                    ),
                  ),
                );
              }
            },
          ),
          // Legend/Info Card
          Positioned(
            bottom: 20,
            left: 50,
            right: 60,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Map Legend',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_stations.length} stations',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.blue, 'Your Location'),
                    _buildLegendItem(Colors.red, 'Driver Location'),
                    if (_showStations)
                      _buildLegendItem(Colors.green, 'Bus Stations'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('UserDashboard: Disposing...');
    _stationService.dispose();
    mapController?.dispose(); // Dispose the controller
    mapController = null; // Set to null after disposing
    super.dispose();
  }

  Future<void> _openInMaps(Station station) async {
    // Try Google Maps first (works on both Android and iOS)
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${station.latitude},${station.longitude}',
    );

    // Alternative: Apple Maps URL scheme (for iOS)
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?q=${station.name}&ll=${station.latitude},${station.longitude}',
    );

    // Try to launch Google Maps
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      // Fallback to Apple Maps on iOS
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // Show error if no map app is available
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open map application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
