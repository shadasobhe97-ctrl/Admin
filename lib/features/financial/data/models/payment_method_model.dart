import '../../../../core/utils/json_parsers.dart';

/// نموذج بيانات طرق الدفع للإدارة المالية.
/// GET|POST|PUT|PATCH|DELETE /api/admin/payment-methods
class PaymentMethodModel {
  final int? id;
  final String nameAr;
  final String code;
  final String targetAudience; // parent | driver | both
  final String processingType; // instant_simulation | manual_proof
  final String? nameEn;
  final String? accountName;
  final String? accountNumber;
  final String? iban;
  final String? walletNumber;
  final double? minAmount;
  final double? maxAmount;
  final String? instructionsAr;
  final String? instructionsEn;
  final bool isActive;
  final int sortOrder;

  const PaymentMethodModel({
    this.id,
    required this.nameAr,
    required this.code,
    required this.targetAudience,
    required this.processingType,
    this.nameEn,
    this.accountName,
    this.accountNumber,
    this.iban,
    this.walletNumber,
    this.minAmount,
    this.maxAmount,
    this.instructionsAr,
    this.instructionsEn,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: JsonParsers.optionalInt(json['id']),
      nameAr: JsonParsers.stringValue(json['name_ar']),
      code: JsonParsers.stringValue(json['code']),
      targetAudience: JsonParsers.stringValue(
        json['target_audience'],
        fallback: 'both',
      ),
      processingType: JsonParsers.stringValue(
        json['processing_type'],
        fallback: 'manual_proof',
      ),
      nameEn: JsonParsers.optionalString(json['name_en']),
      accountName: JsonParsers.optionalString(json['account_name']),
      accountNumber: JsonParsers.optionalString(json['account_number']),
      iban: JsonParsers.optionalString(json['iban']),
      walletNumber: JsonParsers.optionalString(json['wallet_number']),
      minAmount: JsonParsers.optionalDouble(json['min_amount']),
      maxAmount: JsonParsers.optionalDouble(json['max_amount']),
      instructionsAr: JsonParsers.optionalString(json['instructions_ar']),
      instructionsEn: JsonParsers.optionalString(json['instructions_en']),
      isActive: JsonParsers.boolValue(json['is_active'], fallback: true),
      sortOrder: JsonParsers.intValue(json['sort_order'], fallback: 0),
    );
  }

  /// يولد JSON الخاص بعمليات الإنشاء (POST) متضمناً الحقول الموثقة فقط وبدون `id`.
  Map<String, dynamic> toCreateJson() {
    final map = <String, dynamic>{
      'name_ar': nameAr,
      'code': code,
      'target_audience': targetAudience,
      'processing_type': processingType,
      'is_active': isActive,
      'sort_order': sortOrder,
    };

    _addIfPresent(map, 'name_en', nameEn);
    _addIfPresent(map, 'account_name', accountName);
    _addIfPresent(map, 'account_number', accountNumber);
    _addIfPresent(map, 'iban', iban);
    _addIfPresent(map, 'wallet_number', walletNumber);
    if (minAmount != null) map['min_amount'] = minAmount;
    if (maxAmount != null) map['max_amount'] = maxAmount;
    _addIfPresent(map, 'instructions_ar', instructionsAr);
    _addIfPresent(map, 'instructions_en', instructionsEn);

    return map;
  }

  /// يولد JSON الخاص بعمليات التحديث (PUT) متضمناً الحقول المعدلة وبدون `id`.
  Map<String, dynamic> toUpdateJson() => toCreateJson();

  static void _addIfPresent(
    Map<String, dynamic> map,
    String key,
    String? val,
  ) {
    if (val != null && val.trim().isNotEmpty) {
      map[key] = val.trim();
    }
  }

  /// تسمية الجمهور بالعربية للـ UI.
  String get targetAudienceLabel {
    switch (targetAudience.toLowerCase()) {
      case 'parent':
        return 'أولياء الأمور';
      case 'driver':
        return 'السائقون';
      case 'both':
      default:
        return 'الجميع';
    }
  }

  /// تسمية نوع المعالجة بالعربية للـ UI.
  String get processingTypeLabel {
    switch (processingType.toLowerCase()) {
      case 'instant_simulation':
        return 'دفع فوري';
      case 'manual_proof':
      default:
        return 'إثبات يدوي';
    }
  }

  /// تسمية الحالة بالعربية.
  String get statusLabel => isActive ? 'مفعلة' : 'غير مفعلة';

  PaymentMethodModel copyWith({
    int? id,
    String? nameAr,
    String? code,
    String? targetAudience,
    String? processingType,
    String? nameEn,
    String? accountName,
    String? accountNumber,
    String? iban,
    String? walletNumber,
    double? minAmount,
    double? maxAmount,
    String? instructionsAr,
    String? instructionsEn,
    bool? isActive,
    int? sortOrder,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      code: code ?? this.code,
      targetAudience: targetAudience ?? this.targetAudience,
      processingType: processingType ?? this.processingType,
      nameEn: nameEn ?? this.nameEn,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      walletNumber: walletNumber ?? this.walletNumber,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      instructionsAr: instructionsAr ?? this.instructionsAr,
      instructionsEn: instructionsEn ?? this.instructionsEn,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
