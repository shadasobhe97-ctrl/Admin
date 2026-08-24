import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

class DriverChangeComparisonWidget extends StatelessWidget {
  final Map<String, dynamic> currentData;
  final Map<String, dynamic> proposedData;

  const DriverChangeComparisonWidget({
    super.key,
    required this.currentData,
    required this.proposedData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allKeys = {...currentData.keys, ...proposedData.keys}.toList();

    if (allKeys.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text('لا توجد تفاصيل مقارنة متوفرة في استجابة الخادم.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'البيانات الحالية (Current Data)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'البيانات المقترحة (Proposed Data)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...allKeys.map((key) {
          final currVal = currentData[key]?.toString() ?? 'غير محدد';
          final propVal = proposedData[key]?.toString() ?? 'غير محدد';
          final isChanged = currVal != propVal;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isChanged
                  ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.2) : const Color(0xFFFFFBEB))
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isChanged ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : theme.dividerColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _translateFieldKey(key),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        currVal,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                          decoration: isChanged ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_back_rounded, size: 16, color: context.primaryColor),
                    Expanded(
                      child: Text(
                        propVal,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isChanged ? const Color(0xFFD97706) : context.textPrimary,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _translateFieldKey(String key) {
    switch (key) {
      case 'plate_number':
      case 'plate':
        return 'رقم اللوحة المعدنية';
      case 'make':
      case 'brand':
        return 'الشركة المصنعة';
      case 'model':
        return 'موديل المركبة';
      case 'color':
        return 'لون المركبة';
      case 'year':
        return 'سنة الصنع';
      case 'phone_number':
      case 'phone':
        return 'رقم الهاتف';
      case 'full_name':
      case 'name':
        return 'الاسم الكامل';
      default:
        return key;
    }
  }
}
