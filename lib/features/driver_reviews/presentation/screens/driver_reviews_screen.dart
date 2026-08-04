import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/theme/derbi_colors.dart';

class DriverReviewsScreen extends StatefulWidget {
  const DriverReviewsScreen({super.key});

  @override
  State<DriverReviewsScreen> createState() => _DriverReviewsScreenState();
}

class _DriverReviewsScreenState extends State<DriverReviewsScreen> {
  final AdminApiService _apiService = AdminApiService();
  bool _isLoading = true;
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    final res = await _apiService.getDriverReviews();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['data'] is List) {
          _reviews = res['data'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'إدارة التقييمات والتعليقات المنشورة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: DerbiColors.primaryBlue),
              onPressed: _loadReviews,
            )
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.rate_review_outlined, size: 60, color: DerbiColors.textMuted),
                          const SizedBox(height: 12),
                          const Text('لا توجد تقييمات منشورة', style: TextStyle(color: DerbiColors.textMuted)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _loadReviews, child: const Text('تحديث البيانات')),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _reviews.length,
                      itemBuilder: (ctx, index) {
                        final rev = _reviews[index];
                        final rating = rev['rating'] ?? 5;

                        return Card(
                          color: DerbiColors.surfaceCard,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: DerbiColors.borderSlate),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: DerbiColors.warningAmber,
                                  child: Icon(Icons.star, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'التقييم: ${rev['parent_name'] ?? 'ولي أمر'} → السائق: ${rev['driver_name'] ?? 'سائق'}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                          ),
                                          const SizedBox(width: 8),
                                          Row(
                                            children: List.generate(
                                              5,
                                              (i) => Icon(
                                                i < rating ? Icons.star : Icons.star_border,
                                                size: 14,
                                                color: DerbiColors.warningAmber,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '"${rev['comment'] ?? ''}"',
                                        style: const TextStyle(fontSize: 12, color: DerbiColors.textSecondary, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'الحذف النهائي للتعليق',
                                  icon: const Icon(Icons.delete_forever, color: DerbiColors.dangerRose, size: 22),
                                  onPressed: () => _confirmDeleteReview(context, rev),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        )
      ],
    );
  }

  void _confirmDeleteReview(BuildContext context, Map<String, dynamic> review) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          title: const Text('تأكيد الحذف النهائي للتقييم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('هل أنت تأكد من رغبتك في حذف هذا التعليق والتقييم نهائياً من المنصة؟', style: TextStyle(color: DerbiColors.textSecondary, fontSize: 13)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.dangerRose),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.deleteDriverReview(review['review_id'] ?? review['id']);
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم حذف التقييم نهائياً.'), backgroundColor: DerbiColors.dangerRose),
                );
                _loadReviews();
              },
              child: const Text('حذف التعليق'),
            ),
          ],
        ),
      ),
    );
  }
}
