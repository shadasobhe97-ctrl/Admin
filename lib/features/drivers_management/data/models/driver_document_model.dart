/// وثيقة رسمية واحدة من وثائق السائق.
///
/// شكل الخادم: `document_type`, `document_url`, `status`, `feedback`,
/// وثلاثة تواريخ انتهاء مستقلّة (تأمين، طابع، فحص فني). الأسماء القديمة
/// (`doc_type`, `file_url`, `notes`) ما تزال مقروءة للتوافق الخلفي.
class DriverDocumentModel {
  final int? id;
  final String docType;
  final String fileUrl;
  final String status;
  final String? insuranceExpiry;
  final String? stampExpiry;
  final String? technicalInspectionExpiry;

  /// تاريخ انتهاء عام يرسله الخادم لبعض الوثائق (مثل الرخصة).
  final String? genericExpiry;

  /// ملاحظات المراجع على الوثيقة (`feedback` في عقد الخادم).
  final String? notes;

  DriverDocumentModel({
    this.id,
    required this.docType,
    required this.fileUrl,
    required this.status,
    this.insuranceExpiry,
    this.stampExpiry,
    this.technicalInspectionExpiry,
    this.genericExpiry,
    this.notes,
  });

  static String? _text(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty || text == 'null' ? null : text;
  }

  factory DriverDocumentModel.fromJson(Map<String, dynamic> json) {
    return DriverDocumentModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      docType: _text(json['document_type']) ??
          _text(json['doc_type']) ??
          _text(json['type']) ??
          'DOCUMENT',
      fileUrl: _text(json['document_url']) ??
          _text(json['file_url']) ??
          _text(json['url']) ??
          _text(json['file']) ??
          '',
      status: _text(json['status']) ?? 'Pending',
      insuranceExpiry: _text(json['insurance_expiry_date']) ??
          _text(json['insurance_expiry']),
      stampExpiry:
          _text(json['stamp_expiry_date']) ?? _text(json['stamp_expiry']),
      technicalInspectionExpiry:
          _text(json['technical_inspection_expiry_date']) ??
              _text(json['technical_inspection_expiry']),
      genericExpiry:
          _text(json['expiry_date']) ?? _text(json['expires_at']),
      notes: _text(json['feedback']) ?? _text(json['notes']),
    );
  }

  bool get hasExpiry {
    final upper = docType.toUpperCase();
    return !upper.contains('LOGBOOK') && !upper.contains('REGISTRATION');
  }

  /// تاريخ الانتهاء المعروض — أول تاريخ متوفّر من التواريخ الأربعة.
  /// الخادم يملأ التاريخ المناسب لنوع الوثيقة ويترك البقية `null`.
  /// كتيب المركبة (بيانات مالك المركبة) لا يملك تاريخ انتهاء.
  String? get expiryDate {
    if (!hasExpiry) return null;
    return genericExpiry ??
        insuranceExpiry ??
        stampExpiry ??
        technicalInspectionExpiry;
  }

  String get translatedType {
    switch (docType.toUpperCase()) {
      case 'LICENSE':
      case 'DOC_LICENSE':
        return 'رخصة القيادة';
      case 'LOGBOOK':
      case 'DOC_LOGBOOK':
      case 'VEHICLE_LOGBOOK':
      case 'VEHICLE_REGISTRATION':
        return 'كتيب المركبة (بيانات مالك المركبة)';
      case 'BOOKLET_PAGE':
      case 'DOC_BOOKLET_PAGE':
      case 'BOOKLET_PERSONAL_PAGE':
      case 'DOC_BOOKLET_PERSONAL_PAGE':
        return 'كتيب المركبة (أوصاف المركبة الآلية)';
      case 'INSURANCE':
      case 'DOC_INSURANCE':
        return 'التأمين';
      case 'STAMP':
      case 'DOC_STAMP':
        return 'الدمغ (إذن تجول)';
      case 'TECHNICAL_INSPECTION':
      case 'DOC_TECHNICAL_INSPECTION':
        return 'الفحص الفني';
      case 'NATIONAL_ID':
        return 'الرقم الوطني / الهوية';
      case 'BACKGROUND_CHECK':
        return 'شهادة الحالة الجنائية';
      default:
        return docType;
    }
  }
}
