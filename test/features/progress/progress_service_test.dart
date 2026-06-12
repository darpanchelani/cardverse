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
    await storage.useAccount('guest');
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

  test('online High Card uses its configured rewards', () async {
    final record = await service.recordGameResult(
      gameType: 'high_card_online',
      gameName: 'Online High Card',
      result: 'win',
      opponent: 'Multiplayer',
      playerScore: 3,
      opponentScore: 2,
      extraData: const {'roomCode': 'AB12CD'},
      matchId: 'online-1',
      rewardCoins: 100,
      rewardXp: 50,
    );

    expect(record.profile.coins, 600);
    expect(record.profile.xp, 50);
    expect(record.profile.favoriteGame, 'Online High Card');
    expect(record.stats['high_card_online']?.wins, 1);
    expect(record.match.coinsEarned, 100);
    expect(record.match.xpEarned, 50);
  });

  test('online War uses its configured rewards', () async {
    final record = await service.recordGameResult(
      gameType: 'war_online',
      gameName: 'Online War',
      result: 'win',
      opponent: 'Multiplayer',
      playerScore: 12,
      opponentScore: 9,
      extraData: const {'roomCode': 'WR12CD'},
      matchId: 'online-war-1',
      rewardCoins: 150,
      rewardXp: 75,
    );

    expect(record.profile.coins, 650);
    expect(record.profile.xp, 75);
    expect(record.profile.favoriteGame, 'Online War');
    expect(record.stats['war_online']?.wins, 1);
    expect(record.match.coinsEarned, 150);
    expect(record.match.xpEarned, 75);
  });

  test('online Blackjack uses its configured rewards', () async {
    final record = await service.recordGameResult(
      gameType: 'blackjack_online',
      gameName: 'Online Blackjack',
      result: 'win',
      opponent: 'Multiplayer Dealer',
      playerScore: 1250,
      opponentScore: 900,
      extraData: const {'roomCode': 'BJ12CD'},
      matchId: 'online-blackjack-1',
      rewardCoins: 200,
      rewardXp: 100,
    );

    expect(record.profile.coins, 700);
    expect(record.profile.xp, 100);
    expect(record.profile.favoriteGame, 'Online Blackjack');
    expect(record.stats['blackjack_online']?.wins, 1);
    expect(record.match.coinsEarned, 200);
    expect(record.match.xpEarned, 100);
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
    expect(
      stats.keys,
      containsAll([
        'high_card',
        'high_card_online',
        'war',
        'war_online',
        'blackjack',
        'blackjack_online',
      ]),
    );
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

  test('keeps progress and history isolated per account', () async {
    await service.useAccount('darpan@example.com');
    await service.recordGameResult(
      gameType: 'war',
      gameName: 'War',
      result: 'win',
      opponent: 'Computer',
      playerScore: 5,
      opponentScore: 2,
      extraData: const {},
      matchId: 'darpan-war-1',
    );

    await service.useAccount('sara@example.com');
    final saraProfile = await service.getProfile();
    final saraHistory = await service.getMatchHistory();
    expect(saraProfile.totalGames, 0);
    expect(saraHistory, isEmpty);

    await service.recordGameResult(
      gameType: 'blackjack',
      gameName: 'Blackjack',
      result: 'loss',
      opponent: 'Dealer',
      playerScore: 18,
      opponentScore: 20,
      extraData: const {},
      matchId: 'sara-blackjack-1',
    );

    await service.useAccount('darpan@example.com');
    final darpanProfile = await service.getProfile();
    final darpanHistory = await service.getMatchHistory();
    expect(darpanProfile.totalWins, 1);
    expect(darpanHistory.single.id, 'darpan-war-1');
  });
}
