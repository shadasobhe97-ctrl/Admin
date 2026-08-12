class DriverModel {
  final int id;
  final int? userId;
  final String fullName;
  final String phoneNumber;
  final String status;
  final String? approvalStatus;
  final String? nationalId;
  final String? licenseNumber;
  final String? avatarUrl;
  final String? createdAt;
  final bool isActive;

  DriverModel({
    required this.id,
    this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.status,
    this.approvalStatus,
    this.nationalId,
    this.licenseNumber,
    this.avatarUrl,
    this.createdAt,
    this.isActive = true,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] != null) {
      parsedId = json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0);
    }

    int? parsedUserId;
    if (json['user_id'] != null) {
      parsedUserId = json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString());
    }

    bool parsedActive = true;
    if (json['is_active'] != null) {
      parsedActive = json['is_active'] == true || json['is_active'] == 1 || json['is_active'].toString() == 'true';
    }

    return DriverModel(
      id: parsedId,
      userId: parsedUserId,
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? 'سائق بدون اسم',
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      approvalStatus: json['approval_status']?.toString() ?? json['status']?.toString(),
      nationalId: json['national_id']?.toString(),
      licenseNumber: json['license_number']?.toString(),
      avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString(),
      createdAt: json['created_at']?.toString(),
      isActive: parsedActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'status': status,
      'approval_status': approvalStatus,
      'national_id': nationalId,
      'license_number': licenseNumber,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
      'is_active': isActive,
    };
  }
}
