import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/derbi_colors.dart';
import '../../data/models/active_trip_model.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/models/emergency_trip_item_model.dart';
import '../../logic/dashboard_cubit.dart';
import '../../logic/dashboard_state.dart';
import '../widgets/trip_inspector_modal.dart';
import '../widgets/trip_emergency_inspector_modal.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/remote_circle_avatar.dart';

class DashboardOverviewScreen extends StatelessWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (_) => sl<DashboardCubit>()..fetchDashboardData(),
      child: const _DashboardOverviewContent(),
    );
  }
}

class _DashboardOverviewContent extends StatefulWidget {
  const _DashboardOverviewContent();

  @override
  State<_DashboardOverviewContent> createState() =>
      _DashboardOverviewContentState();
}

class _DashboardOverviewContentState extends State<_DashboardOverviewContent> {
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _mapKey = GlobalKey();

  // التحكم في تفاعلية الخريطة لمنع تعارض السحب مع سحب الشاشة
  bool _isMapInteractive = false;

  // التبديل بين عرض الرحلات النشطة والرحلات المعطلة
  bool _showBreakdown = false;

  // معرف الرحلة المحددة للتمركز عليها ورفع كرتها في مقدمة الخريطة (Topmost Z-Index)
  int? _selectedTripId;

  Widget _buildTripsToggle(BuildContext context, int breakdownCount) {
    Widget chip(String label, bool selected, Color color, VoidCallback onTap) {
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : color,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        chip('الرحلات النشطة', !_showBreakdown, AdminColors.brandPrimary,
            () => setState(() => _showBreakdown = false)),
        chip('الرحلات المعطلة ($breakdownCount)', _showBreakdown,
            AdminColors.statusDanger, () => setState(() => _showBreakdown = true)),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _focusOnDriver(BuildContext context, ActiveTripModel trip) {
    if (trip.currentLat == 0.0 && trip.currentLng == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('إحداثيات موقع السائق غير متاحة حالياً على الخريطة.'),
          backgroundColor: AdminColors.orange,
        ),
      );
      return;
    }

    // تفعيل تفاعلية الخريطة تلقائياً وتحديد كرت السائق ليرتفع في مقدمة جميع الكروت
    setState(() {
      _selectedTripId = trip.tripId;
      _isMapInteractive = true;
    });

    // 1. تحريك وزوم الخريطة إلى موقع السائق بدقة
    _mapController.move(LatLng(trip.currentLat, trip.currentLng), 16.5);

    // 2. سحب الشاشة بسلاسة لأعلى حتى يظهر قسم الخريطة
    if (_mapKey.currentContext != null) {
      Scrollable.ensureVisible(
        _mapKey.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم التمركز على موقع السائق "${trip.driverName}" في الخريطة وجعله في المقدمة 🎯',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AdminColors.brandPrimary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _focusOnEmergency(BuildContext context, EmergencyTripItemModel item) {
    final lat = item.breakdownLocation.latitude;
    final lng = item.breakdownLocation.longitude;
    if (lat == 0.0 && lng == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('إحداثيات موقع تعطل الحافلة غير مسجلة حالياً.'),
          backgroundColor: AdminColors.orange,
        ),
      );
      return;
    }

    setState(() {
      _selectedTripId = item.tripId;
      _isMapInteractive = true;
    });

    _mapController.move(LatLng(lat, lng), 16.5);

    if (_mapKey.currentContext != null) {
      Scrollable.ensureVisible(
        _mapKey.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم التمركز على موقع الحافلة المعطلة (رحلة #${item.tripId}) في الخريطة 🚨',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AdminColors.statusDanger,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<DashboardCubit, DashboardState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: DerbiColors.dangerRose,
                ),
              );
            }
            if (state.successMessage != null &&
                state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: DerbiColors.successEmerald,
                ),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<DashboardCubit>().fetchDashboardData();
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. الترويسة الرئيسية + زر التحديث فقط (تم إلغاء زر توليد الرحلات بالكامل)
                    _buildHeader(context, state),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إجمالي النشاطات والإحصائيات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                context.textPrimary,
                          ),
                        ),
                        Text(
                          '← اسحب  لعرض باقي الكروت',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 2. حالة التحميل / الأخطاء / عرض الإحصائيات بكروت مصغرة وسكرول أفقي
                    if (state.isLoading && state.stats == null)
                      const SizedBox(
                        height: 120,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AdminColors.brandPrimary),
                        ),
                      )
                    else if (state.errorMessage != null && state.stats == null)
                      _buildErrorBox(context, state.errorMessage!)
                    else if (state.stats != null)
                      _buildHorizontalStatsList(context, state.stats!),

                    const SizedBox(height: 32),
                    Text(
                      'الرادار الحي والخريطة التفاعلية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. قسم الرادار والخريطة التفاعلية مع دعم الحظر التام للتفاعل عند القفل
                    Container(
                      key: _mapKey,
                      child: _buildRealMapSection(context, state.activeTrips, state),
                    ),
                    const SizedBox(height: 32),

                    _buildTripsToggle(context, state.emergencyTrips.length),
                    const SizedBox(height: 20),

                    if (_showBreakdown) ...[
                      if (state.emergencyTrips.isNotEmpty)
                        _buildBreakdownTripsSection(context, state.emergencyTrips)
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'لا توجد رحلات معطلة حالياً',
                              style: TextStyle(color: context.textSecondary),
                            ),
                          ),
                        ),
                    ] else ...[
                    // 5. قسم تفاصيل رحلات السائقين النشطين
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Text(
                          'تفاصيل الرحلات النشطة الآن في الميدان',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                context.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                AdminColors.brandPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'إجمالي الرحلات: ${state.activeTrips.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AdminColors.brandPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (state.activeTrips.isEmpty)
                      _buildEmptyTripsWidget(context)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.activeTrips.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _buildDriverCardRow(
                              context, state.activeTrips[index]);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardState state) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لوحة التحكم - نظرة عامة والعمليات المباشرة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.brandPrimary,
            foregroundColor: AdminColors.onBrand,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => context.read<DashboardCubit>().fetchDashboardData(),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('تحديث البيانات',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildErrorBox(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.dangerBgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.dangerBorderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AdminColors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AdminColors.red, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<DashboardCubit>().fetchDashboardData(),
            child: const Text('إعادة المحاولة',
                style: TextStyle(color: AdminColors.brandPrimary)),
          ),
        ],
      ),
    );
  }

  // --- قسم الإحصائيات: سكرول أفقي بحجم كروت مصغر ---
  Widget _buildHorizontalStatsList(
      BuildContext context, DashboardStatsModel stats) {
    List<Widget> cards = [
      _buildCompactStatCard(
          context,
          'إجمالي المستخدمين',
          stats.totalUsers.toString(),
          Icons.people_outline,
          AdminColors.statusSuccess),
      _buildCompactStatCard(
          context,
          'إجمالي السائقين',
          stats.totalDrivers.toString(),
          Icons.directions_car_outlined,
          AdminColors.statusInfo),
      _buildCompactStatCard(
          context,
          'سائقون بانتظار المراجعة',
          stats.pendingDrivers.toString(),
          Icons.hourglass_top_outlined,
          AdminColors.statusWarning),
      _buildCompactStatCard(
          context,
          'إجمالي أولياء الأمور',
          stats.totalParents.toString(),
          Icons.family_restroom,
          AdminColors.accentIndigo),
      _buildCompactStatCard(
          context,
          'الاشتراكات النشطة',
          stats.activeSubscriptions.toString(),
          Icons.verified_outlined,
          AdminColors.accentPurple),
      _buildCompactHighlightedStatCard('الرحلات النشطة اليوم',
          stats.activeTripsToday.toString(), Icons.navigation_outlined),
      _buildCompactStatCard(
          context,
          'إجمالي الإيرادات (د.ل)',
          '${stats.totalRevenueDinar.toStringAsFixed(2)} د.ل',
          Icons.payments_outlined,
          AdminColors.accentPink),
    ];

    return SizedBox(
      height: 90,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: cards.map((card) {
            return Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: card,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCompactStatCard(BuildContext context, String title, String count,
      IconData icon, Color accentColor) {
    final theme = Theme.of(context);

    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHighlightedStatCard(
      String title, String count, IconData icon) {
    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AdminColors.brandPrimary, AdminColors.brandPrimaryDeep],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AdminColors.brandPrimary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.onBrandOverlay,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AdminColors.onBrand, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AdminColors.onBrandMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.onBrand,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- قسم الخريطة: مع استخدام IgnorePointer لتعطيل التفاعل 100% عند القفل وترتيب الكروت بحسب التحديد ---
  Widget _buildRealMapSection(
      BuildContext context, List<ActiveTripModel> trips, DashboardState state) {
    final theme = Theme.of(context);

    bool isValidCoord(double lat, double lng) {
      return !lat.isNaN &&
          !lng.isNaN &&
          lat >= -90.0 &&
          lat <= 90.0 &&
          lng >= -180.0 &&
          lng <= 180.0 &&
          (lat != 0.0 || lng != 0.0);
    }

    final validTrips =
        trips.where((t) => isValidCoord(t.currentLat, t.currentLng)).toList();

    final LatLng defaultCenter = validTrips.isNotEmpty
        ? LatLng(validTrips.first.currentLat, validTrips.first.currentLng)
        : const LatLng(32.8872, 13.1913);

    // ترتيب الحافلات بحيث تُرسم الحافلة المحددة (_selectedTripId) في آخر القائمة
    // في FlutterMap يُرسم العنصر الأخير فوق كل العناصر السابقة، مما يضمن ظهور الكرت المختار في المقدمة دائماً مهما تداخلت الكروت
    final sortedTrips = List<ActiveTripModel>.from(validTrips);
    if (_selectedTripId != null) {
      sortedTrips.sort((a, b) {
        if (a.tripId == _selectedTripId) return 1;
        if (b.tripId == _selectedTripId) return -1;
        return 0;
      });
    }

    final markers = <Marker>[];
    for (final trip in sortedTrips) {
      final isSelected = trip.tripId == _selectedTripId;

      markers.add(
        Marker(
          point: LatLng(trip.currentLat, trip.currentLng),
          width: isSelected ? 175 : 155,
          height: isSelected ? 92 : 85,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _selectedTripId = trip.tripId;
              });
              if (trip.isBreakdown) {
                final match = state.emergencyTrips
                    .where((e) => e.tripId == trip.tripId || e.id == trip.tripId)
                    .firstOrNull;
                final dispatchId =
                    match?.dispatchId ?? match?.id ?? trip.emergencyDispatchId;
                TripEmergencyInspectorModal.show(
                  context,
                  dispatchId: dispatchId,
                  tripId: trip.tripId,
                  trip: trip,
                );
              } else {
                TripInspectorModal.show(context, trip);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: isSelected ? 10 : 8, vertical: isSelected ? 5 : 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (trip.isBreakdown
                            ? AdminColors.statusDanger.withValues(alpha: 0.98)
                            : AdminColors.brandPrimary.withValues(alpha: 0.98))
                        : AdminColors.mapMarkerLabelBg.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(isSelected ? 10 : 8),
                    border: Border.all(
                      color: isSelected
                          ? Colors.amber
                          : (trip.isBreakdown
                              ? AdminColors.statusDanger
                              : (trip.isSignalWeak
                                  ? AdminColors.orange
                                  : (trip.isOnline
                                      ? AdminColors.statusSuccess
                                      : AdminColors.brandPrimary))),
                      width: isSelected ? 2.5 : (trip.isBreakdown ? 2.0 : 1.5),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (trip.isBreakdown ? AdminColors.statusDanger : Colors.amber)
                                  .withValues(alpha: 0.8),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: AdminColors.mapMarkerShadow,
                              blurRadius: 6,
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // مؤشر التحديد أو النبض اللحظي
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.stars_rounded, color: Colors.amber, size: 14),
                        )
                      else
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: trip.isBreakdown
                                ? AdminColors.statusDanger
                                : (trip.isSignalWeak
                                    ? AdminColors.orange
                                    : (trip.isOnline
                                        ? AdminColors.statusSuccess
                                        : Colors.grey)),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          trip.driverName,
                          style: TextStyle(
                              color: AdminColors.onMapMarkerLabel,
                              fontSize: isSelected ? 11 : 10,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trip.speedKmH > 0 && !trip.isBreakdown) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black.withValues(alpha: 0.25) : context.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${trip.speedKmH} كم/س',
                            style: const TextStyle(
                                color: AdminColors.onMapMarkerLabel,
                                fontSize: 8,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: trip.isBreakdown
                              ? (isSelected ? Colors.black.withValues(alpha: 0.3) : AdminColors.statusDanger)
                              : (isSelected ? Colors.black.withValues(alpha: 0.3) : AdminColors.successFgLight),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          trip.isBreakdown
                              ? 'عطل طارئ'
                              : '${trip.totalChildrenCount > 0 ? trip.totalChildrenCount : trip.studentsCount} طلاب',
                          style: const TextStyle(
                              color: AdminColors.onMapMarkerLabel,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // أيقونة الحافلة موجهة بزاوية السير الفعلي في الشارع (Vehicle Heading)
                Transform.rotate(
                  angle: (trip.heading * (math.pi / 180)),
                  child: Container(
                    padding: EdgeInsets.all(isSelected ? 8 : 6),
                    decoration: BoxDecoration(
                      color: trip.isBreakdown
                          ? AdminColors.statusDanger
                          : (trip.isSignalWeak
                              ? AdminColors.orange
                              : (trip.isOnline
                                  ? (isSelected ? Colors.white : AdminColors.brandPrimary)
                                  : Colors.grey.shade700)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.white,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.9),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : const [
                              BoxShadow(
                                  color: AdminColors.mapMarkerShadow,
                                  blurRadius: 5,
                                  offset: Offset(0, 2)),
                            ],
                    ),
                    child: Icon(
                      Icons.navigation,
                      color: (isSelected && !trip.isBreakdown && trip.isOnline)
                          ? AdminColors.brandPrimary
                          : AdminColors.onMapMarkerLabel,
                      size: isSelected ? 18 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Text(
                        'رادار التتبع الحي للحافلات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: state.isRealtimeActive
                              ? AdminColors.successBgLight
                              : (state.isUsingFallbackPolling
                                  ? AdminColors.amber.withValues(alpha: 0.15)
                                  : AdminColors.successBgLight),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: state.isRealtimeActive
                                ? AdminColors.statusSuccess.withValues(alpha: 0.3)
                                : (state.isUsingFallbackPolling
                                    ? AdminColors.amber.withValues(alpha: 0.4)
                                    : AdminColors.statusSuccess.withValues(alpha: 0.2)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.isRealtimeActive
                                  ? Icons.bolt_rounded
                                  : (state.isUsingFallbackPolling
                                      ? Icons.sync_rounded
                                      : Icons.circle),
                              size: 14,
                              color: state.isRealtimeActive
                                  ? AdminColors.statusSuccess
                                  : (state.isUsingFallbackPolling
                                      ? AdminColors.amber
                                      : AdminColors.statusSuccess),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.isRealtimeActive
                                  ? 'بث مباشر • ${validTrips.length} رحلة'
                                  : (state.isUsingFallbackPolling
                                      ? 'تحديث تلقائي • ${validTrips.length} رحلة'
                                      : '${validTrips.length} رحلة نشطة'),
                              style: TextStyle(
                                fontSize: 11,
                                color: state.isRealtimeActive
                                    ? AdminColors.successFgLight
                                    : (state.isUsingFallbackPolling
                                        ? AdminColors.amber
                                        : AdminColors.successFgLight),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // زر قفل/تفعيل سحب الخريطة لمنع احتجاز سحب الشاشة
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isMapInteractive
                          ? AdminColors.statusSuccess
                          : (context.borderStrong),
                      width: 1.5,
                    ),
                    backgroundColor: _isMapInteractive
                        ? AdminColors.statusSuccess.withValues(alpha: 0.1)
                        : AdminColors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      _isMapInteractive = !_isMapInteractive;
                    });
                  },
                  icon: Icon(
                    _isMapInteractive
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                    size: 16,
                    color: _isMapInteractive
                        ? AdminColors.statusSuccess
                        : (context.textSecondary),
                  ),
                  label: Text(
                    _isMapInteractive
                        ? 'سحب الخريطة مفعّل'
                        : 'تفعيل سحب الخريطة',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _isMapInteractive
                          ? AdminColors.statusSuccess
                          : (context.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 400,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 18, right: 18, bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    context.borderStrong,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // استخدام IgnorePointer يلغي 100% من الأحداث واللمس على الخريطة عند القفل بحيث تمر الشاشة لأسفل بدون أي تأثير على الخريطة
                  IgnorePointer(
                    ignoring: !_isMapInteractive,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: defaultCenter,
                        initialZoom: 12.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.darby.admin_panel',
                        ),
                        MarkerLayer(
                          markers: markers,
                        ),
                      ],
                    ),
                  ),

                  // شريط توضيحي سفلي عند قفل سحب الخريطة
                  if (!_isMapInteractive)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      left: 12,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                AdminColors.mapScrim.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: AdminColors.onMapMarkerLabelMuted),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.touch_app_outlined,
                                  color: AdminColors.amber, size: 16),
                              const SizedBox(width: 6),
                              const Text(
                                'الخريطة مقفلة لتسهيل تمرير الصفحة — انقر زر "تفعيل سحب الخريطة" للتحكم بها.',
                                style: TextStyle(
                                    color: AdminColors.onMapMarkerLabel,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (validTrips.isEmpty)
                    Container(
                      color: AdminColors.mapScrim.withValues(alpha: 0.75),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_bus_outlined,
                                size: 48, color: AdminColors.onMapMarkerLabelMuted),
                            SizedBox(height: 12),
                            Text(
                              'لا توجد رحلات نشطة حالياً',
                              style: TextStyle(
                                  color: AdminColors.onMapMarkerLabel,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'سيتم إظهار موقع كل حافلة فور بدء الرحلات',
                              style: TextStyle(
                                  color: AdminColors.onMapMarkerLabelMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // دليل دلالات ألوان الخريطة (Legend)
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, bottom: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderSoft),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.palette_outlined, size: 14, color: context.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'دليل الألوان:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  _buildLegendItem(context, color: AdminColors.statusSuccess, label: 'أخضر: متصل وبث مباشر'),
                  _buildLegendItem(context, color: AdminColors.orange, label: 'برتقالي: إشارة ضعيفة'),
                  _buildLegendItem(context, color: AdminColors.statusDanger, label: 'أحمر: عطل طارئ'),
                  _buildLegendItem(context, color: Colors.grey.shade500, label: 'رصاصي: غير متصل'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context,
      {required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownTripsSection(
      BuildContext context, List<EmergencyTripItemModel> emergencies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              'الرحلات المعطلة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AdminColors.statusDanger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AdminColors.statusDanger.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${emergencies.length} رحلات معطلة',
                style: const TextStyle(
                  fontSize: 12,
                  color: AdminColors.statusDanger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: emergencies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildBreakdownCard(context, emergencies[index]);
          },
        ),
      ],
    );
  }

  Widget _buildBreakdownCard(
      BuildContext context, EmergencyTripItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 750;

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'رحلة #${item.tripId} • بلاغ #${item.dispatchId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    _buildEmergencyStatusBadge(item),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'السائق الأصلي: ${item.originalDriver.name} (${item.originalDriver.phone ?? "-"})',
                  style: TextStyle(fontSize: 12, color: context.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'سبب العطل: ${item.reason}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminColors.statusDanger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الأطفال العالقين: ${item.strandedChildrenCount} أطفال',
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  item.hasSubstituteDriver
                      ? 'السائق البديل: ${item.substituteDriver!.name}'
                      : 'السائق البديل: لم يُكلف بعد',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.hasSubstituteDriver
                        ? AdminColors.statusSuccess
                        : AdminColors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (item.breakdownLocation.latitude != 0.0 && item.breakdownLocation.longitude != 0.0) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _focusOnEmergency(context, item),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.infoBorder),
                            foregroundColor: context.infoColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.center_focus_strong_rounded, size: 14),
                          label: const Text(
                            'تمرُكز بالخريطة',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openEmergencyModal(context, item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.statusDanger,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'تفاصيل العطل',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          // Desktop Row
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. رقم الرحلة والسائق الأصلي
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                AdminColors.statusDanger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'رحلة #${item.tripId}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.statusDanger,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'بلاغ #${item.dispatchId}',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.originalDriver.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    if (item.originalDriver.phone != null)
                      Text(
                        item.originalDriver.phone!,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondary,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                  ],
                ),
              ),

              // 2. سبب العطل وعدد الأطفال
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السبب: ${item.reason}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.statusDanger,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الأطفال العالقين: ${item.strandedChildrenCount} أطفال',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. السائق البديل وحالة البلاغ
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.hasSubstituteDriver
                          ? 'بديل: ${item.substituteDriver!.name}'
                          : 'لم يُكلف بديل بعد',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.hasSubstituteDriver
                            ? AdminColors.statusSuccess
                            : AdminColors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildEmergencyStatusBadge(item),
                  ],
                ),
              ),

              // 4. أزرار التفاعل (تمركز بالخريطة + تفاصيل العطل)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.breakdownLocation.latitude != 0.0 && item.breakdownLocation.longitude != 0.0) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.infoBorder),
                        foregroundColor: context.infoColor,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _focusOnEmergency(context, item),
                      icon: const Icon(Icons.center_focus_strong_rounded, size: 15),
                      label: const Text(
                        'تمرُكز بالخريطة',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton(
                    onPressed: () => _openEmergencyModal(context, item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.statusDanger,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'تفاصيل العطل',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmergencyStatusBadge(EmergencyTripItemModel item) {
    Color bg = AdminColors.statusWarning.withValues(alpha: 0.15);
    Color fg = AdminColors.statusWarning;

    if (item.status == 'accepted') {
      bg = AdminColors.statusSuccess.withValues(alpha: 0.15);
      fg = AdminColors.statusSuccess;
    } else if (item.status == 'completed' || item.status == 'resolved') {
      bg = AdminColors.statusInfo.withValues(alpha: 0.15);
      fg = AdminColors.statusInfo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        item.statusLabel.isNotEmpty ? item.statusLabel : item.status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  void _openEmergencyModal(BuildContext context, EmergencyTripItemModel item) {
    final targetDispatchId = item.dispatchId > 0 ? item.dispatchId : item.id;
    TripEmergencyInspectorModal.show(
      context,
      dispatchId: targetDispatchId,
      tripId: item.tripId,
    ).then((_) {
      if (context.mounted) {
        context.read<DashboardCubit>().refreshEmergencies();
      }
    });
  }

  Widget _buildEmptyTripsWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_bus_filled_outlined,
              size: 48, color: context.textMuted),
          const SizedBox(height: 12),
          Text(
            'لا توجد رحلات نشطة حالياً',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'سيتم إدراج الرحلات المباشرة هنا بمجرد انطلاق السائقين في الجولات اليومية.',
            style: TextStyle(
                fontSize: 12,
                color:
                    context.textTertiary),
          ),
        ],
      ),
    );
  }

  // --- تصميم الكرت مطابق تماماً للصورة المعروضة من قبل المستخدم ---
  Widget _buildDriverCardRow(BuildContext context, ActiveTripModel trip) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.borderSoft,
        ),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          final totalStudents = trip.totalChildrenCount > 0 ? trip.totalChildrenCount : trip.studentsCount;

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RemoteCircleAvatar(
                      rawUrl: trip.driverAvatar,
                      radius: 20,
                      initials: trip.driverName.trim().isNotEmpty
                          ? trip.driverName.trim()[0]
                          : 'س',
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
                                  trip.driverName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: context.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: trip.isBreakdown
                                      ? AdminColors.statusDanger.withValues(alpha: 0.12)
                                      : AdminColors.brandPrimary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: trip.isBreakdown
                                        ? AdminColors.statusDanger.withValues(alpha: 0.3)
                                        : AdminColors.brandPrimary.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  'رحلة #${trip.tripId}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: trip.isBreakdown
                                        ? AdminColors.statusDanger
                                        : AdminColors.brandPrimary,
                                  ),
                                ),
                              ),
                              if (trip.status.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: trip.isBreakdown
                                          ? AdminColors.statusDanger.withValues(alpha: 0.12)
                                          : AdminColors.statusSuccess.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: trip.isBreakdown
                                            ? AdminColors.statusDanger.withValues(alpha: 0.3)
                                            : AdminColors.statusSuccess.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      trip.isBreakdown ? 'عطل طارئ' : trip.cleanStatus,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: trip.isBreakdown
                                            ? AdminColors.statusDanger
                                            : AdminColors.statusSuccess,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'معرف السائق: #${trip.driverId}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textTertiary,
                                ),
                              ),
                              if (trip.driverPhone.isNotEmpty)
                                Text(
                                  'هاتف: ${trip.driverPhone}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: context.textSecondary,
                                  ),
                                  textDirection: TextDirection.ltr,
                                ),
                              if (trip.region.isNotEmpty)
                                Text(
                                  'المنطقة: ${trip.region}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (trip.duration.isNotEmpty || trip.startedAt.isNotEmpty)
                                Text(
                                  'المدة: ${trip.duration.isNotEmpty ? trip.duration : trip.startedAt}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                    height: 1,
                    color: context.borderSoft),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'الطلاب: $totalStudents',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                    Text('${trip.ridingCount} على المتن', style: const TextStyle(fontSize: 11, color: AdminColors.statusSuccess, fontWeight: FontWeight.bold)),
                    Text('${trip.waitingCount} بانتظار', style: const TextStyle(fontSize: 11, color: AdminColors.statusWarning, fontWeight: FontWeight.bold)),
                    Text('${trip.arrivedCount} وصل', style: const TextStyle(fontSize: 11, color: AdminColors.statusInfo, fontWeight: FontWeight.bold)),
                    if (trip.absentStudentsCount > 0)
                      Text('${trip.absentStudentsCount} غائب', style: const TextStyle(fontSize: 11, color: AdminColors.statusDanger, fontWeight: FontWeight.bold)),
                    if (trip.destination.isNotEmpty)
                      Text('الوجهة: ${trip.destination}', style: TextStyle(fontSize: 11, color: context.textTertiary)),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: context.infoBorder,
                        ),
                        foregroundColor: context.infoColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: () => _focusOnDriver(context, trip),
                      child: const Text('تمرُكز بالخريطة',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: trip.isBreakdown
                            ? AdminColors.statusDanger
                            : AdminColors.brandPrimary,
                        foregroundColor: AdminColors.onBrand,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (trip.isBreakdown) {
                          final emergencies = context
                              .read<DashboardCubit>()
                              .state
                              .emergencyTrips;
                          final match = emergencies
                              .where((e) =>
                                  e.tripId == trip.tripId || e.id == trip.tripId)
                              .firstOrNull;
                          final dispatchId = match?.dispatchId ??
                              match?.id ??
                              trip.emergencyDispatchId;
                          TripEmergencyInspectorModal.show(
                            context,
                            dispatchId: dispatchId,
                            tripId: trip.tripId,
                            trip: trip,
                          );
                        } else {
                          TripInspectorModal.show(context, trip);
                        }
                      },
                      child: Text(
                        trip.isBreakdown ? 'تفاصيل العطل' : 'ركاب الرحلة',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          // العرض الأفقي للمكتبي
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. جهة اليمين: الأفاتار + اسم السائق والشارة + معرف السائق ووقت الانطلاق والمنطقة
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    RemoteCircleAvatar(
                      rawUrl: trip.driverAvatar,
                      radius: 20,
                      initials: trip.driverName.trim().isNotEmpty
                          ? trip.driverName.trim()[0]
                          : 'س',
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  trip.driverName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: context.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (trip.isBreakdown
                                          ? AdminColors.statusDanger
                                          : AdminColors.successFgLight)
                                      .withValues(alpha: isDark ? 0.3 : 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: (trip.isBreakdown
                                              ? AdminColors.statusDanger
                                              : AdminColors.statusSuccess)
                                          .withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'رحلة #${trip.tripId}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: trip.isBreakdown
                                        ? AdminColors.statusDanger
                                        : AdminColors.statusSuccess,
                                  ),
                                ),
                              ),
                              if (trip.status.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: trip.isBreakdown
                                          ? AdminColors.statusDanger.withValues(alpha: 0.12)
                                          : context.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: trip.isBreakdown
                                            ? AdminColors.statusDanger.withValues(alpha: 0.3)
                                            : context.primaryColor.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    child: Text(
                                      trip.isBreakdown ? 'عطل طارئ' : trip.status,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: trip.isBreakdown
                                            ? AdminColors.statusDanger
                                            : context.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'سائق معرف: #${trip.driverId}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textTertiary,
                                ),
                              ),
                              if (trip.driverPhone.isNotEmpty)
                                Text(
                                  trip.driverPhone,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textDirection: TextDirection.ltr,
                                ),
                              if (trip.region.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 12, color: AdminColors.accentCyan),
                                    const SizedBox(width: 3),
                                    Text(
                                      trip.region,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AdminColors.accentCyan,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              if (trip.duration.isNotEmpty || trip.startedAt.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.schedule_rounded, size: 12, color: context.textTertiary),
                                    const SizedBox(width: 3),
                                    Text(
                                      trip.duration.isNotEmpty ? trip.duration : trip.startedAt,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. المنتصف: عدد الطلاب بالرحلة وتوزيع الركاب والوجهة
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'الطلاب: $totalStudents',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('${trip.ridingCount} على المتن', style: const TextStyle(fontSize: 11, color: AdminColors.statusSuccess, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('${trip.waitingCount} بانتظار', style: const TextStyle(fontSize: 11, color: AdminColors.statusWarning, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('${trip.arrivedCount} وصل', style: const TextStyle(fontSize: 11, color: AdminColors.statusInfo, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.destination.isNotEmpty
                          ? 'الوجهة: ${trip.destination}'
                          : 'الإحداثيات: ${trip.currentLng.toStringAsFixed(4)} , ${trip.currentLat.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 3. جهة اليسار: الأزرار (تمرُكز بالخريطة + تفاصيل الرحلة)
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: context.infoBorder,
                      ),
                      foregroundColor: context.infoColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onPressed: () => _focusOnDriver(context, trip),
                    icon:
                        const Icon(Icons.center_focus_strong_rounded, size: 16),
                    label: const Text(
                      'تمرُكز بالخريطة',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: trip.isBreakdown
                          ? AdminColors.statusDanger
                          : AdminColors.brandPrimary,
                      foregroundColor: AdminColors.onBrand,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (trip.isBreakdown) {
                        final emergencies = context
                            .read<DashboardCubit>()
                            .state
                            .emergencyTrips;
                        final match = emergencies
                            .where((e) =>
                                e.tripId == trip.tripId || e.id == trip.tripId)
                            .firstOrNull;
                        final dispatchId = match?.dispatchId ??
                            match?.id ??
                            trip.emergencyDispatchId;
                        TripEmergencyInspectorModal.show(
                          context,
                          dispatchId: dispatchId,
                          tripId: trip.tripId,
                          trip: trip,
                        );
                      } else {
                        TripInspectorModal.show(context, trip);
                      }
                    },
                    child: Text(
                      trip.isBreakdown ? 'تفاصيل العطل' : 'ركاب الرحلة',
                      style:
                          const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
