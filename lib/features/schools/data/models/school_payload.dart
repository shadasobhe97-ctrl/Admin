import 'school_model.dart';

/// بيانات إنشاء مدرسة — كل الحقول مطلوبة حسب العقد.
///
/// وجود هذا النموذج يمنع بناء الـ Request Body يدوياً داخل الـ Widgets.
class CreateSchoolPayload {
  final String name;
  final double lat;
  final double lng;
  final String address;
  final int zoneId;

  const CreateSchoolPayload({
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.zoneId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name.trim(),
      'lat': lat,
      'lng': lng,
      'address': address.trim(),
      'zone_id': zoneId,
    };
  }
}

/// بيانات تعديل مدرسة — كل الحقول اختيارية (تحديث جزئي).
/// لا يُرسل أي حقل لم يتغيّر.
class UpdateSchoolPayload {
  final String? name;
  final double? lat;
  final double? lng;
  final String? address;
  final int? zoneId;
  final String? status;

  const UpdateSchoolPayload({
    this.name,
    this.lat,
    this.lng,
    this.address,
    this.zoneId,
    this.status,
  });

  /// يبني حمولة التعديل بمقارنة القيم الجديدة بالمدرسة الحالية،
  /// فلا تُرسل إلا الحقول التي تغيّرت فعلاً.
  factory UpdateSchoolPayload.diff({
    required SchoolModel original,
    required String name,
    required double lat,
    required double lng,
    required String address,
    required int zoneId,
    required String status,
  }) {
    return UpdateSchoolPayload(
      name: name.trim() == original.name ? null : name.trim(),
      lat: lat == original.lat ? null : lat,
      lng: lng == original.lng ? null : lng,
      address: address.trim() == original.address ? null : address.trim(),
      zoneId: zoneId == original.zoneId ? null : zoneId,
      status: status == original.status ? null : status,
    );
  }

  bool get isEmpty =>
      name == null &&
      lat == null &&
      lng == null &&
      address == null &&
      zoneId == null &&
      status == null;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (name != null) 'name': name,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (address != null) 'address': address,
      if (zoneId != null) 'zone_id': zoneId,
      if (status != null) 'status': status,
    };
  }
}

/// قيود التحقق كما ينص عليها العقد، في مكان واحد
/// تستعمله الواجهة ولا تكرره.
class SchoolValidation {
  const SchoolValidation._();

  static const int nameMaxLength = 150;
  static const int addressMaxLength = 255;
  static const double minLat = -90;
  static const double maxLat = 90;
  static const double minLng = -180;
  static const double maxLng = 180;

  static String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'يرجى إدخال اسم المدرسة';
    if (name.length > nameMaxLength) {
      return 'اسم المدرسة يجب ألا يتجاوز $nameMaxLength حرفاً';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    final address = value?.trim() ?? '';
    if (address.isEmpty) return 'يرجى إدخال عنوان المدرسة';
    if (address.length > addressMaxLength) {
      return 'العنوان يجب ألا يتجاوز $addressMaxLength حرفاً';
    }
    return null;
  }

  static String? validateLat(String? value) =>
      _validateCoordinate(value, minLat, maxLat, 'دائرة العرض');

  static String? validateLng(String? value) =>
      _validateCoordinate(value, minLng, maxLng, 'خط الطول');

  static String? _validateCoordinate(
    String? value,
    double min,
    double max,
    String label,
  ) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'يرجى إدخال $label';

    final parsed = double.tryParse(text);
    if (parsed == null) return '$label يجب أن يكون رقماً';
    if (parsed < min || parsed > max) {
      return '$label يجب أن يكون بين $min و $max';
    }
    return null;
  }
}
