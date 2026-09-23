import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../../logic/cubit/ai_alerts_cubit.dart';
import '../../logic/state/ai_alerts_state.dart';
import '../widgets/ai_alert_card.dart';
import '../widgets/ai_alert_filter_bar.dart';
import '../widgets/ai_audit_card.dart';

class AiAlertsScreen extends StatelessWidget {
  const AiAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiAlertsCubit>(
      create: (_) => sl<AiAlertsCubit>()
        ..fetchAlerts()
        ..fetchAudits(),
      child: const _AiAlertsView(),
    );
  }
}

class _AiAlertsView extends StatefulWidget {
  const _AiAlertsView();

  @override
  State<_AiAlertsView> createState() => _AiAlertsViewState();
}

class _AiAlertsViewState extends State<_AiAlertsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AiAlertsCubit, AiAlertsState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: context.dangerColor,
            ),
          );
        }
        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: const Color(0xFF059669),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AiAlertsCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مركز تحكّم الذكاء الاصطناعي (AI Control Center)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مراقبة تنبيهات الأمان، تسوية القرارات، وسجل تدقيق الذكاء الاصطناعي.',
                      style: TextStyle(fontSize: 12, color: context.textMuted),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'إعادة تحديث البيانات',
                  icon: Icon(Icons.refresh_rounded, color: context.primaryColor),
                  onPressed: () {
                    if (_tabController.index == 0) {
                      cubit.fetchAlerts(page: state.meta.currentPage);
                    } else {
                      cubit.fetchAudits(page: state.auditsMeta.currentPage);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Tab Bar Navigation ─────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: context.primaryColor,
                labelColor: context.primaryColor,
                unselectedLabelColor: context.textTertiary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'تنبيهات الأمان والتدخل البشري'),
                  Tab(text: 'سجل التدقيق وحيثيات القرارات'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: AI Alerts
                  _buildAlertsTab(context, state, cubit),
                  // Tab 2: AI Audits
                  _buildAuditsTab(context, state, cubit),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Tab 1: Alerts Tab ─────────────────────────────────────────────────────
  Widget _buildAlertsTab(
    BuildContext context,
    AiAlertsState state,
    AiAlertsCubit cubit,
  ) {
    return Column(
      children: [
        AiAlertFilterBar(
          selectedRiskLevel: state.selectedRiskLevel,
          onRiskLevelChanged: (risk) => cubit.changeRiskLevelFilter(risk),
          selectedIsResolved: state.selectedIsResolved,
          onResolvedChanged: (resolved) => cubit.changeResolvedFilter(resolved),
          selectedDriverId: state.selectedDriverId,
          onDriverIdApplied: (id) => cubit.filterByDriverId(id),
          onClearDriverFilter: () => cubit.clearDriverFilter(),
        ),
        const SizedBox(height: 14),
        Expanded(child: _buildAlertsContent(context, state, cubit)),
      ],
    );
  }

  Widget _buildAlertsContent(
    BuildContext context,
    AiAlertsState state,
    AiAlertsCubit cubit,
  ) {
    if (state.isLoading && state.alerts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_rounded, size: 56, color: context.textMuted),
            const SizedBox(height: 12),
            Text(
              'لا توجد تنبيهات ذكاء اصطناعي تطابق التصفية الحالية.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: state.alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.alerts[index];
              return AiAlertCard(
                alert: item,
                onTap: () {
                  cubit.fetchAlertDetails(item.id);
                },
              );
            },
          ),
        ),
        if (state.meta.lastPage > 1 || state.meta.total > 0)
          AdminPagination(
            meta: state.meta,
            enabled: !state.isLoading,
            onPageChanged: (newPage) => cubit.fetchAlerts(page: newPage),
          ),
      ],
    );
  }

  // ── Tab 2: Audits Tab ─────────────────────────────────────────────────────
  Widget _buildAuditsTab(
    BuildContext context,
    AiAlertsState state,
    AiAlertsCubit cubit,
  ) {
    final decisionFilters = [
      {'key': null, 'label': 'جميع القرارات'},
      {'key': 0, 'label': '0 - بدون إجراء'},
      {'key': 1, 'label': '1 - مكافأة وتقييم ممتاز'},
      {'key': 2, 'label': '2 - مخالفة متوسطة'},
      {'key': 3, 'label': '3 - تحذير رسمي'},
      {'key': 4, 'label': '4 - مراجعة وتدخل إداري'},
      {'key': 5, 'label': '5 - إيقاف نهائي'},
    ];

    return Column(
      children: [
        // Decision filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: decisionFilters.map((f) {
              final code = f['key'] as int?;
              final label = f['label'] as String;
              final isSelected = state.selectedDecisionCodeFilter == code;

              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => cubit.changeDecisionCodeFilter(code),
                  selectedColor: context.primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? context.onPrimary : context.textTertiary,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(child: _buildAuditsContent(context, state, cubit)),
      ],
    );
  }

  Widget _buildAuditsContent(
    BuildContext context,
    AiAlertsState state,
    AiAlertsCubit cubit,
  ) {
    if (state.isLoadingAudits && state.audits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.audits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rule_folder_outlined, size: 56, color: context.textMuted),
            const SizedBox(height: 12),
            Text(
              'لا توجد سجلات تدقيق ذكاء اصطناعي حالياً.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: state.audits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final audit = state.audits[index];
              return AiAuditCard(audit: audit);
            },
          ),
        ),
        if (state.auditsMeta.lastPage > 1 || state.auditsMeta.total > 0)
          AdminPagination(
            meta: state.auditsMeta,
            enabled: !state.isLoadingAudits,
            onPageChanged: (newPage) => cubit.fetchAudits(page: newPage),
          ),
      ],
    );
  }
}
