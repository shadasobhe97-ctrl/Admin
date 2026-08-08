import 'admin_model.dart';

class AdminDetailsModel {
  final AdminModel admin;
  final int? createdBy;
  final String? createdByName;
  final String? lastLoginAt;
  final Map<String, dynamic>? extraData;

  AdminDetailsModel({
    required this.admin,
    this.createdBy,
    this.createdByName,
    this.lastLoginAt,
    this.extraData,
  });

  factory AdminDetailsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> adminJson = json;
    if (json['admin'] is Map<String, dynamic>) {
      adminJson = json['admin'];
    } else if (json['data'] is Map<String, dynamic>) {
      adminJson = json['data'];
    }

    return AdminDetailsModel(
      admin: AdminModel.fromJson(adminJson),
      createdBy: json['created_by'] is int ? json['created_by'] : int.tryParse(json['created_by']?.toString() ?? ''),
      createdByName: json['created_by_name']?.toString(),
      lastLoginAt: json['last_login_at']?.toString(),
      extraData: json,
    );
  }
}
