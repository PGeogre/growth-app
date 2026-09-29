import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/db/repositories.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/image_field.dart';

class GrowthPage extends ConsumerWidget {
  const GrowthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('成长中心')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HabitsSection(),
          const SizedBox(height: 20),
          _GoalsSection(),
          const SizedBox(height: 20),
          _MoodSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ---------- 习惯 ----------
class _HabitsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final habits = habitsAsync.valueOrNull ?? [];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle(title: '习惯追踪')),
              TextButton.icon(
                onPressed: () => _showAddHabit(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新建'),
              ),
            ],
          ),
          if (habits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('还没有习惯，点击「新建」开始吧', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            for (final h in habits) _HabitTile(habit: h),
        ],
      ),
    );
  }

  void _showAddHabit(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final icons = ['⭐', '📖', '💪', '🧘', '💧', '🛏️', '🏃', '✍️'];
    var selectedIcon = '⭐';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('新建习惯', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: '习惯名称')),
              const SizedBox(height: 16),
              const Text('选择图标', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final ic in icons)
                    InkWell(
                      onTap: () => setState(() => selectedIcon = ic),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedIcon == ic ? AppColors.primaryLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(ic, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    await Repositories.addHabit(Habit(
                      id: 0,
                      name: nameCtrl.text.trim(),
                      icon: selectedIcon,
                      color: AppColors.primary.toARGB32(),
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    ref.invalidate(habitsProvider);
                  },
                  child: const Text('保存'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitTile extends ConsumerStatefulWidget {
  final Habit habit;
  const _HabitTile({required this.habit});

  @override
  ConsumerState<_HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends ConsumerState<_HabitTile> {
  @override
  Widget build(BuildContext context) {
    final today = du.DateUtils.today();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(widget.habit.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.habit.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                FutureBuilder<int>(
                  future: Repositories.habitStreak(widget.habit.id),
                  builder: (ctx, snap) => Text(
                    '连续 ${snap.data ?? 0} 天',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder<Set<String>>(
            future: Repositories.habitDoneDates(widget.habit.id),
            builder: (ctx, snap) {
              final done = snap.data?.contains(today) ?? false;
              return IconButton(
                icon: Icon(
                  done ? Icons.check_circle : Icons.circle_outlined,
                  color: done ? AppColors.primary : AppColors.textHint,
                ),
                onPressed: () async {
                  await Repositories.toggleHabitLog(widget.habit.id, today, done ? 0 : 1);
                  setState(() {});
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textHint),
            onPressed: () async {
              await Repositories.deleteHabit(widget.habit.id);
              ref.invalidate(habitsProvider);
            },
          ),
        ],
      ),
    );
  }
}

// ---------- 目标 ----------
class _GoalsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final goals = goalsAsync.valueOrNull ?? [];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle(title: '目标管理')),
              TextButton.icon(
                onPressed: () => _showAddGoal(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新建'),
              ),
            ],
          ),
          if (goals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('还没有目标，设定一个开始吧', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            for (final g in goals) _GoalTile(goal: g),
        ],
      ),
    );
  }

  void _showAddGoal(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    var progress = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('新建目标', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: '目标标题')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(hintText: '描述（可选）')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    await Repositories.addGoal(Goal(
                      id: 0,
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      progress: progress.round(),
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    ref.invalidate(goalsProvider);
                  },
                  child: const Text('保存'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalTile extends ConsumerWidget {
  final Goal goal;
  const _GoalTile({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(goal.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
              Text('${goal.progress}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textHint),
                onPressed: () async {
                  await Repositories.deleteGoal(goal.id);
                  ref.invalidate(goalsProvider);
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          ProgressBar(value: goal.progress / 100, color: AppColors.growth),
          const SizedBox(height: 4),
          Slider(
            value: goal.progress.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppColors.growth,
            onChanged: (v) async {
              await Repositories.updateGoal(Goal(
                id: goal.id,
                title: goal.title,
                description: goal.description,
                startDate: goal.startDate,
                endDate: goal.endDate,
                progress: v.round(),
                status: v >= 100 ? '已完成' : '进行中',
              ));
              ref.invalidate(goalsProvider);
            },
          ),
        ],
      ),
    );
  }
}

// ---------- 心情 ----------
class _MoodSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodsAsync = ref.watch(moodsProvider);
    final moods = moodsAsync.valueOrNull ?? [];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle(title: '心情记录')),
              TextButton.icon(
                onPressed: () => _showAddMood(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('记录'),
              ),
            ],
          ),
          if (moods.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('记录今天的心情吧', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            for (final m in moods.take(7))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(m.mood, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        m.note.isEmpty ? m.date : '${m.date} · ${m.note}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ThumbImage(imagePath: m.imagePath, size: 36),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  void _showAddMood(BuildContext context, WidgetRef ref) {
    final noteCtrl = TextEditingController();
    var score = 3;
    String? imagePath;
    const moodEmojis = {1: '😞', 2: '😕', 3: '🙂', 4: '😊', 5: '🤩'};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('记录心情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final e in moodEmojis.entries)
                    InkWell(
                      onTap: () => setState(() => score = e.key),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: score == e.key ? AppColors.mood.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(e.value, style: const TextStyle(fontSize: 30)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(controller: noteCtrl, decoration: const InputDecoration(hintText: '写点什么（可选）')),
              const SizedBox(height: 12),
              ImageField(
                imagePath: imagePath,
                onPick: () async {
                  final p = await pickAndSaveImage();
                  if (p != null) setState(() => imagePath = p);
                },
                onRemove: () => setState(() => imagePath = null),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.mood),
                  onPressed: () async {
                    await Repositories.saveMood(Mood(
                      id: 0,
                      date: du.DateUtils.today(),
                      score: score,
                      mood: moodEmojis[score]!,
                      note: noteCtrl.text.trim(),
                      imagePath: imagePath,
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    ref.invalidate(moodsProvider);
                  },
                  child: const Text('保存'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
