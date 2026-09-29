// 数据模型定义
class Word {
  final int id;
  final String word;
  final String phonetic;
  final String meaning;
  final String example;
  final String exampleCn;
  final String level;
  final bool isMastered;
  final int reviewCount;

  const Word({
    required this.id,
    required this.word,
    this.phonetic = '',
    this.meaning = '',
    this.example = '',
    this.exampleCn = '',
    this.level = '基础',
    this.isMastered = false,
    this.reviewCount = 0,
  });

  factory Word.fromMap(Map<String, Object?> m) => Word(
        id: m['id'] as int,
        word: m['word'] as String,
        phonetic: (m['phonetic'] as String?) ?? '',
        meaning: (m['meaning'] as String?) ?? '',
        example: (m['example'] as String?) ?? '',
        exampleCn: (m['example_cn'] as String?) ?? '',
        level: (m['level'] as String?) ?? '基础',
        isMastered: (m['is_mastered'] as int? ?? 0) == 1,
        reviewCount: (m['review_count'] as int?) ?? 0,
      );

  Word copyWith({bool? isMastered, int? reviewCount}) => Word(
        id: id,
        word: word,
        phonetic: phonetic,
        meaning: meaning,
        example: example,
        exampleCn: exampleCn,
        level: level,
        isMastered: isMastered ?? this.isMastered,
        reviewCount: reviewCount ?? this.reviewCount,
      );
}

class Habit {
  final int id;
  final String name;
  final String icon;
  final int color;
  final bool archived;

  const Habit({
    required this.id,
    required this.name,
    this.icon = '⭐',
    this.color = 0xFF7FA98F,
    this.archived = false,
  });

  factory Habit.fromMap(Map<String, Object?> m) => Habit(
        id: m['id'] as int,
        name: m['name'] as String,
        icon: (m['icon'] as String?) ?? '⭐',
        color: int.tryParse((m['color'] as String?) ?? '') ?? 0xFF7FA98F,
        archived: (m['archived'] as int? ?? 0) == 1,
      );

  Map<String, Object?> toMap() => {
        'name': name,
        'icon': icon,
        'color': '0x${color.toRadixString(16).toUpperCase()}',
        'archived': archived ? 1 : 0,
      };
}

class Goal {
  final int id;
  final String title;
  final String description;
  final String? startDate;
  final String? endDate;
  final int progress;
  final String status;

  const Goal({
    required this.id,
    required this.title,
    this.description = '',
    this.startDate,
    this.endDate,
    this.progress = 0,
    this.status = '进行中',
  });

  factory Goal.fromMap(Map<String, Object?> m) => Goal(
        id: m['id'] as int,
        title: m['title'] as String,
        description: (m['description'] as String?) ?? '',
        startDate: m['start_date'] as String?,
        endDate: m['end_date'] as String?,
        progress: (m['progress'] as int?) ?? 0,
        status: (m['status'] as String?) ?? '进行中',
      );

  Map<String, Object?> toMap() => {
        'title': title,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'progress': progress,
        'status': status,
      };
}

class Mood {
  final int id;
  final String date;
  final int score;
  final String mood;
  final String note;
  final String? imagePath;

  const Mood({
    required this.id,
    required this.date,
    this.score = 3,
    this.mood = '🙂',
    this.note = '',
    this.imagePath,
  });

  factory Mood.fromMap(Map<String, Object?> m) => Mood(
        id: m['id'] as int,
        date: m['date'] as String,
        score: (m['score'] as int?) ?? 3,
        mood: (m['mood'] as String?) ?? '🙂',
        note: (m['note'] as String?) ?? '',
        imagePath: m['image_path'] as String?,
      );

  Map<String, Object?> toMap() => {
        'date': date,
        'score': score,
        'mood': mood,
        'note': note,
        'image_path': imagePath,
      };
}

class Meal {
  final int id;
  final String date;
  final String mealType;
  final String foodName;
  final String note;
  final String? eatenAt;
  final String? imagePath;

  const Meal({
    required this.id,
    required this.date,
    required this.mealType,
    required this.foodName,
    this.note = '',
    this.eatenAt,
    this.imagePath,
  });

  factory Meal.fromMap(Map<String, Object?> m) => Meal(
        id: m['id'] as int,
        date: m['date'] as String,
        mealType: m['meal_type'] as String,
        foodName: m['food_name'] as String,
        note: (m['note'] as String?) ?? '',
        eatenAt: m['eaten_at'] as String?,
        imagePath: m['image_path'] as String?,
      );

  Map<String, Object?> toMap() => {
        'date': date,
        'meal_type': mealType,
        'food_name': foodName,
        'note': note,
        'eaten_at': eatenAt,
        'image_path': imagePath,
      };
}

class Sleep {
  final int id;
  final String date;
  final String sleepTime;
  final String wakeTime;
  final int durationMin;
  final int quality;
  final String note;

  const Sleep({
    required this.id,
    required this.date,
    required this.sleepTime,
    required this.wakeTime,
    required this.durationMin,
    this.quality = 3,
    this.note = '',
  });

  factory Sleep.fromMap(Map<String, Object?> m) => Sleep(
        id: m['id'] as int,
        date: m['date'] as String,
        sleepTime: m['sleep_time'] as String,
        wakeTime: m['wake_time'] as String,
        durationMin: (m['duration_min'] as int?) ?? 0,
        quality: (m['quality'] as int?) ?? 3,
        note: (m['note'] as String?) ?? '',
      );

  Map<String, Object?> toMap() => {
        'date': date,
        'sleep_time': sleepTime,
        'wake_time': wakeTime,
        'duration_min': durationMin,
        'quality': quality,
        'note': note,
      };
}

class Workout {
  final int id;
  final String date;
  final String workoutType;
  final int durationMin;
  final String intensity;
  final String note;
  final String? imagePath;

  const Workout({
    required this.id,
    required this.date,
    required this.workoutType,
    this.durationMin = 0,
    this.intensity = '中',
    this.note = '',
    this.imagePath,
  });

  factory Workout.fromMap(Map<String, Object?> m) => Workout(
        id: m['id'] as int,
        date: m['date'] as String,
        workoutType: m['workout_type'] as String,
        durationMin: (m['duration_min'] as int?) ?? 0,
        intensity: (m['intensity'] as String?) ?? '中',
        note: (m['note'] as String?) ?? '',
        imagePath: m['image_path'] as String?,
      );

  Map<String, Object?> toMap() => {
        'date': date,
        'workout_type': workoutType,
        'duration_min': durationMin,
        'intensity': intensity,
        'note': note,
        'image_path': imagePath,
      };
}

/// 便签
class Note {
  final int id;
  final String title;
  final String content;
  final int color;
  final String? imagePath;
  final bool pinned;

  const Note({
    required this.id,
    this.title = '',
    this.content = '',
    this.color = 0xFFFFE9B8,
    this.imagePath,
    this.pinned = false,
  });

  factory Note.fromMap(Map<String, Object?> m) => Note(
        id: m['id'] as int,
        title: (m['title'] as String?) ?? '',
        content: (m['content'] as String?) ?? '',
        color: int.tryParse((m['color'] as String?) ?? '') ?? 0xFFFFE9B8,
        imagePath: m['image_path'] as String?,
        pinned: (m['pinned'] as int? ?? 0) == 1,
      );

  Map<String, Object?> toMap() => {
        'title': title,
        'content': content,
        'color': '0x${color.toRadixString(16).toUpperCase().padLeft(8, '0')}',
        'image_path': imagePath,
        'pinned': pinned ? 1 : 0,
      };
}
