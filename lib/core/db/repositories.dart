import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'app_database.dart';
import '../utils/date_utils.dart' as du;
import '../../models/models.dart';

/// 数据访问层：各模块 CRUD + 统计聚合
class Repositories {
  Repositories._();

  static Future<Database> get _db => AppDatabase.instance.database;

  // ---------- 主题偏好 ----------
  static Future<String> themeMode() async {
    final db = await _db;
    final rows = await db.query('app_settings', where: 'key = ?', whereArgs: ['theme_mode']);
    return rows.isEmpty ? 'light' : rows.first['value'] as String;
  }

  static Future<void> setThemeMode(String mode) async {
    final db = await _db;
    await db.insert('app_settings', {'key': 'theme_mode', 'value': mode},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---------- 图片工具：把临时图复制到 App 私有目录，返回持久路径 ----------
  static Future<String?> saveImage(String? tmpPath) async {
    if (tmpPath == null || tmpPath.isEmpty) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imgDir = Directory('${dir.path}/images');
      if (!imgDir.existsSync()) imgDir.createSync(recursive: true);
      final ext = tmpPath.split('.').last;
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final dest = '${imgDir.path}/$fileName';
      await File(tmpPath).copy(dest);
      return dest;
    } catch (_) {
      return null;
    }
  }

  // ---------- 便签 ----------
  static Future<List<Note>> notes() async {
    final db = await _db;
    final rows = await db.query('notes', orderBy: 'pinned DESC, updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  static Future<int> addNote(Note n) async {
    final db = await _db;
    return await db.insert('notes', n.toMap());
  }

  static Future<void> updateNote(Note n) async {
    final db = await _db;
    await db.update('notes', n.toMap(), where: 'id = ?', whereArgs: [n.id]);
  }

  static Future<void> deleteNote(int id) async {
    final db = await _db;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }


  // ---------- 单词 ----------
  static Future<List<Word>> words() async {
    final db = await _db;
    final rows = await db.query('words', orderBy: 'id ASC');
    return rows.map(Word.fromMap).toList();
  }

  static Future<List<Word>> todayWords(String date, {int count = 10}) async {
    final db = await _db;
    // 今天还没生成则从词库按掌握度/复习次数取 count 个
    final existing = await db.query('daily_words', where: 'date = ?', whereArgs: [date]);
    if (existing.isEmpty) {
      final rows = await db.query(
        'words',
        orderBy: 'is_mastered ASC, review_count ASC, id ASC',
        limit: count,
      );
      final batch = db.batch();
      for (final r in rows) {
        batch.insert('daily_words', {'date': date, 'word_id': r['id']});
      }
      await batch.commit(noResult: true);
      return rows.map(Word.fromMap).toList();
    }
    // 已有计划，联表取回
    final rows = await db.rawQuery('''
      SELECT w.*, dw.done FROM words w
      INNER JOIN daily_words dw ON dw.word_id = w.id
      WHERE dw.date = ? ORDER BY dw.id ASC
    ''', [date]);
    return rows.map((m) {
      final w = Word.fromMap(m);
      return (m['done'] as int? ?? 0) == 1
          ? w.copyWith(isMastered: true)
          : w;
    }).toList();
  }

  static Future<void> markWordDone(String date, int wordId, bool done) async {
    final db = await _db;
    await db.update(
      'daily_words',
      {'done': done ? 1 : 0, 'done_at': done ? DateTime.now().toIso8601String() : null},
      where: 'date = ? AND word_id = ?',
      whereArgs: [date, wordId],
    );
    if (done) {
      await db.rawUpdate(
          'UPDATE words SET is_mastered = 1, review_count = review_count + 1, last_reviewed_at = ? WHERE id = ?',
          [DateTime.now().toIso8601String(), wordId]);
    } else {
      await db.update('words', {'is_mastered': 0},
          where: 'id = ?', whereArgs: [wordId]);
    }
  }

  static Future<Map<String, int>> wordStats() async {
    final db = await _db;
    final total = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM words')) ??
        0;
    final mastered = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM words WHERE is_mastered = 1')) ??
        0;
    return {'total': total, 'mastered': mastered};
  }

  // ---------- 通用打卡 ----------
  static Future<void> addCheckin(String date, String type, {String note = ''}) async {
    final db = await _db;
    await db.insert('checkins', {'date': date, 'type': type, 'note': note},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Set<String>> checkinDates(String type) async {
    final db = await _db;
    final rows = await db.query('checkins', where: 'type = ?', whereArgs: [type]);
    return rows.map((r) => r['date'] as String).toSet();
  }

  static Future<int> streak(String type) async {
    final dates = await checkinDates(type);
    return du.DateUtils.streakOf(dates);
  }

  // ---------- 习惯 ----------
  static Future<List<Habit>> habits() async {
    final db = await _db;
    final rows = await db.query('habits', where: 'archived = 0', orderBy: 'id ASC');
    return rows.map(Habit.fromMap).toList();
  }

  static Future<int> addHabit(Habit h) async {
    final db = await _db;
    return await db.insert('habits', h.toMap());
  }

  static Future<void> deleteHabit(int id) async {
    final db = await _db;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
    await db.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
  }

  static Future<void> toggleHabitLog(int habitId, String date, int status) async {
    final db = await _db;
    await db.insert(
      'habit_logs',
      {'habit_id': habitId, 'date': date, 'status': status},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Set<String>> habitDoneDates(int habitId) async {
    final db = await _db;
    final rows = await db.query('habit_logs',
        where: 'habit_id = ? AND status = 1', whereArgs: [habitId]);
    return rows.map((r) => r['date'] as String).toSet();
  }

  static Future<int> habitStreak(int habitId) async {
    final dates = await habitDoneDates(habitId);
    return du.DateUtils.streakOf(dates);
  }

  static Future<Map<String, int>> habitLogCounts(int habitId, {int days = 7}) async {
    final db = await _db;
    final start = DateTime.now().subtract(Duration(days: days - 1));
    final startStr = du.DateUtils.format(start);
    final rows = await db.rawQuery('''
      SELECT date, COUNT(*) c FROM habit_logs
      WHERE habit_id = ? AND status = 1 AND date >= ?
      GROUP BY date
    ''', [habitId, startStr]);
    final map = <String, int>{};
    for (final r in rows) {
      map[r['date'] as String] = (r['c'] as int?) ?? 0;
    }
    return map;
  }

  // ---------- 目标 ----------
  static Future<List<Goal>> goals() async {
    final db = await _db;
    final rows = await db.query('goals', orderBy: 'id ASC');
    return rows.map(Goal.fromMap).toList();
  }

  static Future<int> addGoal(Goal g) async {
    final db = await _db;
    return await db.insert('goals', g.toMap());
  }

  static Future<void> updateGoal(Goal g) async {
    final db = await _db;
    await db.update('goals', g.toMap(), where: 'id = ?', whereArgs: [g.id]);
  }

  static Future<void> deleteGoal(int id) async {
    final db = await _db;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- 心情 ----------
  static Future<List<Mood>> moods({int limit = 30}) async {
    final db = await _db;
    final rows = await db.query('moods', orderBy: 'date DESC', limit: limit);
    return rows.map(Mood.fromMap).toList();
  }

  static Future<void> saveMood(Mood m) async {
    final db = await _db;
    await db.insert('moods', m.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Mood?> moodOf(String date) async {
    final db = await _db;
    final rows = await db.query('moods', where: 'date = ?', whereArgs: [date]);
    return rows.isEmpty ? null : Mood.fromMap(rows.first);
  }

  // ---------- 饮食 ----------
  static Future<List<Meal>> meals(String date) async {
    final db = await _db;
    final rows = await db.query('meals', where: 'date = ?', whereArgs: [date],
        orderBy: 'eaten_at ASC, id ASC');
    return rows.map(Meal.fromMap).toList();
  }

  static Future<int> addMeal(Meal m) async {
    final db = await _db;
    return await db.insert('meals', m.toMap());
  }

  static Future<void> deleteMeal(int id) async {
    final db = await _db;
    await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> mealCount(String date) async {
    final db = await _db;
    return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM meals WHERE date = ?', [date])) ??
        0;
  }

  static Future<Map<String, int>> mealCountLast7() async {
    final db = await _db;
    final start = DateTime.now().subtract(const Duration(days: 6));
    final startStr = du.DateUtils.format(start);
    final rows = await db.rawQuery('''
      SELECT date, COUNT(*) c FROM meals WHERE date >= ? GROUP BY date
    ''', [startStr]);
    final map = <String, int>{};
    for (final r in rows) {
      map[r['date'] as String] = (r['c'] as int?) ?? 0;
    }
    return map;
  }

  // ---------- 睡眠 ----------
  static Future<List<Sleep>> sleeps({int limit = 30}) async {
    final db = await _db;
    final rows = await db.query('sleeps', orderBy: 'date DESC', limit: limit);
    return rows.map(Sleep.fromMap).toList();
  }

  static Future<Sleep?> sleepOf(String date) async {
    final db = await _db;
    final rows = await db.query('sleeps', where: 'date = ?', whereArgs: [date]);
    return rows.isEmpty ? null : Sleep.fromMap(rows.first);
  }

  static Future<void> saveSleep(Sleep s) async {
    final db = await _db;
    await db.insert('sleeps', s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteSleep(int id) async {
    final db = await _db;
    await db.delete('sleeps', where: 'id = ?', whereArgs: [id]);
  }

  static Future<double> avgSleepLast7() async {
    final db = await _db;
    final start = DateTime.now().subtract(const Duration(days: 6));
    final startStr = du.DateUtils.format(start);
    final v = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT AVG(duration_min) FROM sleeps WHERE date >= ?
    ''', [startStr]));
    return v?.toDouble() ?? 0;
  }

  // ---------- 运动 ----------
  static Future<List<Workout>> workouts({int limit = 30}) async {
    final db = await _db;
    final rows = await db.query('workouts', orderBy: 'date DESC', limit: limit);
    return rows.map(Workout.fromMap).toList();
  }

  static Future<int> addWorkout(Workout w) async {
    final db = await _db;
    return await db.insert('workouts', w.toMap());
  }

  static Future<void> deleteWorkout(int id) async {
    final db = await _db;
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, Object>> workoutStats() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM workouts')) ??
        0;
    final totalMin = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COALESCE(SUM(duration_min),0) FROM workouts')) ??
        0;
    return {'count': count, 'totalMin': totalMin};
  }

  // ---------- 打卡热力图数据：聚合所有活跃记录到按日期集合 ----------
  static Future<Set<String>> activeDays() async {
    final db = await _db;
    final set = <String>{};
    final c = await db.query('checkins', columns: ['date']);
    for (final r in c) {
      set.add(r['date'] as String);
    }
    final h = await db.query('habit_logs', columns: ['date'], where: 'status = 1');
    for (final r in h) {
      set.add(r['date'] as String);
    }
    final m = await db.query('moods', columns: ['date']);
    for (final r in m) {
      set.add(r['date'] as String);
    }
    final w = await db.query('workouts', columns: ['date']);
    for (final r in w) {
      set.add(r['date'] as String);
    }
    return set;
  }
}
