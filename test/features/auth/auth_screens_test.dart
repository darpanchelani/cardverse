import 'dart:convert';
import 'dart:typed_data';

import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/core/storage/secure_storage_service.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/auth/login_screen.dart';
import 'package:cardverse/features/auth/services/auth_api_service.dart';
import 'package:cardverse/features/auth/services/google_auth_service.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/profile/services/profile_api_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/services/achievement_service.dart';
import 'package:cardverse/features/progress/services/leaderboard_service.dart';
import 'package:cardverse/features/progress/services/progress_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('auth screen offers only Google and guest choices', (
    tester,
  ) async {
    final harness = await _AuthHarness.create();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Play as guest'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Create New Account'), findsNothing);
    expect(find.text('Login'), findsNothing);

    await tester.tap(find.text('Play as guest'));
    await tester.pumpAndSettle();

    expect(harness.auth.isGuest, isTrue);
    expect(find.text('Guest Player'), findsOneWidget);
  });

  testWidgets('Google ID token is exchanged for a CardVerse session', (
    tester,
  ) async {
    final harness = await _AuthHarness.create();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(harness.adapter.receivedIdToken, 'google-test-token');
    expect(harness.auth.isAuthenticated, isTrue);
    expect(find.text('darpan'), findsOneWidget);
  });
}

class _AuthHarness {
  _AuthHarness({
    required this.auth,
    required this.progress,
    required this.multiplayer,
    required this.adapter,
  });

  final AuthController auth;
  final ProgressController progress;
  final MultiplayerControllers multiplayer;
  final _GoogleAuthAdapter adapter;

  static Future<_AuthHarness> create() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final adapter = _GoogleAuthAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://cardverse.test/api'));
    dio.httpClientAdapter = adapter;
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
    return _AuthHarness(
      auth: auth,
      progress: progress,
      multiplayer: MultiplayerControllers.dummy(),
      adapter: adapter,
    );
  }

  Widget app() {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const LoginScreen(googleAuth: _FakeGoogleAuth()),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => Text(progress.profile.username),
        ),
      ],
    );
    return ProgressScope(
      controller: progress,
      child: AuthScope(
        controller: auth,
        child: MultiplayerScope(
          controllers: multiplayer,
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
  }
}

class _FakeGoogleAuth implements GoogleAuthGateway {
  const _FakeGoogleAuth();

  @override
  Stream<String> get idTokens => const Stream.empty();

  @override
  Future<String> authenticate() async => 'google-test-token';

  @override
  Future<void> initialize() async {}
}

class _GoogleAuthAdapter implements HttpClientAdapter {
  String? receivedIdToken;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.path, '/auth/google');
    receivedIdToken =
        (options.data as Map<String, dynamic>)['idToken'] as String;
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {
          'token': 'cardverse-test-token',
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
