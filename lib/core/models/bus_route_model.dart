enum BusStatus {
  running,
  stopped,
  maintenance,
  offline,
}

class BusRouteModel {
  final String id;
  final String busNumber;
  final String routeName;
  final String startLocation;
  final String endLocation;
  final List<String> stops;
  final BusStatus status;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? currentStop;
  final int estimatedArrivalMinutes;
  final DateTime lastUpdated;
  final bool isActive;

  const BusRouteModel({
    required this.id,
    required this.busNumber,
    required this.routeName,
    required this.startLocation,
    required this.endLocation,
    required this.stops,
    required this.status,
    this.currentLatitude,
    this.currentLongitude,
    this.currentStop,
    this.estimatedArrivalMinutes = 0,
    required this.lastUpdated,
    this.isActive = true,
  });

  factory BusRouteModel.fromJson(Map<String, dynamic> json) {
    return BusRouteModel(
      id: json['id'] as String,
      busNumber: json['bus_number'] as String,
      routeName: json['route_name'] as String,
      startLocation: json['start_location'] as String,
      endLocation: json['end_location'] as String,
      stops: List<String>.from(json['stops'] as List),
      status: BusStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BusStatus.offline,
      ),
      currentLatitude: json['current_latitude'] as double?,
      currentLongitude: json['current_longitude'] as double?,
      currentStop: json['current_stop'] as String?,
      estimatedArrivalMinutes: json['estimated_arrival_minutes'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus_number': busNumber,
      'route_name': routeName,
      'start_location': startLocation,
      'end_location': endLocation,
      'stops': stops,
      'status': status.name,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'current_stop': currentStop,
      'estimated_arrival_minutes': estimatedArrivalMinutes,
      'last_updated': lastUpdated.toIso8601String(),
      'is_active': isActive,
    };
  }

  BusRouteModel copyWith({
    String? id,
    String? busNumber,
    String? routeName,
    String? startLocation,
    String? endLocation,
    List<String>? stops,
    BusStatus? status,
    double? currentLatitude,
    double? currentLongitude,
    String? currentStop,
    int? estimatedArrivalMinutes,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return BusRouteModel(
      id: id ?? this.id,
      busNumber: busNumber ?? this.busNumber,
      routeName: routeName ?? this.routeName,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      stops: stops ?? this.stops,
      status: status ?? this.status,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      currentStop: currentStop ?? this.currentStop,
      estimatedArrivalMinutes: estimatedArrivalMinutes ?? this.estimatedArrivalMinutes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isRunning => status == BusStatus.running;
  bool get hasLocation => currentLatitude != null && currentLongitude != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusRouteModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BusRouteModel{id: $id, busNumber: $busNumber, status: $status}';
  }
}