import 'package:flutter/foundation.dart';
import 'dart:js_interop';

@JS('eval')
external void _eval(String code);

class WebNotificationHelper {
  /// تشغيل صوت نغمة تنبيه احترافية عند وصول إشعار جديد في الويب
  static void playNotificationSound() {
    if (!kIsWeb) return;
    try {
      _eval('''
        (function() {
          try {
            var AudioContext = window.AudioContext || window.webkitAudioContext;
            if (!AudioContext) return;
            var ctx = new AudioContext();
            if (ctx.state === 'suspended') {
              ctx.resume();
            }
            var now = ctx.currentTime;

            var osc1 = ctx.createOscillator();
            var gain1 = ctx.createGain();
            osc1.type = 'sine';
            osc1.frequency.setValueAtTime(659.25, now);
            gain1.gain.setValueAtTime(0.15, now);
            gain1.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
            osc1.connect(gain1);
            gain1.connect(ctx.destination);
            osc1.start(now);
            osc1.stop(now + 0.25);

            var osc2 = ctx.createOscillator();
            var gain2 = ctx.createGain();
            osc2.type = 'sine';
            osc2.frequency.setValueAtTime(880.0, now + 0.12);
            gain2.gain.setValueAtTime(0.20, now + 0.12);
            gain2.gain.exponentialRampToValueAtTime(0.001, now + 0.45);
            osc2.connect(gain2);
            gain2.connect(ctx.destination);
            osc2.start(now + 0.12);
            osc2.stop(now + 0.45);
          } catch(e){}
        })();
      ''');
    } catch (e) {
      debugPrint('⚠️ Web audio chime error: $e');
    }
  }

  /// إظهار إشعار سطح المكتب المنبثق من المتصفح أعلى الشاشة (Browser Desktop Notification)
  static void showWebDesktopNotification({
    required String title,
    required String body,
  }) {
    if (!kIsWeb) return;
    try {
      final safeTitle = title.replaceAll("'", "\\'").replaceAll("\n", " ");
      final safeBody = body.replaceAll("'", "\\'").replaceAll("\n", " ");

      _eval('''
        (function() {
          try {
            if (window.Notification && Notification.permission === 'granted') {
              new Notification('$safeTitle', {
                body: '$safeBody',
                icon: '/favicon.png',
                tag: 'darby_notif_' + Date.now()
              });
            }
          } catch(e){}
        })();
      ''');
    } catch (e) {
      debugPrint('⚠️ Web desktop notification error: $e');
    }
  }
}
