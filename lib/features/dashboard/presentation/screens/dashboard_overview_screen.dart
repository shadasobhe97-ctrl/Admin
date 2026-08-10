import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/derbi_colors.dart';
import '../../data/models/active_trip_model.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../logic/dashboard_cubit.dart';
import '../../logic/dashboard_state.dart';
import '../widgets/trip_inspector_modal.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/utils/admin_theme_context.dart';

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
  Timer? _pollingTimer;
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _mapKey = GlobalKey();

  // التحكم في تفاعلية الخريطة لمنع تعارض السحب مع سحب الشاشة
  bool _isMapInteractive = false;

  @override
  void initState() {
    super.initState();
    // إعداد التحديث الدوري التلقائي (Polling) للرحلات النشطة كل 30 ثانية
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        context.read<DashboardCubit>().fetchDashboardData();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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

    // تفعيل تفاعلية الخريطة تلقائياً عند التركيز
    setState(() {
      _isMapInteractive = true;
    });

    // 1. تحريك وزوم الخريطة إلى موقع السائق
    _mapController.move(LatLng(trip.currentLat, trip.currentLng), 16.0);

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
          'تم التمركز على موقع السائق "${trip.driverName}" في الخريطة 🎯',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AdminColors.brandPrimary,
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
                      child: _buildRealMapSection(context, state.activeTrips),
                    ),
                    const SizedBox(height: 32),

                    // 4. قسم تفاصيل رحلات السائقين النشطين
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  // --- قسم الخريطة: مع استخدام IgnorePointer لتعطيل التفاعل 100% عند القفل ---
  Widget _buildRealMapSection(
      BuildContext context, List<ActiveTripModel> trips) {
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

    final markers = <Marker>[];
    for (final trip in validTrips) {
      markers.add(
        Marker(
          point: LatLng(trip.currentLat, trip.currentLng),
          width: 140,
          height: 75,
          child: GestureDetector(
            onTap: () => TripInspectorModal.show(context, trip),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminColors.mapMarkerLabelBg.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AdminColors.brandPrimary, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AdminColors.mapMarkerShadow,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          trip.driverName,
                          style: const TextStyle(
                              color: AdminColors.onMapMarkerLabel,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: AdminColors.successFgLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${trip.studentsCount} طلاب',
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AdminColors.brandPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AdminColors.mapMarkerShadow,
                          blurRadius: 4,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.directions_bus_filled,
                      color: AdminColors.onMapMarkerLabel, size: 18),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'رادار التتبع الحي لرحلات الحافلات (OpenStreetMap)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                context.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdminColors.successBgLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AdminColors.statusSuccess
                                    .withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.circle,
                                  size: 8, color: AdminColors.statusSuccess),
                              const SizedBox(width: 4),
                              Text(
                                '${validTrips.length} رحلة مباشرة على الخريطة',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AdminColors.successFgLight,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تتحول الإحداثيات الواردة من Backend (current_lat, current_lng) فوراً إلى حافلات نشطة',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textTertiary,
                      ),
                    ),
                  ],
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
                        ? 'سحب الخريطة مفعّل (انقر للقفل للتمرير)'
                        : 'تفعيل سحب الخريطة 🔓',
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
            margin: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
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
                                'الخريطة مقفلة مؤقتاً لتسهيل سحب الشاشة لأسفل — انقر زر "تفعيل سحب الخريطة" للتحكم بها.',
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
                              'لا توجد رحلات نشطة حالياً على خريطة OpenStreetMap',
                              style: TextStyle(
                                  color: AdminColors.onMapMarkerLabel,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'سيتم إظهار موقع كل حافلة فور وصول إحداثيات حيّة من Backend',
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
        ],
      ),
    );
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

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: context.infoBg,
                      radius: 20,
                      child: const Icon(Icons.person,
                          color: AdminColors.brandPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                trip.driverName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: context.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AdminColors.successFgLight
                                      .withValues(alpha: isDark ? 0.3 : 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AdminColors.statusSuccess
                                          .withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'رحلة #${trip.tripId}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AdminColors.statusSuccess,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'سائق معرف: #${trip.driverId}  |  وقت الانطلاق: ${trip.startedAt.isNotEmpty ? trip.startedAt : 'غير محدد'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(
                    height: 1,
                    color: context.borderSoft),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الطلاب بالرحلة: ${trip.studentsCount} طلاب',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.accentCyan,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الإحداثيات: ${trip.currentLng.toStringAsFixed(4)} , ${trip.currentLat.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: context.infoBorder,
                          ),
                          foregroundColor: context.infoColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _focusOnDriver(context, trip),
                        icon: const Icon(Icons.center_focus_strong_rounded,
                            size: 16),
                        label: const Text('تمرُكز بالخريطة',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.brandPrimary,
                          foregroundColor: AdminColors.onBrand,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                        onPressed: () => TripInspectorModal.show(context, trip),
                        icon: const Icon(Icons.auto_awesome, size: 14),
                        label: const Text('تفاصيل الرحلة',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          // العرض الأفقي المطابق تماماً لصورة المستخدم
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. جهة اليمين: الأفاتار + اسم السائق والشارة + معرف السائق ووقت الانطلاق
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: context.infoBg,
                    radius: 20,
                    child: const Icon(Icons.person,
                        color: AdminColors.brandPrimary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            trip.driverName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AdminColors.successFgLight
                                  .withValues(alpha: isDark ? 0.3 : 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AdminColors.statusSuccess
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              'رحلة #${trip.tripId}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.statusSuccess,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'سائق معرف: #${trip.driverId}  |  وقت الانطلاق: ${trip.startedAt.isNotEmpty ? trip.startedAt : 'غير محدد'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 2. المنتصف: عدد الطلاب بالرحلة + الإحداثيات
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'الطلاب بالرحلة: ${trip.studentsCount} طلاب',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.accentCyan,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الإحداثيات: ${trip.currentLng.toStringAsFixed(4)} , ${trip.currentLat.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.textTertiary,
                    ),
                  ),
                ],
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
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.brandPrimary,
                      foregroundColor: AdminColors.onBrand,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      elevation: 0,
                    ),
                    onPressed: () => TripInspectorModal.show(context, trip),
                    icon: const Icon(Icons.auto_awesome, size: 14),
                    label: const Text(
                      'تفاصيل الرحلة',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
