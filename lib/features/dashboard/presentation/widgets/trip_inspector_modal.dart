import 'package:flutter/material.dart';
import '../../data/models/active_trip_model.dart';

class TripInspectorModal extends StatelessWidget {
  final ActiveTripModel trip; // تم التحديث إلى ActiveTripModel

  const TripInspectorModal({super.key, required this.trip});

  static void show(BuildContext context, ActiveTripModel trip) { // تم التحديث هنا أيضاً
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: TripInspectorModal(trip: trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // مؤشر السحب والترويسة
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(trip.driverAvatar),
                        radius: 24,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trip.driverName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          Text('${trip.carModel} • ${trip.carPlate}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),

        // قائمة الركاب (الأطفال)
        Expanded(
          child: trip.passengers.isEmpty
              ? const Center(child: Text('لا يوجد ركاب حالياً في هذه الرحلة', style: TextStyle(color: Color(0xFF94A3B8))))
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: trip.passengers.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 32),
                  itemBuilder: (context, index) {
                    final passenger = trip.passengers[index];
                    return Row(
                      children: [
                        // أيقونة الحالة
                        _buildStatusIcon(passenger.status),
                        const SizedBox(width: 16),
                        
                        // تفاصيل الطفل
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(passenger.childName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.school, size: 12, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4),
                                  Text(passenger.schoolName, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    passenger.status == 'وصل' ? passenger.dropoffLocation : passenger.pickupLocation, 
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // زر الاتصال بولي الأمر
                        IconButton(
                          onPressed: () {
                            // TODO: إضافة كود الاتصال بولي الأمر
                          },
                          icon: const Icon(Icons.phone, color: Color(0xFF10B981)),
                          tooltip: 'الاتصال بولي الأمر (${passenger.parentName})',
                        )
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(String status) {
    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (status) {
      case 'راكب':
        bgColor = const Color(0xFFECFDF5);
        iconColor = const Color(0xFF10B981);
        icon = Icons.directions_bus;
        break;
      case 'وصل':
        bgColor = const Color(0xFFEFF6FF);
        iconColor = const Color(0xFF3B82F6);
        icon = Icons.check_circle;
        break;
      default: // ينتظر
        bgColor = const Color(0xFFFFFBEB);
        iconColor = const Color(0xFFF59E0B);
        icon = Icons.access_time_filled;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}