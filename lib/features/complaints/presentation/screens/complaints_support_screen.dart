import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/theme/derbi_colors.dart';

class ComplaintsSupportView extends StatefulWidget {
  const ComplaintsSupportView({super.key});

  @override
  State<ComplaintsSupportView> createState() => _ComplaintsSupportViewState();
}

class _ComplaintsSupportViewState extends State<ComplaintsSupportView> {
  final AdminApiService _apiService = AdminApiService();
  bool _isLoading = true;
  List<dynamic> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    final res = await _apiService.getComplaints();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['data'] is List) {
          _complaints = res['data'];
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
              'مركز الشكاوى والبلاغات الميدانية',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: DerbiColors.primaryBlue),
              onPressed: _loadComplaints,
            )
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _complaints.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mark_email_read_outlined, size: 60, color: DerbiColors.successEmerald),
                          const SizedBox(height: 12),
                          const Text('لا توجد شكاوى مرفوعة حالياً', style: TextStyle(color: DerbiColors.textMuted)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _complaints.length,
                      itemBuilder: (ctx, i) {
                        final c = _complaints[i];
                        final isPending = c['status'] == 'pending';

                        return Card(
                          color: DerbiColors.surfaceCard,
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: DerbiColors.borderSlate),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: isPending ? DerbiColors.dangerRose.withValues(alpha: 0.15) : DerbiColors.successEmerald.withValues(alpha: 0.15),
                                  child: Icon(
                                    isPending ? Icons.report_problem : Icons.check_circle,
                                    color: isPending ? DerbiColors.dangerRose : DerbiColors.successEmerald,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'شكوى رقم #${c['id']} • ${c['type'] ?? 'بلاغ'}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isPending ? DerbiColors.dangerRose.withValues(alpha: 0.15) : DerbiColors.successEmerald.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              isPending ? 'قيد المراجعة' : 'تم المعالجة',
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPending ? DerbiColors.dangerRose : DerbiColors.successEmerald),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'المشتكي: ${c['parent_name'] ?? 'ولي أمر'} • السائق المشكو في حقه: ${c['driver_name'] ?? 'سائق'}',
                                        style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'تفاصيل الشكوى: ${c['description'] ?? ''}',
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
                                  onPressed: () => _reviewComplaintModal(context, c),
                                  icon: const Icon(Icons.gavel, size: 16),
                                  label: const Text('اتخاذ قرار'),
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

  void _reviewComplaintModal(BuildContext context, Map<String, dynamic> complaint) {
    final detailsController = TextEditingController();
    String selectedAction = 'warning';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: DerbiColors.surfaceCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('اتخاذ قرار الإداري بشأن الشكوى رقم #${complaint['id']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حدد القرار الإداري:', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedAction,
                    dropdownColor: DerbiColors.surfaceCard,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: const [
                      DropdownMenuItem(value: 'warning', child: Text('إرسال إنذار رسمي للسائق')),
                      DropdownMenuItem(value: 'suspension', child: Text('إيقاف حساب السائق مؤقتاً')),
                      DropdownMenuItem(value: 'dismiss', child: Text('تجاهل الشكوى وحفظ القضية')),
                    ],
                    onChanged: (val) => setModalState(() => selectedAction = val ?? 'warning'),
                  ),
                  const SizedBox(height: 14),
                  const Text('ملاحظات وتفاصيل القرار الصادر:', style: TextStyle(color: DerbiColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: detailsController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'اكتب نص القرار الموجه للسائق أو الشاكي...',
                    ),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final res = await _apiService.reviewComplaint(
                    complaint['id'],
                    action: selectedAction,
                    adminNotes: detailsController.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  messenger.showSnackBar(
                    SnackBar(content: Text(res['message'] ?? 'تم اتخاذ القرار بنجاح!'), backgroundColor: DerbiColors.successEmerald),
                  );
                  _loadComplaints();
                },
                child: const Text('حفظ وإرسال القرار'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
