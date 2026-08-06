class PasswordResetResponseModel {
  final bool status;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  PasswordResetResponseModel({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponseModel(
      status: json['status'] == true || json['status'] == 1,
      message: json['message']?.toString() ?? '',
      data: json['data'],
      errors: json['errors'] is Map<String, dynamic> ? json['errors'] as Map<String, dynamic> : null,
    );
  }
}
