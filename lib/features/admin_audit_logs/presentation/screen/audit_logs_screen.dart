import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../logic/cubit/audit_logs_cubit.dart';
import '../../logic/state/audit_logs_state.dart';
import '../widget/audit_log_card.dart';
import '../widget/audit_log_filter_bar.dart';
import 'audit_log_details_screen.dart';

/// معرّف دور الأدمن العام حسب عقد الخادم — السجل مخصّص له وحده.
const int _superAdminRoleId = 1;

/// سجل إجراءات المشرفين — يُفتح من «إدارة المشرفين» وللأدمن فقط.
class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل إجراءات المشرفين'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocProvider<AuditLogsCubit>(
            create: (_) => sl<AuditLogsCubit>()..loadLogs(),
            child: const AuditLogsView(),
          ),
        ),
      ),
    );
  }
}

class AuditLogsView extends StatelessWidget {
  const AuditLogsView({super.key});

  void _openDetails(BuildContext context, int logId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AuditLogDetailsScreen(logId: logId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuditLogsCubit, AuditLogsState>(
      builder: (context, state) {
        final cubit = context.read<AuditLogsCubit>();
        final filters = switch (state) {
          AuditLogsLoaded() => state.filters,
          AuditLogsEmpty() => state.filters,
          _ => cubit.filters,
        };
        final isBusy = state is AuditLogsLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(state: state, isBusy: isBusy, onRefresh: cubit.refresh),
            const SizedBox(height: 14),
            AuditLogFilterBar(
              filters: filters,
              enabled: !isBusy,
              onSearch: cubit.search,
              onActionGroupChanged: cubit.filterByActionGroup,
              onEntityTypeChanged: cubit.filterByEntityType,
              onDateRangeSelected: cubit.changeDateRange,
              onDateRangeCleared: cubit.clearDateRange,
              onClearAll: cubit.clearAllFilters,
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AuditLogsState state) {
    final cubit = context.read<AuditLogsCubit>();

    if (state is AuditLogsLoading || state is AuditLogsInitial) {
      return const AdminLoadingView(message: 'جارٍ جلب سجل الإجراءات…');
    }

    if (state is AuditLogsError) {
      // 403 ليس خطأ تقنياً — يُعرض كرسالة صلاحية بلا زر إعادة محاولة.
      if (state.isForbidden) return _ForbiddenView(message: state.message);
      return AdminErrorView(message: state.message, onRetry: cubit.refresh);
    }

    if (state is AuditLogsEmpty) {
      return AdminEmptyView(
        icon: state.isFiltered
            ? Icons.search_off_rounded
            : Icons.history_toggle_off_rounded,
        message: state.isFiltered
            ? 'لا توجد إجراءات مطابقة للفلاتر الحالية'
            : 'لم تُسجَّل أي إجراءات بعد',
        hint: state.isFiltered
            ? 'جرّب توسيع نطاق التاريخ أو إلغاء الفلاتر.'
            : 'ستظهر هنا كل إجراءات المشرفين فور تنفيذها.',
        onRefresh: state.isFiltered ? cubit.clearAllFilters : cubit.refresh,
      );
    }

    if (state is AuditLogsLoaded) {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: state.result.items.length,
              itemBuilder: (_, index) {
                final log = state.result.items[index];
                return AuditLogCard(
                  log: log,
                  onTap: () => _openDetails(context, log.id),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          AdminPagination(
            meta: state.result.meta,
            onPageChanged: cubit.changePage,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _Header extends StatelessWidget {
  final AuditLogsState state;
  final bool isBusy;
  final VoidCallback onRefresh;

  const _Header({
    required this.state,
    required this.isBusy,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final total = state is AuditLogsLoaded
        ? (state as AuditLogsLoaded).result.meta.total
        : null;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'سجل إجراءات المشرفين',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  if (total != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.infoBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.infoBorder),
                      ),
                      child: Text(
                        '${AdminFormat.count(total)} إجراء',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: context.infoColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'كل قرارات وتعديلات وعمليات المشرفين — للقراءة فقط',
                style: TextStyle(fontSize: 11.5, color: context.textMuted),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'تحديث',
          onPressed: isBusy ? null : onRefresh,
          icon: Icon(
            Icons.refresh_rounded,
            size: 19,
            color: isBusy ? context.textTertiary : context.primaryColor,
          ),
        ),
      ],
    );
  }
}

/// عرض مخصّص لحالة 403 — رسالة صلاحية لا رسالة عطل.
class _ForbiddenView extends StatelessWidget {
  final String message;

  const _ForbiddenView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_person_rounded, size: 48, color: context.warningColor),
            const SizedBox(height: 14),
            Text(
              'صلاحية غير كافية',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// هل المستخدم الحالي أدمن عام؟ تُستعمل لإظهار مدخل السجل أو إخفائه.
///
/// الإخفاء تحسين لتجربة المستخدم فقط — الحماية الحقيقية على الخادم (403).
bool canViewAuditLogs() => StorageService.getRoleId() == _superAdminRoleId;
