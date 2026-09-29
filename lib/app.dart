import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_page.dart';
import 'features/health/health_page.dart';
import 'features/english/english_page.dart';
import 'features/growth/growth_page.dart';
import 'features/profile/profile_page.dart';
import 'providers/providers.dart';

class GrowthApp extends ConsumerStatefulWidget {
  const GrowthApp({super.key});

  @override
  ConsumerState<GrowthApp> createState() => _GrowthAppState();
}

class _GrowthAppState extends ConsumerState<GrowthApp> {
  int _index = 0;

  static const _pages = [
    HomePage(),
    HealthPage(),
    EnglishPage(),
    GrowthPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final mode = themeModeAsync.valueOrNull ?? 'light';
    final themeMode = mode == 'dark'
        ? ThemeMode.dark
        : mode == 'system'
            ? ThemeMode.system
            : ThemeMode.light;

    return MaterialApp(
      title: '成长',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: Scaffold(
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
            NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: '健康'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: '英语'),
            NavigationDestination(icon: Icon(Icons.self_improvement_outlined), selectedIcon: Icon(Icons.self_improvement), label: '成长'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: '我的'),
          ],
        ),
      ),
    );
  }
}
