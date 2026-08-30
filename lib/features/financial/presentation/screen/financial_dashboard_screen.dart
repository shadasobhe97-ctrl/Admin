import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../widget/financial_summary_grid.dart';
import '../../../../core/widgets/admin_ui.dart';
import 'disputes_screen.dart';
import 'escrows_screen.dart';
import 'financial_audit_logs_screen.dart';
import 'financial_ledger_screen.dart';
import 'invoices_screen.dart';
import 'payment_methods_screen.dart';
import 'pricing_settings_screen.dart';
import 'recharges_screen.dart';
import 'settlements_screen.dart';
import 'solvency_check_screen.dart';
import 'withdrawals_screen.dart';

/// الشاشة الرئيسية للإدارة المالية.
/// تعرض ملخّص `GET /admin/financial/summary` وتفتح بقية أقسام الميزة.
class FinancialDashboardScreen extends StatelessWidget {
  const FinancialDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadSummary(),
      child: const FinancialDashboardView(),
    );
  }
}

/// الجسم القابل للتضمين داخل لوحة التحكم الرئيسية.
class FinancialDashboardView extends StatelessWidget {
  const FinancialDashboardView({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  /// يعيد تحميل الملخّص بعد العودة من أي قسم قد يكون غيّر البيانات.
  Future<void> _openAndRefresh(BuildContext context, Widget screen) async {
    final cubit = context.read<FinancialCubit>();
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    await cubit.loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialCubit, FinancialState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<FinancialCubit>().loadSummary(),
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'الملخّص المالي المباشر',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'تحديث الملخّص',
                    onPressed: () =>
                        context.read<FinancialCubit>().loadSummary(),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSummarySection(context, state),
              const SizedBox(height: 24),
              Text(
                'أقسام الإدارة المالية',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionsGrid(context),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(BuildContext context, FinancialState state) {
    if (state is FinancialLoading || state is FinancialInitial) {
      return const SizedBox(
        height: 220,
        child: AdminLoadingView(
          message: 'جارٍ جلب الملخّص المالي من الخادم...',
        ),
      );
    }

    if (state is FinancialError) {
      return SizedBox(
        height: 220,
        child: AdminErrorView(
          message: state.message,
          onRetry: () => context.read<FinancialCubit>().loadSummary(),
        ),
      );
    }

    if (state is FinancialLoaded) {
      return FinancialSummaryGrid(
        summary: state.summary,
        onWithdrawalsTap: () =>
            _openAndRefresh(context, const WithdrawalsScreen()),
        onRechargesTap: () => _openAndRefresh(context, const RechargesScreen()),
        onDisputesTap: () => _openAndRefresh(context, const DisputesScreen()),
        onEscrowsTap: () => _openAndRefresh(context, const EscrowsScreen()),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSectionsGrid(BuildContext context) {
    final sections = <_FinancialSection>[
      // طلبات السحب والشحن والنزاعات والأمانات تُفتح من بطاقات الملخّص أعلاه،
      // لأنها تعرض العدد المعلّق أيضاً؛ فلا تتكرر هنا بمدخل ثانٍ.
      _FinancialSection(
        title: 'سجل الحركات المالية',
        description: 'كل القيود المحاسبية مع الفلترة والتصفّح',
        icon: Icons.swap_horiz_rounded,
        color: context.primaryColor,
        onTap: () => _open(context, const FinancialLedgerScreen()),
      ),
      _FinancialSection(
        title: 'سجل عمليات المشرفين',
        description: 'تدقيق إجراءات المشرفين المالية',
        icon: Icons.fact_check_rounded,
        color: context.infoColor,
        onTap: () => _open(context, const FinancialAuditLogsScreen()),
      ),
      _FinancialSection(
        title: 'التسويات الشهرية',
        description: 'العقود الجاهزة للتسوية ومعاينة الإنهاء',
        icon: Icons.assignment_turned_in_rounded,
        color: context.primaryColor,
        onTap: () => _openAndRefresh(context, const SettlementsScreen()),
      ),
      _FinancialSection(
        title: 'فحص الملاءة المالية',
        description: 'التحقق من اتساق أرصدة المنظومة',
        icon: Icons.health_and_safety_rounded,
        color: context.successColor,
        onTap: () => _open(context, const SolvencyCheckScreen()),
      ),
      _FinancialSection(
        title: 'الفواتير',
        description: 'استعراض الفواتير الصادرة وتفاصيلها',
        icon: Icons.receipt_rounded,
        color: context.infoColor,
        onTap: () => _open(context, const InvoicesScreen()),
      ),
      _FinancialSection(
        title: 'إعدادات التسعير',
        description: 'ضبط العمولة وخصومات الأطفال وأسعار الكيلومتر',
        icon: Icons.tune_rounded,
        color: context.primaryColor,
        onTap: () => _open(context, const PricingSettingsScreen()),
      ),
      _FinancialSection(
        title: 'طرق الدفع',
        description: 'إدارة وتفعيل طرق الدفع المعتمدة في المنظومة',
        icon: Icons.credit_card_rounded,
        color: context.infoColor,
        onTap: () => _open(context, const PaymentMethodsScreen()),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1280
            ? 3
            : constraints.maxWidth >= 720
                ? 2
                : 1;
        const spacing = 12.0;
        final width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final section in sections)
              SizedBox(width: width, child: section),
          ],
        );
      },
    );
  }
}

class _FinancialSection extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FinancialSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderSoft),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style:
                          TextStyle(fontSize: 11.5, color: context.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                size: 20,
                color: context.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
