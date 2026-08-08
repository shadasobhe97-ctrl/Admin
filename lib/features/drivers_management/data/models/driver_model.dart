class DriverModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String status;
  final String? avatarUrl;
  final String? createdAt;
  final bool isActive;

  DriverModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.status,
    this.avatarUrl,
    this.createdAt,
    this.isActive = true,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] != null) {
      parsedId = json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0);
    }

    bool parsedActive = true;
    if (json['is_active'] != null) {
      parsedActive = json['is_active'] == true || json['is_active'] == 1 || json['is_active'].toString() == 'true';
    }

    return DriverModel(
      id: parsedId,
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? 'سائق بدون اسم',
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString(),
      createdAt: json['created_at']?.toString(),
      isActive: parsedActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'status': status,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
      'is_active': isActive,
    };
  }
}
