class AdminUserModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final int roleId;
  final bool isActive;
  final String accessToken;

  AdminUserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.roleId,
    required this.isActive,
    required this.accessToken,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? {};
    return AdminUserModel(
      id: userData['id'] ?? 0,
      fullName: userData['full_name'] ?? '',
      phoneNumber: userData['phone_number'] ?? '',
      roleId: userData['role_id'] ?? 0,
      isActive: userData['is_active'] ?? true,
      accessToken: json['access_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role_id': roleId,
      'is_active': isActive,
      'access_token': accessToken,
    };
  }
}
