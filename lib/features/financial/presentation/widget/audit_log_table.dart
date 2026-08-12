import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/financial_audit_log_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// جدول سجل عمليات المشرفين.
/// كل قيم `metadata` تُقرأ بشكل آمن ولا يُفترض وجود أي مفتاح.
class AuditLogTable extends StatelessWidget {
  final List<FinancialAuditLogModel> logs;

  const AuditLogTable({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 940),
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(context.surfaceVariant),
              headingTextStyle: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: context.textSecondary,
              ),
              dataTextStyle:
                  TextStyle(fontSize: 12, color: context.textPrimary),
              dividerThickness: 0.6,
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('الرقم المرجعي')),
                DataColumn(label: Text('المشرف')),
                DataColumn(label: Text('الإجراء')),
                DataColumn(label: Text('العنصر')),
                DataColumn(label: Text('الحالة')),
                DataColumn(label: Text('التاريخ')),
                DataColumn(label: Text('بيانات إضافية')),
              ],
              rows: [
                for (final log in logs)
                  DataRow(
                    cells: [
                      DataCell(Text('${log.id}')),
                      DataCell(
                        Text(
                          log.referenceNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(Text(AdminFormat.orDash(log.adminName))),
                      DataCell(Text(AdminFormat.orDash(log.action))),
                      DataCell(
                        Text(
                          log.entityId == null ? '—' : '#${log.entityId}',
                        ),
                      ),
                      DataCell(AdminStatusChip(status: log.status)),
                      DataCell(Text(AdminFormat.dateTime(log.createdAt))),
                      DataCell(_ExtraMetadataCell(log: log)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// يعرض بقية مفاتيح `metadata` غير المعروفة كما وردت من الخادم.
class _ExtraMetadataCell extends StatelessWidget {
  final FinancialAuditLogModel log;

  const _ExtraMetadataCell({required this.log});

  @override
  Widget build(BuildContext context) {
    final extras = log.extraMetadata;
    if (extras.isEmpty) {
      return Text('—', style: TextStyle(color: context.textMuted));
    }

    final summary = extras.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('  •  ');

    return Tooltip(
      message: summary,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Text(
          summary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: context.textMuted),
        ),
      ),
    );
  }
}
