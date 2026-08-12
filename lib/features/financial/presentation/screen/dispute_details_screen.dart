import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/financial_dispute_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../widget/dispute_details.dart';
import '../widget/dispute_resolution_dialog.dart';
import '../../../../core/widgets/admin_ui.dart';

/// تفاصيل النزاع المالي وحلّه.
class DisputeDetailsScreen extends StatelessWidget {
  final int disputeId;

  const DisputeDetailsScreen({super.key, required this.disputeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadDisputeDetails(disputeId),
      child: _DisputeDetailsView(disputeId: disputeId),
    );
  }
}

class _DisputeDetailsView extends StatefulWidget {
  final int disputeId;

  const _DisputeDetailsView({required this.disputeId});

  @override
  State<_DisputeDetailsView> createState() => _DisputeDetailsViewState();
}

class _DisputeDetailsViewState extends State<_DisputeDetailsView> {
  bool _dataChanged = false;

  Future<void> _openResolutionDialog(FinancialDisputeModel dispute) async {
    final cubit = context.read<FinancialCubit>();
    final request = await DisputeResolutionDialog.show(context, dispute);
    if (request == null || !mounted) return;

    final confirmed = await showAdminConfirmDialog(
      context,
      title: 'تأكيد حل النزاع',
      message: 'سيتم تطبيق القرار: '
          '"${DisputeResolution.label(request.resolution)}" '
          'على مبلغ ${AdminFormat.money(dispute.amount)}. '
          'هذه العملية تؤثر على الأرصدة مباشرة ولا يمكن التراجع عنها. '
          'هل تريد المتابعة؟',
      confirmLabel: 'تنفيذ القرار',
    );
    if (!confirmed || !mounted) return;

    await cubit.resolveDispute(
      dispute.id,
      resolution: request.resolution,
      notes: request.notes,
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
            title: Text('تفاصيل النزاع #${widget.disputeId}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(_dataChanged),
            ),
            actions: [
              IconButton(
                tooltip: 'تحديث',
                onPressed: () => context
                    .read<FinancialCubit>()
                    .loadDisputeDetails(widget.disputeId),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: BlocConsumer<FinancialCubit, FinancialState>(
            listener: (context, state) {
              if (state is DisputeResolved) {
                _dataChanged = true;
                showAdminSnackBar(context, state.message, isError: false);
              } else if (state is DisputeError) {
                showAdminSnackBar(context, state.message, isError: true);
              }
            },
            builder: (context, state) {
              if (state is DisputeDetailsLoading || state is FinancialInitial) {
                return const AdminLoadingView(
                  message: 'جارٍ جلب تفاصيل النزاع...',
                );
              }

              if (state is DisputeError) {
                return AdminErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<FinancialCubit>()
                      .loadDisputeDetails(widget.disputeId),
                );
              }

              if (state is DisputeDetailsLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DisputeDetailsPanel(dispute: state.dispute),
                      const SizedBox(height: 16),
                      _ResolutionSection(
                        dispute: state.dispute,
                        isResolving: state.isResolving,
                        onResolve: () => _openResolutionDialog(state.dispute),
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

class _ResolutionSection extends StatelessWidget {
  final FinancialDisputeModel dispute;
  final bool isResolving;
  final VoidCallback onResolve;

  const _ResolutionSection({
    required this.dispute,
    required this.isResolving,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    if (!dispute.isOpen) {
      return AdminPanel(
        child: Row(
          children: [
            Icon(Icons.lock_rounded, size: 18, color: context.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'هذا النزاع تم حله مسبقاً (الحالة الحالية: '
                '${AdminStatusPalette.label(dispute.status)}).',
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
              'اختر قرار الحل المناسب. سيُطلب تأكيد قبل الإرسال إلى الخادم.',
              style: TextStyle(fontSize: 12.5, color: context.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: isResolving ? null : onResolve,
            icon: isResolving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.gavel_rounded, size: 16),
            label: Text(isResolving ? 'جارٍ التنفيذ...' : 'حل النزاع'),
          ),
        ],
      ),
    );
  }
}
