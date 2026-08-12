import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../widget/audit_log_table.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../../../../core/widgets/admin_ui.dart';

/// سجل عمليات المشرفين المالية.
class FinancialAuditLogsScreen extends StatelessWidget {
  const FinancialAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadAuditLogs(),
      child: const _AuditLogsView(),
    );
  }
}

class _AuditLogsView extends StatefulWidget {
  const _AuditLogsView();

  @override
  State<_AuditLogsView> createState() => _AuditLogsViewState();
}

class _AuditLogsViewState extends State<_AuditLogsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    context.read<FinancialCubit>().loadAuditLogs(
          page: 1,
          search: _searchController.text.trim(),
        );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<FinancialCubit>().clearAuditSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل عمليات المشرفين المالية'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () => context.read<FinancialCubit>().loadAuditLogs(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminPanel(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'بحث في السجل',
                          prefixIcon: Icon(Icons.search_rounded, size: 18),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search_rounded, size: 16),
                      label: const Text('بحث'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      label: const Text('مسح'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<FinancialCubit, FinancialState>(
                  builder: (context, state) {
                    if (state is AuditLogsLoading || state is FinancialInitial) {
                      return const AdminLoadingView(
                        message: 'جارٍ جلب سجل العمليات من الخادم...',
                      );
                    }

                    if (state is AuditLogsEmpty) {
                      return AdminEmptyView(
                        message: 'لا توجد عمليات مسجّلة',
                        hint: state.search == null
                            ? 'لم يُسجَّل أي إجراء مالي من المشرفين بعد.'
                            : 'لا توجد نتائج مطابقة لكلمة البحث "${state.search}".',
                        icon: Icons.fact_check_rounded,
                        onRefresh: () =>
                            context.read<FinancialCubit>().loadAuditLogs(),
                      );
                    }

                    if (state is AuditLogsError) {
                      return AdminErrorView(
                        message: state.message,
                        onRetry: () =>
                            context.read<FinancialCubit>().loadAuditLogs(),
                      );
                    }

                    if (state is AuditLogsLoaded) {
                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: AuditLogTable(logs: state.result.items),
                            ),
                          ),
                          AdminPagination(
                            meta: state.result.meta,
                            onPageChanged: (page) => context
                                .read<FinancialCubit>()
                                .loadAuditLogs(page: page),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
