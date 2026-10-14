import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/report_export_model.dart';
import '../../data/models/report_filters.dart';
import '../../logic/cubit/reports_cubit.dart';
import '../../logic/state/reports_state.dart';
import '../widget/report_export_dialog.dart';

/// منطق عرض التصدير المشترك بين شاشات التقارير، في مكان واحد لا يتكرر.
///
/// الحوار يجمع الاختيارات فقط، والتنفيذ والحفظ يمران عبر [ReportsCubit].

/// يفتح حوار إعداد التصدير ثم يفوّض التنفيذ للـ Cubit مع عرض مؤشر تحميل أنيق.
Future<void> openReportExportDialog(
  BuildContext context, {
  required String initialType,
  required ReportFilters filters,
}) async {
  final cubit = context.read<ReportsCubit>();

  final request = await showDialog<ReportExportRequest>(
    context: context,
    builder: (_) => ReportExportDialog(
      initialType: initialType,
      initialFilters: filters,
    ),
  );

  if (request == null) {
    cubit.restorePreviousReportState();
    return;
  }

  if (!context.mounted) return;

  // عرض مؤشر تحميل صريح للمستخدم أثناء توليد ملف الـ PDF وتنزيله
  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: ctx.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ctx.borderSoft),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(ctx.primaryColor),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'جارٍ توليد وتجهيز مستند الـ PDF المنظم…',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ctx.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  try {
    await cubit.exportReport(
      type: request.type,
      format: request.format,
      filters: request.filters,
    );
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

/// يستجيب لحالات التصدير والحفظ ويعرض رسائل الخادم أو النظام كما هي.
void handleReportExportState(BuildContext context, ReportsState state) {
  if (state is ReportExportSuccess) {
    _showExportResult(context, state.export);
  } else if (state is ReportExportError) {
    showAdminSnackBar(context, state.message, isError: true);
    context.read<ReportsCubit>().restorePreviousReportState();
  } else if (state is ReportExportSaved) {
    showAdminSnackBar(
      context,
      state.path == null
          ? 'تم تنزيل ملف "${state.export.fileName}" في مجلد التنزيلات بنجاح.'
          : 'تم حفظ الملف في: ${state.path}',
      isError: false,
    );
  } else if (state is ReportExportSaveError) {
    showAdminSnackBar(context, state.message, isError: true);
  }
}

/// يعرض حوار نتيجة التصدير ويبقيه متزامناً مع حالة الحفظ في الـ Cubit،
/// وعند إغلاقه يعيد فوراً محتوى الشاشة الأساسية دون أي تفريغ.
void _showExportResult(BuildContext context, ReportExportModel export) async {
  final cubit = context.read<ReportsCubit>();

  await showDialog(
    context: context,
    builder: (_) => BlocProvider<ReportsCubit>.value(
      value: cubit,
      child: BlocBuilder<ReportsCubit, ReportsState>(
        buildWhen: (_, state) =>
            state is ReportExportSaving ||
            state is ReportExportSaved ||
            state is ReportExportSaveCancelled ||
            state is ReportExportSaveError,
        builder: (dialogContext, state) {
          return ReportExportResultDialog(
            export: export,
            isSaving: state is ReportExportSaving,
            onSave: () =>
                dialogContext.read<ReportsCubit>().saveExportedReport(export),
          );
        },
      ),
    ),
  );

  // استعادة حالة الشاشة السابقة لضمان بقاء البيانات معروضة
  cubit.restorePreviousReportState();
}
