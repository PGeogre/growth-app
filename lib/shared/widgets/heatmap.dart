import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart' as du;

/// GitHub 风格打卡热力图（近 15 周）
class HeatmapCalendar extends StatelessWidget {
  final Set<String> activeDays;
  final Color color;

  const HeatmapCalendar({super.key, required this.activeDays, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    // 从今天往回推 15 周
    final now = DateTime.now();
    final start = now.subtract(Duration(days: 14 * 7 + now.weekday - 1));
    final weeks = <List<String>>[];
    final labels = <String>[];
    var cursor = start;
    for (var w = 0; w < 15; w++) {
      final week = <String>[];
      for (var d = 0; d < 7; d++) {
        week.add(du.DateUtils.format(cursor));
        cursor = cursor.add(const Duration(days: 1));
      }
      weeks.add(week);
      labels.add('${week.first.substring(5, 7)}/${week.first.substring(8, 10)}');
    }

    final monthLabels = <int, String>{};
    for (var i = 0; i < weeks.length; i++) {
      final m = weeks[i].first.substring(5, 7);
      if (!monthLabels.containsValue('$m月') && i % 4 == 0) {
        monthLabels[i] = '$m月';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 月份标签
              SizedBox(
                height: 18,
                child: Row(
                  children: [
                    for (var i = 0; i < weeks.length; i++)
                      SizedBox(
                        width: 16,
                        child: Text(
                          monthLabels[i] ?? '',
                          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 星期标签
                  Column(
                    children: const [
                      SizedBox(height: 0, width: 22),
                      _WeekLabel('一'),
                      _WeekLabel('三'),
                      _WeekLabel('五'),
                    ],
                  ),
                  // 色块
                  Column(
                    children: [
                      for (var row = 0; row < 7; row++)
                        Row(
                          children: [
                            for (var w = 0; w < weeks.length; w++)
                              _DayCell(
                                active: activeDays.contains(weeks[w][row]),
                                color: color,
                                isFuture: weeks[w][row].compareTo(du.DateUtils.today()) > 0,
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('少', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(width: 4),
            _legendCell(AppColors.divider),
            _legendCell(color.withValues(alpha: 0.4)),
            _legendCell(color.withValues(alpha: 0.7)),
            _legendCell(color),
            const SizedBox(width: 4),
            const Text('多', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _legendCell(Color c) => Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
      );
}

class _WeekLabel extends StatelessWidget {
  final String text;
  const _WeekLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      width: 22,
      child: Text(text, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
    );
  }
}

class _DayCell extends StatelessWidget {
  final bool active;
  final Color color;
  final bool isFuture;

  const _DayCell({required this.active, required this.color, required this.isFuture});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 13,
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: isFuture
            ? Colors.transparent
            : active
                ? color
                : AppColors.divider,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
