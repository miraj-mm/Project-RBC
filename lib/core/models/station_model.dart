import '../../core/models/station.dart';

/// A data model for `Station` entity, responsible for JSON serialization/deserialization.
class StationModel extends Station {
  StationModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    String? description,
    String? type,
  });

  /// Converts a JSON map into a `StationModel` instance.
  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Station',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
      type: json['type'] as String?,
    );
  }

  /// Converts a `StationModel` instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Creates a `StationModel` from a `Station` entity.
  factory StationModel.fromEntity(Station entity) {
    return StationModel(
      id: entity.id,
      name: entity.name,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  /// Converts a `StationModel` back to a `Station` entity.
  Station toEntity() {
    return Station(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
    );
  }
}