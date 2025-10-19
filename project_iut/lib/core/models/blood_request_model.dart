enum BloodRequestStatus {
  pending,
  active,
  fulfilled,
  cancelled,
  expired,
}

enum BloodRequestPriority {
  normal,
  urgent,
  critical,
}

class BloodRequestModel {
  final String id;
  final String requesterId;
  final String? requesterName;
  final String? requesterPhone;
  final String patientName;
  final String bloodGroup;
  final int unitsRequired;
  final String medicalCondition;
  final String hospitalName;
  final String hospitalAddress;
  final String contactNumber;
  final String? byStander;
  final String? byStanderContact;
  final BloodRequestStatus status;
  final BloodRequestPriority priority;
  final DateTime requiredBy;
  final String? additionalNotes;
  final bool isNgoRequest;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BloodRequestModel({
    required this.id,
    required this.requesterId,
    this.requesterName,
    this.requesterPhone,
    required this.patientName,
    required this.bloodGroup,
    required this.unitsRequired,
    required this.medicalCondition,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.contactNumber,
    this.byStander,
    this.byStanderContact,
    required this.status,
    required this.priority,
    required this.requiredBy,
    this.additionalNotes,
    this.isNgoRequest = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      requesterName: json['requester_name'] as String?,
      requesterPhone: json['requester_phone'] as String?,
      patientName: json['patient_name'] as String,
      bloodGroup: json['blood_group'] as String,
      unitsRequired: (json['units_required'] ?? json['units_needed']) as int,
      medicalCondition: (json['medical_condition'] ?? json['urgency'] ?? 'Not specified') as String,
      hospitalName: json['hospital_name'] as String,
      hospitalAddress: json['hospital_address'] as String,
      contactNumber: (json['contact_number'] ?? json['requester_phone'] ?? '') as String,
      byStander: json['by_stander'] as String?,
      byStanderContact: json['by_stander_contact'] as String?,
      status: BloodRequestStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['status'] as String).toLowerCase(),
        orElse: () => BloodRequestStatus.pending,
      ),
      priority: _mapUrgencyToPriority(json['urgency'] as String? ?? json['priority'] as String?),
      requiredBy: DateTime.parse((json['required_by'] ?? json['needed_by']) as String),
      additionalNotes: json['additional_notes'] as String?,
      isNgoRequest: json['is_ngo_request'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static BloodRequestPriority _mapUrgencyToPriority(String? urgency) {
    if (urgency == null) return BloodRequestPriority.normal;
    switch (urgency.toLowerCase()) {
      case 'critical':
        return BloodRequestPriority.critical;
      case 'high':
      case 'urgent':
        return BloodRequestPriority.urgent;
      case 'medium':
      case 'low':
      case 'normal':
      default:
        return BloodRequestPriority.normal;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'patient_name': patientName,
      'blood_group': bloodGroup,
      'units_required': unitsRequired,
      'medical_condition': medicalCondition,
      'hospital_name': hospitalName,
      'hospital_address': hospitalAddress,
      'contact_number': contactNumber,
      'by_stander': byStander,
      'by_stander_contact': byStanderContact,
      'status': status.name,
      'priority': priority.name,
      'required_by': requiredBy.toIso8601String(),
      'additional_notes': additionalNotes,
      'is_ngo_request': isNgoRequest,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// JSON used for inserting a new blood request into the database.
  /// Omits server-generated fields like `id`, `created_at`, and `updated_at`.
  /// Also omits fields not present in the DB schema (e.g., by_stander).
  Map<String, dynamic> toJsonForInsert() {
    return {
      'requester_id': requesterId,
      'requester_name': requesterName ?? 'Unknown',
      'requester_phone': requesterPhone ?? contactNumber,
      'patient_name': patientName,
      'blood_group': bloodGroup,
      'units_needed': unitsRequired,
      'urgency': _priorityToUrgency(priority),
      'hospital_name': hospitalName,
      'hospital_address': hospitalAddress,
      'needed_by': requiredBy.toIso8601String(),
      'additional_notes': additionalNotes,
      'status': _statusToDbFormat(status),
    }..removeWhere((key, value) => value == null);
  }

  static String _statusToDbFormat(BloodRequestStatus status) {
    // Database expects capitalized status values: 'Active', 'Fulfilled', 'Cancelled', 'Expired'
    switch (status) {
      case BloodRequestStatus.active:
        return 'Active';
      case BloodRequestStatus.fulfilled:
        return 'Fulfilled';
      case BloodRequestStatus.cancelled:
        return 'Cancelled';
      case BloodRequestStatus.expired:
        return 'Expired';
      case BloodRequestStatus.pending:
        return 'Active'; // Map pending to Active for database
    }
  }

  static String _priorityToUrgency(BloodRequestPriority priority) {
    switch (priority) {
      case BloodRequestPriority.critical:
        return 'Critical';
      case BloodRequestPriority.urgent:
        return 'High';
      case BloodRequestPriority.normal:
        return 'Medium';
    }
  }

  BloodRequestModel copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? requesterPhone,
    String? patientName,
    String? bloodGroup,
    int? unitsRequired,
    String? medicalCondition,
    String? hospitalName,
    String? hospitalAddress,
    String? contactNumber,
    String? byStander,
    String? byStanderContact,
    BloodRequestStatus? status,
    BloodRequestPriority? priority,
    DateTime? requiredBy,
    String? additionalNotes,
    bool? isNgoRequest,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BloodRequestModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      patientName: patientName ?? this.patientName,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      unitsRequired: unitsRequired ?? this.unitsRequired,
      medicalCondition: medicalCondition ?? this.medicalCondition,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalAddress: hospitalAddress ?? this.hospitalAddress,
      contactNumber: contactNumber ?? this.contactNumber,
      byStander: byStander ?? this.byStander,
      byStanderContact: byStanderContact ?? this.byStanderContact,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      requiredBy: requiredBy ?? this.requiredBy,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      isNgoRequest: isNgoRequest ?? this.isNgoRequest,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isUrgent => priority == BloodRequestPriority.urgent || priority == BloodRequestPriority.critical;
  bool get isActive => status == BloodRequestStatus.active;
  bool get isExpired => DateTime.now().isAfter(requiredBy);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodRequestModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BloodRequestModel{id: $id, patientName: $patientName, bloodGroup: $bloodGroup, status: $status}';
  }
}