import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/db/repositories.dart';
import '../../providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/charts.dart';

class EnglishPage extends ConsumerWidget {
  const EnglishPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('英语学习')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WordProgressCard(),
          const SizedBox(height: 20),
          _DailyWordsCard(),
          const SizedBox(height: 20),
          _CheckinCard(),
          const SizedBox(height: 20),
          _WeekStatsCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _WordProgressCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(wordStatsProvider);
    final total = statsAsync.valueOrNull?['total'] ?? 0;
    final mastered = statsAsync.valueOrNull?['mastered'] ?? 0;
    final pct = total == 0 ? 0.0 : mastered / total;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '词汇掌握'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ProgressBar(value: pct, color: AppColors.english)),
              const SizedBox(width: 12),
              Text('$mastered/$total', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          Text('已掌握 ${(pct * 100).toStringAsFixed(0)}% 的词汇', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _DailyWordsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(todayWordsProvider);
    final words = wordsAsync.valueOrNull ?? [];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '今日单词'),
          const SizedBox(height: 8),
          if (wordsAsync.isLoading)
            const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else if (words.isEmpty)
            const EmptyState(icon: Icons.menu_book_outlined, message: '暂无单词')
          else
            for (final w in words) _WordTile(word: w),
        ],
      ),
    );
  }
}

class _WordTile extends ConsumerWidget {
  final dynamic word; // Word 类型
  const _WordTile({required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mastered = word.isMastered as bool;
    return InkWell(
      onTap: () => _showWordDetail(context, word),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (mastered ? AppColors.english : AppColors.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(mastered ? Icons.check : Icons.volume_up_outlined,
                  color: mastered ? Colors.white : AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word.word as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(word.phonetic as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(word.level as String, style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(mastered ? Icons.undo : Icons.check_circle_outline,
                  color: mastered ? AppColors.textHint : AppColors.primary),
              onPressed: () async {
                final today = du.DateUtils.today();
                await Repositories.markWordDone(today, word.id as int, !mastered);
                ref.invalidate(todayWordsProvider);
                ref.invalidate(wordStatsProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWordDetail(BuildContext context, dynamic w) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(w.word as String, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(w.phonetic as String, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text(w.meaning as String, style: const TextStyle(fontSize: 16, color: AppColors.primaryDark, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Text(w.example as String, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontStyle: FontStyle.italic)),
            const SizedBox(height: 4),
            Text(w.exampleCn as String, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CheckinCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CheckinCard> createState() => _CheckinCardState();
}

class _CheckinCardState extends ConsumerState<_CheckinCard> {
  @override
  Widget build(BuildContext context) {
    final datesAsync = ref.watch(checkinProvider('english'));
    final doneDates = datesAsync.valueOrNull ?? {};
    final today = du.DateUtils.today();
    final checked = doneDates.contains(today);
    final streak = du.DateUtils.streakOf(doneDates);

    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: AppColors.english.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.local_fire_department, color: AppColors.english, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('连续打卡 $streak 天', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(checked ? '今天已打卡，继续保持！' : '今天还没打卡哦', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          FilledButton(
            onPressed: checked
                ? null
                : () async {
                    await Repositories.addCheckin(today, 'english');
                    ref.invalidate(checkinProvider('english'));
                  },
            child: Text(checked ? '已打卡' : '打卡'),
          ),
        ],
      ),
    );
  }
}

class _WeekStatsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datesAsync = ref.watch(checkinProvider('english'));
    final doneDates = datesAsync.valueOrNull ?? {};
    final now = DateTime.now();
    final labels = <String>[];
    final values = <double>[];
    for (var i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = du.DateUtils.format(d);
      labels.add(du.DateUtils.weekdayNameZh(d.weekday));
      values.add(doneDates.contains(key) ? 1.0 : 0.0);
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '本周打卡'),
          const SizedBox(height: 12),
          SimpleBarChart(values: values, labels: labels, color: AppColors.english),
        ],
      ),
    );
  }
}
