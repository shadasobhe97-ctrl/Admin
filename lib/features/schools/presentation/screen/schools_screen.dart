import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../zones/data/models/zone_model.dart';
import '../../data/models/school_model.dart';
import '../../logic/cubit/schools_cubit.dart';
import '../../logic/state/schools_state.dart';
import '../widget/school_card.dart';
import '../widget/school_form.dart';
import '../widget/school_search_bar.dart';
import 'school_details_screen.dart';

class SchoolsScreen extends StatelessWidget {
  const SchoolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SchoolsCubit>(
      create: (_) => sl<SchoolsCubit>()..fetchSchools(),
      child: const SchoolsViewContent(),
    );
  }
}

class SchoolsViewContent extends StatelessWidget {
  const SchoolsViewContent({super.key});

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? context.dangerColor : context.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSchoolForm(
    BuildContext context, {
    required List<ZoneModel> zones,
    SchoolModel? school,
  }) {
    final cubit = context.read<SchoolsCubit>();
    showDialog(
      context: context,
      builder: (_) => SchoolFormDialog(
        school: school,
        zones: zones,
        onCreate: (payload) => cubit.addSchool(payload),
        onUpdate: (payload) => cubit.updateSchool(school!.id, payload),
      ),
    );
  }

  /// الخادم يمنع الحذف عند وجود أطفال مسجّلين، ورسالته تُعرض كما هي.
  void _confirmDelete(BuildContext context, SchoolModel school) {
    final cubit = context.read<SchoolsCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: dialogContext.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'تأكيد حذف المدرسة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: dialogContext.textPrimary,
            ),
          ),
          content: Text(
            'هل تريد حذف مدرسة "${school.name}" نهائياً؟\n'
            'يمنع النظام الحذف إذا كان هناك أطفال مسجّلون بها.',
            style: TextStyle(
              fontSize: 13,
              color: dialogContext.textSecondary,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogContext.dangerColor,
                foregroundColor: dialogContext.onPrimary,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.deleteSchool(school.id);
              },
              child: const Text('حذف المدرسة'),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, int schoolId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SchoolDetailsScreen(schoolId: schoolId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SchoolsCubit, SchoolsState>(
      listener: (context, state) {
        if (state is SchoolActionSuccess) {
          _showSnack(context, state.message);
        } else if (state is SchoolActionError) {
          _showSnack(context, state.message, isError: true);
        }
      },
      buildWhen: (_, state) =>
          state is! SchoolActionSuccess && state is! SchoolActionError,
      builder: (context, state) {
        final cubit = context.read<SchoolsCubit>();

        final zones = switch (state) {
          SchoolsLoaded() => state.zones,
          SchoolsEmpty() => state.zones,
          _ => cubit.cachedZones,
        };

        final searchQuery = switch (state) {
          SchoolsLoaded() => state.searchQuery,
          SchoolsEmpty() => state.searchQuery,
          _ => null,
        };

        final statusFilter = switch (state) {
          SchoolsLoaded() => state.statusFilter,
          SchoolsEmpty() => state.statusFilter,
          _ => null,
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              state: state,
              onAdd: () => _openSchoolForm(context, zones: zones),
            ),
            const SizedBox(height: 14),

            SchoolSearchBar(
              initialQuery: searchQuery,
              onSearch: cubit.search,
              onClear: () => cubit.search(null),
            ),
            const SizedBox(height: 10),

            _StatusFilterBar(
              selected: statusFilter,
              onSelect: cubit.filterByStatus,
            ),
            const SizedBox(height: 14),

            Expanded(child: _buildBody(context, state, zones)),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    SchoolsState state,
    List<ZoneModel> zones,
  ) {
    final cubit = context.read<SchoolsCubit>();

    if (state is SchoolsLoading || state is SchoolActionLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (state is SchoolsError) {
      return _SchoolsMessage(
        icon: Icons.cloud_off_rounded,
        color: context.dangerColor,
        title: 'تعذّر تحميل المدارس',
        body: state.message,
        actionLabel: 'إعادة المحاولة',
        onAction: cubit.fetchSchools,
      );
    }

    if (state is SchoolsEmpty) {
      // التمييز بين "لا توجد بيانات" و"لا نتائج للبحث الحالي".
      if (state.isFiltered) {
        return _SchoolsMessage(
          icon: Icons.search_off_rounded,
          color: context.textMuted,
          title: 'لا توجد نتائج مطابقة',
          body: 'جرّب تعديل كلمة البحث أو إلغاء فلتر الحالة.',
          actionLabel: 'إلغاء الفلاتر',
          onAction: cubit.clearFilters,
        );
      }

      return _SchoolsMessage(
        icon: Icons.school_outlined,
        color: context.textMuted,
        title: 'لا توجد مدارس مسجّلة',
        body: 'ابدأ بإضافة أول مدرسة وربطها بمنطقتها الجغرافية.',
        actionLabel: 'إضافة مدرسة',
        onAction: () => _openSchoolForm(context, zones: zones),
      );
    }

    if (state is SchoolsLoaded) {
      return ListView.builder(
        itemCount: state.schools.length,
        itemBuilder: (_, index) {
          final school = state.schools[index];
          return SchoolCard(
            school: school,
            onTapDetails: () => _openDetails(context, school.id),
            onEdit: () =>
                _openSchoolForm(context, zones: state.zones, school: school),
            onDelete: () => _confirmDelete(context, school),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class _Header extends StatelessWidget {
  final SchoolsState state;
  final VoidCallback onAdd;

  const _Header({required this.state, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final countLabel = state is SchoolsLoaded
        ? '${(state as SchoolsLoaded).schools.length} من '
            '${(state as SchoolsLoaded).totalCount}'
        : null;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                'دليل المدارس والربط الجغرافي المعتمد',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              if (countLabel != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.infoBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.infoBorder),
                  ),
                  child: Text(
                    countLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.infoColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          tooltip: 'تحديث',
          onPressed: context.read<SchoolsCubit>().fetchSchools,
          icon: Icon(
            Icons.refresh_rounded,
            size: 19,
            color: context.textTertiary,
          ),
        ),
        const SizedBox(width: 6),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            foregroundColor: context.onPrimary,
          ),
          onPressed: onAdd,
          icon: const Icon(Icons.add_business_rounded, size: 16),
          label: const Text(
            'إضافة مدرسة جديدة',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// فلتر حالة الاعتماد، بالقيم المسموح بها من الخادم فقط.
class _StatusFilterBar extends StatelessWidget {
  final String? selected;
  final void Function(String? status) onSelect;

  const _StatusFilterBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'الكل',
          isSelected: selected == null,
          onTap: () => onSelect(null),
        ),
        const SizedBox(width: 8),
        for (final status in SchoolStatus.all) ...[
          _FilterChip(
            label: SchoolStatus.label(status),
            isSelected: selected == status,
            onTap: () => onSelect(status),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.borderSoft,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? context.onPrimary : context.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SchoolsMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  const _SchoolsMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 46, color: color),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.textMuted),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimary,
              ),
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
