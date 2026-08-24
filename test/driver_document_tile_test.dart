import 'package:admin_panel/core/widgets/image_viewer_dialog.dart';
import 'package:admin_panel/features/drivers_management/data/models/driver_document_model.dart';
import 'package:admin_panel/features/drivers_management/data/models/driver_model.dart';
import 'package:admin_panel/features/drivers_management/data/models/driver_vehicle_model.dart';
import 'package:admin_panel/features/drivers_management/presentation/widgets/driver_document_tile.dart';
import 'package:admin_panel/features/drivers_management/presentation/widgets/driver_identity_card.dart';
import 'package:admin_panel/features/drivers_management/presentation/widgets/driver_vehicle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// في بيئة الاختبار تفشل كل طلبات الشبكة، فتُختبر مسارات البديل تلقائياً.
Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

DriverDocumentModel _document({
  String type = 'LICENSE',
  String url = 'https://api.example.com/storage/license.jpg',
  String status = 'Approved',
}) =>
    DriverDocumentModel.fromJson({
      'id': 5,
      'document_type': type,
      'document_url': url,
      'status': status,
      'stamp_expiry_date': '2027-08-01',
    });

void main() {
  group('DriverDocumentTile', () {
    testWidgets('يعرض نوع الوثيقة وتاريخ انتهائها', (tester) async {
      await tester.pumpWidget(
        _wrap(DriverDocumentTile(
          document: _document(),
          driverName: 'محمد الطرابلسي',
        )),
      );

      expect(find.text('رخصة القيادة'), findsOneWidget);
      expect(find.text('تاريخ الانتهاء: 2027-08-01'), findsOneWidget);
    });

    testWidgets('النقر يفتح عارض الصورة — في حالة مقبول', (tester) async {
      await tester.pumpWidget(
        _wrap(DriverDocumentTile(
          document: _document(status: 'Approved'),
          driverName: 'محمد الطرابلسي',
        )),
      );

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.byType(ImageViewerDialog), findsOneWidget);
    });

    testWidgets('النقر يفتح عارض الصورة — في حالة مرفوض', (tester) async {
      await tester.pumpWidget(
        _wrap(DriverDocumentTile(
          document: _document(status: 'Rejected'),
          driverName: 'محمد الطرابلسي',
        )),
      );

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // العرض لا يرتبط بحالة الوثيقة أو السائق إطلاقاً.
      expect(find.byType(ImageViewerDialog), findsOneWidget);
    });

    testWidgets('بلا ملف: لا يفتح العارض ويوضّح السبب', (tester) async {
      await tester.pumpWidget(
        _wrap(DriverDocumentTile(
          document: _document(url: ''),
          driverName: 'محمد الطرابلسي',
        )),
      );

      expect(find.text('لا يوجد ملف مرفوع'), findsOneWidget);

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.byType(ImageViewerDialog), findsNothing);
    });
  });

  group('DriverIdentityCard', () {
    testWidgets('يعرض الاسم والأرقام الرسمية وحالة التفعيل', (tester) async {
      final driver = DriverModel.fromJson({
        'id': 42,
        'status': 'Pending',
        'national_id': '119880012345',
        'license_number': 'LY-4421',
        'license_expiry': '2027-12-31',
        'user_account': {
          'user_id': 87,
          'full_name': 'محمد الطرابلسي',
          'phone_number': '0912345678',
          'is_active': false,
        },
      });

      await tester.pumpWidget(_wrap(DriverIdentityCard(driver: driver)));

      expect(find.text('محمد الطرابلسي'), findsOneWidget);
      expect(find.text('الرقم الوطني: 119880012345'), findsOneWidget);
      expect(find.text('رقم الرخصة: LY-4421'), findsOneWidget);
      expect(find.text('انتهاء الرخصة: 2027-12-31'), findsOneWidget);
      expect(find.text('الحساب معطّل'), findsNothing);
    });

    testWidgets('بلا صورة: تظهر الأحرف الأولى مرة واحدة فقط', (tester) async {
      final driver = DriverModel.fromJson({
        'id': 1,
        'full_name': 'محمد الطرابلسي',
        'phone_number': '0912345678',
        'status': 'Pending',
      });

      await tester.pumpWidget(_wrap(DriverIdentityCard(driver: driver)));

      expect(find.text('ما'), findsOneWidget);
    });
  });

  group('DriverVehicleCard', () {
    testWidgets('يعرض بيانات المركبة كاملة', (tester) async {
      final vehicle = DriverVehicleModel.fromJson({
        'id': 15,
        'brand': 'Toyota',
        'model': 'Coaster',
        'plate_number': 'TR-9988',
        'capacity_manual': 14,
        'has_ac': true,
        'year': '2019',
        'status': 'Approved',
        'is_verified': true,
      });

      await tester.pumpWidget(_wrap(DriverVehicleCard(vehicle: vehicle)));

      expect(find.text('Toyota Coaster'), findsOneWidget);
      expect(find.textContaining('رقم اللوحة: TR-9988'), findsOneWidget);
      expect(find.textContaining('السعة: 14 راكب'), findsOneWidget);
      expect(find.textContaining('مكيّفة'), findsOneWidget);
      expect(find.text('مركبة موثّقة'), findsOneWidget);
    });

    testWidgets('النقر على صورة المركبة يفتح العارض', (tester) async {
      final vehicle = DriverVehicleModel.fromJson({
        'brand': 'Toyota',
        'model': 'Coaster',
        'plate_number': 'TR-9988',
        'vehicle_image_url': 'https://api.example.com/storage/bus.jpg',
      });

      await tester.pumpWidget(_wrap(DriverVehicleCard(vehicle: vehicle)));

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.byType(ImageViewerDialog), findsOneWidget);
    });
  });
}
