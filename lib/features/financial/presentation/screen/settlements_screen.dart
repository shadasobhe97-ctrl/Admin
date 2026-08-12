import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/settlement_contract_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../widget/settlement_card.dart';
import 'termination_preview_screen.dart';

/// العقود الجاهزة للتسوية الشهرية.
/// لا تُنفَّذ أي تسوية عند فتح الشاشة — العرض ثم التأكيد ثم التنفيذ ثم التحديث.
class SettlementsScreen extends StatelessWidget {
  const SettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadPendingSettlements(),
      child: const _SettlementsView(),
    );
  }
}

class _SettlementsView extends StatelessWidget {
  const _SettlementsView();

  Future<void> _confirmSettle(
    BuildContext context,
    SettlementContractModel contract,
  ) async {
    final cubit = context.read<FinancialCubit>();
    final confirmed = await showAdminConfirmDialog(
      context,
      title: 'تأكيد التسوية الشهرية',
      message: 'سيتم تنفيذ التسوية النهائية للعقد ${contract.contractNumber} '
          'بمبلغ منفَّذ ${AdminFormat.money(contract.executedAmount)} '
          'ومبلغ متبقٍّ ${AdminFormat.money(contract.pendingAmount)}. '
          'هل تريد المتابعة؟',
      confirmLabel: 'تنفيذ التسوية',
    );
    if (!confirmed) return;
    await cubit.settleMonthly(contract.contractId);
  }

  void _openTerminationPreview(BuildContext context, int contractId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TerminationPreviewScreen(contractId: contractId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التسويات الشهرية للعقود'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () =>
                  context.read<FinancialCubit>().loadPendingSettlements(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: BlocConsumer<FinancialCubit, FinancialState>(
          listener: (context, state) {
            if (state is SettlementSuccess) {
              showAdminSnackBar(
                context,
                '${state.message}\n'
                'المبلغ المسوّى: ${AdminFormat.money(state.result.finalSettledAmount)}'
                '  •  رصيد مُرحَّل: ${AdminFormat.money(state.result.rolloverRefundCredit)}',
                isError: false,
              );
            } else if (state is SettlementError) {
              showAdminSnackBar(context, state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is SettlementsLoading || state is FinancialInitial) {
              return const AdminLoadingView(
                message: 'جارٍ جلب العقود الجاهزة للتسوية...',
              );
            }

            if (state is SettlementsEmpty) {
              return AdminEmptyView(
                message: 'لا توجد عقود جاهزة للتسوية',
                hint: 'ستظهر هنا العقود التي يحدّدها الخادم كجاهزة للتسوية الشهرية.',
                icon: Icons.assignment_turned_in_rounded,
                onRefresh: () =>
                    context.read<FinancialCubit>().loadPendingSettlements(),
              );
            }

            if (state is SettlementError) {
              return AdminErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<FinancialCubit>().loadPendingSettlements(),
              );
            }

            if (state is SettlementsLoaded) {
              final isBusy = state.processingContractId != null;
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'التسوية لا تُنفَّذ تلقائياً — يجب تأكيد كل عقد على حدة.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.result.items.length,
                        itemBuilder: (context, index) {
                          final contract = state.result.items[index];
                          return SettlementCard(
                            contract: contract,
                            isProcessing: state.processingContractId ==
                                contract.contractId,
                            actionsEnabled: !isBusy,
                            onSettle: () => _confirmSettle(context, contract),
                            onPreviewTermination: () => _openTerminationPreview(
                              context,
                              contract.contractId,
                            ),
                          );
                        },
                      ),
                    ),
                    AdminPagination(
                      meta: state.result.meta,
                      enabled: !isBusy,
                      onPageChanged: (page) => context
                          .read<FinancialCubit>()
                          .loadPendingSettlements(page: page),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
