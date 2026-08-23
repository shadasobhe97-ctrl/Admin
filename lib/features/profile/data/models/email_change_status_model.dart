class EmailChangeStatusModel {
  final bool pending;
  final String? newEmail;
  final int? expiresInMinutes;

  const EmailChangeStatusModel({
    required this.pending,
    this.newEmail,
    this.expiresInMinutes,
  });

  factory EmailChangeStatusModel.fromJson(Map<String, dynamic> json) {
    return EmailChangeStatusModel(
      pending: json['pending'] is bool
          ? json['pending'] as bool
          : json['pending']?.toString() == 'true' || json['pending']?.toString() == '1',
      newEmail: json['new_email']?.toString(),
      expiresInMinutes: json['expires_in_minutes'] is int
          ? json['expires_in_minutes'] as int
          : int.tryParse(json['expires_in_minutes']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending,
      if (newEmail != null) 'new_email': newEmail,
      if (expiresInMinutes != null) 'expires_in_minutes': expiresInMinutes,
    };
  }
}

class EmailVerificationInfo {
  final int? expiresInMinutes;

  const EmailVerificationInfo({this.expiresInMinutes});

  factory EmailVerificationInfo.fromJson(Map<String, dynamic> json) {
    return EmailVerificationInfo(
      expiresInMinutes: json['expires_in_minutes'] is int
          ? json['expires_in_minutes'] as int
          : int.tryParse(json['expires_in_minutes']?.toString() ?? ''),
    );
  }
}
