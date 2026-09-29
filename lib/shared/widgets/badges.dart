import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// 成就徽章定义
class Badge {
  final String name;
  final String emoji;
  final String desc;
  final bool unlocked;

  const Badge({required this.name, required this.emoji, required this.desc, required this.unlocked});
}

/// 根据连续天数生成徽章列表
List<Badge> buildBadges(int streak) {
  return [
    Badge(name: '初次打卡', emoji: '🌱', desc: '完成第一次打卡', unlocked: streak >= 1),
    Badge(name: '三日坚持', emoji: '🔥', desc: '连续打卡 3 天', unlocked: streak >= 3),
    Badge(name: '七日之约', emoji: '💪', desc: '连续打卡 7 天', unlocked: streak >= 7),
    Badge(name: '半月达人', emoji: '🌟', desc: '连续打卡 15 天', unlocked: streak >= 15),
    Badge(name: '满月成就', emoji: '🏆', desc: '连续打卡 30 天', unlocked: streak >= 30),
    Badge(name: '百日传奇', emoji: '👑', desc: '连续打卡 100 天', unlocked: streak >= 100),
  ];
}

/// 徽章墙
class BadgeGrid extends StatelessWidget {
  final List<Badge> badges;

  const BadgeGrid({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        for (final b in badges)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: b.unlocked ? AppColors.primaryLight : AppColors.divider,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: b.unlocked ? 1 : 0.3,
                  child: Text(b.emoji, style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(height: 6),
                Text(
                  b.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: b.unlocked ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  b.desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: b.unlocked ? AppColors.textSecondary : AppColors.textHint),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
