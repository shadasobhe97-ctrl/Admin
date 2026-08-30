import '../../../../core/utils/json_parsers.dart';

/// تفاصيل الحساب المصرفي في طلب السحب.
/// Object: { bank_name, account_number, account_name, mobile_number }
class WithdrawalPaymentMethodDetails {
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? mobileNumber;

  const WithdrawalPaymentMethodDetails({
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.mobileNumber,
  });

  factory WithdrawalPaymentMethodDetails.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return WithdrawalPaymentMethodDetails(
        bankName: JsonParsers.optionalString(json['bank_name']),
        accountNumber: JsonParsers.optionalString(json['account_number']),
        accountName: JsonParsers.optionalString(json['account_name']),
        mobileNumber: JsonParsers.optionalString(json['mobile_number']),
      );
    } else if (json is Map) {
      final map = json.map((k, v) => MapEntry(k.toString(), v));
      return WithdrawalPaymentMethodDetails(
        bankName: JsonParsers.optionalString(map['bank_name']),
        accountNumber: JsonParsers.optionalString(map['account_number']),
        accountName: JsonParsers.optionalString(map['account_name']),
        mobileNumber: JsonParsers.optionalString(map['mobile_number']),
      );
    }
    return const WithdrawalPaymentMethodDetails();
  }

  /// تنسيق تفاصيل الحساب للعرض.
  String get formattedDetails {
    final parts = <String>[];
    if (bankName != null && bankName!.isNotEmpty) parts.add('المصرف: $bankName');
    if (accountNumber != null && accountNumber!.isNotEmpty) parts.add('رقم الحساب: $accountNumber');
    if (accountName != null && accountName!.isNotEmpty) parts.add('اسم الحساب: $accountName');
    if (mobileNumber != null && mobileNumber!.isNotEmpty) parts.add('رقم الهاتف: $mobileNumber');
    return parts.isEmpty ? 'غير متوفرة' : parts.join('  •  ');
  }

  bool get isEmpty =>
      (bankName == null || bankName!.isEmpty) &&
      (accountNumber == null || accountNumber!.isEmpty) &&
      (accountName == null || accountName!.isEmpty) &&
      (mobileNumber == null || mobileNumber!.isEmpty);
}

/// GET /api/admin/financial/withdrawals
/// GET /api/admin/financial/withdrawals/{id}
class WithdrawalModel {
  final int id;
  final int? driverId;
  final String driverName;
  final String? driverPhone;
  final double amount;
  final double? walletBalanceAtRequest;
  final String status;
  final WithdrawalPaymentMethodDetails? paymentMethodDetails;
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
    this.walletBalanceAtRequest,
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
      driverName: _extractDriverName(json),
      driverPhone: JsonParsers.optionalString(json['driver_phone']),
      amount: JsonParsers.doubleValue(json['amount']),
      walletBalanceAtRequest:
          JsonParsers.optionalDouble(json['wallet_balance_at_request']),
      status: JsonParsers.stringValue(json['status']),
      paymentMethodDetails: json['payment_method_details'] != null
          ? WithdrawalPaymentMethodDetails.fromJson(json['payment_method_details'])
          : null,
      rejectionReason: JsonParsers.optionalString(json['rejection_reason']),
      createdAt: JsonParsers.optionalDate(json['created_at']),
      processedAt: JsonParsers.optionalDate(json['processed_at']),
      adminName: JsonParsers.optionalString(json['admin_name']),
    );
  }

  static String _extractDriverName(Map<String, dynamic> json) {
    if (json['driver'] is Map) {
      final driverMap = json['driver'] as Map;
      if (driverMap['user'] is Map) {
        final userMap = driverMap['user'] as Map;
        final name = JsonParsers.optionalString(userMap['full_name']);
        if (name != null && name.isNotEmpty) return name;
      }
      final driverName = JsonParsers.optionalString(driverMap['full_name']);
      if (driverName != null && driverName.isNotEmpty) return driverName;
    }
    return JsonParsers.stringValue(json['driver_name'], fallback: 'غير معروف');
  }

  /// الطلب قابل للمعالجة فقط طالما لم يُعالَج من قبل.
  bool get isPending => status.toLowerCase() == 'pending';

  WithdrawalModel copyWith({
    int? id,
    int? driverId,
    String? driverName,
    String? driverPhone,
    double? amount,
    double? walletBalanceAtRequest,
    String? status,
    WithdrawalPaymentMethodDetails? paymentMethodDetails,
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
      walletBalanceAtRequest:
          walletBalanceAtRequest ?? this.walletBalanceAtRequest,
      status: status ?? this.status,
      paymentMethodDetails: paymentMethodDetails ?? this.paymentMethodDetails,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      adminName: adminName ?? this.adminName,
    );
  }
}

