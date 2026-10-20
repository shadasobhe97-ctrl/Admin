import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/dashboard/data/models/active_trip_model.dart';

void main() {
  group('ActiveTripModel Radar & Hybrid Telemetry Tests', () {
    test('parses backend JSON response with full telemetry properly', () {
      final sampleJson = {
        'id': 851,
        'trip_id': 851,
        'driver_id': 12,
        'name': 'أحمد المحمودي',
        'phone': '+218912345678',
        'avatar': 'https://example.com/avatar.jpg',
        'children': 'محمد و علي',
        'destination': 'مدرسة طرابلس المركزية',
        'duration': '15 دقيقة',
        'status': 'في الطريق للاستلام',
        'lat': 32.88720000,
        'lng': 13.19130000,
        'heading': 120.5,
        'speed': '35 كم/س',
        'is_online': true,
        'firestore_doc': 'trips_tracking/851',
        'map_x': 45.2,
        'map_y': 60.1,
        'region': 'حي الأندلس',
        'last_update': 'منذ دقيقة',
        'updated_at': DateTime.now().toIso8601String(),
      };

      final trip = ActiveTripModel.fromJson(sampleJson);

      expect(trip.tripId, 851);
      expect(trip.driverId, 12);
      expect(trip.driverName, 'أحمد المحمودي');
      expect(trip.driverPhone, '+218912345678');
      expect(trip.currentLat, 32.8872);
      expect(trip.currentLng, 13.1913);
      expect(trip.heading, 120.5);
      expect(trip.speedKmH, 35);
      expect(trip.isOnline, true);
      expect(trip.destination, 'مدرسة طرابلس المركزية');
      expect(trip.currentLocationName, 'حي الأندلس');
      expect(trip.passengers.length, 2);
      expect(trip.passengers.first.childName, 'محمد');
      expect(trip.passengers.last.childName, 'علي');
      expect(trip.isSignalWeak, false);
    });

    test('isSignalWeak returns true if signal is older than 2 minutes', () {
      final oldTrip = ActiveTripModel(
        tripId: 1,
        driverId: 1,
        driverName: 'سائق',
        status: 'active',
        currentLat: 32.0,
        currentLng: 13.0,
        studentsCount: 2,
        startedAt: '08:00',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 3)),
      );

      expect(oldTrip.isSignalWeak, true);
    });

    test('copyWith updates live fields without losing driver or passenger info', () {
      final original = ActiveTripModel(
        tripId: 851,
        driverId: 12,
        driverName: 'أحمد المحمودي',
        driverPhone: '+218912345678',
        status: 'in_progress',
        currentLat: 32.8872,
        currentLng: 13.1913,
        studentsCount: 3,
        startedAt: '08:00',
        heading: 0.0,
        speedKmH: 20,
        isOnline: true,
      );

      final updated = original.copyWith(
        currentLat: 32.8900,
        currentLng: 13.2000,
        heading: 90.0,
        speedKmH: 45,
      );

      expect(updated.driverName, 'أحمد المحمودي');
      expect(updated.driverPhone, '+218912345678');
      expect(updated.currentLat, 32.8900);
      expect(updated.currentLng, 13.2000);
      expect(updated.heading, 90.0);
      expect(updated.speedKmH, 45);
      expect(updated.isOnline, true);
    });
    test('parses backend children_details and rich trip metrics payload correctly', () {
      final backendJson = {
        "id": 1170,
        "trip_id": 1170,
        "driver_id": 909,
        "name": "فتحي عبدالناصر محمد المرابط",
        "phone": "0919000014",
        "avatar": "https://ui-avatars.com/api/?name=فتحي+المرابط",
        "children": "أحمد محمد علي الترهوني و طارق خالد الفيتوري وآخرين (5)",
        "children_details": [
          {
            "child_id": 3,
            "child_name": "أحمد محمد علي الترهوني",
            "parent_name": "محمد علي عبدالسلام الترهوني",
            "parent_phone": "0911111111",
            "school_name": "مدرسة زاوية الدهماني الثانوية للبنين",
            "status": "on_board",
            "status_label": "على متن الحافلة (مع السائق)"
          },
          {
            "child_id": 4,
            "child_name": "طارق خالد الفيتوري",
            "parent_name": "خالد أحمد  الفيتوري",
            "parent_phone": "0912222222",
            "school_name": "مدرسة النوفليين الأهلية النموذجية",
            "status": "on_board",
            "status_label": "على متن الحافلة (مع السائق)"
          },
          {
            "child_id": 46,
            "child_name": "لينا خالد إبراهيم الككلي",
            "parent_name": "خالد إبراهيم محمد الككلي",
            "parent_phone": "0917000003",
            "school_name": "مدرسة النصر النموذجية للتعليم الأساسي",
            "status": "on_board",
            "status_label": "على متن الحافلة (مع السائق)"
          },
          {
            "child_id": 45,
            "child_name": "عمر خالد إبراهيم الككلي",
            "parent_name": "خالد إبراهيم محمد الككلي",
            "parent_phone": "0917000003",
            "school_name": "مدرسة بن عاشور الابتدائية والإعدادية",
            "status": "pending",
            "status_label": "بانتظار الاستلام (لم يُصعد بعد)"
          },
        ],
        "total_children_count": 5,
        "children_on_board_count": 3,
        "pending_pickup_count": 1,
        "delivered_count": 1,
        "absent_count": 0,
        "destination": "مدرسة طرابلس المركزية...",
        "duration": "بدأت للتو",
        "status": "في الطريق للاستلام",
        "lat": 32.860111,
        "lng": 13.093078,
        "heading": null,
        "speed": "0 كم/س",
        "is_online": false,
        "firestore_doc": "trips_tracking/1170",
        "map_x": 21.8,
        "map_y": 46.4,
        "region": "قرقارش",
        "last_update": "منذ 18 ساعة"
      };

      final trip = ActiveTripModel.fromJson(backendJson);

      expect(trip.tripId, 1170);
      expect(trip.driverId, 909);
      expect(trip.driverName, 'فتحي عبدالناصر محمد المرابط');
      expect(trip.driverPhone, '0919000014');
      expect(trip.driverAvatar, 'https://ui-avatars.com/api/?name=فتحي+المرابط');
      expect(trip.region, 'قرقارش');
      expect(trip.duration, 'بدأت للتو');
      expect(trip.status, 'في الطريق للاستلام');
      expect(trip.totalChildrenCount, 5);
      expect(trip.childrenOnBoardCount, 3);
      expect(trip.pendingPickupCount, 1);
      expect(trip.deliveredCount, 1);
      expect(trip.absentCount, 0);
      expect(trip.ridingCount, 3);
      expect(trip.waitingCount, 1);
      expect(trip.arrivedCount, 1);
      expect(trip.absentStudentsCount, 0);

      // Verify children_details parsing
      expect(trip.passengers.length, 4);
      final p1 = trip.passengers[0];
      expect(p1.id, '3');
      expect(p1.childName, 'أحمد محمد علي الترهوني');
      expect(p1.parentName, 'محمد علي عبدالسلام الترهوني');
      expect(p1.parentPhone, '0911111111');
      expect(p1.schoolName, 'مدرسة زاوية الدهماني الثانوية للبنين');
      expect(p1.status, 'on_board');
      expect(p1.isOnBoard, true);
      expect(p1.displayStatus, 'على متن الحافلة (مع السائق)');

      final p4 = trip.passengers[3];
      expect(p4.id, '45');
      expect(p4.childName, 'عمر خالد إبراهيم الككلي');
      expect(p4.status, 'pending');
      expect(p4.isPending, true);
      expect(p4.displayStatus, 'بانتظار الاستلام (لم يُصعد بعد)');
    });
  });
}
