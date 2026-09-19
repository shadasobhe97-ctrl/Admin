import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../di/service_locator.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'storage_service.dart';

/// خدمة إدارة إشعارات الويب للأدمن (FCM Web Push Notifications)
class AdminFcmService {
  static final AdminFcmService _instance = AdminFcmService._internal();
  factory AdminFcmService() => _instance;
  AdminFcmService._internal();

  bool _isInitialized = false;
  String? _currentFcmToken;

  String? get fcmToken => _currentFcmToken;

  /// تهيئة الفايربيز وتفعيل إشعارات الأدمن للويب
  Future<void> initAdminWebNotifications({String? vapidKey}) async {
    try {
      if (!_isInitialized) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _isInitialized = true;
      }

      final messaging = FirebaseMessaging.instance;

      // 1. طلب الصلاحية من المتصفح / النظام
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('🔔 notification permission granted');

        // 2. استخراج FCM Token مفتاح الويب
        final token = await messaging.getToken(
          vapidKey: vapidKey ??
              'BD72q-wL8vN-PlaceholderVapidKey-ReplaceIfCustomRequired',
        );

        if (token != null) {
          _currentFcmToken = token;
          debugPrint('✅ Admin FCM Web Token: $token');

          // أ) تسجيل التوكن لدى الـ Backend API
          await registerTokenToBackend(token);

          // ب) حفظ التوكن في الفايرستور ليصله إشعارات النظام والمحادثات
          await saveTokenToFirestore(token);
        }

        // 3. تجديد التوكن تلقائياً عند تغيّره
        messaging.onTokenRefresh.listen((newToken) async {
          _currentFcmToken = newToken;
          debugPrint('🔄 Admin FCM Token Refreshed: $newToken');
          await registerTokenToBackend(newToken);
          await saveTokenToFirestore(newToken);
        });

        // 4. الاستماع للإشعارات في الوقت الفعلي أثناء فتح اللوحة (Foreground)
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('🔔 Foreground Notification Received: ${message.notification?.title}');
          _handleForegroundNotification(message);
        });
      } else {
        debugPrint('⚠️ Notification permission declined by user');
      }
    } catch (e) {
      debugPrint('❌ Error setting up admin web notifications: $e');
    }
  }

  /// أ) رفع التوكن للسيرفر الرئيسي
  Future<void> registerTokenToBackend(String token) async {
    try {
      final authToken = StorageService.getToken();
      if (authToken == null || authToken.isEmpty) return;

      final apiClient = sl<ApiClient>();
      await apiClient.post(
        ApiEndpoints.deviceToken,
        data: {
          'fcm_token': token,
          'device_id': 'admin_web_browser',
          'device_name': 'Admin Web Browser',
          'platform': 'web',
          'app_version': '1.0.0',
        },
      );
      debugPrint('✅ FCM Token successfully registered to Backend API');
    } catch (e) {
      debugPrint('⚠️ Failed to register FCM token to Backend API: $e');
    }
  }

  /// ب) حفظ التوكن في Firestore تحت `users/admin_{adminId}`
  Future<void> saveTokenToFirestore(String token) async {
    try {
      final userId = StorageService.getUserId();
      if (userId == null) return;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc('admin_$userId');

      await docRef.set({
        'fcm_token': token,
        'role': StorageService.getRoleName() ?? 'admin',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ FCM Token successfully saved to Firestore (users/admin_$userId)');
    } catch (e) {
      debugPrint('⚠️ Failed to save FCM token to Firestore: $e');
    }
  }

  /// معالجة الإشعار الفوري أثناء التواجد بالشاشة
  void _handleForegroundNotification(RemoteMessage message) {
    // يمكن هنا إرسال الإشعار لـ Stream Controller أو البلوك لتحديث العدد وتنبيه المستخدم
  }
}
