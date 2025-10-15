import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../config/app_config.dart';

class TraccarService {
  static const String _baseUrl = 'https://demo.traccar.org'; // Default demo server
  static const int _deviceId = 123456; // Your device ID
  static Timer? _locationTimer;
  static bool _isTracking = false;

  // Headers for Traccar API
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Initialize location tracking
  static Future<void> startTracking() async {
    if (_isTracking) return;

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception('Location permissions are required for tracking');
      }

      _isTracking = true;
      
      // Start periodic location updates (every 30 seconds)
      _locationTimer = Timer.periodic(
        const Duration(seconds: 30),
        (timer) => _sendLocationUpdate(),
      );

      // Send initial location
      await _sendLocationUpdate();
      
      if (AppConfig.debugMode) {
        print('Traccar tracking started');
      }
    } catch (e) {
      _isTracking = false;
      rethrow;
    }
  }

  /// Stop location tracking
  static void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTracking = false;
    
    if (AppConfig.debugMode) {
      print('Traccar tracking stopped');
    }
  }

  /// Send current location to Traccar server
  static Future<void> _sendLocationUpdate() async {
    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Send to Traccar server using GET request (common for simple tracking)
      final uri = Uri.parse('$_baseUrl/api/positions').replace(
        queryParameters: {
          'id': _deviceId.toString(),
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'hdop': position.accuracy.toString(),
          'altitude': position.altitude.toString(),
          'speed': position.speed.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        if (AppConfig.debugMode) {
          print('Location sent to Traccar: ${position.latitude}, ${position.longitude}');
        }
      } else {
        if (AppConfig.debugMode) {
          print('Failed to send location to Traccar: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('Error sending location to Traccar: $e');
      }
    }
  }

  /// Send location using POST request (alternative method)
  static Future<void> sendLocationPost(Position position) async {
    try {
      final locationData = {
        'deviceId': _deviceId,
        'type': 'position',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'altitude': position.altitude,
        'speed': position.speed,
        'course': position.heading,
        'accuracy': position.accuracy,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'attributes': {
          'battery': 100,
          'ignition': true,
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/positions'),
        headers: _headers,
        body: json.encode(locationData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (AppConfig.debugMode) {
          print('Location sent successfully via POST');
        }
      } else {
        if (AppConfig.debugMode) {
          print('Failed to send location: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('Error sending location: $e');
      }
    }
  }

  /// Get device information from Traccar
  static Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/devices/$_deviceId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('Error getting device info: $e');
      }
    }
    return null;
  }

  /// Get latest position from Traccar
  static Future<Map<String, dynamic>?> getLatestPosition() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/positions?deviceId=$_deviceId&from=${DateTime.now().subtract(const Duration(hours: 1)).toUtc().toIso8601String()}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> positions = json.decode(response.body);
        if (positions.isNotEmpty) {
          return positions.last;
        }
      }
    } catch (e) {
      if (AppConfig.debugMode) {
        print('Error getting latest position: $e');
      }
    }
    return null;
  }

  /// Check if tracking is currently active
  static bool get isTracking => _isTracking;

  /// Get tracking status
  static Map<String, dynamic> getTrackingStatus() {
    return {
      'isTracking': _isTracking,
      'deviceId': _deviceId,
      'serverUrl': _baseUrl,
      'updateInterval': 30, // seconds
    };
  }

  /// Configure Traccar server settings
  static void configureServer({
    required String serverUrl,
    required int deviceId,
  }) {
    // Note: In a real app, you would update these values
    // For now, they are constants but could be made configurable
    if (AppConfig.debugMode) {
      print('Traccar configured: $serverUrl, device: $deviceId');
    }
  }

  /// Send a one-time location update
  static Future<void> sendOneTimeLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await sendLocationPost(position);
    } catch (e) {
      if (AppConfig.debugMode) {
        print('Error sending one-time location: $e');
      }
      rethrow;
    }
  }
}