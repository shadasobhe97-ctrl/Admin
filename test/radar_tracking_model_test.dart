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
  });
}
