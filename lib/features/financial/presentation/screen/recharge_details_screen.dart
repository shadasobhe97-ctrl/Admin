import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/recharge_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../widget/recharge_action_dialog.dart';
import '../widget/recharge_details.dart';

/// تفاصيل عملية الشحن ومعالجتها.
class RechargeDetailsScreen extends StatelessWidget {
  final int rechargeId;

  const RechargeDetailsScreen({super.key, required this.rechargeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadRechargeDetails(rechargeId),
      child: _RechargeDetailsView(rechargeId: rechargeId),
    );
  }
}

class _RechargeDetailsView extends StatefulWidget {
  final int rechargeId;

  const _RechargeDetailsView({required this.rechargeId});

  @override
  State<_RechargeDetailsView> createState() => _RechargeDetailsViewState();
}

class _RechargeDetailsViewState extends State<_RechargeDetailsView> {
  bool _dataChanged = false;

  Future<void> _openActionDialog(RechargeModel recharge) async {
    final cubit = context.read<FinancialCubit>();
    final request = await RechargeActionDialog.show(context, recharge);
    if (request == null || !mounted) return;

    final confirmed = await showAdminConfirmDialog(
      context,
      title: request.action == 'complete'
          ? 'تأكيد إتمام الشحن'
          : 'تأكيد تسجيل إخفاق الشحن',
      message: request.action == 'complete'
          ? 'سيتم إضافة ${AdminFormat.money(recharge.amount)} إلى محفظة '
              '${recharge.parentName}. هل تريد المتابعة؟'
          : 'سيتم تسجيل هذه العملية كعملية فاشلة ولن يُضاف أي رصيد. '
              'هل تريد المتابعة؟',
      confirmLabel:
          request.action == 'complete' ? 'إتمام الشحن' : 'تأكيد الإخفاق',
      isDestructive: request.action == 'fail',
    );
    if (!confirmed || !mounted) return;

    await cubit.processRecharge(
      recharge.id,
      action: request.action,
      reason: request.reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) Navigator.of(context).pop(_dataChanged);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('تفاصيل عملية الشحن #${widget.rechargeId}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(_dataChanged),
            ),
            actions: [
              IconButton(
                tooltip: 'تحديث',
                onPressed: () => context
                    .read<FinancialCubit>()
                    .loadRechargeDetails(widget.rechargeId),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: BlocConsumer<FinancialCubit, FinancialState>(
            listener: (context, state) {
              if (state is RechargeProcessSuccess) {
                _dataChanged = true;
                showAdminSnackBar(context, state.message, isError: false);
              } else if (state is RechargeError) {
                showAdminSnackBar(context, state.message, isError: true);
              }
            },
            builder: (context, state) {
              if (state is RechargeDetailsLoading || state is FinancialInitial) {
                return const AdminLoadingView(
                  message: 'جارٍ جلب تفاصيل العملية...',
                );
              }

              if (state is RechargeError) {
                return AdminErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<FinancialCubit>()
                      .loadRechargeDetails(widget.rechargeId),
                );
              }

              if (state is RechargeDetailsLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RechargeDetailsPanel(recharge: state.recharge),
                      const SizedBox(height: 16),
                      _RechargeActionSection(
                        recharge: state.recharge,
                        isProcessing: state.isProcessing,
                        onProcess: () => _openActionDialog(state.recharge),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _RechargeActionSection extends StatelessWidget {
  final RechargeModel recharge;
  final bool isProcessing;
  final VoidCallback onProcess;

  const _RechargeActionSection({
    required this.recharge,
    required this.isProcessing,
    required this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    if (!recharge.isPending) {
      return AdminPanel(
        child: Row(
          children: [
            Icon(Icons.lock_rounded, size: 18, color: context.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'هذه العملية تمت معالجتها مسبقاً (الحالة الحالية: '
                '${AdminStatusPalette.label(recharge.status)}) ولا تقبل معالجة جديدة.',
                style: TextStyle(fontSize: 12.5, color: context.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return AdminPanel(
      child: Row(
        children: [
          Expanded(
            child: Text(
              'اختر الإجراء المناسب لهذه العملية. سيُطلب تأكيد قبل الإرسال إلى الخادم.',
              style: TextStyle(fontSize: 12.5, color: context.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: isProcessing ? null : onProcess,
            icon: isProcessing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.rule_rounded, size: 16),
            label: Text(isProcessing ? 'جارٍ التنفيذ...' : 'معالجة العملية'),
          ),
        ],
      ),
    );
  }
}
