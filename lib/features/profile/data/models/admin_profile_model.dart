class AdminProfileModel {
  final int id;
  final int? userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final bool? isActive;
  final int? roleId;
  final String? roleName;
  final int? createdBy;
  final String? creatorName;
  final String? createdAt;
  final String? lastLoginAt;
  final bool? emailChangePending;
  final String? pendingNewEmail;

  const AdminProfileModel({
    required this.id,
    this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    this.isActive,
    this.roleId,
    this.roleName,
    this.createdBy,
    this.creatorName,
    this.createdAt,
    this.lastLoginAt,
    this.emailChangePending,
    this.pendingNewEmail,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    int? parseNullableId(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    bool? parseBool(dynamic val) {
      if (val == null) return null;
      if (val is bool) return val;
      final str = val.toString().toLowerCase();
      return str == '1' || str == 'true';
    }

    return AdminProfileModel(
      id: parseId(json['id']),
      userId: parseNullableId(json['user_id']),
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString(),
      isActive: parseBool(json['is_active']),
      roleId: parseNullableId(json['role_id']),
      roleName: json['role_name']?.toString() ?? json['role']?.toString(),
      createdBy: parseNullableId(json['created_by']),
      creatorName: json['creator_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      lastLoginAt: json['last_login_at']?.toString(),
      emailChangePending: parseBool(json['email_change_pending']),
      pendingNewEmail: json['pending_new_email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (isActive != null) 'is_active': isActive,
      if (roleId != null) 'role_id': roleId,
      if (roleName != null) 'role_name': roleName,
      if (createdBy != null) 'created_by': createdBy,
      if (creatorName != null) 'creator_name': creatorName,
      if (createdAt != null) 'created_at': createdAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (emailChangePending != null) 'email_change_pending': emailChangePending,
      if (pendingNewEmail != null) 'pending_new_email': pendingNewEmail,
    };
  }

  AdminProfileModel copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    bool? isActive,
    int? roleId,
    String? roleName,
    int? createdBy,
    String? creatorName,
    String? createdAt,
    String? lastLoginAt,
    bool? emailChangePending,
    String? pendingNewEmail,
  }) {
    return AdminProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      emailChangePending: emailChangePending ?? this.emailChangePending,
      pendingNewEmail: pendingNewEmail ?? this.pendingNewEmail,
    );
  }
}
