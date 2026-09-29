import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/db/repositories.dart';
import '../../providers/providers.dart';
import '../../shared/widgets/common.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordStatsAsync = ref.watch(wordStatsProvider);
    final workoutStatsAsync = ref.watch(workoutStatsProvider);

    final words = wordStatsAsync.valueOrNull?['total'] ?? 0;
    final workouts = workoutStatsAsync.valueOrNull?['count'] ?? 0;
    final checkinDatesAsync = ref.watch(checkinProvider('english'));
    final streak = _streak(checkinDatesAsync.valueOrNull ?? {});

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.self_improvement, color: AppColors.primaryDark, size: 36),
                ),
                const SizedBox(height: 12),
                const Text('我的成长', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('坚持就是胜利', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: StatCard(label: '累计词汇', value: '$words', color: AppColors.english, icon: Icons.menu_book_outlined)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: '运动次数', value: '$workouts', color: AppColors.workout, icon: Icons.fitness_center_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(label: '英语连续打卡', value: '$streak 天', color: AppColors.growth, icon: Icons.local_fire_department_outlined)),
              const SizedBox(width: 12),
              const Expanded(child: StatCard(label: '本地存储', value: '✓ 离线', color: AppColors.sleep, icon: Icons.offline_bolt_outlined)),
            ],
          ),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              children: [
                _ThemeTile(),
                const Divider(color: AppColors.divider, height: 1),
                _SettingsTile(icon: Icons.info_outline, title: '关于', subtitle: '个人成长 App v2.0.0', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _streak(Set<String> dates) {
    var streak = 0;
    var cursor = DateTime.now();
    String fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    while (dates.contains(fmt(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

/// 主题切换
class _ThemeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider).valueOrNull ?? 'light';
    final label = mode == 'dark' ? '暗色主题' : mode == 'system' ? '跟随系统' : '浅色主题';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.palette_outlined, color: AppColors.textSecondary),
      title: const Text('主题', style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
      subtitle: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: () => _showThemePicker(context, ref),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择主题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            for (final (v, label) in [('light', '浅色'), ('dark', '暗色'), ('system', '跟随系统')])
              ListTile(
                leading: Icon(
                  v == 'light' ? Icons.light_mode_outlined : v == 'dark' ? Icons.dark_mode_outlined : Icons.brightness_auto_outlined,
                ),
                title: Text(label),
                onTap: () async {
                  await Repositories.setThemeMode(v);
                  if (ctx.mounted) Navigator.pop(ctx);
                  ref.invalidate(themeModeProvider);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
