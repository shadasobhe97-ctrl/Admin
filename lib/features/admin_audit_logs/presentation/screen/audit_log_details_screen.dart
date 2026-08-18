import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/audit_log_model.dart';
import '../../logic/cubit/audit_logs_cubit.dart';
import '../../logic/state/audit_logs_state.dart';
import '../widget/audit_changes_table.dart';
import '../widget/audit_result_chip.dart';

/// تفاصيل سطر واحد من سجل الإجراءات — للقراءة فقط.
class AuditLogDetailsScreen extends StatelessWidget {
  final int logId;

  const AuditLogDetailsScreen({super.key, required this.logId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuditLogsCubit>(
      create: (_) => sl<AuditLogsCubit>()..loadDetails(logId),
      child: _AuditLogDetailsView(logId: logId),
    );
  }
}

class _AuditLogDetailsView extends StatelessWidget {
  final int logId;

  const _AuditLogDetailsView({required this.logId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل الإجراء #$logId'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<AuditLogsCubit, AuditLogsState>(
          builder: (context, state) {
            if (state is AuditLogDetailsLoading || state is AuditLogsInitial) {
              return const AdminLoadingView(
                message: 'جارٍ جلب تفاصيل الإجراء…',
              );
            }

            if (state is AuditLogDetailsError) {
              return AdminErrorView(
                message: state.message,
                onRetry: state.isForbidden
                    ? null
                    : () => context.read<AuditLogsCubit>().loadDetails(logId),
              );
            }

            if (state is AuditLogDetailsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _DetailsBody(log: state.log),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final AuditLogModel log;

  const _DetailsBody({required this.log});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    log.actionLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: context.textPrimary,
                    ),
                  ),
                  AuditGroupChip(actionGroup: log.actionGroup),
                  if (log.hasResult) AuditResultChip(result: log.result),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: context.dividerLine, height: 1),
              const SizedBox(height: 12),

              AdminInfoRow(label: 'المشرف المنفِّذ', value: log.adminName, emphasized: true),
              if (log.adminRole != null)
                AdminInfoRow(label: 'الدور', value: log.adminRole!),
              if (log.adminId != null)
                AdminInfoRow(label: 'معرّف المشرف', value: '#${log.adminId}'),

              AdminInfoRow(label: 'نوع العنصر', value: log.entityTypeLabel),
              AdminInfoRow(label: 'العنصر المتأثر', value: log.entityDescription),
              if (log.entityId != null)
                AdminInfoRow(label: 'معرّف العنصر', value: '#${log.entityId}'),

              AdminInfoRow(
                label: 'رمز الإجراء',
                value: log.action,
              ),
              AdminInfoRow(
                label: 'وقت التنفيذ',
                value: AdminFormat.dateTime(log.createdAt),
                emphasized: true,
              ),
            ],
          ),
        ),

        if (log.hasReason) ...[
          const SizedBox(height: 16),
          AdminPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  icon: Icons.notes_rounded,
                  title: 'السبب / الملاحظة',
                ),
                const SizedBox(height: 10),
                Text(
                  log.reason!,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
        AdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                icon: Icons.compare_arrows_rounded,
                title: 'التغييرات المنفَّذة',
                trailing: log.hasChanges
                    ? Text(
                        '${log.changes.length} حقل',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.textMuted,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              if (log.hasChanges)
                AuditChangesTable(changes: log.changes)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: Text(
                      'هذا الإجراء قرار أو عملية تنفيذية — لا يتضمّن تعديل حقول.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        Row(
          children: [
            Icon(Icons.lock_rounded, size: 14, color: context.textTertiary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'سجل التدقيق للقراءة فقط ولا يمكن تعديله أو حذفه.',
                style: TextStyle(fontSize: 11, color: context.textTertiary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: context.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
