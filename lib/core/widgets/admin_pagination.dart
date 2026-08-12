import 'package:flutter/material.dart';

import '../utils/admin_theme_context.dart';
import '../models/pagination_meta_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// شريط تنقّل بين الصفحات يعتمد كلياً على `meta` القادمة من الخادم.
class AdminPagination extends StatelessWidget {
  final PaginationMetaModel meta;
  final ValueChanged<int> onPageChanged;

  /// يُعطَّل التنقّل أثناء وجود عملية جارية.
  final bool enabled;

  const AdminPagination({
    super.key,
    required this.meta,
    required this.onPageChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrevious = meta.currentPage > 1;
    final hasNext = meta.currentPage < meta.lastPage;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'إجمالي السجلات: ${AdminFormat.count(meta.total)}'
            '  •  ${AdminFormat.count(meta.perPage)} لكل صفحة',
            style: TextStyle(fontSize: 11.5, color: context.textMuted),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'الصفحة السابقة',
                onPressed: enabled && hasPrevious
                    ? () => onPageChanged(meta.currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderSoft),
                ),
                child: Text(
                  'صفحة ${meta.currentPage} من ${meta.lastPage}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: context.textSecondary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'الصفحة التالية',
                onPressed: enabled && hasNext
                    ? () => onPageChanged(meta.currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
