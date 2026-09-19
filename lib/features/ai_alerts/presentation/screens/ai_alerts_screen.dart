import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../../logic/cubit/ai_alerts_cubit.dart';
import '../../logic/state/ai_alerts_state.dart';
import '../widgets/ai_alert_card.dart';
import '../widgets/ai_alert_filter_bar.dart';
import 'ai_alert_details_screen.dart';

/// نقطة الدخول لميزة تنبيهات الذكاء الاصطناعي — توفّر الـ Cubit وتجلب
/// الصفحة الأولى فور الفتح، بنفس نمط بقية الميزات المشابهة.
class AiAlertsScreen extends StatelessWidget {
  const AiAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiAlertsCubit>(
      create: (_) => sl<AiAlertsCubit>()..fetchAlerts(),
      child: const _AiAlertsView(),
    );
  }
}

class _AiAlertsView extends StatefulWidget {
  const _AiAlertsView();

  @override
  State<_AiAlertsView> createState() => _AiAlertsViewState();
}

class _AiAlertsViewState extends State<_AiAlertsView> {
  int? _activeDetailsAlertId;

  @override
  Widget build(BuildContext context) {
    if (_activeDetailsAlertId != null) {
      return AiAlertDetailsScreen(
        alertId: _activeDetailsAlertId!,
        onBack: () => setState(() => _activeDetailsAlertId = null),
      );
    }

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
      },
      builder: (context, state) {
        final cubit = context.read<AiAlertsCubit>();

        return RefreshIndicator(
          onRefresh: () async {
            await cubit.fetchAlerts(page: state.meta.currentPage);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تنبيهات الذكاء الاصطناعي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مراقبة الأنماط السلوكية التي رصدها الذكاء الاصطناعي عن السائقين وما نتج عنها.',
                        style: TextStyle(fontSize: 12, color: context.textMuted),
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'إعادة تحديث القائمة',
                    icon: Icon(Icons.refresh_rounded, color: context.primaryColor),
                    onPressed: () => cubit.fetchAlerts(page: state.meta.currentPage),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AiAlertFilterBar(
                selectedRiskLevel: state.selectedRiskLevel,
                onRiskLevelChanged: (risk) => cubit.changeRiskLevelFilter(risk),
                selectedIsResolved: state.selectedIsResolved,
                onResolvedChanged: (resolved) => cubit.changeResolvedFilter(resolved),
                selectedDriverId: state.selectedDriverId,
                onDriverIdApplied: (id) => cubit.filterByDriverId(id),
                onClearDriverFilter: () => cubit.clearDriverFilter(),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBodyContent(context, state, cubit)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    AiAlertsState state,
    AiAlertsCubit cubit,
  ) {
    if (state.isLoading && state.alerts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: context.dangerColor),
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: TextStyle(color: context.textPrimary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => cubit.fetchAlerts(page: 1),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.alerts.isEmpty) {
      final hasActiveFilter = state.selectedRiskLevel != 'all' ||
          state.selectedIsResolved != null ||
          state.selectedDriverId != null;

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
            if (hasActiveFilter) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  cubit.clearDriverFilter();
                  cubit.changeResolvedFilter(null);
                  cubit.changeRiskLevelFilter('all');
                },
                child: const Text('عرض جميع التنبيهات'),
              ),
            ],
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
                  setState(() => _activeDetailsAlertId = item.id);
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
}
