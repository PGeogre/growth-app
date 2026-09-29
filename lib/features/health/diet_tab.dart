import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/db/repositories.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/image_field.dart';

class DietTab extends ConsumerWidget {
  const DietTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = du.DateUtils.today();
    final mealsAsync = ref.watch(mealsProvider(today));
    final meals = mealsAsync.valueOrNull ?? [];

    final grouped = <String, List<Meal>>{};
    for (final m in meals) {
      grouped.putIfAbsent(m.mealType, () => []).add(m);
    }
    const typeOrder = ['breakfast', 'lunch', 'dinner', 'snack'];
    const typeLabels = {'breakfast': '早餐', 'lunch': '午餐', 'dinner': '晚餐', 'snack': '加餐'};
    const typeColors = {
      'breakfast': AppColors.diet,
      'lunch': AppColors.workout,
      'dinner': AppColors.growth,
      'snack': AppColors.mood,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MealStatsCard(date: today),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: SectionTitle(title: '今日饮食')),
            TextButton.icon(
              onPressed: () => _showAddMeal(context, ref, today),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('记录'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (meals.isEmpty)
          const EmptyState(icon: Icons.restaurant_outlined, message: '今天还没记录饮食')
        else
          for (final type in typeOrder)
            if (grouped[type]?.isNotEmpty ?? false) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('${typeLabels[type]}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: typeColors[type])),
              ),
              for (final m in grouped[type]!)
                SectionCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.foodName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                            if (m.note.isNotEmpty)
                              Text(m.note, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (m.eatenAt != null)
                        Text(m.eatenAt!, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                      ThumbImage(imagePath: m.imagePath),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textHint),
                        onPressed: () async {
                          await Repositories.deleteMeal(m.id);
                          ref.invalidate(mealsProvider(today));
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
            ],
      ],
    );
  }

  void _showAddMeal(BuildContext context, WidgetRef ref, String date) {
    final foodCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var mealType = 'breakfast';
    String? imagePath;

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
            const Text('记录饮食', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final (t, label) in [('breakfast', '早餐'), ('lunch', '午餐'), ('dinner', '晚餐'), ('snack', '加餐')])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: mealType == t,
                      onSelected: (_) => setState(() => mealType = t),
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(color: mealType == t ? AppColors.primaryDark : AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: foodCtrl, decoration: const InputDecoration(hintText: '食物名称')),
            const SizedBox(height: 12),
            TextField(controller: noteCtrl, decoration: const InputDecoration(hintText: '备注（可选）')),
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
                onPressed: () async {
                  if (foodCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入食物名称')));
                    return;
                  }
                  final now = TimeOfDay.now();
                  final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                  await Repositories.addMeal(Meal(
                    id: 0,
                    date: date,
                    mealType: mealType,
                    foodName: foodCtrl.text.trim(),
                    note: noteCtrl.text.trim(),
                    eatenAt: timeStr,
                    imagePath: imagePath,
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                  ref.invalidate(mealsProvider(date));
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

class _MealStatsCard extends ConsumerWidget {
  final String date;
  const _MealStatsCard({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(mealsProvider(date));
    final meals = mealsAsync.valueOrNull ?? [];
    final counts = <String, int>{};
    for (final m in meals) {
      counts[m.mealType] = (counts[m.mealType] ?? 0) + 1;
    }
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '本周饮食记录'),
          const SizedBox(height: 12),
          _WeekMealChart(),
        ],
      ),
    );
  }
}

class _WeekMealChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final labels = <String>[];
    final values = <double>[];
    for (var i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = du.DateUtils.format(d);
      labels.add(du.DateUtils.weekdayNameZh(d.weekday));
      // 用 provider 同步查询最近7天各日餐数
      final m = ref.watch(mealsProvider(key)).valueOrNull ?? [];
      values.add(m.length.toDouble());
    }
    return _MiniBars(values: values, labels: labels);
  }
}

// 复用图表，但为避免过度耦合这里用简化柱状
class _MiniBars extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  const _MiniBars({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${values[i].toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Container(
                    height: maxV <= 0 ? 2 : (values[i] / maxV * 70),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppColors.diet,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(labels[i], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
