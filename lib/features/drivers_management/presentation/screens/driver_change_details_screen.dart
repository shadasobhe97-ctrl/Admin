import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_change_comparison.dart';
import '../widgets/driver_change_review_dialog.dart';

class DriverChangeDetailsScreen extends StatelessWidget {
  final int changeId;

  const DriverChangeDetailsScreen({super.key, required this.changeId});

  static void show(BuildContext context, int changeId) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => sl<DriversManagementCubit>()..fetchPendingDriverChangeDetails(changeId),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            child: DriverChangeDetailsScreen(changeId: changeId),
          ),
        ),
      ),
    );
  }

  void _openReviewDialog(BuildContext context, String changeType) {
    final cubit = context.read<DriversManagementCubit>();
    showDialog(
      context: context,
      builder: (_) => DriverChangeReviewDialog(
        changeId: changeId,
        changeType: changeType,
        onSubmit: (decision, reason) async {
          final ok = await cubit.reviewDriverChange(
            id: changeId,
            decision: decision,
            rejectionReason: reason,
          );
          if (ok && context.mounted) {
            Navigator.pop(context);
          }
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
          final details = state.selectedChangeDetails;

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
                        'مقارنة طلب التعديل والمعاينة',
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
                  const SizedBox(height: 16),

                  if (state.isLoadingDetails)
                    SizedBox(
                      height: 250,
                      child: Center(
                        child: CircularProgressIndicator(color: context.primaryColor),
                      ),
                    )
                  else if (details == null)
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: const Center(
                        child: Text('تعذر تحميل تفاصيل طلب التعديل من الخادم.'),
                      ),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sync_alt_rounded, size: 28, color: context.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'طلب تعديل رقم: #${details.id} | السائق: ${details.driverName ?? "سائق #${details.driverId}"}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'الهاتف: ${details.driverPhone != null && details.driverPhone!.isNotEmpty ? details.driverPhone : "غير محدد"} | نوع التعديل: ${details.translatedType} | السائق ID: #${details.driverId ?? "-"}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textTertiary,
                                  ),
                                ),
                                if (details.rejectionReason != null && details.rejectionReason!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'سبب الرفض السابق: ${details.rejectionReason}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    DriverChangeComparisonWidget(
                      currentData: details.currentData,
                      proposedData: details.proposedData,
                    ),
                    const SizedBox(height: 24),

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
                            backgroundColor: context.primaryColor,
                            foregroundColor: context.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: state.isSubmittingReview
                              ? null
                              : () => _openReviewDialog(context, details.changeType ?? 'تعديل مركبة'),
                          icon: state.isSubmittingReview
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.fact_check_outlined, size: 16),
                          label: const Text('اتخاذ قرار التعديل', style: TextStyle(fontWeight: FontWeight.bold)),
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
