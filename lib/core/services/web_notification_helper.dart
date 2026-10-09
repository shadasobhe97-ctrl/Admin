import 'web_notification_helper_stub.dart'
    if (dart.library.js_interop) 'web_notification_helper_web.dart'
    if (dart.library.html) 'web_notification_helper_web.dart';

class WebNotificationHelper {
  /// تشغيل صوت نغمة تنبيه احترافية عند وصول إشعار جديد في الويب
  static void playNotificationSound() {
    playNotificationSoundImpl();
  }

  /// إظهار إشعار سطح المكتب المنبثق من المتصفح أعلى الشاشة (Browser Desktop Notification)
  static void showWebDesktopNotification({
    required String title,
    required String body,
  }) {
    showWebDesktopNotificationImpl(title: title, body: body);
  }
}
