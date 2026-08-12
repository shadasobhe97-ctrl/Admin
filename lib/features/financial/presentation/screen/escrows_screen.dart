import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../widget/escrow_summary_card.dart';
import '../widget/financial_summary_grid.dart';
import '../../../../core/widgets/admin_ui.dart';

/// شاشة الأمانات وتحريرها.
class EscrowsScreen extends StatelessWidget {
  const EscrowsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadEscrows(),
      child: const _EscrowsView(),
    );
  }
}

class _EscrowsView extends StatelessWidget {
  const _EscrowsView();

  Future<void> _confirmRelease(BuildContext context) async {
    final cubit = context.read<FinancialCubit>();
    final confirmed = await showAdminConfirmDialog(
      context,
      title: 'تأكيد تحرير الأمانات',
      message: 'سيتم تحرير كل الأمانات المستحقة ونقلها إلى الأرصدة المتاحة '
          'للسائقين، مع اقتطاع عمولة المنصة. هذه العملية غير قابلة للتراجع. '
          'هل تريد المتابعة؟',
      confirmLabel: 'تنفيذ التحرير',
    );
    if (!confirmed) return;
    await cubit.releaseEscrows();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأمانات وتحرير الأرباح'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () => context.read<FinancialCubit>().loadEscrows(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: BlocConsumer<FinancialCubit, FinancialState>(
          listener: (context, state) {
            if (state is EscrowReleaseSuccess) {
              showAdminSnackBar(context, state.message, isError: false);
            } else if (state is EscrowError) {
              showAdminSnackBar(context, state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is EscrowsLoading || state is FinancialInitial) {
              return const AdminLoadingView(
                message: 'جارٍ جلب بيانات الأمانات من الخادم...',
              );
            }

            if (state is EscrowError) {
              return AdminErrorView(
                message: state.message,
                onRetry: () => context.read<FinancialCubit>().loadEscrows(),
              );
            }

            if (state is EscrowsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EscrowSummaryCard(
                      escrows: state.escrows,
                      isReleasing: state.isReleasing,
                      onRelease: () => _confirmRelease(context),
                    ),
                    if (state.summary != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        'الملخّص المالي بعد آخر تحديث',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      FinancialSummaryGrid(summary: state.summary!),
                    ],
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
