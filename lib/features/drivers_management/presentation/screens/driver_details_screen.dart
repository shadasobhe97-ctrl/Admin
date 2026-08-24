import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/driver_details_model.dart';
import '../../data/models/driver_document_model.dart';
import '../../data/models/driver_model.dart';
import '../../data/models/update_driver_payload.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_document_tile.dart';
import '../widgets/driver_edit_dialog.dart';
import '../widgets/driver_identity_card.dart';
import '../widgets/driver_review_dialog.dart';
import '../widgets/driver_reviews_section.dart';
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

  const _DriverBody({
    required this.details,
    required this.state,
    required this.onEdit,
    required this.onReview,
  });

  /// التعديل الكامل متاح ما دام السائق لم يُعتمد بعد.
  bool get _isPending =>
      details.driver.status.toLowerCase() == 'pending' ||
      details.driver.approvalStatus?.toLowerCase() == 'pending';

  bool get _isApproved =>
      details.driver.status.toLowerCase() == 'approved' ||
      details.driver.approvalStatus?.toLowerCase() == 'approved';

  List<DriverDocumentModel> _getAllDocuments() {
    final existingDocs = details.documents;

    String normalizeKey(String rawType) {
      final upper = rawType.toUpperCase().replaceAll('-', '_');
      if (upper.contains('LICENSE')) return DriverDocumentField.license;
      if (upper.contains('LOGBOOK') || upper.contains('REGISTRATION')) {
        return DriverDocumentField.logbook;
      }
      if (upper.contains('INSURANCE')) return DriverDocumentField.insurance;
      if (upper.contains('BOOKLET')) return DriverDocumentField.bookletPage;
      if (upper.contains('STAMP')) return DriverDocumentField.stamp;
      if (upper.contains('TECHNICAL') || upper.contains('INSPECTION')) {
        return DriverDocumentField.technicalInspection;
      }
      return rawType;
    }

    final Map<String, DriverDocumentModel> docMap = {};
    final List<DriverDocumentModel> extraDocs = [];

    for (final doc in existingDocs) {
      final key = normalizeKey(doc.docType);
      if (DriverDocumentField.all.contains(key)) {
        docMap[key] = doc;
      } else {
        extraDocs.add(doc);
      }
    }

    String? findExpiry(String? Function(DriverDocumentModel doc) pick) {
      for (final doc in existingDocs) {
        final val = pick(doc);
        if (val != null && val.isNotEmpty) return val;
      }
      return null;
    }

    final List<DriverDocumentModel> result = [];

    for (final field in DriverDocumentField.all) {
      if (docMap.containsKey(field)) {
        result.add(docMap[field]!);
      } else {
        String? expiry;
        if (field == DriverDocumentField.license) {
          expiry = details.driver.licenseExpiry;
        } else if (field == DriverDocumentField.insurance) {
          expiry = findExpiry((d) => d.insuranceExpiry);
        } else if (field == DriverDocumentField.stamp) {
          expiry = findExpiry((d) => d.stampExpiry);
        } else if (field == DriverDocumentField.technicalInspection) {
          expiry = findExpiry((d) => d.technicalInspectionExpiry);
        }

        result.add(
          DriverDocumentModel(
            docType: field,
            fileUrl: '',
            status: 'not_uploaded',
            genericExpiry: expiry,
          ),
        );
      }
    }

    result.addAll(extraDocs);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final driver = details.driver;
    final docs = _getAllDocuments();
    final busy = state.isUpdatingDriver || state.isSubmittingReview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DriverIdentityCard(driver: driver),
        const SizedBox(height: 16),

        if (_isApproved && details.statistics != null) ...[
          DriverStatisticsRow(
            statistics: details.statistics!,
            location: details.location,
          ),
          const SizedBox(height: 20),
        ],

        // ── المركبات ────────────────────────────────────────────────────
        _SectionHeader(
          title: 'بيانات المركبة المسجلة',
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

        // ── الوثائق ─────────────────────────────────────────────────────
        const _SectionHeader(
          title: 'الوثائق الرسمية المستندة',
          hint: 'اضغط على الوثيقة لعرض الصورة',
        ),
        if (docs.isEmpty)
          const _EmptyBox(message: 'لا توجد وثائق رسمية مرفوعة حالياً.')
        else
          ...docs.map(
            (doc) => DriverDocumentTile(
              document: doc,
              driverName: driver.fullName,
            ),
          ),
        const SizedBox(height: 20),

        // ── سجل الاعتماد ────────────────────────────────────────────────
        if (details.approvalHistory.isNotEmpty) ...[
          const _SectionHeader(title: 'سجل قرارات الاعتماد'),
          ...details.approvalHistory.map(
            (entry) => _ApprovalHistoryTile(entry: entry),
          ),
          const SizedBox(height: 20),
        ],

        // ── التقييمات ───────────────────────────────────────────────────
        if (_isApproved && driver.isActive) ...[
          const _SectionHeader(
            title: '⭐ تقييمات وتعليقات أولياء الأمور والركاب',
          ),
          DriverReviewsSection(driverId: driver.id),
          const SizedBox(height: 24),
        ],

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
            if (_isPending)
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
            if (_isPending)
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

/// عنصر واحد من `approval_history` — شكله يختلف بين الإصدارات،
/// لذلك تُقرأ المفاتيح المتوقعة مع بديل نصي آمن.
class _ApprovalHistoryTile extends StatelessWidget {
  final Map<String, dynamic> entry;

  const _ApprovalHistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final action = entry['action'] ?? entry['status'] ?? entry['decision'];
    final by = entry['admin_name'] ?? entry['reviewed_by'] ?? entry['by'];
    final at = entry['created_at'] ?? entry['reviewed_at'] ?? entry['date'];
    final note = entry['reason'] ?? entry['note'] ?? entry['feedback'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.dividerLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history_rounded, size: 17, color: context.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action == null
                      ? 'إجراء مراجعة'
                      : DriverStatusValue.label(action.toString()),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                if (by != null || at != null)
                  Text(
                    [if (by != null) '$by', if (at != null) '$at'].join(' • '),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.textTertiary,
                    ),
                  ),
                if (note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$note',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
