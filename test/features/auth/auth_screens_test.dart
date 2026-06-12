import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/auth/register_screen.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/services/achievement_service.dart';
import 'package:cardverse/features/progress/services/leaderboard_service.dart';
import 'package:cardverse/features/progress/services/progress_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('registration saves username and opens the account home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final progress = ProgressController(
      progressService: ProgressService(storage),
      achievementService: AchievementService(storage),
      leaderboardService: LeaderboardService(storage),
    );
    await progress.initialize();
    final multiplayer = MultiplayerControllers.dummy();
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => Text(progress.profile.username),
        ),
      ],
    );

    await tester.pumpWidget(
      ProgressScope(
        controller: progress,
        child: MultiplayerScope(
          controllers: multiplayer,
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(5));
    await tester.enterText(fields.at(0), 'Darpan Chelani');
    await tester.enterText(fields.at(1), 'darpan');
    await tester.enterText(fields.at(2), 'darpan@example.com');
    await tester.enterText(fields.at(3), 'secret12');
    await tester.enterText(fields.at(4), 'secret12');
    final registerButton = find.text('Register');
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(progress.profile.username, 'darpan');
    expect(find.text('darpan'), findsOneWidget);
  });
}
