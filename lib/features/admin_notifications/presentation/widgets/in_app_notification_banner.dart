import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

/// نظام إشعارات 3D متكدسة فوق بعضها احترافي ومتحرك
/// يدعم إظهار كدسة بطاقات مع أنيميشن ثلاثي الأبعاد وإيماءات السحب (Swipe to dismiss)
class InAppNotificationBanner {
  static OverlayEntry? _stackOverlayEntry;
  static final List<_NotificationItem> _queue = [];
  static final _notifier = _QueueNotifier();

  /// إضافة إشعار جديد إلى كدسة الإشعارات 3D
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
      timestamp: DateTime.now(),
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
            onHideAll: () => hideAll(),
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

  /// إغلاق جميع الإشعارات المتكدسة دفعة واحدة
  static void hideAll() {
    _queue.clear();
    _notifier.notify();
    _stackOverlayEntry?.remove();
    _stackOverlayEntry = null;
  }
}

// ─── Internal Models & Notifiers ─────────────────────────────────────────────

class _NotificationItem {
  final int id;
  final String title;
  final String body;
  final VoidCallback? onTap;
  final DateTime timestamp;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.onTap,
    required this.timestamp,
  });
}

class _QueueNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// ─── 3D Stack Container Widget ───────────────────────────────────────────────

class _NotificationStack extends StatefulWidget {
  final _QueueNotifier notifier;
  final List<_NotificationItem> queue;
  final void Function(int id) onDismiss;
  final VoidCallback onHideAll;
  final void Function(_NotificationItem item) onTapItem;

  const _NotificationStack({
    required this.notifier,
    required this.queue,
    required this.onDismiss,
    required this.onHideAll,
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

    // أقصى عدد بطاقات ظاهر في الكدسة (الحدث في الأعلى)
    const maxVisibleCount = 4;

    // أحدث الإشعارات تكون في أعلى القائمة
    final reversedQueue = widget.queue.reversed.toList();
    final visibleItems = reversedQueue.take(maxVisibleCount).toList();

    const double cardBaseHeight = 84.0;
    const double peekYOffset = 15.0; // ميزان التكديس العمودي 3D
    final double totalContainerHeight = cardBaseHeight +
        ((visibleItems.length - 1) * peekYOffset) +
        (widget.queue.length > 1 ? 38.0 : 0.0);

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── شريط التحكم في الكدسة (يظهر عند وجود أكثر من إشعار) ──
                if (widget.queue.length > 1) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: context.primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.layers_rounded,
                                size: 14,
                                color: context.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.queue.length} إشعارات متكدسة فوق بعضها',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: context.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: widget.onHideAll,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.clear_all_rounded,
                                  size: 14,
                                  color: context.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'مسح الكل',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── الكدسة ثلاثية الأبعاد (3D Stack) ──
                SizedBox(
                  height: totalContainerHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // رسم البطاقات من الخلف إلى الأمام لضمان التراكب المريح
                      for (int i = visibleItems.length - 1; i >= 0; i--) ...[
                        _buildStackedCardWrapper(
                          context: context,
                          item: visibleItems[i],
                          stackIndex: i, // 0 = البطاقة الأولى في الواجهة
                          totalVisible: visibleItems.length,
                          peekYOffset: peekYOffset,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStackedCardWrapper({
    required BuildContext context,
    required _NotificationItem item,
    required int stackIndex,
    required int totalVisible,
    required double peekYOffset,
  }) {
    // التكديس 3D: البطاقة الأمامية index=0
    // البطاقات الخلفية تنزل بـ peekYOffset، وتتداخل بحجم أصغر scale وشفافية متدرجة
    final double topPosition = stackIndex * peekYOffset;
    final double scale = (1.0 - (stackIndex * 0.055)).clamp(0.82, 1.0);
    final double opacity = (1.0 - (stackIndex * 0.18)).clamp(0.45, 1.0);
    final bool isFront = stackIndex == 0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      top: topPosition,
      left: 0,
      right: 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        scale: scale,
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 280),
          opacity: opacity,
          child: _Single3DBannerCard(
            key: ValueKey(item.id),
            item: item,
            isFront: isFront,
            stackDepthIndex: stackIndex,
            onDismiss: () => widget.onDismiss(item.id),
            onTap: () => widget.onTapItem(item),
          ),
        ),
      ),
    );
  }
}

// ─── Single 3D Banner Card with Swipe & Animations ───────────────────────────

class _Single3DBannerCard extends StatefulWidget {
  final _NotificationItem item;
  final bool isFront;
  final int stackDepthIndex;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _Single3DBannerCard({
    super.key,
    required this.item,
    required this.isFront,
    required this.stackDepthIndex,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_Single3DBannerCard> createState() => _Single3DBannerCardState();
}

class _Single3DBannerCardState extends State<_Single3DBannerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  // دعم التمرير بالسحب (Swipe Gesture)
  double _dragOffsetX = 0.0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutBack,
    ));

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeIn,
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    await _animCtrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    // ظل متدرج مع العمق 3D
    final shadowBlur = widget.isFront ? 18.0 : 10.0;
    final shadowOffsetY = widget.isFront ? 8.0 : 4.0;
    final shadowAlpha = widget.isFront ? 0.22 : 0.12;

    Widget cardChild = Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isFront
              ? context.primaryColor.withValues(alpha: 0.5)
              : context.borderSoft.withValues(alpha: 0.4),
          width: widget.isFront ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowAlpha),
            blurRadius: shadowBlur,
            offset: Offset(0, shadowOffsetY),
          ),
          if (widget.isFront)
            BoxShadow(
              color: context.primaryColor.withValues(alpha: 0.10),
              blurRadius: 16,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // أيقونة جرس مع لمسة ضوئية
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.primaryColor.withValues(alpha: 0.22),
                          context.primaryColor.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: context.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // تفاصيل النص (العنوان والوصف)
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
                              _formatTime(widget.item.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: context.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.item.body,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
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
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'عرض',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // زر إغلاق
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: _handleDismiss,
                    color: context.textTertiary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // إضافة سحب للتخلص من البطاقة إذا كانت في الواجهة (Swipe to dismiss)
    if (widget.isFront) {
      cardChild = GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragOffsetX += details.delta.dx;
          });
        },
        onHorizontalDragEnd: (details) {
          if (_dragOffsetX.abs() > 100 ||
              details.primaryVelocity?.abs() != null &&
                  details.primaryVelocity!.abs() > 300) {
            _handleDismiss();
          } else {
            setState(() {
              _dragOffsetX = 0.0;
            });
          }
        },
        child: Transform.translate(
          offset: Offset(_dragOffsetX, 0),
          child: Transform.rotate(
            angle: (_dragOffsetX / 1000).clamp(-0.1, 0.1),
            child: cardChild,
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: cardChild,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 45) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes}د';
    return 'منذ ${diff.inHours}س';
  }
}

