class AdminModel {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final int roleId;
  final String roleName;
  final bool isActive;
  final String? avatarUrl;
  final String? createdAt;
  final bool emailChangePending;
  final String? pendingNewEmail;

  AdminModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.roleId = 2,
    this.roleName = 'مشرف',
    required this.isActive,
    this.avatarUrl,
    this.createdAt,
    this.emailChangePending = false,
    this.pendingNewEmail,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] != null) {
      parsedId = json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0);
    }

    int parsedRoleId = 2;
    if (json['role_id'] != null) {
      parsedRoleId = json['role_id'] is int ? json['role_id'] : (int.tryParse(json['role_id'].toString()) ?? 2);
    }

    bool parsedActive = true;
    if (json['is_active'] != null) {
      parsedActive = json['is_active'] == true || json['is_active'] == 1 || json['is_active'].toString() == 'true';
    }

    bool parsedEmailChangePending = false;
    if (json['email_change_pending'] != null) {
      parsedEmailChangePending = json['email_change_pending'] == true ||
          json['email_change_pending'] == 1 ||
          json['email_change_pending'].toString() == 'true';
    }

    return AdminModel(
      id: parsedId,
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      roleId: parsedRoleId,
      roleName: json['role_name']?.toString() ?? (parsedRoleId == 1 ? 'أدمن' : 'مشرف'),
      isActive: parsedActive,
      avatarUrl: json['avatar_url']?.toString() ??
          json['avatar']?.toString() ??
          json['profile_photo_url']?.toString() ??
          json['photo_url']?.toString(),
      createdAt: json['created_at']?.toString(),
      emailChangePending: parsedEmailChangePending,
      pendingNewEmail: json['pending_new_email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role_id': roleId,
      'role_name': roleName,
      'is_active': isActive,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
      'email_change_pending': emailChangePending,
      'pending_new_email': pendingNewEmail,
    };
  }
}
