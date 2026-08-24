import 'package:dio/dio.dart';

import 'driver_details_model.dart';
import 'driver_document_model.dart';
import 'driver_model.dart';
import 'driver_vehicle_model.dart';

/// حالات السائق التي يقبلها الخادم في `PUT /admin/drivers/{id}`.
class DriverStatusValue {
  const DriverStatusValue._();

  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
  static const String suspended = 'Suspended';
  static const String active = 'Active';

  static const List<String> all = [
    pending,
    approved,
    rejected,
    suspended,
    active,
  ];

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
      case 'active':
        return 'نشط';
      case 'offline':
        return 'غير متصل';
      case 'on_trip':
        return 'في رحلة';
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

/// ملف مختار من الجهاز جاهز للرفع.
///
/// تُقرأ البايتات مباشرة لأن الويب لا يوفّر مساراً على القرص.
class PickedUpload {
  final List<int> bytes;
  final String fileName;

  const PickedUpload({required this.bytes, required this.fileName});

  MultipartFile toMultipart() =>
      MultipartFile.fromBytes(bytes, filename: fileName);
}

/// مفاتيح ملفات الوثائق كما ينص عليها عقد `PUT /admin/drivers/{id}`.
class DriverDocumentField {
  const DriverDocumentField._();

  static const String license = 'doc_license';
  static const String logbook = 'doc_logbook';
  static const String insurance = 'doc_insurance';
  static const String bookletPage = 'doc_booklet_page';
  static const String stamp = 'doc_stamp';
  static const String technicalInspection = 'doc_technical_inspection';

  static const Map<String, String> labels = {
    license: 'رخصة القيادة',
    logbook: 'كتيب المركبة (بيانات مالك المركبة)',
    insurance: 'التأمين',
    bookletPage: 'كتيب المركبة (أوصاف المركبة الآلية)',
    stamp: 'الدمغ (إذن تجول)',
    technicalInspection: 'الفحص الفني',
  };

  static const List<String> all = [
    license,
    logbook,
    insurance,
    bookletPage,
    stamp,
    technicalInspection,
  ];
}

/// حمولة `PUT /api/admin/drivers/{id}` — تحديث جزئي بصيغة multipart/form-data.
///
/// لا يُرسل أي حقل لم يتغيّر، والملفات تُرسل فقط عند اختيار ملف جديد.
class UpdateDriverPayload {
  // ── بيانات السائق والحساب ────────────────────────────────────────────────
  final String? fullName;
  final String? phoneNumber;
  final String? nationalId;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? status;
  final bool? isActive;

  // ── بيانات المركبة ───────────────────────────────────────────────────────
  final int? vehicleId;
  final String? plateNumber;
  final String? brand;
  final String? model;
  final String? color;
  final String? vehicleType;
  final int? year;
  final int? capacityManual;
  final bool? hasAc;
  final PickedUpload? vehicleImage;

  // ── تواريخ الوثائق وملفاتها ──────────────────────────────────────────────
  final String? insuranceExpiry;
  final String? stampExpiry;
  final String? technicalInspectionExpiry;

  /// ملفات الوثائق مفهرسة بمفتاح الخادم (`doc_license` … إلخ).
  final Map<String, PickedUpload> documents;

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
    this.vehicleId,
    this.plateNumber,
    this.brand,
    this.model,
    this.color,
    this.vehicleType,
    this.year,
    this.capacityManual,
    this.hasAc,
    this.vehicleImage,
    this.insuranceExpiry,
    this.stampExpiry,
    this.technicalInspectionExpiry,
    this.documents = const {},
  });

  /// يبني الحمولة بمقارنة القيم الجديدة بالبيانات الحالية،
  /// فلا تُرسل إلا الحقول التي تغيّرت فعلاً.
  ///
  /// [details] مصدر بيانات المركبة والوثائق الحالية؛ حين تكون `null`
  /// تُقارن حقول السائق وحدها.
  factory UpdateDriverPayload.diff({
    required DriverModel original,
    required String reason,
    DriverDetailsModel? details,
    required String fullName,
    required String phoneNumber,
    String? nationalId,
    String? licenseNumber,
    String? licenseExpiry,
    String? status,
    bool? isActive,
    String? plateNumber,
    String? brand,
    String? model,
    String? color,
    String? vehicleType,
    String? year,
    String? capacityManual,
    bool? hasAc,
    PickedUpload? vehicleImage,
    String? insuranceExpiry,
    String? stampExpiry,
    String? technicalInspectionExpiry,
    Map<String, PickedUpload> documents = const {},
  }) {
    String? changedText(String? next, String? current) {
      final value = next?.trim();
      if (value == null || value.isEmpty) return null;
      return value == (current?.trim() ?? '') ? null : value;
    }

    int? changedInt(String? next, int? current) {
      final value = next?.trim();
      if (value == null || value.isEmpty) return null;
      final parsed = int.tryParse(value);
      if (parsed == null || parsed == current) return null;
      return parsed;
    }

    final DriverVehicleModel? vehicle = details?.vehicle;

    /// تاريخ انتهاء الوثيقة الحالي حسب النوع، لمقارنته بالمُدخل.
    String? currentDocDate(
      String? Function(DriverDocumentModel doc) selector,
    ) {
      for (final doc in details?.documents ?? const <DriverDocumentModel>[]) {
        final value = selector(doc);
        if (value != null && value.isNotEmpty) return value;
      }
      return null;
    }

    final vehicleChanged = <String, Object?>{
      'plate': changedText(plateNumber, vehicle?.plateNumber),
      'brand': changedText(brand, vehicle?.brand),
      'model': changedText(model, vehicle?.model),
      'color': changedText(color, vehicle?.color),
      'type': changedText(vehicleType, vehicle?.type),
      'year': changedInt(year, int.tryParse(vehicle?.year ?? '')),
      'capacity': changedInt(capacityManual, vehicle?.capacity),
      'hasAc': hasAc == null || hasAc == vehicle?.hasAc ? null : hasAc,
    };

    final touchesVehicle =
        vehicleChanged.values.any((value) => value != null) ||
            vehicleImage != null;

    return UpdateDriverPayload(
      reason: reason.trim(),
      fullName: changedText(fullName, original.fullName),
      phoneNumber: changedText(phoneNumber, original.phoneNumber),
      nationalId: changedText(nationalId, original.nationalId),
      licenseNumber: changedText(licenseNumber, original.licenseNumber),
      licenseExpiry: changedText(licenseExpiry, original.licenseExpiry),
      status: status == null || status == original.status ? null : status,
      isActive:
          isActive == null || isActive == original.isActive ? null : isActive,
      // يُرسل `vehicle_id` فقط عند تعديل المركبة، ليعرف الخادم أي مركبة يحدّث.
      vehicleId: touchesVehicle ? vehicle?.id : null,
      plateNumber: vehicleChanged['plate'] as String?,
      brand: vehicleChanged['brand'] as String?,
      model: vehicleChanged['model'] as String?,
      color: vehicleChanged['color'] as String?,
      vehicleType: vehicleChanged['type'] as String?,
      year: vehicleChanged['year'] as int?,
      capacityManual: vehicleChanged['capacity'] as int?,
      hasAc: vehicleChanged['hasAc'] as bool?,
      vehicleImage: vehicleImage,
      insuranceExpiry: changedText(
        insuranceExpiry,
        currentDocDate((doc) => doc.insuranceExpiry),
      ),
      stampExpiry: changedText(
        stampExpiry,
        currentDocDate((doc) => doc.stampExpiry),
      ),
      technicalInspectionExpiry: changedText(
        technicalInspectionExpiry,
        currentDocDate((doc) => doc.technicalInspectionExpiry),
      ),
      documents: documents,
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
      isActive == null &&
      plateNumber == null &&
      brand == null &&
      model == null &&
      color == null &&
      vehicleType == null &&
      year == null &&
      capacityManual == null &&
      hasAc == null &&
      vehicleImage == null &&
      insuranceExpiry == null &&
      stampExpiry == null &&
      technicalInspectionExpiry == null &&
      documents.isEmpty;

  /// أسماء الحقول المتغيّرة، لعرضها في تأكيد الحفظ.
  List<String> get changedFieldLabels => [
        if (fullName != null) 'الاسم الكامل',
        if (phoneNumber != null) 'رقم الهاتف',
        if (nationalId != null) 'الرقم الوطني',
        if (licenseNumber != null) 'رقم الرخصة',
        if (licenseExpiry != null) 'تاريخ انتهاء الرخصة',
        if (status != null) 'حالة السائق',
        if (isActive != null) 'تفعيل الحساب',
        if (plateNumber != null) 'رقم اللوحة',
        if (brand != null) 'الشركة المصنّعة',
        if (model != null) 'الموديل',
        if (color != null) 'اللون',
        if (vehicleType != null) 'نوع المركبة',
        if (year != null) 'سنة الصنع',
        if (capacityManual != null) 'السعة',
        if (hasAc != null) 'التكييف',
        if (vehicleImage != null) 'صورة المركبة',
        if (insuranceExpiry != null) 'انتهاء التأمين',
        if (stampExpiry != null) 'انتهاء الدمغ',
        if (technicalInspectionExpiry != null) 'انتهاء الفحص الفني',
        for (final key in documents.keys)
          DriverDocumentField.labels[key] ?? key,
      ];

  /// الحقول النصية فقط — تُستخدم في الاختبارات وفي بناء الـ FormData.
  Map<String, dynamic> toFields() {
    return <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (nationalId != null) 'national_id': nationalId,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (licenseExpiry != null) 'license_expiry': licenseExpiry,
      if (status != null) 'status': status,
      // القيم المنطقية تُرسل كـ 1/0 لأن multipart لا ينقل أنواعاً.
      if (isActive != null) 'is_active': isActive! ? '1' : '0',
      if (vehicleId != null) 'vehicle_id': '$vehicleId',
      if (plateNumber != null) 'plate_number': plateNumber,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (color != null) 'color': color,
      if (vehicleType != null) 'type': vehicleType,
      if (year != null) 'year': '$year',
      if (capacityManual != null) 'capacity_manual': '$capacityManual',
      if (hasAc != null) 'has_ac': hasAc! ? '1' : '0',
      if (insuranceExpiry != null) 'insurance_expiry': insuranceExpiry,
      if (stampExpiry != null) 'stamp_expiry': stampExpiry,
      if (technicalInspectionExpiry != null)
        'technical_inspection_expiry': technicalInspectionExpiry,
      'reason': reason,
    };
  }

  /// جسم الطلب النهائي بصيغة multipart/form-data.
  FormData toFormData() {
    final map = toFields();
    if (vehicleImage != null) {
      map['vehicle_image'] = vehicleImage!.toMultipart();
    }
    documents.forEach((field, upload) {
      map[field] = upload.toMultipart();
    });
    return FormData.fromMap(map);
  }
}

/// قواعد التحقق كما ينص عليها عقد الخادم، في مكان واحد لا يتكرر.
class DriverValidation {
  const DriverValidation._();

  static const int nameMaxLength = 150;
  static const int minVehicleYear = 1980;
  static const int minCapacity = 1;
  static const int maxCapacity = 60;

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

  /// سنة الصنع: من 1980 حتى العام القادم، كما يقبلها الخادم.
  static String? validateVehicleYear(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final year = int.tryParse(text);
    if (year == null) return 'أدخل سنة بأرقام صحيحة';

    final maxYear = DateTime.now().year + 1;
    if (year < minVehicleYear || year > maxYear) {
      return 'سنة الصنع يجب أن تكون بين $minVehicleYear و$maxYear';
    }
    return null;
  }

  /// السعة: من 1 إلى 60 راكباً.
  static String? validateCapacity(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final capacity = int.tryParse(text);
    if (capacity == null) return 'أدخل السعة بأرقام صحيحة';
    if (capacity < minCapacity || capacity > maxCapacity) {
      return 'السعة يجب أن تكون بين $minCapacity و$maxCapacity';
    }
    return null;
  }

  static String? validateReason(String? value) {
    final reason = value?.trim() ?? '';
    if (reason.isEmpty) return 'سبب التعديل مطلوب ويُحفظ في سجل الإجراءات';
    if (reason.length < 5) return 'يرجى توضيح السبب بشكل كافٍ';
    return null;
  }
}
