import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/financial_report_model.dart';
import 'reports_ui.dart';

/// رسم بياني للإيرادات مبني بالكامل على `revenue_summary.chart_data`.
/// لا تُولَّد أي نقطة بيانات في الواجهة؛ إن كانت القائمة فارغة تُعرض حالة فراغ.
class RevenueChart extends StatelessWidget {
  final List<RevenueChartPoint> chartData;

  const RevenueChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const ReportSectionEmpty(
        message: 'لم يُرسل الخادم بيانات كافية لرسم منحنى الإيرادات لهذه الفترة.',
        icon: Icons.show_chart_rounded,
      );
    }

    final maxValue = chartData
        .map((point) => point.totalVolume)
        .reduce((a, b) => a > b ? a : b);

    // هامش علوي بسيط حتى لا يلامس أعلى عمود سقف الرسم.
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChartLegend(
          items: [
            _LegendItem('عمولة المنصة', context.primaryColor),
            _LegendItem('أرباح السائقين', context.successColor),
            _LegendItem('إجمالي الحجم', context.infoColor),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: context.borderSoft,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    getTitlesWidget: (value, _) => Text(
                      AdminFormat.count(value),
                      style: TextStyle(
                        fontSize: 9,
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index < 0 || index >= chartData.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          chartData[index].period,
                          style: TextStyle(
                            fontSize: 9,
                            color: context.textTertiary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => context.cardColor,
                  tooltipBorder: BorderSide(color: context.borderStrong),
                  getTooltipItem: (group, _, rod, __) {
                    final point = chartData[group.x];
                    return BarTooltipItem(
                      '${point.period}\n${AdminFormat.money(rod.toY)}',
                      TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    );
                  },
                ),
              ),
              barGroups: [
                for (var index = 0; index < chartData.length; index++)
                  BarChartGroupData(
                    x: index,
                    barsSpace: 3,
                    barRods: [
                      _rod(
                        chartData[index].platformCommission,
                        context.primaryColor,
                      ),
                      _rod(
                        chartData[index].driverEarnings,
                        context.successColor,
                      ),
                      _rod(chartData[index].totalVolume, context.infoColor),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartRodData _rod(double value, Color color) {
    return BarChartRodData(
      toY: value,
      width: 9,
      color: color,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
    );
  }
}

class _LegendItem {
  final String label;
  final Color color;

  const _LegendItem(this.label, this.color);
}

class _ChartLegend extends StatelessWidget {
  final List<_LegendItem> items;

  const _ChartLegend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: TextStyle(fontSize: 11, color: context.textSecondary),
              ),
            ],
          ),
      ],
    );
  }
}
