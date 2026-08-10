import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/school_model.dart';
import '../../data/models/zone_model.dart';
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

class SchoolsViewContent extends StatefulWidget {
  const SchoolsViewContent({super.key});

  @override
  State<SchoolsViewContent> createState() => _SchoolsViewContentState();
}

class _SchoolsViewContentState extends State<SchoolsViewContent> {
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openAddSchoolForm(BuildContext context, List<ZoneModel> zones) {
    showDialog(
      context: context,
      builder: (_) => SchoolFormDialog(
        zones: zones,
        onSubmit: (payload) {
          context.read<SchoolsCubit>().addSchool(payload);
        },
      ),
    );
  }

  void _openEditSchoolForm(BuildContext context, SchoolModel school, List<ZoneModel> zones) {
    showDialog(
      context: context,
      builder: (_) => SchoolFormDialog(
        school: school,
        zones: zones,
        onSubmit: (payload) {
          context.read<SchoolsCubit>().updateSchool(school.id, payload);
        },
      ),
    );
  }

  void _confirmDeleteSchool(BuildContext context, SchoolModel school) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: theme.cardColor,
          title: const Text('تأكيد حذف المدرسة'),
          content: Text('هل أنت متأكد من رغبتك في حذف مدرسة "${school.name}" من النظام نهائياً؟'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<SchoolsCubit>().deleteSchool(school.id);
              },
              child: const Text('حذف المدرسة'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, int schoolId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SchoolDetailsScreen(schoolId: schoolId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SchoolsCubit, SchoolsState>(
      listener: (context, state) {
        if (state is SchoolActionSuccess) {
          _showSnack(state.message, isError: false);
        } else if (state is SchoolActionError) {
          _showSnack(state.message, isError: true);
        }
      },
      builder: (context, state) {
        List<SchoolModel> schools = [];
        List<ZoneModel> zones = [];
        String? searchQuery;
        bool isLoading = false;
        String? errorMessage;

        if (state is SchoolsLoading || state is SchoolActionLoading) {
          isLoading = true;
        } else if (state is SchoolsLoaded) {
          schools = state.schools;
          zones = state.zones;
          searchQuery = state.searchQuery;
        } else if (state is SchoolsEmpty) {
          zones = state.zones;
          searchQuery = state.searchQuery;
        } else if (state is SchoolsError) {
          errorMessage = state.message;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'دليل المدارس والربط الجغرافي المعتمد',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _openAddSchoolForm(
                    context,
                    zones.isNotEmpty ? zones : context.read<SchoolsCubit>().cachedZones,
                  ),
                  icon: const Icon(Icons.school, size: 16),
                  label: const Text('إضافة مدرسة جديدة'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            SchoolSearchBar(
              initialQuery: searchQuery,
              onSearch: (query) {
                context.read<SchoolsCubit>().fetchSchools(search: query);
              },
              onClear: () {
                context.read<SchoolsCubit>().fetchSchools(search: null);
              },
            ),
            const SizedBox(height: 16),

            // Main Content Area
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : errorMessage != null
                      ? Center(
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
                                const SizedBox(height: 12),
                                Text(
                                  errorMessage,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<SchoolsCubit>().fetchSchools(),
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : schools.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 60,
                                    color: theme.colorScheme.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    (searchQuery != null && searchQuery.isNotEmpty)
                                        ? 'لا توجد نتائج بحث مطابقة لـ "$searchQuery"'
                                        : 'لا توجد مدارس مسجلة حالياً في النظام',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => context.read<SchoolsCubit>().fetchSchools(),
                                    child: const Text('تحديث البيانات'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: schools.length,
                              itemBuilder: (ctx, index) {
                                final school = schools[index];
                                return SchoolCard(
                                  school: school,
                                  onTapDetails: () => _navigateToDetails(context, school.id),
                                  onEdit: () => _openEditSchoolForm(
                                    context,
                                    school,
                                    zones.isNotEmpty ? zones : context.read<SchoolsCubit>().cachedZones,
                                  ),
                                  onDelete: () => _confirmDeleteSchool(context, school),
                                );
                              },
                            ),
            ),
          ],
        );
      },
    );
  }
}
