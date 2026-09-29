import 'package:intl/intl.dart';

class DateUtils {
  DateUtils._();

  static String today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static String format(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  static String monthKey(DateTime d) => DateFormat('yyyy-MM').format(d);

  static String weekKey(DateTime d) {
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return format(monday);
  }

  /// 计算连续打卡天数（给定已打卡日期集合，从今天往前数）
  static int streakOf(Set<String> doneDates) {
    var streak = 0;
    var cursor = DateTime.now();
    while (doneDates.contains(format(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// 睡眠时长（分钟），跨天自动处理
  static int sleepMinutes(DateTime sleepTime, DateTime wakeTime) {
    var diff = wakeTime.difference(sleepTime).inMinutes;
    if (diff < 0) diff += 24 * 60; // 跨天
    return diff;
  }

  static String weekdayNameZh(int weekday) {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[weekday - 1];
  }
}
