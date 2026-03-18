class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? gender;
  final int? age;
  final String? bloodGroup;
  final DateTime? lastDonationDate;
  final String? profilePictureUrl;
  final int livesSaved;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.age,
    this.bloodGroup,
    this.lastDonationDate,
    this.profilePictureUrl,
    this.livesSaved = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      bloodGroup: json['blood_group'] as String?,
      lastDonationDate: json['last_donation_date'] != null
          ? DateTime.parse(json['last_donation_date'] as String)
          : null,
      profilePictureUrl: json['profile_picture_url'] as String?,
      livesSaved: json['lives_saved'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (lastDonationDate != null) 'last_donation_date': lastDonationDate!.toIso8601String(),
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
      'lives_saved': livesSaved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // Note: is_active field removed from schema
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    int? age,
    String? bloodGroup,
    DateTime? lastDonationDate,
    String? profilePictureUrl,
    int? livesSaved,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      livesSaved: livesSaved ?? this.livesSaved,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, bloodGroup: $bloodGroup}';
  }
}