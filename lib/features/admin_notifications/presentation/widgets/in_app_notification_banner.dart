import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

/// نظام إشعارات متكدسة - يدعم إظهار أكثر من إشعار في نفس الوقت
/// كل إشعار يبقى على الشاشة حتى يضغط المستخدم على زر الإغلاق (X)
class InAppNotificationBanner {
  static OverlayEntry? _stackOverlayEntry;
  static final List<_NotificationItem> _queue = [];
  static final _notifier = _QueueNotifier();

  /// إضافة إشعار جديد للكدسة
  static void show(
    BuildContext context, {
    required String title,
    required String body,
    VoidCallback? onTap,
  }) {
    final item = _NotificationItem(
      id: DateTime.now().microsecondsSinceEpoch,
      title: title,
      body: body,
      onTap: onTap,
    );

    _queue.add(item);
    _notifier.notify();

    // إنشاء الـ Overlay الرئيسي إذا لم يكن موجوداً
    if (_stackOverlayEntry == null) {
      final overlayState = Overlay.of(context, rootOverlay: true);
      _stackOverlayEntry = OverlayEntry(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: _NotificationStack(
            notifier: _notifier,
            queue: _queue,
            onDismiss: (id) => _dismiss(id),
            onTapItem: (item) {
              _dismiss(item.id);
              item.onTap?.call();
            },
          ),
        ),
      );
      overlayState.insert(_stackOverlayEntry!);
    }
  }

  /// إزالة إشعار واحد بمعرّفه
  static void _dismiss(int id) {
    _queue.removeWhere((item) => item.id == id);
    _notifier.notify();

    if (_queue.isEmpty) {
      _stackOverlayEntry?.remove();
      _stackOverlayEntry = null;
    }
  }

  /// إغلاق جميع الإشعارات دفعةً واحدة
  static void hideAll() {
    _queue.clear();
    _notifier.notify();
    _stackOverlayEntry?.remove();
    _stackOverlayEntry = null;
  }
}

// ─── Internal Models ─────────────────────────────────────────────────────────

class _NotificationItem {
  final int id;
  final String title;
  final String body;
  final VoidCallback? onTap;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.onTap,
  });
}

class _QueueNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// ─── Stack Container Widget ───────────────────────────────────────────────────

class _NotificationStack extends StatefulWidget {
  final _QueueNotifier notifier;
  final List<_NotificationItem> queue;
  final void Function(int id) onDismiss;
  final void Function(_NotificationItem item) onTapItem;

  const _NotificationStack({
    required this.notifier,
    required this.queue,
    required this.onDismiss,
    required this.onTapItem,
  });

  @override
  State<_NotificationStack> createState() => _NotificationStackState();
}

class _NotificationStackState extends State<_NotificationStack> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onQueueChanged);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onQueueChanged);
    super.dispose();
  }

  void _onQueueChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.queue.isEmpty) return const SizedBox.shrink();

    // عرض أقصى 5 إشعارات في نفس الوقت
    final visible = widget.queue.length > 5
        ? widget.queue.sublist(widget.queue.length - 5)
        : List<_NotificationItem>.from(widget.queue);

    return Positioned(
      top: 16,
      left: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: visible.reversed.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SingleBannerCard(
              key: ValueKey(item.id),
              item: item,
              onDismiss: () => widget.onDismiss(item.id),
              onTap: () => widget.onTapItem(item),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Single Notification Card ─────────────────────────────────────────────────

class _SingleBannerCard extends StatefulWidget {
  final _NotificationItem item;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _SingleBannerCard({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_SingleBannerCard> createState() => _SingleBannerCardState();
}

class _SingleBannerCardState extends State<_SingleBannerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: context.primaryColor.withValues(alpha: 0.4),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // أيقونة الجرس
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_active_rounded,
                            color: context.primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // نص العنوان والتفاصيل
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.item.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'الآن',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: context.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.item.body,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // زر "عرض"
                        TextButton(
                          onPressed: widget.onTap,
                          style: TextButton.styleFrom(
                            foregroundColor: context.primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          child: const Text(
                            'عرض',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),

                        // زر الإغلاق (X) - يبقى الإشعار حتى الضغط عليه
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: _handleDismiss,
                          color: context.textTertiary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'إغلاق الإشعار',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
