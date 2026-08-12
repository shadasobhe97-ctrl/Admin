import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/withdrawal_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../widget/withdrawal_action_dialog.dart';
import '../widget/withdrawal_details.dart';

/// تفاصيل طلب السحب ومعالجته.
/// تُعيد `true` عند الخروج إذا تغيّرت بيانات الخادم، لتحديث القائمة.
class WithdrawalDetailsScreen extends StatelessWidget {
  final int withdrawalId;

  const WithdrawalDetailsScreen({super.key, required this.withdrawalId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadWithdrawalDetails(withdrawalId),
      child: _WithdrawalDetailsView(withdrawalId: withdrawalId),
    );
  }
}

class _WithdrawalDetailsView extends StatefulWidget {
  final int withdrawalId;

  const _WithdrawalDetailsView({required this.withdrawalId});

  @override
  State<_WithdrawalDetailsView> createState() => _WithdrawalDetailsViewState();
}

class _WithdrawalDetailsViewState extends State<_WithdrawalDetailsView> {
  bool _dataChanged = false;

  Future<void> _openActionDialog(WithdrawalModel withdrawal) async {
    final cubit = context.read<FinancialCubit>();
    final request = await WithdrawalActionDialog.show(context, withdrawal);
    if (request == null || !mounted) return;

    final confirmed = await showAdminConfirmDialog(
      context,
      title: request.action == 'approve'
          ? 'تأكيد الموافقة على السحب'
          : 'تأكيد رفض طلب السحب',
      message: request.action == 'approve'
          ? 'سيتم اعتماد صرف مبلغ ${AdminFormat.money(withdrawal.amount)} '
              'للسائق ${withdrawal.driverName}. هل تريد المتابعة؟'
          : 'سيتم رفض الطلب وإرجاع المبلغ إلى رصيد السائق حسب سياسة النظام. '
              'هل تريد المتابعة؟',
      confirmLabel: request.action == 'approve' ? 'اعتماد الصرف' : 'تأكيد الرفض',
      isDestructive: request.action == 'reject',
    );
    if (!confirmed || !mounted) return;

    await cubit.processWithdrawal(
      withdrawal.id,
      action: request.action,
      rejectionReason: request.rejectionReason,
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
            title: Text('تفاصيل طلب السحب #${widget.withdrawalId}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(_dataChanged),
            ),
            actions: [
              IconButton(
                tooltip: 'تحديث',
                onPressed: () => context
                    .read<FinancialCubit>()
                    .loadWithdrawalDetails(widget.withdrawalId),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: BlocConsumer<FinancialCubit, FinancialState>(
            listener: (context, state) {
              if (state is WithdrawalProcessSuccess) {
                _dataChanged = true;
                showAdminSnackBar(context, state.message, isError: false);
              } else if (state is WithdrawalError) {
                // رسالة الخادم تُعرض كما هي، بما فيها حالة 422
                // عندما يكون الطلب قد عولج مسبقاً.
                showAdminSnackBar(context, state.message, isError: true);
              }
            },
            builder: (context, state) {
              if (state is WithdrawalDetailsLoading ||
                  state is FinancialInitial) {
                return const AdminLoadingView(
                  message: 'جارٍ جلب تفاصيل الطلب...',
                );
              }

              if (state is WithdrawalError) {
                return AdminErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<FinancialCubit>()
                      .loadWithdrawalDetails(widget.withdrawalId),
                );
              }

              if (state is WithdrawalDetailsLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WithdrawalDetailsPanel(withdrawal: state.withdrawal),
                      const SizedBox(height: 16),
                      _ActionSection(
                        withdrawal: state.withdrawal,
                        isProcessing: state.isProcessing,
                        onProcess: () => _openActionDialog(state.withdrawal),
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

/// منطقة إجراءات المعالجة — تُعطَّل تماماً إن لم يكن الطلب معلّقاً
/// أو أثناء تنفيذ عملية جارية.
class _ActionSection extends StatelessWidget {
  final WithdrawalModel withdrawal;
  final bool isProcessing;
  final VoidCallback onProcess;

  const _ActionSection({
    required this.withdrawal,
    required this.isProcessing,
    required this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    if (!withdrawal.isPending) {
      return AdminPanel(
        child: Row(
          children: [
            Icon(Icons.lock_rounded, size: 18, color: context.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'هذا الطلب تمت معالجته مسبقاً (الحالة الحالية: '
                '${AdminStatusPalette.label(withdrawal.status)}) ولا يقبل معالجة جديدة.',
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
              'اختر الإجراء المناسب لهذا الطلب. سيُطلب تأكيد قبل الإرسال إلى الخادم.',
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
            label: Text(isProcessing ? 'جارٍ التنفيذ...' : 'معالجة الطلب'),
          ),
        ],
      ),
    );
  }
}
