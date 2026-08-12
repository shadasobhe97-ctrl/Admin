import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../widget/financial_status_filter_bar.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../widget/withdrawal_card.dart';
import 'withdrawal_details_screen.dart';

/// قائمة طلبات سحب أرباح السائقين.
class WithdrawalsScreen extends StatelessWidget {
  const WithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadWithdrawals(),
      child: const _WithdrawalsView(),
    );
  }
}

class _WithdrawalsView extends StatefulWidget {
  const _WithdrawalsView();

  @override
  State<_WithdrawalsView> createState() => _WithdrawalsViewState();
}

class _WithdrawalsViewState extends State<_WithdrawalsView> {
  /// `null` تعني عدم إرسال فلتر `status` إلى الخادم.
  String? _status;

  static const Map<String, String> _statusOptions = {
    'pending': 'معلّق',
    'approved': 'مقبول',
    'rejected': 'مرفوض',
  };

  void _applyStatus(String? status) {
    setState(() => _status = status);
    context.read<FinancialCubit>().loadWithdrawals(status: status);
  }

  Future<void> _openDetails(int id) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WithdrawalDetailsScreen(withdrawalId: id),
      ),
    );
    if (!mounted) return;
    // إعادة جلب القائمة من الخادم بعد أي معالجة ناجحة.
    if (changed == true) {
      context.read<FinancialCubit>().refreshWithdrawals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلبات سحب أرباح السائقين'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () =>
                  context.read<FinancialCubit>().loadWithdrawals(status: _status),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialStatusFilterBar(
                options: _statusOptions,
                selected: _status,
                onChanged: _applyStatus,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocConsumer<FinancialCubit, FinancialState>(
                  listener: (context, state) {
                    if (state is WithdrawalError) {
                      showAdminSnackBar(context, state.message,
                          isError: true);
                    }
                  },
                  builder: (context, state) {
                    if (state is WithdrawalsLoading ||
                        state is FinancialInitial) {
                      return const AdminLoadingView(
                        message: 'جارٍ جلب طلبات السحب من الخادم...',
                      );
                    }

                    if (state is WithdrawalsEmpty) {
                      return AdminEmptyView(
                        message: 'لا توجد طلبات سحب مطابقة',
                        hint: _status == null
                            ? 'لم يُسجَّل أي طلب سحب حتى الآن.'
                            : 'لا توجد طلبات بحالة "${_statusOptions[_status] ?? _status}".',
                        icon: Icons.outbox_rounded,
                        onRefresh: () => _applyStatus(_status),
                      );
                    }

                    if (state is WithdrawalError) {
                      return AdminErrorView(
                        message: state.message,
                        onRetry: () => _applyStatus(_status),
                      );
                    }

                    if (state is WithdrawalsLoaded) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.result.items.length,
                              itemBuilder: (context, index) {
                                final withdrawal = state.result.items[index];
                                return WithdrawalCard(
                                  withdrawal: withdrawal,
                                  onOpenDetails: () =>
                                      _openDetails(withdrawal.id),
                                );
                              },
                            ),
                          ),
                          AdminPagination(
                            meta: state.result.meta,
                            onPageChanged: (page) => context
                                .read<FinancialCubit>()
                                .loadWithdrawals(status: _status, page: page),
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
