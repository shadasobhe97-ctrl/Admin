import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/trip_cancellation_preview_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../widget/trip_cancellation_preview_card.dart';

/// معاينة إلغاء رحلة حسب مصفوفة الغرامات، ثم تنفيذ الإلغاء بعد التأكيد.
class TripCancellationPreviewScreen extends StatelessWidget {
  final int tripId;

  const TripCancellationPreviewScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>(),
      child: _TripCancellationView(tripId: tripId),
    );
  }
}

class _TripCancellationView extends StatefulWidget {
  final int tripId;

  const _TripCancellationView({required this.tripId});

  @override
  State<_TripCancellationView> createState() => _TripCancellationViewState();
}

class _TripCancellationViewState extends State<_TripCancellationView> {
  String _cancelledBy = CancelledBy.parent;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  void _loadPreview() {
    context.read<FinancialCubit>().loadTripCancellationPreview(
          widget.tripId,
          cancelledBy: _cancelledBy,
        );
  }

  Future<void> _confirmCancellation(
    TripCancellationPreviewModel preview,
  ) async {
    final cubit = context.read<FinancialCubit>();
    final confirmed = await showAdminConfirmDialog(
      context,
      title: 'تأكيد إلغاء الرحلة',
      message: 'سيتم إلغاء الرحلة #${preview.tripId} وتطبيق مصفوفة الغرامات: '
          'استرجاع ${AdminFormat.money(preview.parentRefundDinar)} لولي الأمر، '
          'و${AdminFormat.money(preview.driverPayDinar)} للسائق، '
          'وغرامة ${AdminFormat.money(preview.penaltyDinar)}. '
          'هذه العملية غير قابلة للتراجع. هل تريد المتابعة؟',
      confirmLabel: 'تنفيذ الإلغاء',
      isDestructive: true,
    );
    if (!confirmed) return;
    await cubit.cancelTripWithMatrix(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('معاينة إلغاء الرحلة #${widget.tripId}'),
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
            if (state is TripCancellationExecuted) {
              showAdminSnackBar(context, state.message, isError: false);
            } else if (state is PreviewError) {
              showAdminSnackBar(context, state.message, isError: true);
            }
          },
          builder: (context, state) {
            final isExecuting =
                state is TripCancellationPreviewLoaded && state.isExecuting;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminPanel(
                    child: Row(
                      children: [
                        Text(
                          'الجهة الملغية:',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        for (final option in CancelledBy.all) ...[
                          ChoiceChip(
                            label: Text(CancelledBy.label(option)),
                            selected: _cancelledBy == option,
                            onSelected: state is PreviewLoading || isExecuting
                                ? null
                                : (_) {
                                    setState(() => _cancelledBy = option);
                                    _loadPreview();
                                  },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBody(context, state, isExecuting),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
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
        child: AdminErrorView(message: state.message, onRetry: _loadPreview),
      );
    }

    if (state is TripCancellationPreviewLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripCancellationPreviewCard(preview: state.preview),
          const SizedBox(height: 16),
          AdminPanel(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'التنفيذ الفعلي يستخدم مسار cancel-with-matrix وهو منفصل '
                    'عن المعاينة أعلاه.',
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
                      : () => _confirmCancellation(state.preview),
                  icon: isExecuting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_rounded, size: 16),
                  label:
                      Text(isExecuting ? 'جارٍ التنفيذ...' : 'تنفيذ إلغاء الرحلة'),
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
