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

    return Column(
      children: [
        // 1. مؤشر السحب والترويسة
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
                  width: 44,
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
                    radius: 26,
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
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: context.primaryColor.withValues(alpha: 0.3)),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AdminColors.successBgLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AdminColors.statusSuccess.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  trip.status,
                                  style: const TextStyle(
                                    fontSize: 11,
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
                          spacing: 10,
                          runSpacing: 6,
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: context.surfaceVariant,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: context.borderSoft),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone_rounded, size: 12, color: AdminColors.statusSuccess),
                                      const SizedBox(width: 4),
                                      Text(
                                        trip.driverPhone,
                                        style: TextStyle(fontSize: 11, color: context.textPrimary, fontWeight: FontWeight.bold),
                                        textDirection: TextDirection.ltr,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (trip.region.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 13, color: AdminColors.accentCyan),
                                  const SizedBox(width: 3),
                                  Text(
                                    trip.region,
                                    style: TextStyle(fontSize: 12, color: context.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            if (trip.duration.isNotEmpty || trip.startedAt.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined, size: 13, color: AdminColors.statusWarning),
                                  const SizedBox(width: 3),
                                  Text(
                                    trip.duration.isNotEmpty ? trip.duration : trip.startedAt,
                                    style: TextStyle(fontSize: 12, color: context.textSecondary),
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
              const SizedBox(height: 12),

              // 2. شريط المؤشرات الحية للرحلة (تيليميتري)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // حالة البث الحي
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: trip.isSignalWeak
                          ? AdminColors.orange.withValues(alpha: 0.15)
                          : (trip.isOnline ? AdminColors.successBgLight : Colors.grey.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: trip.isSignalWeak
                            ? AdminColors.orange
                            : (trip.isOnline ? AdminColors.statusSuccess : Colors.grey),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: trip.isSignalWeak
                              ? AdminColors.orange
                              : (trip.isOnline ? AdminColors.statusSuccess : Colors.grey),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          trip.isSignalWeak
                              ? 'إشارة ضعيفة / متوقف'
                              : (trip.isOnline ? 'بث حي متصل' : 'غير متصل'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: trip.isSignalWeak
                                ? AdminColors.orange
                                : (trip.isOnline ? AdminColors.successFgLight : context.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // السرعة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed_rounded, size: 14, color: context.primaryColor),
                        const SizedBox(width: 5),
                        Text(
                          '${trip.speedKmH} كم/س',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.primaryColor),
                        ),
                      ],
                    ),
                  ),

                  // زاوية التوجيه
                  if (trip.heading > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.borderSoft),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.navigation_rounded, size: 14, color: context.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            '${trip.heading.toStringAsFixed(0)}°',
                            style: TextStyle(fontSize: 11, color: context.textSecondary),
                          ),
                        ],
                      ),
                    ),

                  // الوجهة المدرسية
                  if (trip.destination.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.borderSoft),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_outlined, size: 14, color: context.textSecondary),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              trip.destination,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // آخر تحديث
                  if (trip.lastUpdate.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'آخر إشارة: ${trip.lastUpdate}',
                        style: TextStyle(fontSize: 11, color: context.textTertiary),
                      ),
                    ),

                  // مستند التتبع المباشر
                  if (trip.firestoreDoc.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'وثيقة: ${trip.firestoreDoc}',
                        style: TextStyle(fontSize: 10, color: context.textTertiary),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // 3. شريط العدادات الإحصائية للطلاب (Total, On Board, Pending, Delivered, Absent)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              final total = trip.totalChildrenCount > 0 ? trip.totalChildrenCount : trip.studentsCount;

              final badges = [
                _buildStatMetricCard(
                  title: 'إجمالي الطلاب',
                  count: '$total',
                  icon: Icons.people_alt_rounded,
                  bgColor: context.primaryColor.withValues(alpha: 0.1),
                  borderColor: context.primaryColor.withValues(alpha: 0.3),
                  textColor: context.primaryColor,
                  filterKey: 'all',
                ),
                _buildStatMetricCard(
                  title: 'على متن الحافلة',
                  count: '${trip.ridingCount}',
                  icon: Icons.directions_bus_rounded,
                  bgColor: AdminColors.successBgLight,
                  borderColor: AdminColors.statusSuccess.withValues(alpha: 0.4),
                  textColor: AdminColors.statusSuccess,
                  filterKey: 'on_board',
                ),
                _buildStatMetricCard(
                  title: 'بانتظار الاستلام',
                  count: '${trip.waitingCount}',
                  icon: Icons.hourglass_top_rounded,
                  bgColor: AdminColors.warningBgLight,
                  borderColor: AdminColors.statusWarning.withValues(alpha: 0.4),
                  textColor: AdminColors.statusWarning,
                  filterKey: 'pending',
                ),
                _buildStatMetricCard(
                  title: 'تم التوصيل',
                  count: '${trip.arrivedCount}',
                  icon: Icons.check_circle_rounded,
                  bgColor: AdminColors.infoBgLight,
                  borderColor: AdminColors.statusInfo.withValues(alpha: 0.4),
                  textColor: AdminColors.statusInfo,
                  filterKey: 'delivered',
                ),
                if (trip.absentStudentsCount > 0)
                  _buildStatMetricCard(
                    title: 'غائب',
                    count: '${trip.absentStudentsCount}',
                    icon: Icons.person_off_rounded,
                    bgColor: AdminColors.dangerBgLight,
                    borderColor: AdminColors.statusDanger.withValues(alpha: 0.4),
                    textColor: AdminColors.statusDanger,
                    filterKey: 'absent',
                  ),
              ];

              if (isSmall) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: badges
                      .map((b) => SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: b,
                          ))
                      .toList(),
                );
              }

              return Row(
                children: badges
                    .map((b) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: b,
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ),

        // 4. حقل البحث السريع بالاسم أو المدرسة أو رقم الهاتف
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'البحث عن طالب، مدرسة، ولي أمر أو رقم هاتف...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              filled: true,
              fillColor: context.surfaceVariant.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.borderSoft),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.borderSoft),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 5. قائمة الركاب (الطلاب بالتفاصيل الكاملة)
        Expanded(
          child: filteredPassengers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_search_rounded, size: 48, color: context.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'لا توجد نتائج تطابق بحثك'
                            : 'لا يوجد ركاب مسجلون ضمن هذا التصنيف',
                        style: TextStyle(fontSize: 14, color: context.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: filteredPassengers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final passenger = filteredPassengers[index];
                    return _buildPassengerCard(context, passenger);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required String filterKey,
  }) {
    final isSelected = _selectedFilter == filterKey;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = isSelected && filterKey != 'all' ? 'all' : filterKey;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : context.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? borderColor : context.borderSoft,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: textColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? textColor : context.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? textColor : context.textPrimary,
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

  Widget _buildPassengerCard(BuildContext context, TripPassenger passenger) {
    Color statusBgColor;
    Color statusTextColor;
    IconData statusIcon;

    if (passenger.isOnBoard) {
      statusBgColor = AdminColors.successBgLight;
      statusTextColor = AdminColors.statusSuccess;
      statusIcon = Icons.directions_bus_rounded;
    } else if (passenger.isDelivered) {
      statusBgColor = AdminColors.infoBgLight;
      statusTextColor = AdminColors.statusInfo;
      statusIcon = Icons.check_circle_rounded;
    } else if (passenger.isAbsent) {
      statusBgColor = AdminColors.dangerBgLight;
      statusTextColor = AdminColors.statusDanger;
      statusIcon = Icons.person_off_rounded;
    } else {
      // Pending
      statusBgColor = AdminColors.warningBgLight;
      statusTextColor = AdminColors.statusWarning;
      statusIcon = Icons.access_time_filled_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف العلوي: الاسم والمعرف + شارة الحالة
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: statusBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusTextColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            passenger.childName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        if (passenger.id.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: context.borderSoft),
                            ),
                            child: Text(
                              'ID: #${passenger.id}',
                              style: TextStyle(fontSize: 10, color: context.textTertiary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // شارة الحالة مع النص الدقيق الوارد من الباك إند
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusTextColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        passenger.displayStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // زر الاتصال المباشر بولي الأمر
              if (passenger.parentPhone.isNotEmpty)
                IconButton(
                  onPressed: () => _copyToClipboard(context, passenger.parentPhone, 'رقم ولي الأمر (${passenger.parentName})'),
                  icon: const Icon(Icons.phone_in_talk_rounded, color: AdminColors.statusSuccess, size: 20),
                  tooltip: 'نسخ رقم ولي الأمر (${passenger.parentPhone})',
                  style: IconButton.styleFrom(
                    backgroundColor: AdminColors.statusSuccess.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: context.borderSoft),
          const SizedBox(height: 10),

          // التفاصيل: المدرسة وولي الأمر والعنوان
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              if (passenger.schoolName.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_outlined, size: 14, color: AdminColors.textMutedLight),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        passenger.schoolName,
                        style: TextStyle(fontSize: 12, color: context.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              if (passenger.parentName.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: AdminColors.textMutedLight),
                    const SizedBox(width: 5),
                    Text(
                      'ولي الأمر: ${passenger.parentName}',
                      style: TextStyle(fontSize: 12, color: context.textTertiary),
                    ),
                  ],
                ),
              if (passenger.parentPhone.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_iphone_rounded, size: 14, color: AdminColors.textMutedLight),
                    const SizedBox(width: 5),
                    Text(
                      passenger.parentPhone,
                      style: TextStyle(fontSize: 12, color: context.textSecondary, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              if (passenger.pickupLocation.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AdminColors.textMutedLight),
                    const SizedBox(width: 5),
                    Text(
                      passenger.pickupLocation,
                      style: TextStyle(fontSize: 12, color: context.textTertiary),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('تم نسخ $label: $text إلى الحافظة بنجاح')),
          ],
        ),
        backgroundColor: AdminColors.statusSuccess,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}