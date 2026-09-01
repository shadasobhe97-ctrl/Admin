import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/termination_preview_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../widget/termination_preview_card.dart';

/// معاينة إنهاء العقد في منتصف الشهر.
///
/// المعاينة تأتي من `termination-preview` ولا تنفّذ شيئاً؛ التنفيذ الفعلي
/// يمرّ عبر `terminate-mid-month` بعد تأكيد صريح من المستخدم.
class TerminationPreviewScreen extends StatelessWidget {
  final int contractId;

  const TerminationPreviewScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>(),
      child: _TerminationPreviewView(contractId: contractId),
    );
  }
}

class _TerminationPreviewView extends StatefulWidget {
  final int contractId;

  const _TerminationPreviewView({required this.contractId});

  @override
  State<_TerminationPreviewView> createState() =>
      _TerminationPreviewViewState();
}

class _TerminationPreviewViewState extends State<_TerminationPreviewView> {
  String _terminatedBy = TerminatedBy.parent;
  bool _isArbitraryParent = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  void _loadPreview() {
    context.read<FinancialCubit>().loadTerminationPreview(
          widget.contractId,
          terminatedBy: _terminatedBy,
          isArbitraryParent: _isArbitraryParent,
        );
  }

  Future<void> _confirmTermination(TerminationPreviewModel preview) async {
    final cubit = context.read<FinancialCubit>();
    final confirmed = await showAdminConfirmDialog(
      context,
      title: 'تأكيد إنهاء العقد',
      message: 'سيتم إنهاء العقد ${preview.contractNumber} فعلياً، مع اقتطاع '
          'غرامة بقيمة ${AdminFormat.money(preview.penaltyFee)} '
          'وإرجاع ${AdminFormat.money(preview.refundToParent)} لولي الأمر. '
          'هذه العملية غير قابلة للتراجع. هل تريد المتابعة؟',
      confirmLabel: 'تنفيذ الإنهاء',
      isDestructive: true,
    );
    if (!confirmed) return;
    await cubit.terminateMidMonth(widget.contractId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('معاينة إنهاء العقد #${widget.contractId}'),
          actions: [
            IconButton(
              tooltip: 'تحديث المعاينة',
              onPressed: _loadPreview,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: BlocConsumer<FinancialCubit, FinancialState>(
          listener: (context, state) {
            if (state is TerminationExecuted) {
              showAdminSnackBar(context, state.message, isError: false);
            } else if (state is PreviewError) {
              showAdminSnackBar(context, state.message, isError: true);
            }
          },
          builder: (context, state) {
            final isExecuting =
                state is TerminationPreviewLoaded && state.isExecuting;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PreviewOptions(
                    terminatedBy: _terminatedBy,
                    isArbitraryParent: _isArbitraryParent,
                    enabled: state is! PreviewLoading && !isExecuting,
                    onTerminatedByChanged: (value) {
                      setState(() => _terminatedBy = value);
                      _loadPreview();
                    },
                    onArbitraryChanged: (value) {
                      setState(() => _isArbitraryParent = value);
                      _loadPreview();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewBody(context, state, isExecuting),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPreviewBody(
    BuildContext context,
    FinancialState state,
    bool isExecuting,
  ) {
    if (state is PreviewLoading || state is FinancialInitial) {
      return const SizedBox(
        height: 240,
        child: AdminLoadingView(message: 'جارٍ حساب المعاينة على الخادم...'),
      );
    }

    if (state is PreviewError) {
      return SizedBox(
        height: 240,
        child: AdminErrorView(
          message: state.message,
          onRetry: _loadPreview,
        ),
      );
    }

    if (state is TerminationPreviewLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TerminationPreviewCard(
            preview: state.preview,
            terminatedBy: state.terminatedBy,
            isArbitraryParent: state.isArbitraryParent,
          ),
          const SizedBox(height: 16),
          AdminPanel(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'التنفيذ الفعلي يستخدم مسار terminate-mid-month وهو منفصل '
                    'تماماً عن المعاينة أعلاه.',
                    style:
                        TextStyle(fontSize: 12.5, color: context.textSecondary),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.dangerColor,
                    foregroundColor: context.onPrimary,
                  ),
                  onPressed: isExecuting
                      ? null
                      : () => _confirmTermination(state.preview),
                  icon: isExecuting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_schedule_send_rounded, size: 16),
                  label: Text(
                    isExecuting ? 'جارٍ التنفيذ...' : 'تنفيذ إنهاء العقد',
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

/// خيارات المعاينة التي تُرسَل كـ Query Parameters إلى الخادم.
class _PreviewOptions extends StatelessWidget {
  final String terminatedBy;
  final bool isArbitraryParent;
  final bool enabled;
  final ValueChanged<String> onTerminatedByChanged;
  final ValueChanged<bool> onArbitraryChanged;

  const _PreviewOptions({
    required this.terminatedBy,
    required this.isArbitraryParent,
    required this.enabled,
    required this.onTerminatedByChanged,
    required this.onArbitraryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: Row(
        children: [
          Text(
            'الجهة المُنهية:',
            style: TextStyle(fontSize: 12.5, color: context.textSecondary),
          ),
          const SizedBox(width: 12),
          for (final option in TerminatedBy.all) ...[
            ChoiceChip(
              label: Text(TerminatedBy.label(option)),
              selected: terminatedBy == option,
              onSelected:
                  enabled ? (_) => onTerminatedByChanged(option) : null,
            ),
            const SizedBox(width: 8),
          ],
          const Spacer(),
          Text(
            'إنهاء تعسّفي من ولي الأمر',
            style: TextStyle(fontSize: 12.5, color: context.textSecondary),
          ),
          Switch(
            value: isArbitraryParent,
            onChanged: enabled ? onArbitraryChanged : null,
          ),
        ],
      ),
    );
  }
}
