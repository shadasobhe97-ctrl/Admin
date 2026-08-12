import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/report_export_model.dart';
import '../../data/models/report_filters.dart';
import '../../logic/cubit/reports_cubit.dart';
import '../../logic/state/reports_state.dart';
import '../widget/report_export_dialog.dart';

/// منطق عرض التصدير المشترك بين شاشات التقارير، في مكان واحد لا يتكرر.
///
/// الحوار يجمع الاختيارات فقط، والتنفيذ والحفظ يمران عبر [ReportsCubit].

/// يفتح حوار إعداد التصدير ثم يفوّض التنفيذ للـ Cubit.
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

  if (request == null) return;

  await cubit.exportReport(
    type: request.type,
    format: request.format,
    filters: request.filters,
  );
}

/// يستجيب لحالات التصدير والحفظ ويعرض رسائل الخادم أو النظام كما هي.
void handleReportExportState(BuildContext context, ReportsState state) {
  if (state is ReportExportSuccess) {
    _showExportResult(context, state.export);
  } else if (state is ReportExportError) {
    showAdminSnackBar(context, state.message, isError: true);
  } else if (state is ReportExportSaved) {
    showAdminSnackBar(
      context,
      state.path == null
          ? 'تم تنزيل الملف "${state.export.fileName}".'
          : 'تم حفظ الملف في: ${state.path}',
      isError: false,
    );
  } else if (state is ReportExportSaveError) {
    showAdminSnackBar(context, state.message, isError: true);
  }
  // إلغاء المستخدم لنافذة الحفظ ليس خطأً، فلا تُعرض له أي رسالة.
}

/// يعرض حوار نتيجة التصدير ويبقيه متزامناً مع حالة الحفظ في الـ Cubit.
void _showExportResult(BuildContext context, ReportExportModel export) {
  final cubit = context.read<ReportsCubit>();

  showDialog(
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
}
