import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';

/// خطأ يخص حفظ الملفات على الجهاز، منفصل عن أخطاء الشبكة.
class FileExportException implements Exception {
  final String message;

  const FileExportException(this.message);

  @override
  String toString() => message;
}

/// نتيجة محاولة الحفظ.
class FileExportResult {
  /// المسار الذي حُفظ فيه الملف، أو `null` على الويب حيث يتولى المتصفح التنزيل.
  final String? path;

  /// `false` إذا ألغى المستخدم نافذة الحفظ.
  final bool isSaved;

  const FileExportResult({required this.isSaved, this.path});

  const FileExportResult.cancelled() : isSaved = false, path = null;
}

/// خدمة حفظ الملفات على الجهاز.
///
/// تُعزل تفاصيل الحزمة خلف هذه الواجهة، فلا تعرف بقية طبقات التطبيق
/// أي شيء عن `file_saver`، ويمكن استبدالها لاحقاً دون لمس أي Feature.
abstract class FileExportService {
  /// يفتح نافذة "حفظ باسم" ليختار المستخدم الوجهة.
  Future<FileExportResult> saveBytes({
    required String fileName,
    required Uint8List bytes,
  });
}

class FileSaverExportService implements FileExportService {
  const FileSaverExportService();

  @override
  Future<FileExportResult> saveBytes({
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (bytes.isEmpty) {
      throw const FileExportException('لا يوجد محتوى لحفظه في الملف.');
    }

    final baseName = _baseName(fileName);
    final extension = _extension(fileName);

    try {
      final path = await FileSaver.instance.saveAs(
        name: baseName,
        bytes: bytes,
        fileExtension: extension,
        mimeType: _mimeTypeFor(extension),
      );

      // `saveAs` يعيد `null` عندما يغلق المستخدم النافذة دون اختيار وجهة.
      if (path == null) return const FileExportResult.cancelled();
      return FileExportResult(isSaved: true, path: path);
    } catch (error) {
      debugPrint('[FILE EXPORT] فشل حفظ "$fileName": $error');
      throw FileExportException(
        'تعذّر حفظ الملف على الجهاز: '
        '${error.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  /// الامتداد بدون نقطة، أو سلسلة فارغة إن لم يحمل الاسم امتداداً.
  String _extension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) return '';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String _baseName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) return fileName;
    return fileName.substring(0, dotIndex);
  }

  MimeType _mimeTypeFor(String extension) {
    switch (extension) {
      case 'csv':
        return MimeType.csv;
      case 'json':
        return MimeType.json;
      default:
        return MimeType.other;
    }
  }
}
