import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/theme/derbi_colors.dart';

class DriverUpdatesManagerView extends StatefulWidget {
  const DriverUpdatesManagerView({super.key});

  @override
  State<DriverUpdatesManagerView> createState() => _DriverUpdatesManagerViewState();
}

class _DriverUpdatesManagerViewState extends State<DriverUpdatesManagerView> {
  final AdminApiService _apiService = AdminApiService();
  bool _isLoading = true;
  List<dynamic> _pendingChanges = [];

  @override
  void initState() {
    super.initState();
    _loadPendingChanges();
  }

  Future<void> _loadPendingChanges() async {
    setState(() => _isLoading = true);
    final res = await _apiService.getPendingChanges();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['data'] is List) {
          _pendingChanges = res['data'];
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
              'طلبات تعديل بيانات السائقين والمركبات المعلقة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: DerbiColors.primaryBlue),
              onPressed: _loadPendingChanges,
            )
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pendingChanges.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 60, color: DerbiColors.successEmerald),
                          const SizedBox(height: 12),
                          const Text('لا توجد طلبات تعديل معلقة حالياً', style: TextStyle(color: DerbiColors.textMuted)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _pendingChanges.length,
                      itemBuilder: (ctx, index) {
                        final item = _pendingChanges[index];
                        return _PendingChangeCard(
                          item: item,
                          onActionComplete: _loadPendingChanges,
                          apiService: _apiService,
                        );
                      },
                    ),
        )
      ],
    );
  }
}

class _PendingChangeCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onActionComplete;
  final AdminApiService apiService;

  const _PendingChangeCard({
    required this.item,
    required this.onActionComplete,
    required this.apiService,
  });

  @override
  State<_PendingChangeCard> createState() => _PendingChangeCardState();
}

class _PendingChangeCardState extends State<_PendingChangeCard> {
  bool _isExpanded = false;
  bool _isLoadingDetails = false;
  Map<String, dynamic>? _detailsData;

  Future<void> _toggleExpand() async {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded && _detailsData == null) {
      setState(() => _isLoadingDetails = true);
      final res = await widget.apiService.getPendingChangeDetails(widget.item['id']);
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
          _detailsData = res['data'] ?? {};
        });
      }
    }
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('رفض طلب التعديل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: 380,
            child: TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(labelText: 'سبب الرفض'),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.dangerRose),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await widget.apiService.reviewPendingChange(
                  widget.item['id'],
                  action: 'reject',
                  rejectionReason: reasonController.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم رفض التعديل.'), backgroundColor: DerbiColors.dangerRose),
                );
                widget.onActionComplete();
              },
              child: const Text('تأكيد الرفض'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final oldData = _detailsData?['old_data'] as Map<String, dynamic>? ?? {};
    final newData = _detailsData?['new_data'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: DerbiColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DerbiColors.borderSlate),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: _toggleExpand,
            leading: CircleAvatar(
              backgroundColor: DerbiColors.primaryBlue.withValues(alpha: 0.15),
              child: const Icon(Icons.sync, color: DerbiColors.primaryBlue),
            ),
            title: Text(
              '${item['driver_name']} (طلب رقم #${item['id']})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
            ),
            subtitle: Text(
              'نوع التعديل: ${item['change_type'] ?? 'تحديث ملف'} • التاريخ: ${item['created_at'] ?? ''}',
              style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'قبول وتطبيق التعديل',
                  icon: const Icon(Icons.check_circle, color: DerbiColors.successEmerald, size: 24),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final res = await widget.apiService.reviewPendingChange(item['id'], action: 'approve');
                    if (context.mounted) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(res['message'] ?? 'تمت الموافقة بنجاح.'), backgroundColor: DerbiColors.successEmerald),
                      );
                      widget.onActionComplete();
                    }
                  },
                ),
                IconButton(
                  tooltip: 'رفض الطلب',
                  icon: const Icon(Icons.cancel, color: DerbiColors.dangerRose, size: 24),
                  onPressed: () => _showRejectDialog(context),
                ),
                Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: DerbiColors.textSecondary),
              ],
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: DerbiColors.borderSlate)),
              ),
              child: _isLoadingDetails
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: DerbiColors.dangerRose.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: DerbiColors.dangerRose.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('البيانات القديمة:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: DerbiColors.dangerRose)),
                                const SizedBox(height: 6),
                                if (oldData.isEmpty)
                                  const Text('لا توجد بيانات سابقة', style: TextStyle(fontSize: 11, color: DerbiColors.textMuted))
                                else
                                  for (var e in oldData.entries)
                                    Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 11, color: DerbiColors.textSecondary, decoration: TextDecoration.lineThrough)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: DerbiColors.successEmerald.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: DerbiColors.successEmerald.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('البيانات الجديدة المطلوبة:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: DerbiColors.successEmerald)),
                                const SizedBox(height: 6),
                                if (newData.isEmpty)
                                  const Text('لا توجد بيانات جديدة', style: TextStyle(fontSize: 11, color: DerbiColors.textMuted))
                                else
                                  for (var e in newData.entries)
                                    Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            )
        ],
      ),
    );
  }
}
