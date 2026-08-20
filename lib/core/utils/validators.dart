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

  /// التحقق من شروط كلمة المرور:
  /// 1. 8 أحرف على الأقل
  /// 2. تحتوي على حرف إنجليزي واحد على الأقل (كبير أو صغير)
  /// 3. تحتوي على رقم واحد على الأقل
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تتكون من 8 أحرف على الأقل';
    }

    final hasEnglishLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    if (!hasEnglishLetter) {
      return 'كلمة المرور يجب أن تحتوي على حرف إنجليزي واحد على الأقل (كبير أو صغير)';
    }

    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasDigit) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    return null;
  }
}
