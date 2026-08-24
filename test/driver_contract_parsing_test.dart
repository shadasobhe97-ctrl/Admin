import 'package:admin_panel/features/drivers_management/data/models/driver_details_model.dart';
import 'package:admin_panel/features/drivers_management/data/models/driver_document_model.dart';
import 'package:admin_panel/features/drivers_management/data/models/driver_model.dart';
import 'package:admin_panel/features/drivers_management/data/models/update_driver_payload.dart';
import 'package:flutter_test/flutter_test.dart';

/// استجابة `GET|PUT /api/admin/drivers/{id}` كما وثّقها الخادم.
Map<String, dynamic> _detailsResponse() => {
      'success': true,
      'status': true,
      'message': 'تم تحديث بيانات السائق بنجاح.',
      'data': {
        'id': 42,
        'status': 'Pending',
        'national_id': '119880012345',
        'license_number': 'LY-4421',
        'license_expiry': '2027-12-31',
        'location': {'lat': null, 'lng': null, 'last_ping_at': null},
        'statistics': {
          'rating_avg': 5.0,
          'completed_trips_count': 0,
          'retention_rate': 100.0,
        },
        'user_account': {
          'user_id': 87,
          'full_name': 'محمد الطرابلسي',
          'phone_number': '0912345678',
          'is_active': false,
        },
        'vehicles': [
          {
            'id': 15,
            'brand': 'Toyota',
            'plate_number': 'TR-9988',
            'capacity_manual': 14,
            'has_ac': true,
            'vehicle_image_url':
                'https://api.example.com/storage/drivers/vehicles/xyz.jpg',
            'status': 'Pending',
            'is_verified': false,
          }
        ],
        'documents': [
          {
            'id': 106,
            'document_type': 'STAMP',
            'document_url':
                'https://api.example.com/storage/drivers/documents/stamp.jpg',
            'insurance_expiry_date': null,
            'stamp_expiry_date': '2027-08-01',
            'technical_inspection_expiry_date': null,
            'status': 'Pending',
            'feedback': null,
          }
        ],
        'approval_history': [],
      },
    };

void main() {
  group('DriverDetailsModel — عقد الخادم', () {
    test('يقرأ البيانات الشخصية من داخل user_account', () {
      final details = DriverDetailsModel.fromJson(_detailsResponse());

      expect(details.driver.id, 42);
      expect(details.driver.userId, 87);
      expect(details.driver.fullName, 'محمد الطرابلسي');
      expect(details.driver.phoneNumber, '0912345678');
      // `is_active` يأتي من الحساب لا من جذر السائق.
      expect(details.driver.isActive, isFalse);
      expect(details.driver.nationalId, '119880012345');
      expect(details.driver.licenseExpiry, '2027-12-31');
      expect(details.driver.status, 'Pending');
    });

    test('يقرأ المركبات من مصفوفة vehicles', () {
      final details = DriverDetailsModel.fromJson(_detailsResponse());

      expect(details.vehicles, hasLength(1));
      final vehicle = details.vehicle!;
      expect(vehicle.id, 15);
      expect(vehicle.brand, 'Toyota');
      expect(vehicle.plateNumber, 'TR-9988');
      expect(vehicle.capacity, 14);
      expect(vehicle.hasAc, isTrue);
      expect(vehicle.isVerified, isFalse);
      expect(vehicle.imageUrl, contains('vehicles/xyz.jpg'));
    });

    test('يقرأ الوثائق بمفاتيح document_type و document_url', () {
      final details = DriverDetailsModel.fromJson(_detailsResponse());

      expect(details.documents, hasLength(1));
      final doc = details.documents.first;
      expect(doc.id, 106);
      expect(doc.docType, 'STAMP');
      expect(doc.translatedType, 'الدمغ (إذن تجول)');
      expect(doc.fileUrl, contains('documents/stamp.jpg'));
      // تاريخ الانتهاء يُلتقط من الحقل المناسب للنوع.
      expect(doc.expiryDate, '2027-08-01');
    });

    test('يقرأ الإحصاءات والموقع', () {
      final details = DriverDetailsModel.fromJson(_detailsResponse());

      expect(details.statistics!.ratingAvg, 5.0);
      expect(details.statistics!.completedTripsCount, 0);
      expect(details.statistics!.retentionRate, 100.0);
      expect(details.location!.hasPosition, isFalse);
      expect(details.approvalHistory, isEmpty);
    });

    test('المركبة الموثّقة تُقدَّم على غيرها', () {
      final json = _detailsResponse();
      (json['data'] as Map<String, dynamic>)['vehicles'] = [
        {'id': 1, 'brand': 'A', 'plate_number': 'X', 'is_verified': false},
        {'id': 2, 'brand': 'B', 'plate_number': 'Y', 'is_verified': true},
      ];

      expect(DriverDetailsModel.fromJson(json).vehicle!.id, 2);
    });

    test('الشكل المسطّح لقائمة السائقين ما يزال مقروءاً', () {
      final driver = DriverModel.fromJson({
        'id': 42,
        'full_name': 'محمد الطرابلسي',
        'phone_number': '0912345678',
        'avatar_url': null,
        'status': 'Pending',
        'created_at': '2026-08-23 14:20',
      });

      expect(driver.fullName, 'محمد الطرابلسي');
      expect(driver.phoneNumber, '0912345678');
      expect(driver.avatarUrl, isNull);
      expect(driver.createdAt, '2026-08-23 14:20');
    });
  });

  group('UpdateDriverPayload — حقول المركبة والوثائق', () {
    test('حقول المركبة تُرسل بأسماء العقد مع vehicle_id', () {
      final details = DriverDetailsModel.fromJson(_detailsResponse());

      final payload = UpdateDriverPayload.diff(
        original: details.driver,
        details: details,
        reason: 'تحديث بعد الزيارة الميدانية',
        fullName: details.driver.fullName,
        phoneNumber: details.driver.phoneNumber,
        plateNumber: 'TR-1234',
        capacityManual: '20',
        year: '2019',
      );

      final fields = payload.toFields();
      expect(fields['plate_number'], 'TR-1234');
      expect(fields['capacity_manual'], '20');
      expect(fields['year'], '2019');
      // يُرسل معرّف المركبة ليعرف الخادم أيّ مركبة يحدّث.
      expect(fields['vehicle_id'], '15');
      expect(fields.containsKey('brand'), isFalse);
    });

    test('لا يُرسل vehicle_id عندما لا تتغيّر المركبة', () {
      final details = DriverDetailsModel.fromJson(_detailsResponse());

      final payload = UpdateDriverPayload.diff(
        original: details.driver,
        details: details,
        reason: 'تصحيح الاسم فقط',
        fullName: 'محمد علي الطرابلسي',
        phoneNumber: details.driver.phoneNumber,
        plateNumber: 'TR-9988', // نفس القيمة الحالية
      );

      final fields = payload.toFields();
      expect(fields['full_name'], 'محمد علي الطرابلسي');
      expect(fields.containsKey('vehicle_id'), isFalse);
      expect(fields.containsKey('plate_number'), isFalse);
    });

    test('تاريخ الطابع لا يُرسل إن ساوى القيمة الحالية في الوثائق', () {
      final details = DriverDetailsModel.fromJson(_detailsResponse());

      final unchanged = UpdateDriverPayload.diff(
        original: details.driver,
        details: details,
        reason: 'بلا تغيير في التواريخ',
        fullName: details.driver.fullName,
        phoneNumber: details.driver.phoneNumber,
        stampExpiry: '2027-08-01',
      );
      expect(unchanged.isEmpty, isTrue);

      final changed = UpdateDriverPayload.diff(
        original: details.driver,
        details: details,
        reason: 'تمديد الطابع',
        fullName: details.driver.fullName,
        phoneNumber: details.driver.phoneNumber,
        stampExpiry: '2028-08-01',
      );
      expect(changed.toFields()['stamp_expiry'], '2028-08-01');
    });

    test('الملفات المرفوعة تدخل في isEmpty وفي أسماء الحقول المتغيّرة', () {
      final details = DriverDetailsModel.fromJson(_detailsResponse());

      final payload = UpdateDriverPayload.diff(
        original: details.driver,
        details: details,
        reason: 'رفع طابع جديد',
        fullName: details.driver.fullName,
        phoneNumber: details.driver.phoneNumber,
        documents: {
          DriverDocumentField.stamp:
              const PickedUpload(bytes: [1, 2, 3], fileName: 'stamp.jpg'),
        },
      );

      expect(payload.isEmpty, isFalse);
      expect(payload.changedFieldLabels, contains('الدمغ (إذن تجول)'));
      expect(payload.toFormData().files.map((e) => e.key), contains('doc_stamp'));
    });

    test('القيم المنطقية تُرسل كـ 1/0 لأن multipart نصّي', () {
      final details = DriverDetailsModel.fromJson(_detailsResponse());

      final payload = UpdateDriverPayload.diff(
        original: details.driver,
        details: details,
        reason: 'تفعيل الحساب وإطفاء التكييف',
        fullName: details.driver.fullName,
        phoneNumber: details.driver.phoneNumber,
        isActive: true, // الحالي false
        hasAc: false, // الحالي true
      );

      final fields = payload.toFields();
      expect(fields['is_active'], '1');
      expect(fields['has_ac'], '0');
    });
  });

  group('DriverValidation — حدود المركبة', () {
    test('سنة الصنع بين 1980 والعام القادم', () {
      final nextYear = DateTime.now().year + 1;
      expect(DriverValidation.validateVehicleYear(''), isNull);
      expect(DriverValidation.validateVehicleYear('1980'), isNull);
      expect(DriverValidation.validateVehicleYear('$nextYear'), isNull);
      expect(DriverValidation.validateVehicleYear('1979'), isNotNull);
      expect(DriverValidation.validateVehicleYear('${nextYear + 1}'), isNotNull);
      expect(DriverValidation.validateVehicleYear('غير رقم'), isNotNull);
    });

    test('السعة بين 1 و60', () {
      expect(DriverValidation.validateCapacity(''), isNull);
      expect(DriverValidation.validateCapacity('1'), isNull);
      expect(DriverValidation.validateCapacity('60'), isNull);
      expect(DriverValidation.validateCapacity('0'), isNotNull);
      expect(DriverValidation.validateCapacity('61'), isNotNull);
    });
  });

  group('DriverDocumentModel — أنواع الوثائق', () {
    test('كل مفاتيح العقد لها اسم عربي', () {
      final types = {
        'LICENSE': 'رخصة القيادة',
        'LOGBOOK': 'كتيب المركبة (بيانات مالك المركبة)',
        'BOOKLET_PAGE': 'كتيب المركبة (أوصاف المركبة الآلية)',
        'INSURANCE': 'التأمين',
        'STAMP': 'الدمغ (إذن تجول)',
        'TECHNICAL_INSPECTION': 'الفحص الفني',
      };

      types.forEach((type, label) {
        final doc = DriverDocumentModel.fromJson({
          'document_type': type,
          'document_url': 'https://x.com/a.jpg',
          'status': 'Pending',
        });
        expect(doc.translatedType, label);
      });
    });
  });
}
