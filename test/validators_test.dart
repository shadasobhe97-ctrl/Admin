import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('returns error when email is null or empty', () {
      expect(Validators.validateEmail(null), 'الرجاء إدخال البريد الإلكتروني');
      expect(Validators.validateEmail(''), 'الرجاء إدخال البريد الإلكتروني');
      expect(Validators.validateEmail('   '), 'الرجاء إدخال البريد الإلكتروني');
    });

    test('returns error when email format is invalid', () {
      expect(Validators.validateEmail('invalidemail'), 'الرجاء إدخال بريد إلكتروني صحيح');
      expect(Validators.validateEmail('user@'), 'الرجاء إدخال بريد إلكتروني صحيح');
      expect(Validators.validateEmail('user@domain'), 'الرجاء إدخال بريد إلكتروني صحيح');
      expect(Validators.validateEmail('@domain.com'), 'الرجاء إدخال بريد إلكتروني صحيح');
    });

    test('returns null when email format is valid', () {
      expect(Validators.validateEmail('admin@darby.ly'), isNull);
      expect(Validators.validateEmail('user.name@sub.domain.com'), isNull);
    });
  });

  group('Validators - Password', () {
    test('returns error when password is null or empty', () {
      expect(Validators.validatePassword(null), 'الرجاء إدخال كلمة المرور');
      expect(Validators.validatePassword(''), 'الرجاء إدخال كلمة المرور');
    });

    const combinedError = 'كلمة المرور يجب أن تتكون من 6 خانات على الأقل،\n'
        'وتحتوي على حرف إنجليزي ورقم على الأقل';

    test('returns error when password is less than 6 characters', () {
      expect(
        Validators.validatePassword('A1b2c'),
        combinedError,
      );
    });

    test('returns error when password lacks an English letter', () {
      expect(
        Validators.validatePassword('123456'),
        combinedError,
      );
      expect(
        Validators.validatePassword('١٢٣٤٥٦'),
        combinedError,
      );
    });

    test('returns error when password lacks a digit', () {
      expect(
        Validators.validatePassword('Password'),
        combinedError,
      );
    });

    test('returns null when password satisfies all conditions', () {
      expect(Validators.validatePassword('Pass12'), isNull);
      expect(Validators.validatePassword('admin123'), isNull);
      expect(Validators.validatePassword('Pass1234!'), isNull);
    });
  });
}
