import 'package:flutter/foundation.dart' show kIsWeb;

import '../network/api_endpoints.dart';
import '../services/storage_service.dart';

/// أدوات تجهيز روابط الملفات القادمة من الخادم لعرضها في الواجهة.
///
/// الخادم قد يُرجع الرابط كاملاً (`https://host/storage/x.jpg`) أو نسبياً
/// (`/storage/x.jpg` أو `storage/x.jpg`)، لذلك تُوحَّد الصيغة هنا في مكان واحد.
class MediaUrl {
  const MediaUrl._();

  /// جذر الخادم بدون اللاحقة `/api` — الملفات تُخدَّم من خارج مسار الـ API.
  static String get _host {
    final base = ApiEndpoints.baseUrl;
    final withoutSlash = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    return withoutSlash.endsWith('/api')
        ? withoutSlash.substring(0, withoutSlash.length - 4)
        : withoutSlash;
  }

  /// يعيد رابطاً مطلقاً صالحاً للعرض، أو `null` إن كان المدخل فارغاً.
  static String? resolve(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;

    final lower = value.toLowerCase();
    if (lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('data:') ||
        lower.startsWith('blob:')) {
      return value;
    }

    final path = value.startsWith('/') ? value : '/$value';
    return '$_host$path';
  }

  /// ترويسات طلب الصورة.
  ///
  /// `bypass-tunnel-reminder` ضرورية عند تشغيل الخادم خلف localtunnel:
  /// النفق يعترض أي طلب يحمل User-Agent متصفّح ويردّ بصفحة تنبيه HTML
  /// (‏511) بدل الملف، فتفشل الصورة. الـ token يلزم للملفات المحميّة.
  ///
  /// تنبيه: على الويب أي ترويسة مخصّصة تفرض طلب preflight، ويجب أن يسمح
  /// الخادم بـ CORS على مسار `storage/*` وإلا رفض المتصفح الطلب — لذلك
  /// يُجرَّب هذا المسار أولاً ثم يُستبدل بوسم `img` عند فشله
  /// (انظر `RemoteImage`).
  static Map<String, String> get imageHeaders {
    final headers = <String, String>{
      'bypass-tunnel-reminder': 'true',
      'Bypass-Tunnel-Reminder': 'true',
    };

    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// `true` عندما يكون تحميل البايتات مع الترويسات ممكناً بلا قيود CORS،
  /// أي على المنصّات غير الويب. على الويب يبقى محاولة أولى قابلة للفشل.
  static bool get canUseHeadersSafely => !kIsWeb;

  static const List<String> _imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
    '.heic',
  ];

  /// امتداد الملف مستخرجاً من آخر مقطع في المسار بعد إسقاط الـ query string.
  ///
  /// البحث محصور في المقطع الأخير حتى لا تُلتقط النقطة الموجودة في اسم
  /// النطاق (`x.com/files/91827` ليس له امتداد).
  static String extensionOf(String url) {
    final withoutQuery = url.split('?').first.split('#').first;
    final segment = withoutQuery.split('/').last;
    final dot = segment.lastIndexOf('.');
    if (dot == -1) return '';
    return segment.substring(dot).toLowerCase();
  }

  static bool isImage(String url) {
    final ext = extensionOf(url);
    // بعض الروابط تأتي بلا امتداد (مسارات موقّعة) — تُعامل كصورة افتراضياً
    // لأن الوثائق المرفوعة صور في الغالب، ويظهر بديل واضح عند فشل التحميل.
    if (ext.isEmpty) return true;
    return _imageExtensions.contains(ext);
  }

  static bool isPdf(String url) => extensionOf(url) == '.pdf';
}
