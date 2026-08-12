import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../widget/financial_status_filter_bar.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../widget/recharge_card.dart';
import 'recharge_details_screen.dart';

/// قائمة عمليات شحن محافظ أولياء الأمور.
class RechargesScreen extends StatelessWidget {
  const RechargesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadRecharges(),
      child: const _RechargesView(),
    );
  }
}

class _RechargesView extends StatefulWidget {
  const _RechargesView();

  @override
  State<_RechargesView> createState() => _RechargesViewState();
}

class _RechargesViewState extends State<_RechargesView> {
  String? _status;

  static const Map<String, String> _statusOptions = {
    'pending': 'معلّق',
    'completed': 'مكتمل',
    'failed': 'فاشل',
  };

  void _applyStatus(String? status) {
    setState(() => _status = status);
    context.read<FinancialCubit>().loadRecharges(status: status);
  }

  Future<void> _openDetails(int id) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RechargeDetailsScreen(rechargeId: id)),
    );
    if (!mounted) return;
    if (changed == true) {
      context.read<FinancialCubit>().refreshRecharges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلبات شحن محافظ أولياء الأمور'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () =>
                  context.read<FinancialCubit>().loadRecharges(status: _status),
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
                    if (state is RechargeError) {
                      showAdminSnackBar(context, state.message,
                          isError: true);
                    }
                  },
                  builder: (context, state) {
                    if (state is RechargesLoading || state is FinancialInitial) {
                      return const AdminLoadingView(
                        message: 'جارٍ جلب عمليات الشحن من الخادم...',
                      );
                    }

                    if (state is RechargesEmpty) {
                      return AdminEmptyView(
                        message: 'لا توجد عمليات شحن مطابقة',
                        hint: _status == null
                            ? 'لم تُسجَّل أي عملية شحن حتى الآن.'
                            : 'لا توجد عمليات بحالة "${_statusOptions[_status] ?? _status}".',
                        icon: Icons.move_to_inbox_rounded,
                        onRefresh: () => _applyStatus(_status),
                      );
                    }

                    if (state is RechargeError) {
                      return AdminErrorView(
                        message: state.message,
                        onRetry: () => _applyStatus(_status),
                      );
                    }

                    if (state is RechargesLoaded) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.result.items.length,
                              itemBuilder: (context, index) {
                                final recharge = state.result.items[index];
                                return RechargeCard(
                                  recharge: recharge,
                                  onOpenDetails: () => _openDetails(recharge.id),
                                );
                              },
                            ),
                          ),
                          AdminPagination(
                            meta: state.result.meta,
                            onPageChanged: (page) => context
                                .read<FinancialCubit>()
                                .loadRecharges(status: _status, page: page),
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
