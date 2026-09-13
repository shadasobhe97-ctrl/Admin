import 'package:dio/dio.dart';

import '../../../../core/utils/json_parsers.dart';

/// نموذج بيانات طرق الدفع للإدارة المالية.
///
/// يعكس عقد Backend الفعلي فقط:
///   GET    /api/admin/payment-methods
///   GET    /api/admin/payment-methods/{id}
///   POST   /api/admin/payment-methods
///   PUT    /api/admin/payment-methods/{id}
///   PATCH  /api/admin/payment-methods/{id}/toggle-status
///   DELETE /api/admin/payment-methods/{id}
///
/// حقول الـ Response: id, name_ar, code, icon_url, min_amount, max_amount,
/// is_active, sort_order, created_at, updated_at.
///
/// حقول Add/Edit: name_ar, code, min_amount, max_amount, sort_order, icon.
/// `is_active` يُعدَّل فقط عبر endpoint `toggle-status`.
class PaymentMethodModel {
  final int? id;
  final String nameAr;
  final String code;
  final String? iconUrl;
  final double? minAmount;
  final double? maxAmount;
  final bool isActive;
  final int sortOrder;
  final String? createdAt;
  final String? updatedAt;

  /// بايتات صورة الأيقونة الجديدة إذا اختار المستخدم صورة (Add أو Edit).
  /// لا تُرسَل في `PUT` إن كانت `null` — أي "لم يغيّر المستخدم الأيقونة".
  final List<int>? iconBytes;
  final String? iconFileName;

  const PaymentMethodModel({
    this.id,
    required this.nameAr,
    required this.code,
    this.iconUrl,
    this.minAmount,
    this.maxAmount,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
    this.iconBytes,
    this.iconFileName,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: JsonParsers.optionalInt(json['id']),
      nameAr: JsonParsers.stringValue(json['name_ar']),
      code: JsonParsers.stringValue(json['code']),
      iconUrl: JsonParsers.optionalString(json['icon_url']),
      minAmount: JsonParsers.optionalDouble(json['min_amount']),
      maxAmount: JsonParsers.optionalDouble(json['max_amount']),
      isActive: JsonParsers.boolValue(json['is_active'], fallback: true),
      sortOrder: JsonParsers.intValue(json['sort_order'], fallback: 0),
      createdAt: JsonParsers.optionalString(json['created_at']),
      updatedAt: JsonParsers.optionalString(json['updated_at']),
    );
  }

  /// FormData لعملية الإضافة (POST): كل الحقول ما عدا `is_active`.
  /// الصورة تُرسَل كملف عبر `MultipartFile` تحت الاسم `icon`.
  FormData toCreateFormData() {
    final map = <String, dynamic>{
      'name_ar': nameAr,
      'code': code,
      'sort_order': sortOrder,
    };
    if (minAmount != null) map['min_amount'] = minAmount;
    if (maxAmount != null) map['max_amount'] = maxAmount;
    if (iconBytes != null && iconBytes!.isNotEmpty) {
      map['icon'] = MultipartFile.fromBytes(
        iconBytes!,
        filename: iconFileName ?? 'icon.png',
      );
    }
    return FormData.fromMap(map);
  }

  /// FormData لعملية التعديل (PUT) — Partial Update.
  /// يُرسَل فقط ما تغيّر عن [original]. الصورة تُرسَل فقط عند اختيار صورة جديدة.
  /// `is_active` لا يُرسَل إطلاقاً هنا.
  FormData toUpdatePartialFormData(PaymentMethodModel original) {
    final map = <String, dynamic>{};

    if (nameAr.trim() != original.nameAr.trim()) {
      map['name_ar'] = nameAr.trim();
    }
    if (code.trim() != original.code.trim()) {
      map['code'] = code.trim();
    }
    if (minAmount != original.minAmount) {
      if (minAmount != null) map['min_amount'] = minAmount;
    }
    if (maxAmount != original.maxAmount) {
      if (maxAmount != null) map['max_amount'] = maxAmount;
    }
    if (sortOrder != original.sortOrder) {
      map['sort_order'] = sortOrder;
    }
    if (iconBytes != null && iconBytes!.isNotEmpty) {
      map['icon'] = MultipartFile.fromBytes(
        iconBytes!,
        filename: iconFileName ?? 'icon.png',
      );
    }

    return FormData.fromMap(map);
  }

  /// هل يوجد تعديل حقيقي مقارنةً بـ [original]؟
  bool hasChangesFrom(PaymentMethodModel original) {
    if (nameAr.trim() != original.nameAr.trim()) return true;
    if (code.trim() != original.code.trim()) return true;
    if (minAmount != original.minAmount) return true;
    if (maxAmount != original.maxAmount) return true;
    if (sortOrder != original.sortOrder) return true;
    if (iconBytes != null && iconBytes!.isNotEmpty) return true;
    return false;
  }

  /// تسمية الحالة بالعربية.
  String get statusLabel => isActive ? 'مفعلة' : 'غير مفعلة';

  PaymentMethodModel copyWith({
    int? id,
    String? nameAr,
    String? code,
    String? iconUrl,
    double? minAmount,
    double? maxAmount,
    bool? isActive,
    int? sortOrder,
    String? createdAt,
    String? updatedAt,
    List<int>? iconBytes,
    String? iconFileName,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      code: code ?? this.code,
      iconUrl: iconUrl ?? this.iconUrl,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iconBytes: iconBytes ?? this.iconBytes,
      iconFileName: iconFileName ?? this.iconFileName,
    );
  }
}
