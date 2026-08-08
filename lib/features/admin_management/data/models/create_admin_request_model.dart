import 'package:dio/dio.dart';

class CreateAdminRequestModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final int roleId;
  final bool isActive;
  final int createdBy;
  final List<int>? avatarBytes;
  final String? avatarFileName;

  CreateAdminRequestModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.roleId = 2,
    this.isActive = true,
    required this.createdBy,
    this.avatarBytes,
    this.avatarFileName,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'role_id': roleId,
      'is_active': isActive ? 1 : 0,
      'created_by': createdBy,
    };

    if (avatarBytes != null && avatarBytes!.isNotEmpty) {
      map['avatar_url'] = MultipartFile.fromBytes(
        avatarBytes!,
        filename: avatarFileName ?? 'avatar.jpg',
      );
    }

    return FormData.fromMap(map);
  }
}
