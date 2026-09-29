import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/heatmap.dart';
import '../../shared/widgets/badges.dart';
import '../notes/notes_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = du.DateUtils.today();
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 6 ? '夜深了' : hour < 12 ? '早上好' : hour < 18 ? '下午好' : '晚上好';

    return Scaffold(
      appBar: AppBar(
        title: Text('$greeting，$today'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayWordsProvider);
          ref.invalidate(mealsProvider(today));
          ref.invalidate(sleepsProvider);
          ref.invalidate(workoutsProvider);
          ref.invalidate(goalsProvider);
          ref.invalidate(notesProvider);
          ref.invalidate(activeDaysProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TodayOverviewCard(date: today),
            const SizedBox(height: 20),
            _TodayTimeline(date: today),
            const SizedBox(height: 20),
            _NotesPreviewCard(),
            const SizedBox(height: 20),
            _HeatmapCard(),
            const SizedBox(height: 20),
            _BadgesPreviewCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TodayOverviewCard extends ConsumerWidget {
  final String date;
  const _TodayOverviewCard({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(todayWordsProvider);
    final mealsAsync = ref.watch(mealsProvider(date));
    final sleepsAsync = ref.watch(sleepsProvider);
    final workoutsAsync = ref.watch(workoutsProvider);
    final goalsAsync = ref.watch(goalsProvider);

    final words = wordsAsync.valueOrNull ?? [];
    final wordDone = words.where((w) => w.isMastered).length;
    final meals = mealsAsync.valueOrNull ?? [];
    final todaySleep = sleepsAsync.valueOrNull?.where((s) => s.date == date).toList() ?? [];
    final sleepToday = todaySleep.isNotEmpty ? todaySleep.first.durationMin : 0;
    final workoutToday = workoutsAsync.valueOrNull?.where((w) => w.date == date).toList() ?? [];
    final goals = goalsAsync.valueOrNull ?? [];

    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('今日概览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _Metric(label: '单词', value: '$wordDone/${words.length}', color: AppColors.english)),
              Expanded(child: _Metric(label: '饮食', value: '${meals.length} 餐', color: AppColors.diet)),
              Expanded(child: _Metric(label: '睡眠', value: sleepToday > 0 ? _fmtDuration(sleepToday) : '—', color: AppColors.sleep)),
              Expanded(child: _Metric(label: '运动', value: '${workoutToday.length} 次', color: AppColors.workout)),
            ],
          ),
          const SizedBox(height: 16),
          if (goals.isNotEmpty) ...[
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),
            const Text('目标进度', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            for (final g in goals.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(g.title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    SizedBox(width: 100, child: ProgressBar(value: g.progress / 100)),
                    const SizedBox(width: 8),
                    Text('${g.progress}%', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _fmtDuration(int min) {
    final h = min ~/ 60;
    final m = min % 60;
    return h > 0 ? '$h时$m分' : '$m分';
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Metric({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

/// 今日时间线：聚合各模块今天的记录
class _TodayTimeline extends ConsumerWidget {
  final String date;
  const _TodayTimeline({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider(date)).valueOrNull ?? [];
    final moods = ref.watch(moodsProvider).valueOrNull ?? [];
    final workouts = ref.watch(workoutsProvider).valueOrNull ?? [];
    final todayMood = moods.where((m) => m.date == date).toList();
    final todayWorkout = workouts.where((w) => w.date == date).toList();

    final entries = <(String, String, IconData, Color)>[];
    for (final m in meals) {
      entries.add((m.eatenAt ?? '今日', m.foodName, Icons.restaurant, AppColors.diet));
    }
    for (final m in todayMood) {
      entries.add(('心情', m.mood + (m.note.isNotEmpty ? ' ${m.note}' : ''), Icons.mood, AppColors.mood));
    }
    for (final w in todayWorkout) {
      entries.add(('运动', '${w.workoutType} ${w.durationMin}分钟', Icons.fitness_center, AppColors.workout));
    }
    entries.sort((a, b) => a.$1.compareTo(b.$1));

    if (entries.isEmpty) {
      return SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SectionTitle(title: '今日时间线'),
            SizedBox(height: 12),
            Text('今天还没有记录，去健康/成长页记一笔吧', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '今日时间线'),
          const SizedBox(height: 12),
          for (var i = 0; i < entries.length; i++)
            Row(
              children: [
                Icon(entries[i].$3, size: 18, color: entries[i].$4),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entries[i].$2,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(entries[i].$1, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
        ],
      ),
    );
  }
}

/// 便签墙预览卡片
class _NotesPreviewCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider).valueOrNull ?? [];
    return SectionCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesPage())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: '便签', trailing: '查看全部 →', onTrailingTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesPage()))),
          const SizedBox(height: 12),
          if (notes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text('记录灵感和待办，点这里新建便签', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final n in notes.take(4))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(n.color),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      n.title.isEmpty ? (n.content.isEmpty ? '便签' : n.content) : n.title,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF3A3A3A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// 打卡热力图卡片
class _HeatmapCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDays = ref.watch(activeDaysProvider).valueOrNull ?? {};
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '打卡热力图'),
          const SizedBox(height: 12),
          HeatmapCalendar(activeDays: activeDays, color: AppColors.primary),
        ],
      ),
    );
  }
}

/// 徽章预览卡片
class _BadgesPreviewCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datesAsync = ref.watch(checkinProvider('english'));
    final streak = du.DateUtils.streakOf(datesAsync.valueOrNull ?? {});
    final badges = buildBadges(streak);
    final unlocked = badges.where((b) => b.unlocked).length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle(title: '成就徽章')),
              Text('$unlocked/${badges.length} 已解锁', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          BadgeGrid(badges: badges),
        ],
      ),
    );
  }
}
