import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/repositories.dart';
import '../models/models.dart';

// ---------- 主题 ----------
final themeModeProvider = FutureProvider.autoDispose<String>((ref) async {
  return Repositories.themeMode();
});

// ---------- 单词 ----------
final todayWordsProvider = FutureProvider.autoDispose<List<Word>>((ref) async {
  return Repositories.todayWords(_today());
});

final wordStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  return Repositories.wordStats();
});

// ---------- 打卡 ----------
final checkinProvider = FutureProvider.autoDispose.family<Set<String>, String>((ref, type) {
  return Repositories.checkinDates(type);
});

// ---------- 习惯 ----------
final habitsProvider = FutureProvider.autoDispose<List<Habit>>((ref) async {
  return Repositories.habits();
});

// ---------- 目标 ----------
final goalsProvider = FutureProvider.autoDispose<List<Goal>>((ref) async {
  return Repositories.goals();
});

// ---------- 心情 ----------
final moodsProvider = FutureProvider.autoDispose<List<Mood>>((ref) async {
  return Repositories.moods();
});

// ---------- 饮食 ----------
final mealsProvider = FutureProvider.autoDispose.family<List<Meal>, String>((ref, date) {
  return Repositories.meals(date);
});

// ---------- 睡眠 ----------
final sleepsProvider = FutureProvider.autoDispose<List<Sleep>>((ref) async {
  return Repositories.sleeps();
});

// ---------- 运动 ----------
final workoutsProvider = FutureProvider.autoDispose<List<Workout>>((ref) async {
  return Repositories.workouts();
});

final workoutStatsProvider = FutureProvider.autoDispose<Map<String, Object>>((ref) async {
  return Repositories.workoutStats();
});

// ---------- 便签 ----------
final notesProvider = FutureProvider.autoDispose<List<Note>>((ref) async {
  return Repositories.notes();
});

// ---------- 打卡热力图 ----------
final activeDaysProvider = FutureProvider.autoDispose<Set<String>>((ref) async {
  return Repositories.activeDays();
});

// ---------- 工具 ----------
String _today() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

/// 刷新某个 future provider 的辅助函数
void invalidate(WidgetRef ref, List<dynamic> providers) {
  for (final p in providers) {
    ref.invalidate(p);
  }
}
