import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/cubit/ai_alerts_cubit.dart';
import '../../logic/state/ai_alerts_state.dart';

/// عنصر خيار مفرد داخل القائمة المنسدلة
class FilterOptionItem<T> {
  final T value;
  final String label;

  const FilterOptionItem({required this.value, required this.label});
}

/// زر القائمة المنسدلة المدمج (Compact Filter Dropdown)
class CompactFilterDropdown<T> extends StatelessWidget {
  final String title;
  final T selectedValue;
  final String selectedLabel;
  final IconData icon;
  final List<FilterOptionItem<T>> options;
  final ValueChanged<T> onChanged;

  const CompactFilterDropdown({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.selectedLabel,
    required this.icon,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustom = selectedValue != options.first.value;

    return PopupMenuButton<T>(
      initialValue: selectedValue,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: theme.cardColor,
      itemBuilder: (context) {
        return options.map((opt) {
          final isSelected = opt.value == selectedValue;
          return PopupMenuItem<T>(
            value: opt.value,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 16,
                  color: isSelected ? context.primaryColor : context.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? context.primaryColor : context.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCustom ? context.primaryColor : theme.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isCustom ? context.primaryColor : context.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              '$title: ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            Text(
              selectedLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isCustom ? context.primaryColor : context.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: context.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// شريط البحث المكتمل الذي يمتد بجانب الفلاتر
class FullWidthSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final bool hasActiveQuery;

  const FullWidthSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
    this.hasActiveQuery = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        style: TextStyle(fontSize: 13, color: context.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'ابحث برقم السائق (driver_id) أو الملاحظات والتنبيهات...',
          hintStyle: TextStyle(fontSize: 12.5, color: context.textMuted),
          prefixIcon: Icon(Icons.search_rounded, size: 19, color: context.primaryColor),
          suffixIcon: hasActiveQuery || controller.text.isNotEmpty
              ? IconButton(
                  tooltip: 'إلغاء البحث',
                  icon: Icon(Icons.close_rounded, size: 18, color: context.textMuted),
                  onPressed: () {
                    controller.clear();
                    onClear();
                  },
                )
              : IconButton(
                  tooltip: 'بحث',
                  icon: Icon(Icons.arrow_forward_rounded, size: 18, color: context.primaryColor),
                  onPressed: () => onSubmitted(controller.text),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

/// الشريط العلوي المحتوي على الفلاتر (مستوى الخطورة + الحالة) على اليمين وشريط البحث على اليسار
class TopFilterControlBar extends StatelessWidget {
  final AiAlertsState state;
  final AiAlertsCubit cubit;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchClear;

  const TopFilterControlBar({
    super.key,
    required this.state,
    required this.cubit,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.onSearchClear,
  });

  @override
  Widget build(BuildContext context) {
    final riskOptions = const [
      FilterOptionItem<String>(value: 'all', label: 'كل المستويات'),
      FilterOptionItem<String>(value: 'CRITICAL', label: 'حرج'),
      FilterOptionItem<String>(value: 'HIGH', label: 'مرتفع'),
    ];

    final resolvedOptions = const [
      FilterOptionItem<String>(value: 'all', label: 'الكل'),
      FilterOptionItem<String>(value: 'unresolved', label: 'قيد المتابعة'),
      FilterOptionItem<String>(value: 'resolved', label: 'تم الحل'),
    ];

    final currentRiskLabel = riskOptions.firstWhere(
      (e) => e.value == state.selectedRiskLevel,
      orElse: () => riskOptions.first,
    ).label;

    final currentResolvedKey = state.selectedIsResolved == null
        ? 'all'
        : (state.selectedIsResolved! ? 'resolved' : 'unresolved');

    final currentResolvedLabel = resolvedOptions.firstWhere(
      (e) => e.value == currentResolvedKey,
      orElse: () => resolvedOptions.first,
    ).label;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 650;

        final riskDropdown = CompactFilterDropdown<String>(
          title: 'مستوى الخطورة',
          selectedValue: state.selectedRiskLevel,
          selectedLabel: currentRiskLabel,
          icon: Icons.warning_amber_rounded,
          options: riskOptions,
          onChanged: (val) => cubit.changeRiskLevelFilter(val),
        );

        final statusDropdown = CompactFilterDropdown<String>(
          title: 'الحالة',
          selectedValue: currentResolvedKey,
          selectedLabel: currentResolvedLabel,
          icon: Icons.check_circle_outline_rounded,
          options: resolvedOptions,
          onChanged: (val) {
            if (val == 'all') {
              cubit.changeResolvedFilter(null);
            } else if (val == 'resolved') {
              cubit.changeResolvedFilter(true);
            } else if (val == 'unresolved') {
              cubit.changeResolvedFilter(false);
            }
          },
        );

        final searchBar = FullWidthSearchBar(
          controller: searchController,
          hasActiveQuery: state.selectedDriverId != null,
          onSubmitted: onSearchSubmitted,
          onClear: onSearchClear,
        );

        if (isCompact) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: riskDropdown),
                  const SizedBox(width: 8),
                  Expanded(child: statusDropdown),
                ],
              ),
              const SizedBox(height: 8),
              searchBar,
            ],
          );
        }

        return Row(
          children: [
            riskDropdown,
            const SizedBox(width: 8),
            statusDropdown,
            const SizedBox(width: 10),
            Expanded(child: searchBar),
          ],
        );
      },
    );
  }
}
