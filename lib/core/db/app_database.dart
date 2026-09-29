import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'growth_app.db');
    final db = await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
    await _seedWords(db);
    return db;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT DEFAULT '',
          content TEXT DEFAULT '',
          color TEXT DEFAULT '0xFFFFE9B8',
          image_path TEXT,
          pinned INTEGER DEFAULT 0,
          created_at TEXT DEFAULT (datetime('now','localtime')),
          updated_at TEXT DEFAULT (datetime('now','localtime'))
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      await db.execute("INSERT OR IGNORE INTO app_settings (key, value) VALUES ('theme_mode', 'light')");
      // 图片字段迁移（表可能不存在于旧库，用 try 容错）
      for (final spec in [
        ['meals', 'image_path TEXT'],
        ['moods', 'image_path TEXT'],
        ['workouts', 'image_path TEXT'],
      ]) {
        try {
          await db.execute('ALTER TABLE ${spec[0]} ADD COLUMN ${spec[1]}');
        } catch (_) {
          // 列已存在则忽略
        }
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        phonetic TEXT DEFAULT '',
        meaning TEXT DEFAULT '',
        example TEXT DEFAULT '',
        example_cn TEXT DEFAULT '',
        level TEXT DEFAULT '基础',
        is_mastered INTEGER DEFAULT 0,
        review_count INTEGER DEFAULT 0,
        last_reviewed_at TEXT,
        created_at TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        word_id INTEGER NOT NULL,
        done INTEGER DEFAULT 0,
        done_at TEXT,
        UNIQUE(date, word_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT DEFAULT '⭐',
        color TEXT DEFAULT '0xFF7FA98F',
        archived INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status INTEGER DEFAULT 1,
        created_at TEXT DEFAULT (datetime('now','localtime')),
        UNIQUE(habit_id, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT DEFAULT '',
        start_date TEXT,
        end_date TEXT,
        progress INTEGER DEFAULT 0,
        status TEXT DEFAULT '进行中',
        created_at TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    await db.execute('''
      CREATE TABLE moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        score INTEGER DEFAULT 3,
        mood TEXT DEFAULT '🙂',
        note TEXT DEFAULT '',
        image_path TEXT,
        created_at TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        food_name TEXT NOT NULL,
        note TEXT DEFAULT '',
        eaten_at TEXT,
        image_path TEXT,
        created_at TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    await db.execute('''
      CREATE TABLE sleeps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        sleep_time TEXT NOT NULL,
        wake_time TEXT NOT NULL,
        duration_min INTEGER DEFAULT 0,
        quality INTEGER DEFAULT 3,
        note TEXT DEFAULT '',
        created_at TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        workout_type TEXT NOT NULL,
        duration_min INTEGER DEFAULT 0,
        intensity TEXT DEFAULT '中',
        note TEXT DEFAULT '',
        image_path TEXT,
        created_at TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    await db.execute('''
      CREATE TABLE checkins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        note TEXT DEFAULT '',
        created_at TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT DEFAULT '',
        content TEXT DEFAULT '',
        color TEXT DEFAULT '0xFFFFE9B8',
        image_path TEXT,
        pinned INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now','localtime')),
        updated_at TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute("INSERT OR IGNORE INTO app_settings (key, value) VALUES ('theme_mode', 'light')");
  }

  /// 首次启动灌入内置词库
  Future<void> _seedWords(Database db) async {
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM words')) ??
        0;
    if (count > 0) return;

    final raw = await rootBundle.loadString('assets/words.json');
    // 简单 JSON 解析（避免引入额外依赖），词库格式固定
    final list = _parseWordList(raw);
    final batch = db.batch();
    for (final w in list) {
      batch.insert('words', w);
    }
    await batch.commit(noResult: true);
  }

  List<Map<String, Object?>> _parseWordList(String raw) {
    final result = <Map<String, Object?>>[];
    final re = RegExp(r'\{[^{}]*\}');
    for (final m in re.allMatches(raw)) {
      final block = m.group(0)!;
      final map = <String, Object?>{};
      for (final kv in RegExp(r'"([^"]+)"\s*:\s*"([^"]*)"').allMatches(block)) {
        map[kv.group(1)!] = kv.group(2)!;
      }
      if (map['word'] != null) result.add(map);
    }
    return result;
  }
}
