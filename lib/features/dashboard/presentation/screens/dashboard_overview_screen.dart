import 'package:flutter/material.dart';
import '../../data/models/active_trip_model.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/services/dashboard_service.dart';
import '../widgets/trip_inspector_modal.dart';

class DashboardOverviewScreen extends StatefulWidget {
  const DashboardOverviewScreen({super.key});

  @override
  State<DashboardOverviewScreen> createState() => _DashboardOverviewScreenState();
}

class _DashboardOverviewScreenState extends State<DashboardOverviewScreen> {
  final DashboardService _dashboardService = DashboardService();
  late Future<DashboardStatsModel> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = _dashboardService.fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    // عينات رحلات السائقين الحية (يمكن لاحقاً ربطها أيضاً بالباك إند)
    final List<ActiveTripModel> sampleTrips = [
      ActiveTripModel(
        id: '1',
        driverName: 'عبد السلام المصراتي',
        driverPhone: '091-3456789',
        driverAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
        carModel: 'هيونداي أفانتي 2018',
        carPlate: '15-43928 ليبيا',
        rating: 4.8,
        speedKmH: 45,
        currentLocationName: 'حي الأندلس الرئيسي',
        timeElapsed: '25 دقيقة',
        status: 'active',
        passengers: [
          TripPassenger(id: 'p1', childName: 'محمد عبد السلام', parentName: 'أبو محمد', parentPhone: '0911111111', schoolName: 'المدرسة النموذجية', pickupLocation: 'حي الأندلس', dropoffLocation: 'المدرسة', status: 'راكب', scheduledTime: '07:30 ص'),
          TripPassenger(id: 'p2', childName: 'فاطمة عبد السلام', parentName: 'أبو محمد', parentPhone: '0911111111', schoolName: 'المدرسة النموذجية', pickupLocation: 'حي الأندلس', dropoffLocation: 'المدرسة', status: 'ينتظر', scheduledTime: '07:35 ص'),
          TripPassenger(id: 'p3', childName: 'علي عبد السلام', parentName: 'أبو محمد', parentPhone: '0911111111', schoolName: 'المدرسة النموذجية', pickupLocation: 'حي الأندلس', dropoffLocation: 'المدرسة', status: 'وصل', scheduledTime: '07:40 ص'),
        ],
      ),
      ActiveTripModel(
        id: '2',
        driverName: 'مفتاح الزنتاني',
        driverPhone: '092-6549873',
        driverAvatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100',
        carModel: 'كيا سيراتو 2019',
        carPlate: '22-90184 ليبيا',
        rating: 4.9,
        speedKmH: 30,
        currentLocationName: 'طريق السراج - جزيرة مصحة الفردوس',
        timeElapsed: '18 دقيقة',
        status: 'active',
        passengers: [
          TripPassenger(id: 'p4', childName: 'ريم مفتاح', parentName: 'أبو ريم', parentPhone: '0922222222', schoolName: 'مدرسة الفردوس', pickupLocation: 'السراج', dropoffLocation: 'المدرسة', status: 'راكب', scheduledTime: '07:15 ص'),
          TripPassenger(id: 'p5', childName: 'عمر مفتاح', parentName: 'أبو ريم', parentPhone: '0922222222', schoolName: 'مدرسة الفردوس', pickupLocation: 'السراج', dropoffLocation: 'المدرسة', status: 'ينتظر', scheduledTime: '07:20 ص'),
        ],
      ),
      ActiveTripModel(
        id: '3',
        driverName: 'علي غومة',
        driverPhone: '092-2223344',
        driverAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        carModel: 'هيونداي إلنترا 2020',
        carPlate: '9-33829 ليبيا',
        rating: 4.7,
        speedKmH: 55,
        currentLocationName: 'طريق قرقارش - السياحية',
        timeElapsed: '35 دقيقة',
        status: 'active',
        passengers: [
          TripPassenger(id: 'p6', childName: 'حسن علي', parentName: 'أم حسن', parentPhone: '0933333333', schoolName: 'سراج التعليمية', pickupLocation: 'قرقارش', dropoffLocation: 'المدرسة', status: 'راكب', scheduledTime: '07:00 ص'),
          TripPassenger(id: 'p7', childName: 'يوسف علي', parentName: 'أم حسن', parentPhone: '0933333333', schoolName: 'سراج التعليمية', pickupLocation: 'قرقارش', dropoffLocation: 'المدرسة', status: 'وصل', scheduledTime: '07:05 ص'),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white, // خلفية بيضاء نقية
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () async => _loadStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان العلوي مع زر إعادة تحميل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'لوحة التحكم - نظرة عامة',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    IconButton(
                      onPressed: _loadStats,
                      icon: const Icon(Icons.refresh, color: Color(0xFF2563EB)),
                      tooltip: 'تحديث البيانات',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // جلب وعرض الإحصائيات الحقيقية القادمة من الـ API أو الـ Mock
                FutureBuilder<DashboardStatsModel>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Text('خطأ في جلب الإحصائيات: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                      );
                    } else if (!snapshot.hasData) {
                      return const Text('لا توجد بيانات متاحة حالياً');
                    }

                    final stats = snapshot.data!;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : 1);
                        
                        List<Widget> statCards = [
                          _buildStatCard('إجمالي المستخدمين', stats.totalUsers.value, stats.totalUsers.change, Icons.people_outline, const Color(0xFF10B981)),
                          _buildStatCard('السائقون المفعلون', stats.activeDrivers.value, stats.activeDrivers.change, Icons.directions_car_outlined, const Color(0xFF3B82F6)),
                          _buildStatCard('إجمالي أولياء الأمور', stats.totalParents.value, stats.totalParents.change, Icons.family_restroom, const Color(0xFF6366F1)),
                          _buildStatCard('الأطفال المشتركون', stats.subscribedChildren.value, stats.subscribedChildren.change, Icons.child_care, const Color(0xFF8B5CF6)),
                          _buildStatCard('الاشتراكات اليومية', stats.dailySubscriptions.value, stats.dailySubscriptions.change, Icons.today, const Color(0xFFEC4899)),
                          _buildStatCard('الاشتراكات الشهرية', stats.monthlySubscriptions.value, stats.monthlySubscriptions.change, Icons.date_range, const Color(0xFFF59E0B)),
                          _buildHighlightedStatCard('السائقون النشطون بالرحلات', stats.activeTrips.value, stats.activeTrips.change, Icons.share_location),
                        ];

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.2,
                          children: statCards,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),

                _buildMapSection(),
                const SizedBox(height: 32),

                const Text(
                  'تفاصيل رحلات السائقين النشطين',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: sampleTrips.length,
                  itemBuilder: (context, index) {
                    final trip = sampleTrips[index];
                    return _buildDriverCard(context, trip);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, String subtitle, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedStatCard(String title, String count, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('رادار التتبع الحي للسائقين النشطين (طرابلس الكبرى)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2))),
                          child: const Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                              SizedBox(width: 4),
                              Text('تحديث تلقائي', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('اضغط على أية سيارة سائق على الخريطة لعرض ركابه', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            height: 350,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1121),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned(top: 150, left: 0, right: 0, child: Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 2)),
                Positioned(top: 0, bottom: 0, left: 300, child: VerticalDivider(color: Colors.white.withValues(alpha: 0.1), thickness: 2)),
                _buildDriverMarker(top: 100, right: 250, name: 'عبد السلام المصراتي', passengers: '2 بالسيارة'),
                _buildDriverMarker(top: 220, right: 650, name: 'مفتاح الزنتاني', passengers: '1 بالسيارة'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverMarker({required double top, required double right, required String name, required String passengers}) {
    return Positioned(
      top: top,
      right: right,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(4)),
                  child: Text(passengers, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2563EB), width: 2),
            ),
            child: const Icon(Icons.directions_car, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, ActiveTripModel trip) {
    int raqibCount = trip.passengers.where((p) => p.status == 'راكب').length;
    int waitCount = trip.passengers.where((p) => p.status == 'ينتظر').length;
    int doneCount = trip.passengers.where((p) => p.status == 'وصل').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(trip.driverAvatar), radius: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text(trip.driverPhone, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                  child: Text(trip.carPlate, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('السيارة:', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    Text(trip.carModel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الموقع الحالي:', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    Expanded(
                      child: Text(
                        trip.currentLocationName,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(child: _buildCounterBox('راكب معاه', '$raqibCount أطفال', const Color(0xFFECFDF5), const Color(0xFF10B981), Icons.directions_bus)),
                const SizedBox(width: 6),
                Expanded(child: _buildCounterBox('ينتظر', '$waitCount أطفال', const Color(0xFFFFFBEB), const Color(0xFFF59E0B), Icons.access_time)),
                const SizedBox(width: 6),
                Expanded(child: _buildCounterBox('وصل', '$doneCount أطفال', const Color(0xFFEFF6FF), const Color(0xFF3B82F6), Icons.check_circle)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => TripInspectorModal.show(context, trip),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: Colors.amber),
                  SizedBox(width: 6),
                  Text('عرض معلومات ركاب الرحلة الذكية', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBox(String title, String count, Color bgColor, Color textColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: textColor),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}