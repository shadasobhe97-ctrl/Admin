class Validators {
  Validators._();

  /// التحقق من صيغة البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }

    final email = value.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  /// 1. 6 خانات على الأقل
  /// 2. تحتوي على حرف إنجليزي واحد على الأقل (A-Z أو a-z)
  /// 3. تحتوي على رقم واحد على الأقل (0-9)
  /// يظهر خطأ كامل فوري يشمل كافة الشروط معاً عند المخالفة.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    final hasMinLength = value.length >= 6;
    final hasEnglishLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);

    if (!hasMinLength || !hasEnglishLetter || !hasDigit) {
      return 'كلمة المرور يجب أن تتكون من 6 خانات على الأقل،\n'
          'وتحتوي على حرف إنجليزي ورقم على الأقل';
    }
    return null;
  }
}
