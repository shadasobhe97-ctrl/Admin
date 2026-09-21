import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/remote_circle_avatar.dart';
import '../../data/models/parent_model.dart';
import '../../logic/cubit/parents_cubit.dart';
import '../../logic/cubit/parents_state.dart';
import '../widgets/parent_details_dialog.dart';

class ParentsScreen extends StatelessWidget {
  const ParentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParentsCubit>(
      create: (context) => sl<ParentsCubit>()..fetchParents(),
      child: const _ParentsScreenContent(),
    );
  }
}

class _ParentsScreenContent extends StatefulWidget {
  const _ParentsScreenContent();

  @override
  State<_ParentsScreenContent> createState() => _ParentsScreenContentState();
}

class _ParentsScreenContentState extends State<_ParentsScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        body: BlocConsumer<ParentsCubit, ParentsState>(
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
                  backgroundColor: context.successColor,
                ),
              );
            }
          },
          builder: (context, state) {
            final allParents = state.parents;
            final filteredParents = state.filteredParents;

            final totalCount = allParents.length;
            final activeCount = allParents.where((p) => p.isActive).length;
            final inactiveCount = allParents.where((p) => !p.isActive).length;
            final totalChildren = allParents.fold<int>(
                0, (sum, p) => sum + (p.childrenCount > 0 ? p.childrenCount : p.children.length));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Screen Header & Actions ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.family_restroom_rounded,
                                color: context.primaryColor, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              'عرض وإدارة أولياء الأمور',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'استعراض كامل قائمة أولياء الأمور وحساباتهم والأبناء المسجلين في المنظومة',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    IconButton.filledTonal(
                      onPressed: () => context.read<ParentsCubit>().fetchParents(),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      tooltip: 'تحديث البيانات',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── 2. KPI Summary Cards ────────────────────────────────────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    return GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: isWide ? 2.5 : 2.2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildKpiCard(
                          context,
                          title: 'إجمالي أولياء الأمور',
                          value: '$totalCount',
                          icon: Icons.people_alt_rounded,
                          color: context.primaryColor,
                        ),
                        _buildKpiCard(
                          context,
                          title: 'الحسابات النشطة',
                          value: '$activeCount',
                          icon: Icons.check_circle_rounded,
                          color: context.successColor,
                        ),
                        _buildKpiCard(
                          context,
                          title: 'الحسابات المعطلة',
                          value: '$inactiveCount',
                          icon: Icons.pause_circle_rounded,
                          color: context.dangerColor,
                        ),
                        _buildKpiCard(
                          context,
                          title: 'إجمالي الأطفال',
                          value: '$totalChildren',
                          icon: Icons.child_care_rounded,
                          color: Colors.amber.shade700,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ── 3. Search & Filter Bar ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              context.read<ParentsCubit>().searchParents(val),
                          style: TextStyle(fontSize: 13, color: context.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'البحث باسم ولي الأمر، رقم الهاتف، الإيميل، أو المعرف...',
                            prefixIcon: Icon(Icons.search_rounded,
                                color: context.primaryColor),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<ParentsCubit>().searchParents('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Filter Pills
                      Wrap(
                        spacing: 6,
                        children: [
                          _buildFilterPill(
                            context,
                            label: 'الكل ($totalCount)',
                            filterKey: 'all',
                            currentFilter: state.statusFilter,
                          ),
                          _buildFilterPill(
                            context,
                            label: 'النشطين ($activeCount)',
                            filterKey: 'active',
                            currentFilter: state.statusFilter,
                          ),
                          _buildFilterPill(
                            context,
                            label: 'المعطلين ($inactiveCount)',
                            filterKey: 'inactive',
                            currentFilter: state.statusFilter,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 4. Main Table / List Body ──────────────────────────────────
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredParents.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 48, color: context.textTertiary),
                                  const SizedBox(height: 12),
                                  Text(
                                    'لم يتم العثور على أي أولياء أمور يطابقون خيارات البحث الحالية',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ListView.separated(
                                  itemCount: filteredParents.length,
                                  separatorBuilder: (_, __) =>
                                      Divider(height: 1, color: theme.dividerColor),
                                  itemBuilder: (context, index) {
                                    final parent = filteredParents[index];
                                    return _buildParentRow(context, parent);
                                  },
                                ),
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: context.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context, {
    required String label,
    required String filterKey,
    required String currentFilter,
  }) {
    final isSelected = currentFilter == filterKey;
    return InkWell(
      onTap: () => context.read<ParentsCubit>().setStatusFilter(filterKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor
              : context.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : context.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildParentRow(BuildContext context, ParentModel parent) {
    final cubit = context.read<ParentsCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          RemoteCircleAvatar(
            rawUrl: parent.avatarUrl,
            radius: 24,
            initials: parent.fullName.isNotEmpty ? parent.fullName[0] : 'و',
            foregroundColor: context.primaryColor,
            backgroundColor: context.primaryColor.withValues(alpha: 0.15),
          ),
          const SizedBox(width: 14),

          // Parent Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      parent.fullName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${parent.id}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: context.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_android_rounded,
                        size: 14, color: context.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      parent.phoneNumber,
                      style: TextStyle(fontSize: 12, color: context.textSecondary),
                    ),
                    if (parent.email != null && parent.email!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.email_outlined,
                          size: 14, color: context.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          parent.email!,
                          style:
                              TextStyle(fontSize: 12, color: context.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Children count badge
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: context.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.child_care_rounded,
                          size: 16, color: context.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        '${parent.childrenCount} أطفال',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status Badges
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 6,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (parent.isActive
                            ? context.successColor
                            : context.dangerColor)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    parent.isActive ? 'نشط' : 'معطل',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: parent.isActive
                          ? context.successColor
                          : context.dangerColor,
                    ),
                  ),
                ),
                if (parent.isTrusted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'موثوق',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => ParentDetailsDialog.show(context, parent, cubit: cubit),
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: const Text('التفاصيل', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              if (!parent.isActive)
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: context.successColor.withValues(alpha: 0.15),
                    foregroundColor: context.successColor,
                  ),
                  onPressed: () => cubit.activateParent(parent.id),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  tooltip: 'إعادة تفعيل الحساب',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
