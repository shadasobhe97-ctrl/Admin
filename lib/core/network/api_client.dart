import 'package:dio/dio.dart';
import '../services/storage_service.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'ar',
          'Content-Type': 'application/json',
          'bypass-tunnel-reminder': 'true',
          'Bypass-Tunnel-Reminder': 'true',
        },
      ),
    );

    // إضافة Interceptor لتزويد الـ Bearer Token تلقائياً في كل الطلبات المحمية
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.post(path, data: data, queryParameters: queryParameters);
  }

  /// طلب GET يعيد المحتوى كبايتات خام، للملفات التي لا تكون JSON
  /// (مثل تصدير التقارير بصيغة CSV).
  Future<Response<List<int>>> download(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get<List<int>>(
      path,
      queryParameters: queryParameters,
      options: Options(responseType: ResponseType.bytes),
    );
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}
