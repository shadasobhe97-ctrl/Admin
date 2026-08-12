import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_avatar.dart';
import '../widgets/driver_review_dialog.dart';
import '../widgets/driver_reviews_section.dart';
import '../widgets/driver_status_badge.dart';

class DriverDetailsScreen extends StatelessWidget {
  final int driverId;

  const DriverDetailsScreen({super.key, required this.driverId});

  static void show(BuildContext context, int driverId) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => sl<DriversManagementCubit>()..fetchDriverDetails(driverId),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            child: DriverDetailsScreen(driverId: driverId),
          ),
        ),
      ),
    );
  }

  void _openReviewDialog(BuildContext context, String driverName) {
    final cubit = context.read<DriversManagementCubit>();
    showDialog(
      context: context,
      builder: (_) => DriverReviewDialog(
        driverName: driverName,
        onSubmit: (status, reason) {
          cubit.reviewDriver(
            id: driverId,
            status: status,
            rejectionReason: reason,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<DriversManagementCubit, DriversManagementState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
          }
          if (state.successMessage != null && state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          final details = state.selectedDriverDetails;
          final driver = details?.driver;
          final docs = details?.documents ?? [];
          final vehicle = details?.vehicle;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تفاصيل السائق والوثائق الرسمية',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (state.isLoadingDetails)
                    const SizedBox(
                      height: 280,
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                      ),
                    )
                  else if (driver == null)
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: const Center(
                        child: Text('تعذر تحميل تفاصيل السائق من الخادم.'),
                      ),
                    )
                  else ...[
                    // Driver Info Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              DriverAvatar(
                                avatarUrl: driver.avatarUrl,
                                fullName: driver.fullName,
                                radius: 36,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driver.fullName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'رقم الهاتف: ${driver.phoneNumber} | معرّف (ID): #${driver.id}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DriverStatusBadge(status: driver.status),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Divider(height: 1, color: theme.dividerColor),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF2563EB)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'الرقم الوطني: ${driver.nationalId ?? "غير متوفر"}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.card_membership_rounded, size: 18, color: Color(0xFF2563EB)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'رقم الرخصة: ${driver.licenseNumber ?? "غير متوفر"}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Section
                    Text(
                      'بيانات المركبة المسجلة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (vehicle == null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: const Text('لا توجد بيانات مركبة مسجلة حالياً.'),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_bus_rounded, size: 36, color: Color(0xFF2563EB)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${vehicle.make} ${vehicle.model}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'رقم اللوحة: ${vehicle.plateNumber}${vehicle.year != null ? " | سنة: ${vehicle.year}" : ""}${vehicle.capacity != null ? " | السعة: ${vehicle.capacity} راكب" : ""}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Documents Section
                    Text(
                      'الوثائق الرسمية المستندة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (docs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: const Text('لا توجد وثائق رسمية مرفعوة حالياً.'),
                      )
                    else
                      ...docs.map((doc) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.description_outlined, size: 24, color: Color(0xFF2563EB)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.translatedType,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (doc.expiryDate != null)
                                      Text(
                                        'تاريخ الانتهاء: ${doc.expiryDate}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              DriverStatusBadge(status: doc.status),
                              if (doc.fileUrl.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.open_in_new_rounded, size: 18, color: Color(0xFF2563EB)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('رابط الوثيقة: ${doc.fileUrl}')),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 20),

                    // Driver Reviews Section (Only displayed if driver status is Approved and isActive)
                    if ((driver.status.toLowerCase() == 'approved' || driver.approvalStatus?.toLowerCase() == 'approved') && driver.isActive) ...[
                      Text(
                        '⭐ تقييمات وتعليقات أولياء الأمور والركاب',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DriverReviewsSection(driverId: driver.id),
                      const SizedBox(height: 24),
                    ],

                    // Actions Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            side: BorderSide(color: theme.dividerColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('إغلاق'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: state.isSubmittingReview
                              ? null
                              : () => _openReviewDialog(context, driver.fullName),
                          icon: state.isSubmittingReview
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.rate_review_outlined, size: 16),
                          label: const Text('اتخاذ قرار الاعتماد / الرفض', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
