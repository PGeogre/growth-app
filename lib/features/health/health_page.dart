import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'diet_tab.dart';
import 'sleep_tab.dart';
import 'workout_tab.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('健康'),
          bottom: const TabBar(
            labelColor: AppColors.primaryDark,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: '饮食'),
              Tab(text: '睡眠'),
              Tab(text: '运动'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DietTab(),
            SleepTab(),
            WorkoutTab(),
          ],
        ),
      ),
    );
  }
}
