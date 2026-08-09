class AdminProfileModel {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? roleName;
  final bool? isActive;
  final String? avatarUrl;
  final String? createdAt;

  const AdminProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.roleName,
    this.isActive,
    this.avatarUrl,
    this.createdAt,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminProfileModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      roleName: json['role_name']?.toString() ?? json['role']?.toString(),
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : (json['is_active'] != null ? json['is_active'].toString() == '1' || json['is_active'].toString() == 'true' : null),
      avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      if (roleName != null) 'role_name': roleName,
      if (isActive != null) 'is_active': isActive,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  AdminProfileModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? roleName,
    bool? isActive,
    String? avatarUrl,
    String? createdAt,
  }) {
    return AdminProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      roleName: roleName ?? this.roleName,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
