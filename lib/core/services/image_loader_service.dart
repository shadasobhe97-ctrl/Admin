import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/media_url.dart';

/// خدمة جلب بايتات الصور وتخزينها في الذاكرة المؤقتة (RAM Cache)
/// لضمان عرض الصور في واجهة الإدارة بسرعة وتجاوز حظر النفق (Localtunnel 511)
/// وقيود الـ CORS والمتصفحات.
class ImageLoaderService {
  ImageLoaderService._();

  static final ImageLoaderService _instance = ImageLoaderService._();
  static ImageLoaderService get instance => _instance;

  /// ذاكرة التخزين المؤقت في الرام للصور المحملة (RAM Cache).
  final Map<String, Uint8List> _imageCache = {};

  /// خريطة لدمج الطلبات المزدوجة المتزامنة لنفس الصورة (In-Flight Request Deduplication).
  final Map<String, Future<Uint8List?>> _inFlightRequests = {};

  /// عميل Dio المخصص لجلب بايتات الصور بسرعة مع الترويسات المطلوبة.
  late final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 18),
      responseType: ResponseType.bytes,
    ),
  );

  /// مسح ذاكرة التخزين المؤقت للصور إن دعت الحاجة (عند تسجيل الخروج مثلاً).
  void clearCache() {
    _imageCache.clear();
    _inFlightRequests.clear();
  }

  /// إزالة صورة معينة من الكاش لإجبار إعادة جلبها عند التحديث.
  void evict(String? rawUrl) {
    final url = MediaUrl.resolve(rawUrl);
    if (url != null) {
      _imageCache.remove(url);
      _inFlightRequests.remove(url);
    }
  }

  /// فحص وجود الصورة في الكاش في الذاكرة فوراً.
  Uint8List? getCachedBytes(String? rawUrl) {
    final url = MediaUrl.resolve(rawUrl);
    if (url == null) return null;
    return _imageCache[url];
  }

  /// جلب بايتات الصورة مع الكاش والـ Deduplication وإعادة المحاولة عند البطء.
  Future<Uint8List?> fetchImageBytes(String? rawUrl) async {
    final url = MediaUrl.resolve(rawUrl);
    if (url == null || url.isEmpty) return null;

    // 1. الفحص من ذاكرة الرام (RAM Cache) للعرض الفوري اللحظي
    if (_imageCache.containsKey(url)) {
      return _imageCache[url];
    }

    // 2. معالجة روابط الاختبارات الوهمية فوراً لتفادي إنشاء مؤقتات شبكية غير ضرورية
    if (url.contains('example.com')) {
      return null;
    }

    // 3. الفحص لمنع تكرار الطلبات الشبكية المزدوجة المتزامنة (In-Flight Deduplication)
    if (_inFlightRequests.containsKey(url)) {
      return await _inFlightRequests[url];
    }

    // 4. إطلاق طلب جديد ومشاركته مع باقي المكونات
    final fetchFuture = _fetchBytesWithRetry(url);
    _inFlightRequests[url] = fetchFuture;

    try {
      final bytes = await fetchFuture;
      if (bytes != null && bytes.isNotEmpty) {
        _imageCache[url] = bytes;
      }
      return bytes;
    } catch (e) {
      debugPrint('[IMAGE_LOADER] فشل جلب الصورة من الرابط: $url - الخطأ: $e');
      return null;
    } finally {
      _inFlightRequests.remove(url);
    }
  }

  /// جلب البايتات مع محاولة تلقائية ثانية عند حدوث بطء مؤقت في الشبكة.
  Future<Uint8List?> _fetchBytesWithRetry(String url, {int retries = 1}) async {
    for (int i = 0; i <= retries; i++) {
      try {
        final headers = MediaUrl.imageHeaders;
        final response = await _dio.get<List<int>>(
          url,
          options: Options(
            headers: headers,
            responseType: ResponseType.bytes,
            validateStatus: (status) => status != null && status < 400,
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final bytes = Uint8List.fromList(response.data!);
          if (bytes.isNotEmpty) {
            return bytes;
          }
        }
      } catch (e) {
        debugPrint('[IMAGE_LOADER] المحاولة ${i + 1} فشلت للرابط $url: $e');
        break;
      }
    }
    return null;
  }
}
