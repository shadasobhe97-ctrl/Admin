class LoginRequestModel {
  final String phoneNumber;
  final String password;
  final String platform;
  final String? deviceName;
  final String? fcmToken;

  LoginRequestModel({
    required this.phoneNumber,
    required this.password,
    this.platform = 'web',
    this.deviceName = 'Web_Admin_Panel',
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'password': password,
      'platform': platform,
      if (deviceName != null) 'device_name': deviceName,
      if (fcmToken != null) 'fcm_token': fcmToken,
    };
  }
}
