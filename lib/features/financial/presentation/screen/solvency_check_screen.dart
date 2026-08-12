import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/solvency_check_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_ui.dart';

/// فحص الملاءة المالية.
/// حالة الاتساق تُقرأ من `is_solvent` القادم من الخادم ولا تُحتسب محلياً.
class SolvencyCheckScreen extends StatelessWidget {
  const SolvencyCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadSolvencyCheck(),
      child: const _SolvencyView(),
    );
  }
}

class _SolvencyView extends StatelessWidget {
  const _SolvencyView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('فحص الملاءة المالية'),
          actions: [
            IconButton(
              tooltip: 'إعادة الفحص',
              onPressed: () =>
                  context.read<FinancialCubit>().loadSolvencyCheck(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: BlocBuilder<FinancialCubit, FinancialState>(
          builder: (context, state) {
            if (state is SolvencyLoading || state is FinancialInitial) {
              return const AdminLoadingView(
                message: 'جارٍ تنفيذ الفحص على الخادم...',
              );
            }

            if (state is SolvencyError) {
              return AdminErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<FinancialCubit>().loadSolvencyCheck(),
              );
            }

            if (state is SolvencyLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _SolvencyResult(solvency: state.solvency),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SolvencyResult extends StatelessWidget {
  final SolvencyCheckModel solvency;

  const _SolvencyResult({required this.solvency});

  @override
  Widget build(BuildContext context) {
    // اللون مشتق من نتيجة الخادم فقط، ومصدره الـ Theme الحالي.
    final statusColor =
        solvency.isSolvent ? context.successColor : context.dangerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminPanel(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  solvency.isSolvent
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      solvency.isSolvent
                          ? 'النظام متسق مالياً'
                          : 'يوجد اختلال في الاتساق المالي',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                    if (solvency.message != null) ...[
                      const SizedBox(height: 4),
                      // رسالة الخادم كما وردت.
                      Text(
                        solvency.message!,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل الفحص',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: context.textPrimary,
                ),
              ),
              Divider(color: context.dividerLine, height: 24),
              AdminInfoRow(
                label: 'الفرق المرصود',
                value: '${AdminFormat.money(solvency.discrepancyDinar)} '
                    '(${AdminFormat.count(solvency.discrepancyCents)} سنت)',
                valueColor: solvency.discrepancyCents == 0
                    ? context.successColor
                    : context.dangerColor,
                emphasized: true,
              ),
              AdminInfoRow(
                label: 'أمانات أولياء الأمور',
                value: AdminFormat.money(solvency.parentsEscrowPool),
              ),
              AdminInfoRow(
                label: 'أرباح السائقين المعلّقة',
                value: AdminFormat.money(solvency.driverPendingPool),
              ),
              AdminInfoRow(
                label: 'أرباح السائقين المتاحة',
                value: AdminFormat.money(solvency.driverAvailablePool),
              ),
              AdminInfoRow(
                label: 'إيرادات المنصة',
                value: AdminFormat.money(solvency.platformRevenuePool),
              ),
              Divider(color: context.dividerLine, height: 24),
              AdminInfoRow(
                label: 'الإجمالي المحتسب من الخادم',
                value: AdminFormat.money(solvency.totalCalculatedDinar),
                emphasized: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
