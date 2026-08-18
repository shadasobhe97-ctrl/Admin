import 'driver_model.dart';

/// حالات السائق التي يقبلها الخادم في `PUT /admin/drivers/{id}`.
class DriverStatusValue {
  const DriverStatusValue._();

  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
  static const String suspended = 'Suspended';

  static const List<String> all = [pending, approved, rejected, suspended];

  static String label(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'معتمد';
      case 'rejected':
        return 'مرفوض';
      case 'suspended':
        return 'موقوف';
      default:
        return status;
    }
  }

  /// يطابق قيمة الخادم مهما اختلفت حالة الأحرف.
  static String? normalize(String? status) {
    if (status == null) return null;
    for (final value in all) {
      if (value.toLowerCase() == status.toLowerCase()) return value;
    }
    return null;
  }
}

/// حمولة `PUT /api/admin/drivers/{id}` — تحديث جزئي.
/// لا يُرسل أي حقل لم يتغيّر.
class UpdateDriverPayload {
  final String? fullName;
  final String? phoneNumber;
  final String? nationalId;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? status;
  final bool? isActive;

  /// سبب التعديل — إلزامي، ويُخزَّن في سجل الإجراءات لا في جدول السائق.
  final String reason;

  const UpdateDriverPayload({
    required this.reason,
    this.fullName,
    this.phoneNumber,
    this.nationalId,
    this.licenseNumber,
    this.licenseExpiry,
    this.status,
    this.isActive,
  });

  /// يبني الحمولة بمقارنة القيم الجديدة ببيانات السائق الحالية،
  /// فلا تُرسل إلا الحقول التي تغيّرت فعلاً.
  factory UpdateDriverPayload.diff({
    required DriverModel original,
    required String reason,
    required String fullName,
    required String phoneNumber,
    String? nationalId,
    String? licenseNumber,
    String? licenseExpiry,
    String? status,
    bool? isActive,
  }) {
    String? changed(String? next, String? current) {
      final value = next?.trim();
      if (value == null || value.isEmpty) return null;
      return value == (current?.trim() ?? '') ? null : value;
    }

    return UpdateDriverPayload(
      reason: reason.trim(),
      fullName: changed(fullName, original.fullName),
      phoneNumber: changed(phoneNumber, original.phoneNumber),
      nationalId: changed(nationalId, original.nationalId),
      licenseNumber: changed(licenseNumber, original.licenseNumber),
      licenseExpiry: changed(licenseExpiry, original.licenseExpiry),
      status: status == null || status == original.status ? null : status,
      isActive: isActive == null || isActive == original.isActive
          ? null
          : isActive,
    );
  }

  /// `true` عندما لا يوجد أي حقل تغيّر — فلا داعي لإرسال الطلب.
  bool get isEmpty =>
      fullName == null &&
      phoneNumber == null &&
      nationalId == null &&
      licenseNumber == null &&
      licenseExpiry == null &&
      status == null &&
      isActive == null;

  /// أسماء الحقول المتغيّرة، لعرضها في تأكيد الحفظ.
  List<String> get changedFieldLabels => [
        if (fullName != null) 'الاسم الكامل',
        if (phoneNumber != null) 'رقم الهاتف',
        if (nationalId != null) 'الرقم الوطني',
        if (licenseNumber != null) 'رقم الرخصة',
        if (licenseExpiry != null) 'تاريخ انتهاء الرخصة',
        if (status != null) 'حالة السائق',
        if (isActive != null) 'تفعيل الحساب',
      ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (nationalId != null) 'national_id': nationalId,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (licenseExpiry != null) 'license_expiry': licenseExpiry,
      if (status != null) 'status': status,
      if (isActive != null) 'is_active': isActive,
      'reason': reason,
    };
  }
}

/// قواعد التحقق كما ينص عليها عقد الخادم، في مكان واحد لا يتكرر.
class DriverValidation {
  const DriverValidation._();

  static const int nameMaxLength = 150;

  /// رقم ليبي: 10 أرقام تبدأ بـ 09.
  static final RegExp _phonePattern = RegExp(r'^09\d{8}$');

  /// التاريخ بصيغة YYYY-MM-DD.
  static final RegExp _datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static String? validateFullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'يرجى إدخال اسم السائق';
    if (name.length > nameMaxLength) {
      return 'الاسم يجب ألا يتجاوز $nameMaxLength حرفاً';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'يرجى إدخال رقم الهاتف';
    if (!_phonePattern.hasMatch(phone)) {
      return 'رقم الهاتف يجب أن يبدأ بـ 09 ويتكون من 10 أرقام';
    }
    return null;
  }

  /// اختياري — يُتحقق منه فقط عند الإدخال.
  static String? validateOptionalDate(String? value) {
    final date = value?.trim() ?? '';
    if (date.isEmpty) return null;
    if (!_datePattern.hasMatch(date)) {
      return 'الصيغة المطلوبة: YYYY-MM-DD';
    }

    final parsed = DateTime.tryParse(date);
    if (parsed == null) return 'تاريخ غير صالح';

    // `DateTime` يدحرج القيم الزائدة (2027-13-45 يصير 2028-02-14)،
    // لذلك تُقارن النتيجة بالنص الأصلي لرفض التواريخ غير الحقيقية.
    final normalized = '${parsed.year.toString().padLeft(4, '0')}-'
        '${parsed.month.toString().padLeft(2, '0')}-'
        '${parsed.day.toString().padLeft(2, '0')}';
    if (normalized != date) return 'تاريخ غير صالح';

    return null;
  }

  static String? validateReason(String? value) {
    final reason = value?.trim() ?? '';
    if (reason.isEmpty) return 'سبب التعديل مطلوب ويُحفظ في سجل الإجراءات';
    if (reason.length < 5) return 'يرجى توضيح السبب بشكل كافٍ';
    return null;
  }
}
