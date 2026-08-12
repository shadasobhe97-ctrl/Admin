import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../data/models/ledger_entry_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../widget/ledger_filter_bar.dart';
import '../widget/ledger_table.dart';

/// سجل الحركات المالية (Immutable Ledger) مع الفلترة والتصفّح من الخادم.
class FinancialLedgerScreen extends StatelessWidget {
  const FinancialLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadLedger(),
      child: const _LedgerView(),
    );
  }
}

class _LedgerView extends StatelessWidget {
  const _LedgerView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل الحركات المالية'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () => context.read<FinancialCubit>().loadLedger(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: BlocBuilder<FinancialCubit, FinancialState>(
          builder: (context, state) {
            final cubit = context.read<FinancialCubit>();
            final filters = _filtersOf(state, cubit.ledgerFilters);

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LedgerFilterBar(
                    // المفتاح يعيد بناء الشريط عند إعادة تعيين الفلاتر برمجياً.
                    key: ValueKey(filters.hashCode),
                    filters: filters,
                    enabled: state is! LedgerLoading,
                    onApply: (newFilters) => cubit.loadLedger(filters: newFilters),
                    onReset: cubit.resetLedgerFilters,
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildBody(context, state, filters)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  LedgerFilters _filtersOf(FinancialState state, LedgerFilters fallback) {
    if (state is LedgerLoaded) return state.filters;
    if (state is LedgerEmpty) return state.filters;
    return fallback;
  }

  Widget _buildBody(
    BuildContext context,
    FinancialState state,
    LedgerFilters filters,
  ) {
    if (state is LedgerLoading || state is FinancialInitial) {
      return const AdminLoadingView(
        message: 'جارٍ جلب سجل الحركات من الخادم...',
      );
    }

    if (state is LedgerEmpty) {
      return AdminEmptyView(
        message: 'لا توجد حركات مطابقة',
        hint: filters.hasActiveFilters
            ? 'جرّب توسيع نطاق الفلاتر أو إعادة تعيينها.'
            : 'لم تُسجَّل أي حركة مالية بعد.',
        icon: Icons.receipt_long_rounded,
        onRefresh: () => context.read<FinancialCubit>().loadLedger(),
      );
    }

    if (state is LedgerError) {
      return AdminErrorView(
        message: state.message,
        onRetry: () => context.read<FinancialCubit>().loadLedger(),
      );
    }

    if (state is LedgerLoaded) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: LedgerTable(entries: state.result.items),
            ),
          ),
          AdminPagination(
            meta: state.result.meta,
            onPageChanged: context.read<FinancialCubit>().changeLedgerPage,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
