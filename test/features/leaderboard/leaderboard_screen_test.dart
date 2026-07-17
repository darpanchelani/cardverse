import 'package:cardverse/app/theme.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/leaderboard/leaderboard_screen.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/services/achievement_service.dart';
import 'package:cardverse/features/progress/services/leaderboard_service.dart';
import 'package:cardverse/features/progress/services/progress_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProgressController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    controller = ProgressController(
      progressService: ProgressService(storage),
      achievementService: AchievementService(storage),
      leaderboardService: LeaderboardService(storage),
    );
    await controller.initialize();
  });

  testWidgets('switches between daily, weekly, and overall rankings', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(controller));
    await tester.pumpAndSettle();

    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Overall'), findsOneWidget);
    expect(find.text('All time, ranked by wins'), findsOneWidget);

    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    expect(find.text('Today, ranked by wins'), findsOneWidget);

    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    expect(find.text('This week, ranked by wins'), findsOneWidget);
  });

  testWidgets('changes the ranking metric', (tester) async {
    await tester.pumpWidget(_testApp(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rank by Wins'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('XP').last);
    await tester.pumpAndSettle();

    expect(find.text('Rank by XP'), findsOneWidget);
    expect(find.text('All time, ranked by XP'), findsOneWidget);
  });
}

Widget _testApp(ProgressController controller) {
  return ProgressScope(
    controller: controller,
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: const LeaderboardScreen(),
    ),
  );
}
