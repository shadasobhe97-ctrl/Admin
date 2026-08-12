import 'package:dio/dio.dart';

/// استثناء موحّد يحمل رسالة الخادم الحقيقية كما هي، دون استبدالها برسالة عامة.
class ApiException implements Exception {
  /// الرسالة المعروضة للمستخدم (مصدرها الخادم متى ما توفّرت).
  final String message;

  /// رمز حالة HTTP إن وُجد.
  final int? statusCode;

  /// تفاصيل أخطاء التحقق كما أرسلها الخادم في `errors`.
  final Map<String, List<String>> errors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.errors = const {},
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  /// 422 يُستخدم من الخادم للتحقق وكذلك لحالات العمليات المُعالَجة مسبقاً
  /// (Idempotency)، لذلك تُعرض رسالته وتفاصيله كما هي.
  bool get isUnprocessable => statusCode == 422;

  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// الرسالة الكاملة: رسالة الخادم متبوعة بتفاصيل `errors` إن توفّرت.
  String get detailedMessage {
    if (errors.isEmpty) return message;

    final details = errors.values
        .expand((values) => values)
        .where((value) => value.trim().isNotEmpty && value.trim() != message.trim())
        .toList();

    if (details.isEmpty) return message;
    return '$message\n${details.join('\n')}';
  }

  @override
  String toString() => detailedMessage;
}

/// يحوّل أي خطأ قادم من طبقة الشبكة إلى [ApiException] مع الحفاظ على
/// رسالة الخادم الأصلية وأولويتها على أي رسالة افتراضية.
class ApiErrorMapper {
  const ApiErrorMapper._();

  static ApiException map(Object error, {required String fallbackMessage}) {
    if (error is ApiException) return error;

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      final parsedErrors = _parseErrors(data);
      final serverMessage = _parseMessage(data);

      if (serverMessage != null) {
        return ApiException(
          serverMessage,
          statusCode: statusCode,
          errors: parsedErrors,
        );
      }

      if (parsedErrors.isNotEmpty) {
        return ApiException(
          parsedErrors.values.first.first,
          statusCode: statusCode,
          errors: parsedErrors,
        );
      }

      return ApiException(
        _messageForStatus(statusCode) ??
            _messageForDioType(error.type) ??
            fallbackMessage,
        statusCode: statusCode,
      );
    }

    return ApiException(
      error.toString().replaceAll('Exception: ', '').trim().isEmpty
          ? fallbackMessage
          : error.toString().replaceAll('Exception: ', ''),
    );
  }

  static String? _parseMessage(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return null;
  }

  static Map<String, List<String>> _parseErrors(dynamic data) {
    if (data is! Map) return const {};

    final rawErrors = data['errors'];
    if (rawErrors is! Map) return const {};

    final result = <String, List<String>>{};
    rawErrors.forEach((key, value) {
      final messages = <String>[];
      if (value is List) {
        for (final item in value) {
          if (item != null && item.toString().trim().isNotEmpty) {
            messages.add(item.toString());
          }
        }
      } else if (value != null && value.toString().trim().isNotEmpty) {
        messages.add(value.toString());
      }
      if (messages.isNotEmpty) {
        result[key.toString()] = messages;
      }
    });
    return result;
  }

  static String? _messageForStatus(int? statusCode) {
    switch (statusCode) {
      case 401:
        return 'انتهت صلاحية الجلسة (401)، يرجى إعادة تسجيل الدخول.';
      case 403:
        return 'غير مصرّح لك بتنفيذ هذه العملية (403).';
      case 404:
        return 'العنصر المطلوب غير موجود (404).';
      case 422:
        return 'تعذّر تنفيذ العملية، البيانات المرسلة غير مقبولة (422).';
      case 500:
        return 'حدث خطأ داخلي في الخادم (500).';
      case 503:
        return 'الخدمة غير متاحة حالياً (503)، يرجى المحاولة لاحقاً.';
      default:
        return null;
    }
  }

  static String? _messageForDioType(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة الاتصال بالخادم، يرجى التحقق من الإنترنت.';
      case DioExceptionType.connectionError:
        return 'تعذّر الاتصال بالخادم، يرجى التحقق من الشبكة.';
      case DioExceptionType.badCertificate:
        return 'تعذّر التحقق من شهادة الأمان الخاصة بالخادم.';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب.';
      default:
        return null;
    }
  }
}
