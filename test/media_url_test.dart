import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/core/network/api_endpoints.dart';
import 'package:admin_panel/core/utils/media_url.dart';

void main() {
  group('MediaUrl.resolve', () {
    test('يترك الرابط المطلق كما هو', () {
      const absolute = 'https://cdn.example.com/storage/license.jpg';
      expect(MediaUrl.resolve(absolute), absolute);
    });

    test('يعيد null للمدخل الفارغ أو المسافات', () {
      expect(MediaUrl.resolve(null), isNull);
      expect(MediaUrl.resolve(''), isNull);
      expect(MediaUrl.resolve('   '), isNull);
    });

    test('يبني رابطاً مطلقاً من مسار نسبي بإسقاط لاحقة /api', () {
      final resolved = MediaUrl.resolve('/storage/docs/license.jpg');

      expect(resolved, isNotNull);
      expect(resolved, endsWith('/storage/docs/license.jpg'));
      expect(resolved, isNot(contains('/api/')));
      expect(resolved!.startsWith(ApiEndpoints.baseUrl.split('/api').first),
          isTrue);
    });

    test('يضيف الشرطة المائلة للمسار الذي لا يبدأ بها', () {
      expect(
        MediaUrl.resolve('storage/docs/id.png'),
        MediaUrl.resolve('/storage/docs/id.png'),
      );
    });
  });

  group('MediaUrl — نوع الملف', () {
    test('يتعرف على صيغ الصور مهما اختلفت حالة الأحرف', () {
      expect(MediaUrl.isImage('https://x.com/a.JPG'), isTrue);
      expect(MediaUrl.isImage('https://x.com/a.png?token=1'), isTrue);
      expect(MediaUrl.isImage('https://x.com/a.pdf'), isFalse);
      expect(MediaUrl.isImage('https://x.com/a.docx'), isFalse);
    });

    test('يعامل الرابط بلا امتداد كصورة لأن الوثائق صور في الغالب', () {
      expect(MediaUrl.isImage('https://x.com/files/91827'), isTrue);
    });

    test('يميّز ملفات PDF', () {
      expect(MediaUrl.isPdf('https://x.com/license.pdf'), isTrue);
      expect(MediaUrl.isPdf('https://x.com/license.pdf?v=2'), isTrue);
      expect(MediaUrl.isPdf('https://x.com/license.jpg'), isFalse);
    });
  });
}
