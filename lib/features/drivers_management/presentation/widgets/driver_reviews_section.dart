import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import 'driver_review_card.dart';

class DriverReviewsSection extends StatefulWidget {
  final int driverId;

  const DriverReviewsSection({super.key, required this.driverId});

  @override
  State<DriverReviewsSection> createState() => _DriverReviewsSectionState();
}

class _DriverReviewsSectionState extends State<DriverReviewsSection> {
  @override
  void initState() {
    super.initState();
    context.read<DriversManagementCubit>().fetchDriverReviewsForDriver(widget.driverId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<DriversManagementCubit, DriversManagementState>(
      builder: (context, state) {
        final cubit = context.read<DriversManagementCubit>();

        if (state.isLoadingReviews) {
          return const SizedBox(
            height: 140,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            ),
          );
        }

        if (state.isReviewsEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                const Icon(Icons.rate_review_outlined, size: 36, color: Color(0xFF94A3B8)),
                const SizedBox(height: 8),
                Text(
                  'لا توجد تقييمات منشورة لهذا السائق حالياً',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: state.reviews.map((review) {
            return DriverReviewCard(
              review: review,
              onDelete: (reviewId) {
                cubit.deleteDriverReview(reviewId, driverIdFilter: widget.driverId);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
