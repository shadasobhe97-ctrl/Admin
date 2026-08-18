import 'package:admin_panel/features/drivers_management/data/models/driver_model.dart';
import 'package:admin_panel/features/drivers_management/data/models/update_driver_payload.dart';
import 'package:flutter_test/flutter_test.dart';

DriverModel _driver() => DriverModel(
      id: 8,
      fullName: 'مفتاح الزنتاني',
      phoneNumber: '0911111111',
      status: 'Pending',
      nationalId: '119880012345',
      licenseNumber: 'LY-4421',
      licenseExpiry: '2027-05-01',
      isActive: true,
    );

void main() {
  group('UpdateDriverPayload.diff — لا يُرسل إلا ما تغيّر', () {
    test('الحقول غير المتغيّرة لا تُرسل إطلاقاً', () {
      final original = _driver();
      final payload = UpdateDriverPayload.diff(
        original: original,
        reason: 'تصحيح بعد مطابقة الوثائق',
        fullName: original.fullName,
        phoneNumber: '0912233445', // الوحيد المتغيّر
        nationalId: original.nationalId,
        licenseNumber: original.licenseNumber,
        licenseExpiry: original.licenseExpiry,
        isActive: original.isActive,
      );

      final json = payload.toJson();
      expect(json['phone_number'], '0912233445');
      expect(json.containsKey('full_name'), isFalse);
      expect(json.containsKey('national_id'), isFalse);
      expect(json.containsKey('license_number'), isFalse);
      expect(json.containsKey('license_expiry'), isFalse);
      expect(json.containsKey('is_active'), isFalse);
      // السبب يُرسل دائماً
      expect(json['reason'], 'تصحيح بعد مطابقة الوثائق');
    });

    test('isEmpty صحيحة عندما لا يتغيّر أي حقل', () {
      final original = _driver();
      final payload = UpdateDriverPayload.diff(
        original: original,
        reason: 'بلا تغيير',
        fullName: original.fullName,
        phoneNumber: original.phoneNumber,
        nationalId: original.nationalId,
        licenseNumber: original.licenseNumber,
        licenseExpiry: original.licenseExpiry,
        isActive: original.isActive,
      );

      expect(payload.isEmpty, isTrue);
      expect(payload.changedFieldLabels, isEmpty);
    });

    test('تغيير عدة حقول يُدرجها كلها بأسماء العقد', () {
      final payload = UpdateDriverPayload.diff(
        original: _driver(),
        reason: 'تحديث الرخصة',
        fullName: 'مفتاح علي الزنتاني',
        phoneNumber: '0911111111',
        licenseNumber: 'LY-4428',
        licenseExpiry: '2028-01-15',
        isActive: false,
      );

      final json = payload.toJson();
      expect(json['full_name'], 'مفتاح علي الزنتاني');
      expect(json['license_number'], 'LY-4428');
      expect(json['license_expiry'], '2028-01-15');
      expect(json['is_active'], false);
      expect(json.containsKey('phone_number'), isFalse);

      expect(payload.changedFieldLabels, hasLength(4));
    });
  });

  group('DriverValidation — قواعد العقد', () {
    test('رقم الهاتف: 10 أرقام تبدأ بـ 09', () {
      expect(DriverValidation.validatePhone('0912233445'), isNull);
      expect(DriverValidation.validatePhone('0812233445'), isNotNull);
      expect(DriverValidation.validatePhone('091223344'), isNotNull);
      expect(DriverValidation.validatePhone('09122334455'), isNotNull);
      expect(DriverValidation.validatePhone(''), isNotNull);
    });

    test('الاسم مطلوب وبحد أقصى 150 حرفاً', () {
      expect(DriverValidation.validateFullName('مفتاح'), isNull);
      expect(DriverValidation.validateFullName('  '), isNotNull);
      expect(DriverValidation.validateFullName('م' * 151), isNotNull);
    });

    test('تاريخ الانتهاء اختياري لكن بصيغة YYYY-MM-DD عند إدخاله', () {
      expect(DriverValidation.validateOptionalDate(''), isNull);
      expect(DriverValidation.validateOptionalDate('2027-05-01'), isNull);
      expect(DriverValidation.validateOptionalDate('01-05-2027'), isNotNull);
      expect(DriverValidation.validateOptionalDate('2027-13-45'), isNotNull);
    });

    test('سبب التعديل إلزامي', () {
      expect(DriverValidation.validateReason(''), isNotNull);
      expect(DriverValidation.validateReason('   '), isNotNull);
      expect(DriverValidation.validateReason('خطأ'), isNotNull); // قصير جداً
      expect(DriverValidation.validateReason('تصحيح بعد المقابلة'), isNull);
    });
  });

  test('DriverModel يقرأ license_expiry من الخادم', () {
    final driver = DriverModel.fromJson({
      'id': 8,
      'full_name': 'مفتاح',
      'phone_number': '0911111111',
      'status': 'Pending',
      'license_expiry': '2027-05-01',
    });

    expect(driver.licenseExpiry, '2027-05-01');
  });
}
