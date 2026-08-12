import 'dart:convert';
import 'dart:typed_data';

import 'report_filters.dart';

/// نتيجة GET /api/admin/reports/export
///
/// تحفظ المحتوى كما وصل من الخادم دون تفسير مسبق:
/// CSV يُحفظ كبايتات (مع الـ BOM إن أرسله الخادم لدعم العربية في Excel)،
/// و JSON يُحفظ كنص إضافةً إلى البايتات.
class ReportExportModel {
  final String type;
  final String format;

  /// اسم الملف المستخرج من `Content-Disposition`، أو المبني محلياً عند غيابه.
  final String fileName;

  /// `Content-Type` كما أرسله الخادم.
  final String? contentType;

  final Uint8List bytes;

  const ReportExportModel({
    required this.type,
    required this.format,
    required this.fileName,
    required this.bytes,
    this.contentType,
  });

  bool get isCsv => format == ReportFormat.csv;

  int get sizeInBytes => bytes.length;

  String get sizeLabel {
    if (sizeInBytes < 1024) return '$sizeInBytes بايت';
    final kb = sizeInBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} ك.ب';
    return '${(kb / 1024).toStringAsFixed(2)} م.ب';
  }

  /// المحتوى كنص UTF-8، مع تجاوز الـ BOM حتى لا يظهر كرمز غريب في المعاينة.
  String get asText {
    var data = bytes;
    if (data.length >= 3 &&
        data[0] == 0xEF &&
        data[1] == 0xBB &&
        data[2] == 0xBF) {
      data = Uint8List.sublistView(data, 3);
    }
    return utf8.decode(data, allowMalformed: true);
  }

  bool get hasBom =>
      bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF;

  /// عدد أسطر المحتوى، مفيد لعرض حجم تقرير CSV.
  int get lineCount =>
      asText.split('\n').where((line) => line.trim().isNotEmpty).length;

  /// يستخرج اسم الملف من ترويسة `Content-Disposition` إن وُجدت،
  /// وإلا يبني اسماً من نوع التقرير وتاريخ اليوم.
  static String resolveFileName({
    required String? contentDisposition,
    required String type,
    required String format,
    required DateTime now,
  }) {
    final fromHeader = _parseContentDisposition(contentDisposition);
    if (fromHeader != null) return fromHeader;

    final date = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return 'derbi-report-$type-$date.$format';
  }

  /// يدعم `filename*=UTF-8''...` و`filename="..."`.
  static String? _parseContentDisposition(String? header) {
    if (header == null || header.trim().isEmpty) return null;

    final extended = RegExp(
      "filename\\*\\s*=\\s*UTF-8''([^;]+)",
      caseSensitive: false,
    ).firstMatch(header);
    if (extended != null) {
      final value = extended.group(1)?.trim();
      if (value != null && value.isNotEmpty) {
        return Uri.decodeComponent(value);
      }
    }

    final plain = RegExp(
      'filename\\s*=\\s*"?([^";]+)"?',
      caseSensitive: false,
    ).firstMatch(header);
    final value = plain?.group(1)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }
}
