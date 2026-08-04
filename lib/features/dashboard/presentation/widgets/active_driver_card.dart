import 'package:flutter/material.dart';
import '../../data/models/active_trip_model.dart';

class ActiveDriverCard extends StatelessWidget {
  final ActiveTripModel trip; // تم التعديل هنا ليتطابق مع الموديل الجديد
  final VoidCallback onTapInspect;

  const ActiveDriverCard({
    super.key,
    required this.trip,
    required this.onTapInspect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTapInspect,
        borderRadius: BorderRadius.circular(16),
        hoverColor: const Color(0xFFEFF6FF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ترويسة السائق
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(trip.driverAvatar),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.driverName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          trip.driverPhone,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      trip.carPlate,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // بيانات المركبة والموقع
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(trip.carModel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Flexible(
                      child: Text(
                        trip.currentLocationName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // العدادات الثلاثية
              Row(
                children: [
                  Expanded(child: _buildStatusBadge('🚖 راكب معاه', '${trip.ridingCount} أطفال', const Color(0xFFECFDF5), const Color(0xFFA7F3D0), const Color(0xFF065F46))),
                  const SizedBox(width: 6),
                  Expanded(child: _buildStatusBadge('⏳ ينتظر', '${trip.waitingCount} أطفال', const Color(0xFFFFFBEB), const Color(0xFFFDE68A), const Color(0xFF92400E))),
                  const SizedBox(width: 6),
                  Expanded(child: _buildStatusBadge('✅ وصل', '${trip.arrivedCount} أطفال', const Color(0xFFEFF6FF), const Color(0xFFBFDBFE), const Color(0xFF1E40AF))),
                ],
              ),
              const SizedBox(height: 12),

              // زر الفحص
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTapInspect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF60A5FA)),
                  label: const Text('عرض ركاب الرحلة الذكية', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String title, String count, Color bgColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 2),
          Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: textColor)),
        ],
      ),
    );
  }
}