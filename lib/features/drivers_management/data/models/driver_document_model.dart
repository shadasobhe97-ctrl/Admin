class DriverDocumentModel {
  final String docType;
  final String fileUrl;
  final String status;
  final String? expiryDate;
  final String? notes;

  DriverDocumentModel({
    required this.docType,
    required this.fileUrl,
    required this.status,
    this.expiryDate,
    this.notes,
  });

  factory DriverDocumentModel.fromJson(Map<String, dynamic> json) {
    return DriverDocumentModel(
      docType: json['doc_type']?.toString() ?? json['type']?.toString() ?? 'DOCUMENT',
      fileUrl: json['file_url']?.toString() ?? json['url']?.toString() ?? json['file']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      expiryDate: json['expiry_date']?.toString() ?? json['expires_at']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  String get translatedType {
    switch (docType.toUpperCase()) {
      case 'LICENSE':
        return 'رخصة القيادة';
      case 'NATIONAL_ID':
        return 'الرقم الوطني / الهوية';
      case 'VEHICLE_REGISTRATION':
        return 'كتيب / ترخيص المركبة';
      case 'INSURANCE':
        return 'التأمين';
      case 'BACKGROUND_CHECK':
        return 'شهادة الحالة الجنائية';
      default:
        return docType;
    }
  }
}
