import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/school_model.dart';
import '../../logic/cubit/schools_cubit.dart';
import '../../logic/state/schools_state.dart';
import '../widget/school_map_view_dialog.dart';


class SchoolDetailsScreen extends StatelessWidget {
  final int schoolId;

  const SchoolDetailsScreen({
    super.key,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SchoolsCubit>(
      create: (_) => sl<SchoolsCubit>()..fetchSchoolDetails(schoolId),
      child: const SchoolDetailsViewContent(),
    );
  }
}

class SchoolDetailsViewContent extends StatelessWidget {
  const SchoolDetailsViewContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المدرسة'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<SchoolsCubit, SchoolsState>(
          builder: (context, state) {
            if (state is SchoolDetailsLoading) {
              return Center(
                child: CircularProgressIndicator(color: theme.colorScheme.primary),
              );
            }

            if (state is SchoolActionError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 50,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('رجوع'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is SchoolDetailsLoaded) {
              final school = state.school;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.cardShadow,
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                            child: Icon(
                              Icons.school_rounded,
                              color: theme.colorScheme.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  school.name.isNotEmpty ? school.name : 'مدرسة بدون اسم',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'المعرف في النظام (ID): #${school.id}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                _StatusBadge(school: school),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: theme.colorScheme.outlineVariant),
                      const SizedBox(height: 12),
                      _detailItem(
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'العنوان الجغرافي',
                        value: school.address.isNotEmpty ? school.address : 'غير محدد',
                      ),
                      _detailItem(
                        context,
                        icon: Icons.map_outlined,
                        label: 'المنطقة الجغرافية',
                        value: school.zoneName != null && school.zoneName!.isNotEmpty
                            ? school.zoneName!
                            : (school.zoneId != null ? 'منطقة #${school.zoneId}' : 'غير محددة'),
                      ),
                      if (school.hasCoordinates)
                        InkWell(
                          onTap: () {
                            SchoolMapViewDialog.show(
                              context,
                              lat: school.lat!,
                              lng: school.lng!,
                              schoolName: school.name,
                            );
                          },
                          child: _detailItem(
                            context,
                            icon: Icons.my_location_rounded,
                            label: 'الإحداثيات الجغرافية (GPS)',
                            value: 'انقر لعرض الموقع على الخريطة\n${school.coordinatesLabel}',
                            isClickable: true,
                          ),
                        )
                      else
                        _detailItem(
                          context,
                          icon: Icons.my_location_rounded,
                          label: 'الإحداثيات الجغرافية (GPS)',
                          value: 'غير متوفرة',
                        ),
                      _detailItem(
                        context,
                        icon: Icons.verified_outlined,
                        label: 'حالة الاعتماد',
                        value: school.statusLabel,
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _detailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isClickable = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isClickable ? theme.colorScheme.primary : null,
                    decoration: isClickable ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
          if (isClickable)
            Icon(Icons.open_in_new_rounded, size: 16, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}

/// شارة حالة الاعتماد — ألوانها من الثيم لا من قيم ثابتة.
class _StatusBadge extends StatelessWidget {
  final SchoolModel school;

  const _StatusBadge({required this.school});

  @override
  Widget build(BuildContext context) {
    final isApproved = school.isApproved;
    final foreground = isApproved ? context.successColor : context.warningColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved ? context.successBg : context.warningBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApproved ? context.successBorder : context.warningBorder,
        ),
      ),
      child: Text(
        school.statusLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: foreground,
        ),
      ),
    );
  }
}
