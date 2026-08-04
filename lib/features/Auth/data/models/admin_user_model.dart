class AdminUserModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String email;
  final int roleId;
  final String roleName;
  final bool isActive;
  final String accessToken;
  final String tokenType;

  AdminUserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email = '',
    required this.roleId,
    this.roleName = 'مدير النظام',
    required this.isActive,
    required this.accessToken,
    this.tokenType = 'Bearer',
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] is Map<String, dynamic> ? json['user'] : {};
    
    int parsedId = 0;
    if (userData['id'] != null) {
      parsedId = userData['id'] is int ? userData['id'] : (int.tryParse(userData['id'].toString()) ?? 0);
    } else if (json['id'] != null) {
      parsedId = json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0);
    }

    int parsedRoleId = 1;
    if (userData['role_id'] != null) {
      parsedRoleId = userData['role_id'] is int ? userData['role_id'] : (int.tryParse(userData['role_id'].toString()) ?? 1);
    }

    return AdminUserModel(
      id: parsedId,
      fullName: userData['full_name'] ?? json['full_name'] ?? userData['name'] ?? 'الآدمن الرئيسي',
      phoneNumber: userData['phone_number'] ?? json['phone_number'] ?? '',
      email: userData['email'] ?? json['email'] ?? '',
      roleId: parsedRoleId,
      roleName: json['role_name'] ?? userData['role_name'] ?? 'مدير النظام',
      isActive: userData['is_active'] == true || userData['is_active'] == 1 || userData['is_active'] == null,
      accessToken: json['access_token'] ?? json['token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'role_id': roleId,
      'role_name': roleName,
      'is_active': isActive,
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }
}
