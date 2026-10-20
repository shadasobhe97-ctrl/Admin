import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/active_trip_model.dart';

/// خدمة التتبع اللحظي للرادار عبر Firebase Firestore
/// تطبق المعمارية الهجينة:
/// 1. دمج الإحداثيات والسرعة والزاوية الحية من كولكشن `trips_tracking`.
/// 2. إشعار الـ Cubit بأي خطأ لتفعيل الـ Polling الاحتياطي (Fallback).
class RadarTrackingService {
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  RadarTrackingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// بدء الاستماع اللحظي إلى مجموعة `trips_tracking`
  void startTracking({
    required Map<int, ActiveTripModel> currentTrips,
    required void Function(List<ActiveTripModel> updatedTrips) onTripsUpdated,
    required void Function(dynamic error) onError,
  }) {
    stopTracking();

    try {
      final query = _firestore
          .collection('trips_tracking')
          .where('status', isEqualTo: 'active');

      _subscription = query.snapshots().listen(
        (snapshot) {
          final updatedMap = Map<int, ActiveTripModel>.from(currentTrips);

          for (final change in snapshot.docChanges) {
            final data = change.doc.data();
            if (data == null) continue;

            final rawTripId = data['trip_id'] ?? change.doc.id;
            final tripId = int.tryParse(rawTripId.toString()) ?? 0;
            if (tripId == 0) continue;

            final status = (data['status'] ?? '').toString().toLowerCase();
            final isOnline = data['is_online'] == true ||
                data['is_online'].toString() == '1' ||
                data['is_online'].toString() == 'true';

            // إذا أصبحت الرحلة مكتملة أو غير متصلة أو حُذفت الوثيقة، تُزال من الرادار
            if (change.type == DocumentChangeType.removed ||
                status == 'completed' ||
                !isOnline) {
              updatedMap.remove(tripId);
              continue;
            }

            // قراءة الإحداثيات والزاوية والسرعة
            double? lat;
            if (data['driver_lat'] != null) {
              lat = double.tryParse(data['driver_lat'].toString());
            } else if (data['lat'] != null) {
              lat = double.tryParse(data['lat'].toString());
            }

            double? lng;
            if (data['driver_lng'] != null) {
              lng = double.tryParse(data['driver_lng'].toString());
            } else if (data['lng'] != null) {
              lng = double.tryParse(data['lng'].toString());
            }

            double? heading;
            if (data['heading'] != null) {
              heading = double.tryParse(data['heading'].toString());
            }

            int? speedKmH;
            if (data['speed'] != null) {
              if (data['speed'] is num) {
                speedKmH = (data['speed'] as num).round();
              } else {
                final match = RegExp(r'\d+').firstMatch(data['speed'].toString());
                if (match != null) {
                  speedKmH = int.tryParse(match.group(0)!);
                }
              }
            }

            DateTime? updatedAt;
            if (data['updated_at'] != null) {
              updatedAt = DateTime.tryParse(data['updated_at'].toString());
            }

            final existingTrip = updatedMap[tripId];
            if (existingTrip != null) {
              // تحديث الرحلة القائمة بالبيانات اللحظية مع الاحتفاظ ببيانات السائق والأطفال
              updatedMap[tripId] = existingTrip.copyWith(
                currentLat: lat ?? existingTrip.currentLat,
                currentLng: lng ?? existingTrip.currentLng,
                heading: heading ?? existingTrip.heading,
                speedKmH: speedKmH ?? existingTrip.speedKmH,
                isOnline: isOnline,
                lastUpdate: 'الآن (بث حي)',
                updatedAt: updatedAt ?? DateTime.now(),
              );
            } else if (lat != null && lng != null) {
              // إضافة رحلة جديدة دخلت الخدمة للتو
              updatedMap[tripId] = ActiveTripModel(
                tripId: tripId,
                driverId: int.tryParse(data['driver_id']?.toString() ?? '0') ?? 0,
                driverName: data['driver_name']?.toString() ?? 'سائق في الخدمة',
                status: 'in_progress',
                currentLat: lat,
                currentLng: lng,
                studentsCount: int.tryParse(data['students_count']?.toString() ?? '0') ?? 0,
                startedAt: 'الآن',
                heading: heading ?? 0.0,
                speedKmH: speedKmH ?? 0,
                isOnline: isOnline,
                lastUpdate: 'الآن (بث حي)',
                updatedAt: updatedAt ?? DateTime.now(),
              );
            }
          }

          // مزامنة الـ Map المرجعي وإرسال القائمة المحدثة
          currentTrips
            ..clear()
            ..addAll(updatedMap);
          onTripsUpdated(updatedMap.values.toList());
        },
        onError: (err) {
          debugPrint('⚠️ [RadarTrackingService] Firestore listener error: $err');
          onError(err);
        },
      );
    } catch (e) {
      debugPrint('⚠️ [RadarTrackingService] Failed to initialize Firestore listener: $e');
      onError(e);
    }
  }

  /// إيقاف الاستماع اللحظي
  void stopTracking() {
    _subscription?.cancel();
    _subscription = null;
  }
}
