import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// 简单折线图（用于睡眠趋势等）
class SimpleLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final String unit;

  const SimpleLineChart({
    super.key,
    required this.values,
    required this.labels,
    this.color = AppColors.sleep,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox(height: 160, child: Center(child: Text('暂无数据', style: TextStyle(color: AppColors.textHint))));
    }
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final spots = <FlSpot>[
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];
    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY <= 0 ? 10 : maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY <= 0 ? 10 : maxY * 1.2) / 4,
            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.divider, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2.5,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 简单柱状图（用于打卡/饮食统计）
class SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;

  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox(height: 160, child: Center(child: Text('暂无数据', style: TextStyle(color: AppColors.textHint))));
    }
    final maxY = values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 10 : maxY * 1.3,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY <= 0 ? 10 : maxY * 1.3) / 4,
            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.divider, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: color,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}
