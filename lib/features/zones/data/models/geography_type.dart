/// أنواع التقسيم الإداري الجغرافي المعرفة في النظام والـ API.
enum GeographyType {
  municipality,
  subMunicipality,
  region,
}

extension GeographyTypeExtension on GeographyType {
  /// قيمة المفتاح النصي التي يطلبها الخادم في الـ Request.
  String get apiKey {
    switch (this) {
      case GeographyType.municipality:
        return 'municipality';
      case GeographyType.subMunicipality:
        return 'sub_municipality';
      case GeographyType.region:
        return 'region';
    }
  }

  /// التسمية العربية الموجهة للمستخدم في الواجهة.
  String get label {
    switch (this) {
      case GeographyType.municipality:
        return 'البلدية الكبرى';
      case GeographyType.subMunicipality:
        return 'البلدية الفرعية';
      case GeographyType.region:
        return 'المنطقة الدقيقة';
    }
  }

  /// تلميح البحث الموجه للمستخدم.
  String get searchHint {
    switch (this) {
      case GeographyType.municipality:
        return 'ابحث باسم البلدية الكبرى...';
      case GeographyType.subMunicipality:
        return 'ابحث باسم البلدية الفرعية...';
      case GeographyType.region:
        return 'ابحث باسم المنطقة الدقيقة...';
    }
  }
}
