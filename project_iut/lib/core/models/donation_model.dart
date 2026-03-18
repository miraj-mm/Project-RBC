enum DonationStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
}

enum DonationType {
  blood,
  dress,
  food,
  medicine,
}

class DonationModel {
  final String id;
  final String donorId;
  final String? requestId;
  final DonationType type;
  final DonationStatus status;
  final String? bloodGroup;
  final int? unitsRequired;
  final String? itemDescription;
  final String location;
  final String contactPerson;
  final String contactNumber;
  final DateTime scheduledDateTime;
  final DateTime? actualDateTime;
  final String? notes;
  final bool isVerified;
  final String? certificateUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DonationModel({
    required this.id,
    required this.donorId,
    this.requestId,
    required this.type,
    required this.status,
    this.bloodGroup,
    this.unitsRequired,
    this.itemDescription,
    required this.location,
    required this.contactPerson,
    required this.contactNumber,
    required this.scheduledDateTime,
    this.actualDateTime,
    this.notes,
    this.isVerified = false,
    this.certificateUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] as String,
      donorId: json['donor_id'] as String,
      requestId: json['request_id'] as String?,
      type: DonationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DonationType.blood,
      ),
      status: DonationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DonationStatus.scheduled,
      ),
      bloodGroup: json['blood_group'] as String?,
      unitsRequired: json['units_required'] as int?,
      itemDescription: json['item_description'] as String?,
      location: json['location'] as String,
      contactPerson: json['contact_person'] as String,
      contactNumber: json['contact_number'] as String,
      scheduledDateTime: DateTime.parse(json['scheduled_date_time'] as String),
      actualDateTime: json['actual_date_time'] != null
          ? DateTime.parse(json['actual_date_time'] as String)
          : null,
      notes: json['notes'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      certificateUrl: json['certificate_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'request_id': requestId,
      'type': type.name,
      'status': status.name,
      'blood_group': bloodGroup,
      'units_required': unitsRequired,
      'item_description': itemDescription,
      'location': location,
      'contact_person': contactPerson,
      'contact_number': contactNumber,
      'scheduled_date_time': scheduledDateTime.toIso8601String(),
      'actual_date_time': actualDateTime?.toIso8601String(),
      'notes': notes,
      'is_verified': isVerified,
      'certificate_url': certificateUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DonationModel copyWith({
    String? id,
    String? donorId,
    String? requestId,
    DonationType? type,
    DonationStatus? status,
    String? bloodGroup,
    int? unitsRequired,
    String? itemDescription,
    String? location,
    String? contactPerson,
    String? contactNumber,
    DateTime? scheduledDateTime,
    DateTime? actualDateTime,
    String? notes,
    bool? isVerified,
    String? certificateUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DonationModel(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      requestId: requestId ?? this.requestId,
      type: type ?? this.type,
      status: status ?? this.status,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      unitsRequired: unitsRequired ?? this.unitsRequired,
      itemDescription: itemDescription ?? this.itemDescription,
      location: location ?? this.location,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      actualDateTime: actualDateTime ?? this.actualDateTime,
      notes: notes ?? this.notes,
      isVerified: isVerified ?? this.isVerified,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isBloodDonation => type == DonationType.blood;
  bool get isOngoing => status == DonationStatus.ongoing;
  bool get isCompleted => status == DonationStatus.completed;
  bool get isScheduledForToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduled = DateTime(
      scheduledDateTime.year,
      scheduledDateTime.month,
      scheduledDateTime.day,
    );
    return today == scheduled;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DonationModel{id: $id, type: $type, status: $status}';
  }
}