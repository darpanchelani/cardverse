import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/services/achievement_service.dart';
import 'package:cardverse/features/progress/services/leaderboard_service.dart';
import 'package:cardverse/features/progress/services/progress_service.dart';
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

  test('unlocks and rewards the first win once', () async {
    await controller.recordGameResult(
      recordId: 'win-1',
      gameType: 'high_card',
      gameName: 'High Card',
      result: 'win',
      opponent: 'Computer',
      playerScore: 14,
      opponentScore: 8,
      extraData: const {},
    );

    expect(controller.profile.totalGames, 1);
    expect(controller.profile.totalWins, 1);
    expect(controller.profile.coins, 600);
    expect(controller.profile.xp, 50);
    expect(
      controller.achievements
          .firstWhere((achievement) => achievement.id == 'first_win')
          .isUnlocked,
      isTrue,
    );

    await controller.recordGameResult(
      recordId: 'loss-1',
      gameType: 'high_card',
      gameName: 'High Card',
      result: 'loss',
      opponent: 'Computer',
      playerScore: 5,
      opponentScore: 10,
      extraData: const {},
    );

    expect(controller.profile.coins, 610);
    expect(controller.profile.xp, 60);
  });

  test('ignores duplicate match identifiers', () async {
    Future<void> record() {
      return controller.recordGameResult(
        recordId: 'same-result',
        gameType: 'war',
        gameName: 'War',
        result: 'win',
        opponent: 'Computer',
        playerScore: 26,
        opponentScore: 0,
        extraData: const {},
      );
    }

    await Future.wait([record(), record()]);
    await record();

    expect(controller.profile.totalGames, 1);
    expect(controller.matchHistory, hasLength(1));
    expect(controller.gameStats['war']?.wins, 1);
  });

  test('clear history preserves accumulated profile stats', () async {
    await controller.recordGameResult(
      recordId: 'history-1',
      gameType: 'blackjack',
      gameName: 'Blackjack',
      result: 'push',
      opponent: 'Dealer',
      playerScore: 19,
      opponentScore: 19,
      extraData: const {},
    );

    await controller.clearHistory();

    expect(controller.matchHistory, isEmpty);
    expect(controller.profile.totalGames, 1);
    expect(controller.profile.totalDraws, 1);
  });
}
