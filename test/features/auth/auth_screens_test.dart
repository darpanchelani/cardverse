import 'dart:convert';
import 'dart:typed_data';

import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/core/storage/secure_storage_service.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/auth/services/auth_api_service.dart';
import 'package:cardverse/features/auth/register_screen.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/profile/services/profile_api_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/services/achievement_service.dart';
import 'package:cardverse/features/progress/services/leaderboard_service.dart';
import 'package:cardverse/features/progress/services/progress_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  testWidgets('registration saves username and opens the account home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final dio = Dio(BaseOptions(baseUrl: 'http://cardverse.test/api'));
    dio.httpClientAdapter = _AuthAdapter();
    final api = ApiClient(dio: dio);
    final auth = AuthController(
      authService: AuthApiService(api),
      profileService: ProfileApiService(api),
      secureStorage: SecureStorageService(),
      localStorage: storage,
    );
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
        child: AuthScope(
          controller: auth,
          child: MultiplayerScope(
            controllers: multiplayer,
            child: MaterialApp.router(routerConfig: router),
          ),
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
    expect(auth.isAuthenticated, isTrue);
    expect(find.text('darpan'), findsOneWidget);
  });
}

class _AuthAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.path, '/auth/register');
    expect((options.data as Map<String, dynamic>)['username'], 'darpan');
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {
          'token': 'test-token',
          'user': {
            '_id': 'account-darpan',
            'username': 'darpan',
            'email': 'darpan@example.com',
            'avatar': 'default',
            'level': 1,
            'xp': 0,
            'coins': 500,
            'totalGames': 0,
            'totalWins': 0,
            'totalLosses': 0,
            'totalDraws': 0,
            'currentStreak': 0,
            'bestStreak': 0,
            'favoriteGame': 'None',
            'isOnline': false,
            'createdAt': DateTime(2026).toIso8601String(),
          },
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
