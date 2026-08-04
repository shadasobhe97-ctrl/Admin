import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/derbi_colors.dart';
import '../../../../core/widgets/stat_card.dart';

class AnalyticalReportsView extends StatefulWidget {
  const AnalyticalReportsView({super.key});

  @override
  State<AnalyticalReportsView> createState() => _AnalyticalReportsViewState();
}

class _AnalyticalReportsViewState extends State<AnalyticalReportsView> {
  String _selectedPeriod = 'هذا الشهر';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Export Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'هذه السنة'].map((period) {
                  final isSel = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: isSel,
                      selectedColor: DerbiColors.primaryBlue,
                      backgroundColor: DerbiColors.surfaceCard,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : DerbiColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _selectedPeriod = period),
                    ),
                  );
                }).toList(),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: DerbiColors.borderSlate),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري تصدير التقرير بملف PDF...'), backgroundColor: DerbiColors.primaryBlue),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 16, color: DerbiColors.dangerRose),
                    label: const Text('تصدير PDF'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.successEmerald),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري تحميل التقرير بملف Excel...'), backgroundColor: DerbiColors.successEmerald),
                      );
                    },
                    icon: const Icon(Icons.table_chart, size: 16),
                    label: const Text('تصدير Excel'),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),

          // KPI Overview Cards
          Row(
            children: const [
              Expanded(child: StatCard(title: 'معدل إنجاز الرحلات', value: '98.4%', icon: Icons.task_alt, color: DerbiColors.successEmerald, trend: '+2.1%', isPositiveTrend: true, subtitle: 'معدل الالتزام بالمواعيد')),
              SizedBox(width: 16),
              Expanded(child: StatCard(title: 'متوسط زمن الرحلة', value: '24 دقيقة', icon: Icons.timer, color: DerbiColors.primaryBlue, trend: '-3 د', isPositiveTrend: true, subtitle: 'ساعات الذروة المدرسية')),
              SizedBox(width: 16),
              Expanded(child: StatCard(title: 'تقييم رضا أولياء الأمور', value: '4.92 / 5', icon: Icons.star, color: DerbiColors.warningAmber, trend: '+0.1', isPositiveTrend: true, subtitle: 'بناءً على 1,420 تقييم')),
            ],
          ),
          const SizedBox(height: 24),

          // Charts Row (Bar Chart & Pie Chart)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekly Trips Bar Chart Card
              Expanded(
                flex: 2,
                child: Container(
                  height: 380,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: DerbiColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DerbiColors.borderSlate),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('معدل الرحلات اليومية في طرابلس الكبرى', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          Icon(Icons.bar_chart, color: DerbiColors.primaryBlue),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 500,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
                                    if (val.toInt() >= 0 && val.toInt() < days.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(days[val.toInt()], style: const TextStyle(color: DerbiColors.textMuted, fontSize: 11)),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  getTitlesWidget: (val, meta) {
                                    return Text('${val.toInt()}', style: const TextStyle(color: DerbiColors.textMuted, fontSize: 10));
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (val) => FlLine(color: DerbiColors.borderSlate.withValues(alpha: 0.5), strokeWidth: 1),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _makeBarGroup(0, 420, DerbiColors.primaryBlue),
                              _makeBarGroup(1, 480, DerbiColors.primaryBlue),
                              _makeBarGroup(2, 450, DerbiColors.primaryBlue),
                              _makeBarGroup(3, 490, DerbiColors.primaryBlue),
                              _makeBarGroup(4, 430, DerbiColors.primaryBlue),
                              _makeBarGroup(5, 120, DerbiColors.borderSlate),
                              _makeBarGroup(6, 150, DerbiColors.borderSlate),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Regional Distribution Pie Chart Card
              Expanded(
                flex: 1,
                child: Container(
                  height: 380,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: DerbiColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DerbiColors.borderSlate),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('توزيع الرحلات حسب مناطق طرابلس', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(value: 35, title: '35%', color: DerbiColors.primaryBlue, radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                              PieChartSectionData(value: 25, title: '25%', color: DerbiColors.successEmerald, radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                              PieChartSectionData(value: 20, title: '20%', color: DerbiColors.warningAmber, radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                              PieChartSectionData(value: 20, title: '20%', color: DerbiColors.dangerRose, radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          _buildLegendRow(DerbiColors.primaryBlue, 'حي الأندلس وقرقارش (35%)'),
                          _buildLegendRow(DerbiColors.successEmerald, 'بن عاشور والنوفليين (25%)'),
                          _buildLegendRow(DerbiColors.warningAmber, 'سوق الجمعة وتاجوراء (20%)'),
                          _buildLegendRow(DerbiColors.dangerRose, 'عين زارة وطريق الشوك (20%)'),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildLegendRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 11, color: DerbiColors.textSecondary)),
        ],
      ),
    );
  }
}
