import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/permissions/authorization_service.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/driver_review_model.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_empty_state.dart';
import '../widgets/driver_review_card.dart';
import '../widgets/driver_search_field.dart';

class DriverReviewsScreen extends StatelessWidget {
  const DriverReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AuthorizationService.hasPermission('drivers.reviews.view') &&
        !AuthorizationService.hasPermission('driver_reviews.manage') &&
        !AuthorizationService.hasPermission('*')) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person_rounded, size: 56, color: context.warningColor),
              const SizedBox(height: 16),
              Text(
                'صلاحية غير كافية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'استعراض قسم تقييمات السائقين يتطلب صلاحية (drivers.reviews.view) أو (driver_reviews.manage).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: context.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) =>
          sl<DriversManagementCubit>()..fetchAllDriverReviews(),
      child: const _DriverReviewsContent(),
    );
  }
}

class _DriverReviewsContent extends StatefulWidget {
  const _DriverReviewsContent();

  @override
  State<_DriverReviewsContent> createState() => _DriverReviewsContentState();
}

class _DriverReviewsContentState extends State<_DriverReviewsContent> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _ratingFilter = 'all'; // 'all', 'critical', 'positive'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<DriversManagementCubit, DriversManagementState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state.successMessage != null &&
                state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<DriversManagementCubit>();

            // تصفية التقييمات بناءً على نص البحث وفئة التقييم
            final filteredReviews = state.reviews.where((review) {
              if (_ratingFilter == 'critical' && review.rating > 2) {
                return false;
              }
              if (_ratingFilter == 'positive' && review.rating < 4) {
                return false;
              }
              if (_searchQuery.trim().isEmpty) return true;
              final q = _searchQuery.trim().toLowerCase();
              final driverName = review.driverName.toLowerCase();
              final parentName = (review.parentName ?? '').toLowerCase();
              final comment = review.comment.toLowerCase();
              final ratingStr = review.rating.toString();
              return driverName.contains(q) ||
                  parentName.contains(q) ||
                  comment.contains(q) ||
                  ratingStr.contains(q);
            }).toList();

            return RefreshIndicator(
              onRefresh: () async => await cubit.fetchAllDriverReviews(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Title Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التقييمات والتعليقات على السائقين',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'مراجعة تقييمات أولياء الأمور والركاب لخدمات السائقين، التعليقات الميدانية وإدارة المحتوى',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        IconButton.filledTonal(
                          onPressed: () => cubit.fetchAllDriverReviews(),
                          icon: Icon(Icons.refresh_rounded,
                              color: context.primaryColor),
                          tooltip: 'تحديث التقييمات من Backend',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 1.5 Review KPI Summary Cards
                    _buildReviewStats(context, state.reviews),
                    const SizedBox(height: 16),

                    // 2. Search Field
                    DriverSearchField(
                      hintText:
                          'ابحث باسم السائق، اسم ولي الأمر، أو التعليق...',
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      onClear: _searchQuery.isNotEmpty
                          ? () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            }
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // 3. Content List / Loading / Empty
                    if (state.isLoadingReviews)
                      SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: context.primaryColor),
                        ),
                      )
                    else if (state.isReviewsEmpty)
                      DriverEmptyState(
                        title: 'لا توجد تقييمات أو تعليقات حالياً',
                        description:
                            'لم يقدم أي ولي أمر أو راكب تقييماً لأي سائق حتى الآن.',
                        onRefresh: () => cubit.fetchAllDriverReviews(),
                      )
                    else if (filteredReviews.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 48, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد تقييمات تطابق نتيجة البحث',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'جرب البحث باسم سائق آخر أو ولي أمر مختلف.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredReviews.length,
                        itemBuilder: (context, index) {
                          final review = filteredReviews[index];
                          return DriverReviewCard(
                            review: review,
                            onDelete: (reviewId) =>
                                cubit.deleteDriverReview(reviewId),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewStats(
    BuildContext context,
    List<DriverReviewModel> reviews,
  ) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    final totalReviews = reviews.length;
    final avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
    final criticalCount = reviews.where((r) => r.rating <= 2).length;
    final positiveCount = reviews.where((r) => r.rating >= 4).length;

    final cards = [
      _ReviewStatItem(
        title: 'متوسط التقييم العام',
        value: '${avgRating.toStringAsFixed(1)} / 5.0',
        subtitle: 'بناءً على $totalReviews تقييم',
        filterKey: 'all',
        icon: Icons.star_rounded,
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFEF3C7),
      ),
      _ReviewStatItem(
        title: 'إجمالي التقييمات',
        value: '$totalReviews',
        subtitle: 'جميع المراجعات المستلمة',
        filterKey: 'all',
        icon: Icons.rate_review_rounded,
        color: context.primaryColor,
        bgColor: context.surfaceVariant,
      ),
      _ReviewStatItem(
        title: 'تقييمات حرجة (1-2 نجوم)',
        value: '$criticalCount',
        subtitle: 'تستدعي تدخلاً ومتابعة',
        filterKey: 'critical',
        icon: Icons.warning_amber_rounded,
        color: context.dangerColor,
        bgColor: context.dangerBg,
      ),
      _ReviewStatItem(
        title: 'تقييمات إيجابية (4-5 نجوم)',
        value: '$positiveCount',
        subtitle: 'مستوى رضا مرتفع',
        filterKey: 'positive',
        icon: Icons.thumb_up_alt_rounded,
        color: context.successColor,
        bgColor: context.successBg,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        if (isWide) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                Expanded(
                  child: _buildReviewStatCard(
                    context,
                    item: cards[i],
                    isSelected: _ratingFilter == cards[i].filterKey,
                    onTap: () {
                      setState(() {
                        if (_ratingFilter == cards[i].filterKey &&
                            cards[i].filterKey != 'all') {
                          _ratingFilter = 'all';
                        } else {
                          _ratingFilter = cards[i].filterKey;
                        }
                      });
                    },
                  ),
                ),
                if (i != cards.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                SizedBox(
                  width: 180,
                  child: _buildReviewStatCard(
                    context,
                    item: cards[i],
                    isSelected: _ratingFilter == cards[i].filterKey,
                    onTap: () {
                      setState(() {
                        if (_ratingFilter == cards[i].filterKey &&
                            cards[i].filterKey != 'all') {
                          _ratingFilter = 'all';
                        } else {
                          _ratingFilter = cards[i].filterKey;
                        }
                      });
                    },
                  ),
                ),
                if (i != cards.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewStatCard(
    BuildContext context, {
    required _ReviewStatItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected && item.filterKey != 'all'
                ? item.color
                : context.borderSoft,
            width: isSelected && item.filterKey != 'all' ? 1.8 : 1,
          ),
          boxShadow: isSelected && item.filterKey != 'all'
              ? [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20, color: item.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected && item.filterKey != 'all'
                          ? item.color
                          : context.textMuted,
                      fontWeight: isSelected && item.filterKey != 'all'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewStatItem {
  final String title;
  final String value;
  final String subtitle;
  final String filterKey;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _ReviewStatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.filterKey,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

