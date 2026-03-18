import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a station entity with geographical coordinates and name.
class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  /// Returns the geographical location as a LatLng object.
  LatLng get location => LatLng(latitude, longitude);

  @override
  List<Object?> get props => [id, name, latitude, longitude];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Station &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude );

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ;
}