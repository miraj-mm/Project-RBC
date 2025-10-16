import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../config/app_config.dart';

class LocationService {
  static const String _placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _geocodingBaseUrl = 'https://maps.googleapis.com/maps/api/geocode';

  /// Search for places using Google Places API
  static Future<List<PlacePrediction>> searchPlaces(String query) async {
    if (query.isEmpty || AppConfig.googleMapsApiKey.isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse('$_placesBaseUrl/autocomplete/json')
          .replace(queryParameters: {
        'input': query,
        'key': AppConfig.googleMapsApiKey,
        'types': 'geocode',
        'components': 'country:bd', // Restrict to Bangladesh
      });

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((e) => PlacePrediction.fromJson(e))
              .toList();
          return predictions;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching places: $e');
      }
    }

    return [];
  }

  /// Get place details by place ID
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty || AppConfig.googleMapsApiKey.isEmpty) {
      return null;
    }

    try {
      final url = Uri.parse('$_placesBaseUrl/details/json')
          .replace(queryParameters: {
        'place_id': placeId,
        'key': AppConfig.googleMapsApiKey,
        'fields': 'formatted_address,geometry,name',
      });

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting place details: $e');
      }
    }

    return null;
  }

  /// Validate address using Google Geocoding API
  static Future<LocationValidationResult> validateAddress(String address) async {
    if (address.isEmpty) {
      return LocationValidationResult(
        isValid: false,
        error: 'Address cannot be empty',
      );
    }

    try {
      // First try with geocoding package
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        
        // Get formatted address from Google Geocoding API
        final formattedAddress = await _getFormattedAddress(
          location.latitude, 
          location.longitude,
        );
        
        return LocationValidationResult(
          isValid: true,
          latitude: location.latitude,
          longitude: location.longitude,
          formattedAddress: formattedAddress ?? address,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error validating address: $e');
      }
    }

    return LocationValidationResult(
      isValid: false,
      error: 'Could not validate the address. Please check and try again.',
    );
  }

  /// Get current location
  static Future<LocationResult> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          error: 'Location services are disabled. Please enable location services.',
        );
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            success: false,
            error: 'Location permissions are denied. Please grant location permission.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          success: false,
          error: 'Location permissions are permanently denied. Please enable them in settings.',
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get formatted address
      final formattedAddress = await _getFormattedAddress(
        position.latitude,
        position.longitude,
      );

      return LocationResult(
        success: true,
        latitude: position.latitude,
        longitude: position.longitude,
        address: formattedAddress ?? 'Unknown location',
      );
    } catch (e) {
      return LocationResult(
        success: false,
        error: 'Failed to get current location: ${e.toString()}',
      );
    }
  }

  /// Get formatted address from coordinates
  static Future<String?> _getFormattedAddress(double lat, double lng) async {
    if (AppConfig.googleMapsApiKey.isEmpty) {
      // Fallback to geocoding package
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          return '${place.street}, ${place.locality}, ${place.country}';
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error getting address from coordinates: $e');
        }
      }
      return null;
    }

    try {
      final url = Uri.parse('$_geocodingBaseUrl/json')
          .replace(queryParameters: {
        'latlng': '$lat,$lng',
        'key': AppConfig.googleMapsApiKey,
      });

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'] as String;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting formatted address: $e');
      }
    }

    return null;
  }

  /// Generate Google Maps link
  static String generateGoogleMapsLink(double lat, double lng, {String? label}) {
    final encodedLabel = label != null ? Uri.encodeComponent(label) : '';
    return 'https://www.google.com/maps?q=$lat,$lng${encodedLabel.isNotEmpty ? '($encodedLabel)' : ''}';
  }

  /// Generate shareable location link with address
  static String generateShareableLink(double lat, double lng, String address) {
    final encodedAddress = Uri.encodeComponent(address);
    return 'https://maps.google.com/?q=$lat,$lng($encodedAddress)';
  }
}

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    this.mainText = '',
    this.secondaryText = '',
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String name;

  PlaceDetails({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};
    
    return PlaceDetails(
      formattedAddress: json['formatted_address'] ?? '',
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
      name: json['name'] ?? '',
    );
  }
}

class LocationValidationResult {
  final bool isValid;
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;
  final String? error;

  LocationValidationResult({
    required this.isValid,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.error,
  });
}

class LocationResult {
  final bool success;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? error;

  LocationResult({
    required this.success,
    this.latitude,
    this.longitude,
    this.address,
    this.error,
  });
}