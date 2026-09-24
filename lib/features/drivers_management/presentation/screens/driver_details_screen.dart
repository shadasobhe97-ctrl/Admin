import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/permissions/authorization_service.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/widgets/image_viewer_dialog.dart';
import '../../../../core/widgets/remote_image.dart';
import '../../data/models/driver_details_model.dart';
import '../../data/models/driver_model.dart';
import '../../data/models/update_driver_payload.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_document_tile.dart';
import '../widgets/driver_edit_dialog.dart';
import '../widgets/driver_identity_card.dart';
import '../widgets/driver_review_dialog.dart';
import '../widgets/driver_statistics_row.dart';
import '../widgets/driver_vehicle_card.dart';

/// تفاصيل السائق الكاملة: الحساب، المركبة، الوثائق، والإحصاءات.
///
/// كل الوثائق وصور المركبة والحساب قابلة للنقر لعرضها بالحجم الكامل،
/// في كل حالات السائق دون استثناء.
class DriverDetailsScreen extends StatelessWidget {
  final int driverId;

  const DriverDetailsScreen({super.key, required this.driverId});

  static void show(BuildContext context, int driverId) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) =>
            sl<DriversManagementCubit>()..fetchDriverDetails(driverId),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            child: DriverDetailsScreen(driverId: driverId),
          ),
        ),
      ),
    );
  }

  void _openReviewDialog(BuildContext context, DriverModel driver) {
    final cubit = context.read<DriversManagementCubit>();
    showDialog(
      context: context,
      builder: (_) => DriverReviewDialog(
        driverName: driver.fullName,
        onSubmit: (status, reason) {
          cubit.reviewDriver(
            id: driverId,
            status: status,
            rejectionReason: reason,
          );
        },
        onEditData: () =>
            _openEditDialog(context, driver, returnToReview: true),
      ),
    );
  }

  /// يفتح نموذج التعديل ثم يحفظ عبر `PUT /admin/drivers/{id}`.
  ///
  /// [returnToReview] يعيد فتح حوار الاعتماد بعد الحفظ — يُستخدم عندما يأتي
  /// التعديل من داخل تدفّق المراجعة، لا من زر التعديل المباشر.
  Future<void> _openEditDialog(
    BuildContext context,
    DriverModel driver, {
    bool returnToReview = false,
  }) async {
    final cubit = context.read<DriversManagementCubit>();

    final payload = await showDialog<UpdateDriverPayload>(
      context: context,
      builder: (_) => DriverEditDialog(
        driver: driver,
        details: cubit.state.selectedDriverDetails,
        isReviewFlow: returnToReview,
      ),
    );
    if (payload == null) return;

    final saved = await cubit.updateDriver(id: driverId, payload: payload);
    if (!saved || !returnToReview || !context.mounted) return;

    // بعد الحفظ يعود المشرف إلى قرار الاعتماد بالبيانات المصحّحة.
    final updated = cubit.state.selectedDriverDetails?.driver ?? driver;
    if (context.mounted) _openReviewDialog(context, updated);
  }

  void _openSuspendDialog(BuildContext context, DriverModel driver) {
    final cubit = context.read<DriversManagementCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.block_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('إيقاف حساب السائق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'هل أنت تأكد من إيقاف حساب السائق "${driver.fullName}"؟\nسيتم تعطيل دخول السائق واستقبال الرحلات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.suspendDriver(driver.id);
            },
            child: const Text('تأكيد الإيقاف', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openActivateDialog(BuildContext context, DriverModel driver) {
    final cubit = context.read<DriversManagementCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('إعادة تفعيل حساب السائق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'هل أنت تأكد من إعادة تفعيل حساب السائق "${driver.fullName}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.activateDriver(driver.id);
            },
            child: const Text('تأكيد التفعيل', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<DriversManagementCubit, DriversManagementState>(
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          final details = state.selectedDriverDetails;
          final driver = details?.driver;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.cardColor,
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
                          color: context.textPrimary,
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
                    SizedBox(
                      height: 280,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: context.primaryColor,
                        ),
                      ),
                    )
                  else if (driver == null || details == null)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('تعذر تحميل تفاصيل السائق من الخادم.'),
                      ),
                    )
                  else
                    _DriverBody(
                      details: details,
                      state: state,
                      onEdit: () => _openEditDialog(context, driver),
                      onReview: () => _openReviewDialog(context, driver),
                      onSuspend: () => _openSuspendDialog(context, driver),
                      onActivate: () => _openActivateDialog(context, driver),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DriverBody extends StatelessWidget {
  final DriverDetailsModel details;
  final DriversManagementState state;
  final VoidCallback onEdit;
  final VoidCallback onReview;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;

  const _DriverBody({
    required this.details,
    required this.state,
    required this.onEdit,
    required this.onReview,
    required this.onSuspend,
    required this.onActivate,
  });

  /// التعديل الكامل متاح ما دام السائق لم يُعتمد بعد.
  bool get _isPending =>
      details.driver.status.toLowerCase() == 'pending' ||
      details.driver.approvalStatus?.toLowerCase() == 'pending';

  bool get _isApproved =>
      details.driver.status.toLowerCase() == 'approved' ||
      details.driver.approvalStatus?.toLowerCase() == 'approved';

  bool get _isSuspended =>
      details.driver.status.toLowerCase() == 'suspended' ||
      !details.driver.isActive;

  @override
  Widget build(BuildContext context) {
    final driver = details.driver;
    final licenseImage = driver.resolvedLicenseImage;
    final busy = state.isUpdatingDriver || state.isSubmittingReview || state.isSuspendingOrActivating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. بطاقة بيانات السائق والحساب الشخصي ────────────────────────
        DriverIdentityCard(driver: driver),
        const SizedBox(height: 20),

        // ── 2. وثيقة رخصة القيادة الرسمية ─────────────────────────────────
        if (licenseImage != null && licenseImage.isNotEmpty)
          _LicenseImageTile(
            imageUrl: licenseImage,
            driverName: driver.fullName,
          ),

        // ── 3. الإحصاءات والأداء والموقع ─────────────────────────────────
        if (details.statistics != null) ...[
          const _SectionHeader(
            title: '📊 إحصاءات أداء السائق والموقع الجغرافي',
          ),
          DriverStatisticsRow(
            statistics: details.statistics!,
            location: details.location,
          ),
          const SizedBox(height: 20),
        ],

        // ── 4. حالة الذكاء الاصطناعي والمراقبة ────────────────────────────
        if (details.aiStatus != null) ...[
          const _SectionHeader(
            title: '🤖 حالة مراقبة الذكاء الاصطناعي والتنبيهات',
          ),
          _AiStatusCard(aiStatus: details.aiStatus!),
          const SizedBox(height: 20),
        ],

        // ── 5. الوثائق والمستندات الرسمية ─────────────────────────────────
        _SectionHeader(
          title: '📜 الوثائق والمستندات الرسمية',
          hint: details.documents.isNotEmpty
              ? '${details.documents.length} وثائق مرفوعة'
              : null,
        ),
        if (details.documents.isEmpty)
          const _EmptyBox(message: 'لا توجد وثائق أو مستندات مسجلة حالياً.')
        else
          ...details.documents.map(
            (doc) => DriverDocumentTile(
              document: doc,
              driverName: driver.fullName,
            ),
          ),
        const SizedBox(height: 20),

        // ── 6. المركبات المسجلة ──────────────────────────────────────────
        _SectionHeader(
          title: '🚘 بيانات المركبة المسجلة',
          hint: details.vehicles.length > 1
              ? '${details.vehicles.length} مركبات'
              : null,
        ),
        if (details.vehicles.isEmpty)
          const _EmptyBox(message: 'لا توجد بيانات مركبة مسجلة حالياً.')
        else
          ...details.vehicles.map(
            (vehicle) => DriverVehicleCard(vehicle: vehicle),
          ),
        const SizedBox(height: 20),

        // ── الإجراءات ───────────────────────────────────────────────────
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: BorderSide(color: context.dividerLine),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('إغلاق'),
            ),
            // تعديل مباشر لكامل بيانات السائق ما دام قيد الانتظار.
            if (_isPending && AuthorizationService.hasPermission('drivers.edit_data'))
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  side: BorderSide(color: context.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: busy ? null : onEdit,
                icon: state.isUpdatingDriver
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit_outlined, size: 16),
                label: const Text(
                  'تعديل بيانات السائق',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (_isPending && AuthorizationService.hasPermission('drivers.review_initial'))
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: busy ? null : onReview,
                icon: state.isSubmittingReview
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.rate_review_outlined, size: 16),
                label: const Text(
                  'اتخاذ قرار الاعتماد / الرفض',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            // زر إيقاف أو تفعيل حساب السائق
            if (_isSuspended)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: busy ? null : onActivate,
                icon: state.isSuspendingOrActivating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 16),
                label: const Text(
                  'إعادة تفعيل الحساب',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else if (_isApproved)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: busy ? null : onSuspend,
                icon: state.isSuspendingOrActivating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.block_rounded, size: 16),
                label: const Text(
                  'إيقاف حساب السائق',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? hint;

  const _SectionHeader({required this.title, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint!,
                style: TextStyle(fontSize: 11.5, color: context.textTertiary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String message;

  const _EmptyBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerLine),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 13, color: context.textSecondary),
      ),
    );
  }
}

class _LicenseImageTile extends StatelessWidget {
  final String imageUrl;
  final String driverName;

  const _LicenseImageTile({required this.imageUrl, required this.driverName});

  @override
  Widget build(BuildContext context) {
    final link = MediaUrl.resolve(imageUrl);
    if (link == null || link.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF1E293B)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.dividerLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_membership_rounded,
                  color: context.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'صورة رخصة القيادة الرسمية',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'اضغط لعرض الوثيقة بالحجم الكامل',
                style: TextStyle(fontSize: 11.5, color: context.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => ImageViewerDialog.show(
              context,
              title: 'صورة رخصة القيادة',
              subtitle: driverName,
              rawUrl: link,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.dividerLine),
              ),
              clipBehavior: Clip.antiAlias,
              child: RemoteImage(
                rawUrl: link,
                fallback: const Center(
                  child: Text('تعذر عرض صورة رخصة القيادة'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiStatusCard extends StatelessWidget {
  final DriverAiStatus aiStatus;

  const _AiStatusCard({required this.aiStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF1E293B)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: aiStatus.isSuspended
              ? Colors.red.withValues(alpha: 0.5)
              : context.dividerLine,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                aiStatus.isSuspended
                    ? Icons.report_problem_rounded
                    : Icons.smart_toy_outlined,
                color: aiStatus.isSuspended ? Colors.red : context.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                aiStatus.isSuspended
                    ? 'حساب السائق موقوف بواسطة نظام الذكاء الاصطناعي'
                    : 'مستقر - حالة السائق سليمة في نظام الذكاء الاصطناعي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color:
                      aiStatus.isSuspended ? Colors.red : context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _AiStatChip(
                label: 'متوسط التقييم',
                value: aiStatus.ratingAvg != null
                    ? '⭐ ${aiStatus.ratingAvg}'
                    : 'لا يوجد',
              ),
              const SizedBox(width: 10),
              _AiStatChip(
                label: 'التنبيهات النشطة',
                value: '${aiStatus.activeWarningsCount}',
                color: aiStatus.activeWarningsCount > 0 ? Colors.orange : null,
              ),
              const SizedBox(width: 10),
              _AiStatChip(
                label: 'مرات الإيقاف',
                value: '${aiStatus.suspensionCount}',
                color: aiStatus.suspensionCount > 0 ? Colors.red : null,
              ),
            ],
          ),
          if (aiStatus.isSuspended &&
              aiStatus.suspendedUntil != null &&
              aiStatus.suspendedUntil!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'موقوف حتى تاريخ: ${aiStatus.suspendedUntil}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
          if (aiStatus.lastIncidentAt != null &&
              aiStatus.lastIncidentAt!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'آخر حادثة مسجلة: ${aiStatus.lastIncidentAt}',
              style: TextStyle(fontSize: 12, color: context.textTertiary),
            ),
          ],
          if (aiStatus.aiLastResetAt != null &&
              aiStatus.aiLastResetAt!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'آخر إعادة ضبط للنظام: ${aiStatus.aiLastResetAt}',
              style: TextStyle(fontSize: 12, color: context.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

class _AiStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _AiStatChip({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: (color ?? context.textTertiary).withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: context.textTertiary),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color ?? context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
