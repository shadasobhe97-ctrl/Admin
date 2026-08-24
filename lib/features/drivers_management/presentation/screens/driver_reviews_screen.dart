import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_empty_state.dart';
import '../widgets/driver_review_card.dart';
import '../widgets/driver_search_field.dart';

class DriverReviewsScreen extends StatelessWidget {
  const DriverReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

            // تصفية التقييمات بناءً على نص البحث
            final filteredReviews = state.reviews.where((review) {
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
                    const SizedBox(height: 20),

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
}
