import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/db/repositories.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/image_field.dart';

class WorkoutTab extends ConsumerWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsProvider);
    final workouts = workoutsAsync.valueOrNull ?? [];
    final statsAsync = ref.watch(workoutStatsProvider);
    final count = statsAsync.valueOrNull?['count'] ?? 0;
    final totalMin = statsAsync.valueOrNull?['totalMin'] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: StatCard(label: '累计次数', value: '$count 次', color: AppColors.workout, icon: Icons.fitness_center_outlined)),
            const SizedBox(width: 12),
            Expanded(child: StatCard(label: '累计时长', value: _fmt(totalMin as int), color: AppColors.workout, icon: Icons.timer_outlined)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: SectionTitle(title: '运动记录')),
            TextButton.icon(
              onPressed: () => _showAddWorkout(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('记录'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (workouts.isEmpty)
          const EmptyState(icon: Icons.fitness_center_outlined, message: '暂无运动记录')
        else
          for (final w in workouts)
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _intensityColor(w.intensity).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.directions_run, color: _intensityColor(w.intensity), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.workoutType, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('${w.date} · ${w.durationMin}分钟 · ${w.intensity}强度${w.note.isNotEmpty ? ' · ${w.note}' : ''}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  ThumbImage(imagePath: w.imagePath),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textHint),
                    onPressed: () async {
                      await Repositories.deleteWorkout(w.id);
                      ref.invalidate(workoutsProvider);
                      ref.invalidate(workoutStatsProvider);
                    },
                  ),
                ],
              ),
            ),
      ],
    );
  }

  String _fmt(int min) {
    final h = min ~/ 60;
    final m = min % 60;
    return h > 0 ? '$h小时$m分' : '$m分';
  }

  Color _intensityColor(String intensity) {
    switch (intensity) {
      case '低':
        return AppColors.workout;
      case '高':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  void _showAddWorkout(BuildContext context, WidgetRef ref) {
    final typeCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var intensity = '中';
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
              const Text('记录运动', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextField(controller: typeCtrl, decoration: const InputDecoration(hintText: '运动类型（如跑步、健身）')),
              const SizedBox(height: 12),
              TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '时长（分钟）')),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final (v, label) in [('低', '低强度'), ('中', '中强度'), ('高', '高强度')])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: intensity == v,
                        onSelected: (_) => setState(() => intensity = v),
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(color: intensity == v ? AppColors.primaryDark : AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
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
                    if (typeCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入运动类型')));
                      return;
                    }
                    await Repositories.addWorkout(Workout(
                      id: 0,
                      date: du.DateUtils.today(),
                      workoutType: typeCtrl.text.trim(),
                      durationMin: int.tryParse(durationCtrl.text.trim()) ?? 0,
                      intensity: intensity,
                      note: noteCtrl.text.trim(),
                      imagePath: imagePath,
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    ref.invalidate(workoutsProvider);
                    ref.invalidate(workoutStatsProvider);
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
