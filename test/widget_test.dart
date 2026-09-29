import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:english_coach/app.dart';

void main() {
  testWidgets('App renders bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GrowthApp()));
    await tester.pump();

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('健康'), findsOneWidget);
    expect(find.text('英语'), findsOneWidget);
    expect(find.text('成长'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
