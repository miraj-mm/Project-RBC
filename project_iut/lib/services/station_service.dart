import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/exceptions.dart';
import '../core/models/station.dart';
import '../core/utils/haversine_utils.dart';
import '../core/datasources/station_remote_datasource.dart';
import '../core/repositories/station_repository.dart';
import '../core/repositories/station_repository_impl.dart';

/// A service class to manage station-related operations and interact with the UI.
class StationService {
  late final StationRepository _stationRepository;
  bool _isInitialized = false;

  StationService() {
    // Constructor initializes with a default repository setup.
    // In a real app, you might use a dependency injection system here.
    _stationRepository = StationRepositoryImpl(
      remoteDataSource: StationRemoteDataSourceImpl(
        supabaseClient: Supabase.instance.client,
      ),
    );
  }

  /// Initializes the service. This is mainly to set the _isInitialized flag
  /// and ensure Supabase client is available to the underlying data source.
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        // A small delay to ensure Supabase client is ready in the main app
        await Future.delayed(const Duration(milliseconds: 100));
        _isInitialized = true;
        print('StationService: Initialized successfully.');
      }
    } catch (e) {
      print('StationService ERROR: Initialization failed - $e');
      throw ServiceNotInitializedException('StationService');
    }
  }

  /// Fetches all stations from the repository.
  Future<List<Station>> fetchStations() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      print('StationService: Fetching stations...');
      final stations = await _stationRepository.getStations();
      print('StationService: Fetched ${stations.length} stations.');
      return stations;
    } on DataFetchException catch (e) {
      print('StationService ERROR: Failed to fetch stations - $e');
      throw Exception('Failed to load stations: ${e.message}');
    } catch (e) {
      print('StationService ERROR: Unexpected error fetching stations - $e');
      throw Exception('An unexpected error occurred while loading stations.');
    }
  }

  /// Fetches stations near a specific location within a given radius.
  Future<List<Station>> fetchNearbyStations(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    List<Station> allStations = await fetchStations();

    List<Station> nearbyStations = allStations.where((station) {
      double distance = HaversineCalculator.calculateDistance(
        latitude,
        longitude,
        station.latitude,
        station.longitude,
      );
      return distance <= radiusKm;
    }).toList();

    print(
        'StationService: Found ${nearbyStations.length} stations within ${radiusKm}km');
    return nearbyStations;
  }

  /// Streams real-time updates for stations.
  Stream<List<Station>> streamStations() {
    if (!_isInitialized) {
      throw ServiceNotInitializedException('StationService');
    }
    print('StationService: Subscribing to station stream...');
    return _stationRepository.streamStations();
  }

  /// Creates a set of Google Maps Markers for the given list of stations.
  Set<Marker> createStationMarkers(List<Station> stations, {
    BitmapDescriptor? customIcon,
    Function(Station)? onTap,
  }) {
    return stations.map((station) {
      return Marker(
        markerId: MarkerId('station_${station.id}'),
        position: station.location,
        infoWindow: InfoWindow(
          title: station.name,
        ),
        icon: customIcon ?? BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen
        ),
        onTap: onTap != null ? () => onTap(station) : null,
      );
    }).toSet();
  }

  /// Disposes of any resources held by the service.
  void dispose() {
    _isInitialized = false;
    print('StationService: Disposed.');
  }
}