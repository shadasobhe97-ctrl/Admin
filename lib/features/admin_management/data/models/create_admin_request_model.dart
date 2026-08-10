import 'package:dio/dio.dart';

class CreateAdminRequestModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? password;
  final List<int>? avatarBytes;
  final String? avatarFileName;

  CreateAdminRequestModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.password,
    this.avatarBytes,
    this.avatarFileName,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
    };

    if (password != null && password!.isNotEmpty) {
      map['password'] = password;
    }

    if (avatarBytes != null && avatarBytes!.isNotEmpty) {
      map['avatar'] = MultipartFile.fromBytes(
        avatarBytes!,
        filename: avatarFileName ?? 'avatar.jpg',
      );
    }

    return FormData.fromMap(map);
  }
}
