import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/admin_colors.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/remote_circle_avatar.dart';
import '../../data/models/active_trip_model.dart';

class TripInspectorModal extends StatefulWidget {
  final ActiveTripModel trip;

  const TripInspectorModal({super.key, required this.trip});

  static void show(BuildContext context, ActiveTripModel trip) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminColors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: TripInspectorModal(trip: trip),
      ),
    );
  }

  @override
  State<TripInspectorModal> createState() => _TripInspectorModalState();
}

class _TripInspectorModalState extends State<TripInspectorModal> {
  String _selectedFilter = 'all'; // all, on_board, pending, delivered, absent
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trip = widget.trip;

    // تصفية الطلاب حسب الحالة والبحث
    final filteredPassengers = trip.passengers.where((p) {
      if (_selectedFilter == 'on_board' && !p.isOnBoard) return false;
      if (_selectedFilter == 'pending' && !p.isPending) return false;
      if (_selectedFilter == 'delivered' && !p.isDelivered) return false;
      if (_selectedFilter == 'absent' && !p.isAbsent) return false;

      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchName = p.childName.toLowerCase().contains(query);
        final matchSchool = p.schoolName.toLowerCase().contains(query);
        final matchParent = p.parentName.toLowerCase().contains(query);
        final matchPhone = p.parentPhone.contains(query);
        final matchId = p.id.contains(query);
        if (!matchName && !matchSchool && !matchParent && !matchPhone && !matchId) {
          return false;
        }
      }
      return true;
    }).toList();

    // تجميع الطلاب حسب ولي الأمر (ولي الأمر هو الأساس وتحته أبناؤه)
    final Map<String, _ParentGroup> groupsMap = {};
    for (final p in filteredPassengers) {
      final key = p.parentPhone.trim().isNotEmpty
          ? p.parentPhone.trim()
          : (p.parentName.trim().isNotEmpty ? p.parentName.trim() : 'child_${p.id}');

      if (!groupsMap.containsKey(key)) {
        groupsMap[key] = _ParentGroup(
          parentName: p.parentName.trim().isNotEmpty ? p.parentName.trim() : 'ولي أمر غير مسجل',
          parentPhone: p.parentPhone.trim(),
          children: [],
        );
      }
      groupsMap[key]!.children.add(p);
    }
    final parentGroups = groupsMap.values.toList();

    return Column(
      children: [
        // 1. ترويسة النافذة وبيانات السائق
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: context.surfaceVariant.withValues(alpha: 0.3),
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: context.borderStrong,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RemoteCircleAvatar(
                    rawUrl: trip.driverAvatar,
                    radius: 24,
                    initials: trip.driverName.trim().isNotEmpty
                        ? trip.driverName.trim()[0]
                        : 'س',
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                trip.driverName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: context.primaryColor.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                'رحلة #${trip.tripId}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                            if (trip.status.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AdminColors.successBgLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AdminColors.statusSuccess.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  trip.status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AdminColors.statusSuccess,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'معرف السائق: #${trip.driverId}',
                              style: TextStyle(fontSize: 12, color: context.textTertiary),
                            ),
                            if (trip.driverPhone.isNotEmpty)
                              InkWell(
                                onTap: () => _copyToClipboard(context, trip.driverPhone, 'رقم هاتف السائق'),
                                borderRadius: BorderRadius.circular(4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 12, color: AdminColors.statusSuccess),
                                    const SizedBox(width: 4),
                                    Text(
                                      trip.driverPhone,
                                      style: TextStyle(fontSize: 11, color: context.textPrimary, fontWeight: FontWeight.bold),
                                      textDirection: TextDirection.ltr,
                                    ),
                                  ],
                                ),
                              ),
                            if (trip.region.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 13, color: AdminColors.accentCyan),
                                  const SizedBox(width: 3),
                                  Text(
                                    trip.region,
                                    style: TextStyle(fontSize: 11, color: context.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            if (trip.duration.isNotEmpty || trip.startedAt.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.schedule_rounded, size: 13, color: context.textTertiary),
                                  const SizedBox(width: 3),
                                  Text(
                                    trip.duration.isNotEmpty ? trip.duration : trip.startedAt,
                                    style: TextStyle(fontSize: 11, color: context.textSecondary),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 2. مؤشرات التيليميتري الميدانية الهادئة
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trip.isSignalWeak
                          ? AdminColors.orange.withValues(alpha: 0.12)
                          : (trip.isOnline ? AdminColors.successBgLight : Colors.grey.withValues(alpha: 0.12)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: trip.isSignalWeak
                            ? AdminColors.orange
                            : (trip.isOnline ? AdminColors.statusSuccess : Colors.grey),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 7,
                          color: trip.isSignalWeak
                              ? AdminColors.orange
                              : (trip.isOnline ? AdminColors.statusSuccess : Colors.grey),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          trip.isSignalWeak
                              ? 'إشارة متوقفة'
                              : (trip.isOnline ? 'بث حي متصل' : 'غير متصل'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: trip.isSignalWeak
                                ? AdminColors.orange
                                : (trip.isOnline ? AdminColors.successFgLight : context.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: context.borderSoft),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed_rounded, size: 13, color: context.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '${trip.speedKmH} كم/س',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  if (trip.destination.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: context.borderSoft),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_outlined, size: 13, color: context.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              trip.destination,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (trip.lastUpdate.isNotEmpty)
                    Text(
                      'آخر إشارة: ${trip.lastUpdate}',
                      style: TextStyle(fontSize: 10, color: context.textTertiary),
                    ),
                ],
              ),
            ],
          ),
        ),

        // 3. شريط العدادات الإحصائية (أزرار فلترة نظيفة وخالية من الإيموجيات)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final total = trip.totalChildrenCount > 0 ? trip.totalChildrenCount : trip.studentsCount;

              final badges = [
                _buildFilterTab(
                  title: 'إجمالي الطلاب',
                  count: '$total',
                  filterKey: 'all',
                  icon: Icons.groups_outlined,
                  color: context.primaryColor,
                ),
                _buildFilterTab(
                  title: 'على متن الحافلة',
                  count: '${trip.ridingCount}',
                  filterKey: 'on_board',
                  icon: Icons.directions_bus_outlined,
                  color: AdminColors.statusSuccess,
                ),
                _buildFilterTab(
                  title: 'بانتظار الاستلام',
                  count: '${trip.waitingCount}',
                  filterKey: 'pending',
                  icon: Icons.hourglass_empty_rounded,
                  color: AdminColors.statusWarning,
                ),
                _buildFilterTab(
                  title: 'تم التوصيل',
                  count: '${trip.arrivedCount}',
                  filterKey: 'delivered',
                  icon: Icons.done_all_rounded,
                  color: AdminColors.statusInfo,
                ),
                if (trip.absentStudentsCount > 0)
                  _buildFilterTab(
                    title: 'غائب',
                    count: '${trip.absentStudentsCount}',
                    filterKey: 'absent',
                    icon: Icons.person_off_outlined,
                    color: AdminColors.statusDanger,
                  ),
              ];

              return Row(
                children: badges
                    .map((b) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: b,
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ),

        // 4. حقل بحث سريع
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'البحث عن ولي أمر، طالب، مدرسة أو هاتف...',
              hintStyle: TextStyle(fontSize: 12, color: context.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              filled: true,
              fillColor: context.surfaceVariant.withValues(alpha: 0.4),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.borderSoft),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.borderSoft),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 5. قائمة الركاب مرتبة حسب أولياء الأمور (ولي الأمر وتحته أبناؤه)
        Expanded(
          child: parentGroups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_search_outlined, size: 40, color: context.textMuted),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'لا توجد نتائج مطابقة لبحثك'
                            : 'لا يوجد ركاب مسجلون ضمن هذا التصنيف',
                        style: TextStyle(fontSize: 13, color: context.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  itemCount: parentGroups.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final group = parentGroups[index];
                    return _buildParentFamilyCard(context, group);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterTab({
    required String title,
    required String count,
    required String filterKey,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedFilter == filterKey;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = isSelected && filterKey != 'all' ? 'all' : filterKey;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : context.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : context.borderSoft,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: isSelected ? color : context.textSecondary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? color : context.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isSelected ? color : context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة ولي الأمر الرئيسية وبداخلها قائمة أبنائه التابعين له في الرحلة
  Widget _buildParentFamilyCard(BuildContext context, _ParentGroup group) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ترويسة ولي الأمر
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.surfaceVariant.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(bottom: BorderSide(color: context.borderSoft)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_rounded, size: 16, color: context.primaryColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.parentName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            if (group.parentPhone.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              InkWell(
                                onTap: () => _copyToClipboard(context, group.parentPhone, 'رقم ولي الأمر (${group.parentName})'),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 12, color: AdminColors.statusSuccess),
                                    const SizedBox(width: 4),
                                    Text(
                                      group.parentPhone,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textDirection: TextDirection.ltr,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('(نسخ)', style: TextStyle(fontSize: 10, color: context.textTertiary)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: context.borderSoft),
                  ),
                  child: Text(
                    group.children.length == 1
                        ? 'طالب واحد'
                        : (group.children.length == 2 ? 'طالبان' : '${group.children.length} طلاب'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // قائمة الطلاب التابعين لهذا الولي
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: group.children.map((child) {
                final isLast = group.children.last == child;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          // أيقونة الحالة الهادئة
                          _buildStatusDot(child),
                          const SizedBox(width: 10),

                          // بيانات الطالب والمدرسة
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      child.childName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                    if (child.id.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '#${child.id}',
                                        style: TextStyle(fontSize: 10, color: context.textTertiary),
                                      ),
                                    ],
                                  ],
                                ),
                                if (child.schoolName.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.school_outlined, size: 12, color: context.textTertiary),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          child.schoolName,
                                          style: TextStyle(fontSize: 11, color: context.textTertiary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // شارة الحالة الواردة من الباك إند دون إيموجي
                          _buildStatusPill(child),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(height: 1, color: context.borderSoft.withValues(alpha: 0.5)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(TripPassenger child) {
    Color dotColor;
    if (child.isOnBoard) {
      dotColor = AdminColors.statusSuccess;
    } else if (child.isDelivered) {
      dotColor = AdminColors.statusInfo;
    } else if (child.isAbsent) {
      dotColor = AdminColors.statusDanger;
    } else {
      dotColor = AdminColors.statusWarning;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStatusPill(TripPassenger child) {
    Color bgColor;
    Color textColor;

    if (child.isOnBoard) {
      bgColor = AdminColors.successBgLight;
      textColor = AdminColors.statusSuccess;
    } else if (child.isDelivered) {
      bgColor = AdminColors.infoBgLight;
      textColor = AdminColors.statusInfo;
    } else if (child.isAbsent) {
      bgColor = AdminColors.dangerBgLight;
      textColor = AdminColors.statusDanger;
    } else {
      bgColor = AdminColors.warningBgLight;
      textColor = AdminColors.statusWarning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        child.displayStatus,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ $label: $text إلى الحافظة'),
        backgroundColor: AdminColors.statusSuccess,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ParentGroup {
  final String parentName;
  final String parentPhone;
  final List<TripPassenger> children;

  _ParentGroup({
    required this.parentName,
    required this.parentPhone,
    required this.children,
  });
}