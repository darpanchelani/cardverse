import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/progress/services/progress_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProgressService service;
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.create();
    service = ProgressService(storage);
  });

  test('records and reloads a winning game result', () async {
    final record = await service.recordGameResult(
      gameType: 'high_card',
      gameName: 'High Card',
      result: 'win',
      opponent: 'Computer',
      playerScore: 14,
      opponentScore: 10,
      extraData: const {'roundNumber': 1},
      matchId: 'high-card-1',
    );

    expect(record.profile.totalGames, 1);
    expect(record.profile.totalWins, 1);
    expect(record.profile.coins, 550);
    expect(record.profile.xp, 25);
    expect(record.profile.favoriteGame, 'High Card');
    expect(record.stats['high_card']?.wins, 1);

    final reloadedProfile = await service.getProfile();
    final reloadedStats = await service.getAllGameStats();
    final reloadedHistory = await service.getMatchHistory();

    expect(reloadedProfile.totalWins, 1);
    expect(reloadedStats['high_card']?.gamesPlayed, 1);
    expect(reloadedHistory.single.id, 'high-card-1');
    expect(reloadedHistory.single.coinsEarned, 50);
    expect(reloadedHistory.single.xpEarned, 25);
  });

  test('push rewards are persisted as draws', () async {
    await service.recordGameResult(
      gameType: 'blackjack',
      gameName: 'Blackjack',
      result: 'push',
      opponent: 'Dealer',
      playerScore: 20,
      opponentScore: 20,
      extraData: const {},
      matchId: 'blackjack-1',
    );

    final profile = await service.getProfile();
    final stats = await service.getStatsForGame('blackjack');

    expect(profile.totalDraws, 1);
    expect(profile.coins, 520);
    expect(profile.xp, 15);
    expect(stats.draws, 1);
  });

  test('corrupt JSON falls back to default progress', () async {
    await storage.saveString(StorageKeys.playerProfile, '{not-json');
    await storage.saveString(StorageKeys.gameStats, 'not-json');
    await storage.saveString(StorageKeys.matchHistory, '[broken');

    final profile = await service.getProfile();
    final stats = await service.getAllGameStats();
    final history = await service.getMatchHistory();

    expect(profile.username, 'Guest Player');
    expect(profile.totalGames, 0);
    expect(stats.keys, containsAll(['high_card', 'war', 'blackjack']));
    expect(history, isEmpty);
  });

  test('level thresholds follow the configured progression', () {
    expect(ProgressService.calculateLevel(0), 1);
    expect(ProgressService.calculateLevel(100), 2);
    expect(ProgressService.calculateLevel(250), 3);
    expect(ProgressService.calculateLevel(500), 4);
    expect(ProgressService.calculateLevel(900), 5);
    expect(ProgressService.calculateLevel(1400), 6);
  });
}
