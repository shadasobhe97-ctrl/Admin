import 'package:flutter/material.dart';
import '../../data/models/active_trip_model.dart';
import '../../../../core/utils/admin_theme_context.dart';

class ActiveTripsTableWidget extends StatelessWidget {
  final List<ActiveTripModel> trips;

  const ActiveTripsTableWidget({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'رادار الرحلات الحية',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            if (trips.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'لا توجد رحلات حية حالياً.',
                    style: TextStyle(color: context.colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    context.primaryColor.withOpacity(0.1),
                  ),
                  columns: const [
                    DataColumn(label: Text('رقم الرحلة', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('اسم السائق', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('الأطفال', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('الوجهة', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('السرعة', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('المنطقة', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: trips.map((trip) {
                    return DataRow(
                      cells: [
                        DataCell(Text('#${trip.tripId}')),
                        DataCell(Text(trip.driverName)),
                        DataCell(Text(trip.kidsCount.toString())),
                        DataCell(Text(trip.destination)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(trip.speed, style: const TextStyle(color: Colors.blue)),
                          ),
                        ),
                        DataCell(Text(trip.region)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(trip.status, style: const TextStyle(color: Colors.green)),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
