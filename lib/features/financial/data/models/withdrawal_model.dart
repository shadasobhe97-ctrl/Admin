import '../../../../core/utils/json_parsers.dart';

/// GET /api/admin/financial/withdrawals
/// GET /api/admin/financial/withdrawals/{id}
class WithdrawalModel {
  final int id;
  final int? driverId;
  final String driverName;
  final String? driverPhone;
  final double amount;
  final double? walletBalanceAtReq;
  final String status;
  final String? paymentMethodDetails;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? processedAt;
  final String? adminName;

  const WithdrawalModel({
    required this.id,
    this.driverId,
    required this.driverName,
    this.driverPhone,
    required this.amount,
    this.walletBalanceAtReq,
    required this.status,
    this.paymentMethodDetails,
    this.rejectionReason,
    this.createdAt,
    this.processedAt,
    this.adminName,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: JsonParsers.intValue(json['id']),
      driverId: JsonParsers.optionalInt(json['driver_id']),
      driverName: JsonParsers.stringValue(json['driver_name']),
      driverPhone: JsonParsers.optionalString(json['driver_phone']),
      amount: JsonParsers.doubleValue(json['amount']),
      walletBalanceAtReq:
          JsonParsers.optionalDouble(json['wallet_balance_at_req']),
      status: JsonParsers.stringValue(json['status']),
      paymentMethodDetails:
          JsonParsers.optionalString(json['payment_method_details']),
      rejectionReason: JsonParsers.optionalString(json['rejection_reason']),
      createdAt: JsonParsers.optionalDate(json['created_at']),
      processedAt: JsonParsers.optionalDate(json['processed_at']),
      adminName: JsonParsers.optionalString(json['admin_name']),
    );
  }

  /// الطلب قابل للمعالجة فقط طالما لم يُعالَج من قبل.
  bool get isPending => status.toLowerCase() == 'pending';

  WithdrawalModel copyWith({
    int? id,
    int? driverId,
    String? driverName,
    String? driverPhone,
    double? amount,
    double? walletBalanceAtReq,
    String? status,
    String? paymentMethodDetails,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? processedAt,
    String? adminName,
  }) {
    return WithdrawalModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      amount: amount ?? this.amount,
      walletBalanceAtReq: walletBalanceAtReq ?? this.walletBalanceAtReq,
      status: status ?? this.status,
      paymentMethodDetails: paymentMethodDetails ?? this.paymentMethodDetails,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      adminName: adminName ?? this.adminName,
    );
  }
}
