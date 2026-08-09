import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_empty_state.dart';
import '../widgets/driver_review_card.dart';

class DriverReviewsScreen extends StatelessWidget {
  const DriverReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DriversManagementCubit>()..fetchAllDriverReviews(),
      child: const _DriverReviewsContent(),
    );
  }
}

class _DriverReviewsContent extends StatelessWidget {
  const _DriverReviewsContent();

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
                SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
              );
            }
            if (state.successMessage != null && state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<DriversManagementCubit>();

            return RefreshIndicator(
              onRefresh: () async => await cubit.fetchAllDriverReviews(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title Bar
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
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'مراجعة تقييمات أولياء الأمور والركاب لخدمات السائقين، التعليقات الميدانية وإدارة المحتوى',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        IconButton.filledTonal(
                          onPressed: () => cubit.fetchAllDriverReviews(),
                          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
                          tooltip: 'تحديث التقييمات من Backend',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Content
                    if (state.isLoadingReviews)
                      const SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                        ),
                      )
                    else if (state.isReviewsEmpty)
                      DriverEmptyState(
                        title: 'لا توجد تقييمات أو تعليقات حالياً',
                        description: 'لم يقدم أي ولي أمر أو راكب تقييماً لأي سائق حتى الآن.',
                        onRefresh: () => cubit.fetchAllDriverReviews(),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.reviews.length,
                        itemBuilder: (context, index) {
                          final review = state.reviews[index];
                          return DriverReviewCard(
                            review: review,
                            onDelete: (reviewId) => cubit.deleteDriverReview(reviewId),
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
