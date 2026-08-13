import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/cubit/complaints_cubit.dart';
import '../../logic/state/complaints_state.dart';
import '../widgets/complaint_action_dialog.dart';
import '../widgets/complaint_status_badge.dart';
import '../widgets/driver_complaints_history_widget.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final dynamic complaintId;
  final VoidCallback? onBack;

  const ComplaintDetailsScreen({
    super.key,
    required this.complaintId,
    this.onBack,
  });

  void _showActionDialog(
    BuildContext context, {
    required String action,
    required String driverName,
    required ComplaintsCubit cubit,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<ComplaintsCubit, ComplaintsState>(
            builder: (context, state) {
              return ComplaintActionDialog(
                action: action,
                driverName: driverName,
                isLoading: state.isActionLoading,
                onSubmit: (actionDetails) async {
                  final success = await cubit.reviewComplaint(
                    complaintId,
                    action: action,
                    actionDetails: actionDetails,
                  );
                  if (success && dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.successMessage ?? 'تم حفظ القرار الإداري بنجاح.',
                        ),
                        backgroundColor: context.successColor,
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintsCubit, ComplaintsState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: context.dangerColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isDetailsLoading && state.selectedComplaintDetails == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final complaint = state.selectedComplaintDetails;
        if (complaint == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: context.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  'تعذّر تحميل تفاصيل الشكوى المطلوبة.',
                  style: TextStyle(color: context.textMuted),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  child: const Text('العودة للقائمة'),
                ),
              ],
            ),
          );
        }

        final driverName = complaint.driver?.name ?? 'السائق';

        return Scaffold(
          backgroundColor: context.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: context.cardColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            ),
            title: Text(
              'تفاصيل الشكوى #${complaint.id}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: ComplaintStatusBadge(status: complaint.status),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Complaint Card Overview
                Card(
                  elevation: 0,
                  color: context.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: context.borderSoft),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        if (complaint.createdAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'تاريخ التقديم: ${complaint.createdAt}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: context.textMuted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Divider(color: context.borderSoft),
                        const SizedBox(height: 12),
                        Text(
                          'نص الشكوى / البلاغ:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          complaint.description,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Info Grid: SubmittedBy, Driver, Trip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reporter Info Card
                    Expanded(
                      child: _buildSectionCard(
                        context: context,
                        title: 'مقدم الشكوى',
                        icon: Icons.person_rounded,
                        children: [
                          _buildDetailRow(
                            context,
                            'الاسم',
                            complaint.submittedBy?.name ?? 'غير معروف',
                          ),
                          if (complaint.submittedBy?.phone != null)
                            _buildDetailRow(
                              context,
                              'رقم الهاتف',
                              complaint.submittedBy!.phone!,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Driver Info Card
                    Expanded(
                      child: _buildSectionCard(
                        context: context,
                        title: 'السائق المستهدف',
                        icon: Icons.directions_bus_rounded,
                        children: [
                          _buildDetailRow(
                            context,
                            'الاسم',
                            complaint.driver?.name ?? 'غير محدد',
                          ),
                          if (complaint.driver?.phone != null)
                            _buildDetailRow(
                              context,
                              'رقم الهاتف',
                              complaint.driver!.phone!,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Trip Info Card
                    Expanded(
                      child: _buildSectionCard(
                        context: context,
                        title: 'الرحلة المرتبطة',
                        icon: Icons.route_rounded,
                        children: [
                          _buildDetailRow(
                            context,
                            'رقم الرحلة',
                            complaint.trip != null
                                ? '#${complaint.trip!.id}'
                                : 'لا تتبع رحلة',
                          ),
                          if (complaint.trip != null)
                            _buildDetailRow(
                              context,
                              'حالة الرحلة',
                              complaint.trip!.status,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 3. Administrative Decisions Section
                Card(
                  elevation: 0,
                  color: context.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: complaint.status == 'pending'
                          ? context.warningBorder
                          : context.borderSoft,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.gavel_rounded,
                              color: complaint.status == 'pending'
                                  ? context.warningColor
                                  : context.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'القرار الإداري والمراجعة',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(color: context.borderSoft),
                        const SizedBox(height: 12),

                        if (complaint.status == 'pending') ...[
                          Text(
                            'هذه الشكوى قيد الانتظار لم يتم اتخاذ قرار فيها بعد. يرجى اختيار أحد القرارات التالية:',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // 1. Warning Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showActionDialog(
                                    context,
                                    action: 'warning',
                                    driverName: driverName,
                                    cubit: context.read<ComplaintsCubit>(),
                                  ),
                                  icon: const Icon(Icons.warning_amber_rounded),
                                  label: const Text('توجيه إنذار للسائق'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.warningColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // 2. Suspension Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showActionDialog(
                                    context,
                                    action: 'suspension',
                                    driverName: driverName,
                                    cubit: context.read<ComplaintsCubit>(),
                                  ),
                                  icon: const Icon(Icons.block_rounded),
                                  label: const Text('إيقاف حساب السائق'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.dangerColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // 3. Dismiss Button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showActionDialog(
                                    context,
                                    action: 'dismiss',
                                    driverName: driverName,
                                    cubit: context.read<ComplaintsCubit>(),
                                  ),
                                  icon: const Icon(Icons.close_rounded),
                                  label: const Text('تجاهل الشكوى'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: context.textSecondary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side:
                                        BorderSide(color: context.borderSoft),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Action Already Completed / Dismissed
                          Row(
                            children: [
                              Text(
                                'الإجراء المتخذ: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: context.textSecondary,
                                ),
                              ),
                              ComplaintActionBadge(
                                actionTaken: complaint.actionTaken,
                              ),
                            ],
                          ),
                          if (complaint.actionDetails != null &&
                              complaint.actionDetails!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              'تفاصيل وملاحظات القرار الإداري:',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: context.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                complaint.actionDetails!,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: context.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. Driver Complaint History Section
                DriverComplaintsHistoryWidget(
                  history: state.driverComplaintsHistory,
                  isLoading: state.isDriverHistoryLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: context.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: context.borderSoft),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11.5, color: context.textMuted),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
