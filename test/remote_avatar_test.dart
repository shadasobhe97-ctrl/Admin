import 'dart:typed_data';

import 'package:admin_panel/core/services/storage_service.dart';
import 'package:admin_panel/core/widgets/remote_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// أصغر ملف PNG صالح (1×1 شفافة) لاختبار عرض البايتات المحلية.
final Uint8List _pngPixel = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  group('RemoteCircleAvatar', () {
    testWidgets('بلا رابط: تظهر الأحرف الأولى', (tester) async {
      await tester.pumpWidget(
        _wrap(const RemoteCircleAvatar(rawUrl: null, initials: 'مط')),
      );

      expect(find.text('مط'), findsOneWidget);
    });

    testWidgets('بلا رابط مع أيقونة بديلة: تظهر الأيقونة', (tester) async {
      await tester.pumpWidget(
        _wrap(const RemoteCircleAvatar(
          rawUrl: null,
          fallbackIcon: Icons.person_rounded,
        )),
      );

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('البايتات المحلية تُعرض فوراً دون شبكة', (tester) async {
      await tester.pumpWidget(
        _wrap(RemoteCircleAvatar(
          rawUrl: 'https://api.example.com/storage/avatar.jpg',
          initials: 'مط',
          bytes: _pngPixel,
        )),
      );
      await tester.pump();

      // الصورة المختارة لها الأولوية على الرابط البعيد.
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('مط'), findsNothing);
    });

    testWidgets('فشل الشبكة يعود إلى الأحرف الأولى لا إلى فراغ',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const RemoteCircleAvatar(
          rawUrl: 'https://api.example.com/storage/avatar.jpg',
          initials: 'مط',
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('مط'), findsOneWidget);
    });
  });

  group('StorageService — صورة الجلسة', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
    });

    test('حفظ الصورة يُخطر المستمعين', () async {
      final seen = <String?>[];
      void listener() => seen.add(StorageService.avatarUrlListenable.value);
      StorageService.avatarUrlListenable.addListener(listener);

      await StorageService.saveAvatarUrl('/storage/avatars/1.jpg');
      expect(StorageService.getAvatarUrl(), '/storage/avatars/1.jpg');
      expect(seen, contains('/storage/avatars/1.jpg'));

      StorageService.avatarUrlListenable.removeListener(listener);
    });

    test('القيمة الفارغة تمسح الصورة المخزّنة', () async {
      await StorageService.saveAvatarUrl('/storage/avatars/1.jpg');
      await StorageService.saveAvatarUrl('   ');

      expect(StorageService.getAvatarUrl(), isNull);
      expect(StorageService.avatarUrlListenable.value, isNull);
    });

    test('رفع صورة جديدة يغيّر الرابط المعروض رغم ثبات المسار', () async {
      const samePath = '/storage/avatars/1.jpg';

      await StorageService.saveAvatarUrl(samePath);
      final first = StorageService.avatarUrlListenable.value;

      // الخادم يعيد المسار نفسه بعد الرفع؛ بصمة الوقت هي ما يكسر
      // ذاكرة الصور ويُخطر الشريط الجانبي بالتغيير.
      await StorageService.saveAvatarUrl(samePath, bustCache: true);
      final second = StorageService.avatarUrlListenable.value;

      expect(second, isNot(first));
      expect(second, startsWith(samePath));
      expect(second, contains('v='));
      // المخزَّن يبقى نظيفاً بلا بصمة.
      expect(StorageService.getAvatarUrl(), samePath);
    });

    test('كل حفظ ببصمة ينتج رابطاً مختلفاً عن سابقه', () async {
      const samePath = '/storage/avatars/1.jpg';

      await StorageService.saveAvatarUrl(samePath, bustCache: true);
      final first = StorageService.avatarUrlListenable.value;
      await StorageService.saveAvatarUrl(samePath, bustCache: true);
      final second = StorageService.avatarUrlListenable.value;

      expect(first, isNotNull);
      expect(second, isNot(first));
    });

    test('تسجيل الخروج يمسح الصورة مع بقيّة الجلسة', () async {
      await StorageService.saveSession(
        token: 't',
        roleId: 1,
        userId: 5,
        userName: 'مشرف',
        userPhone: '0912345678',
        avatarUrl: '/storage/avatars/1.jpg',
      );
      expect(StorageService.getAvatarUrl(), '/storage/avatars/1.jpg');

      await StorageService.clearSession();
      expect(StorageService.getAvatarUrl(), isNull);
      expect(StorageService.avatarUrlListenable.value, isNull);
    });
  });
}
