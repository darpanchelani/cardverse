import 'dart:convert';

import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/progress/models/game_stats_model.dart';
import 'package:cardverse/features/progress/models/match_history_model.dart';
import 'package:cardverse/features/progress/models/player_profile_model.dart';

class ProgressRecord {
  const ProgressRecord({
    required this.profile,
    required this.stats,
    required this.match,
  });

  final PlayerProfileModel profile;
  final Map<String, GameStatsModel> stats;
  final MatchHistoryModel match;
}

class ProgressService {
  ProgressService(this._storage);

  final LocalStorageService _storage;

  Future<void> useAccount(String accountId) => _storage.useAccount(accountId);

  Future<PlayerProfileModel> getProfile() async {
    final raw = await _storage.getString(
      _storage.scopedKey(StorageKeys.playerProfile),
    );
    if (raw == null) return PlayerProfileModel.defaults();
    try {
      return PlayerProfileModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return PlayerProfileModel.defaults();
    }
  }

  Future<void> saveProfile(PlayerProfileModel profile) async {
    await _storage.saveString(
      _storage.scopedKey(StorageKeys.playerProfile),
      jsonEncode(profile.toJson()),
    );
  }

  Future<Map<String, GameStatsModel>> getAllGameStats() async {
    final defaults = {
      'high_card': GameStatsModel.empty('high_card'),
      'high_card_online': GameStatsModel.empty('high_card_online'),
      'war': GameStatsModel.empty('war'),
      'war_online': GameStatsModel.empty('war_online'),
      'blackjack': GameStatsModel.empty('blackjack'),
    };
    final raw = await _storage.getString(
      _storage.scopedKey(StorageKeys.gameStats),
    );
    if (raw == null) return defaults;
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      for (final entry in decoded.entries) {
        defaults[entry.key] = GameStatsModel.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    } catch (_) {
      return defaults;
    }
    return defaults;
  }

  Future<GameStatsModel> getStatsForGame(String gameType) async {
    final stats = await getAllGameStats();
    return stats[gameType] ?? GameStatsModel.empty(gameType);
  }

  Future<void> saveGameStats(Map<String, GameStatsModel> stats) async {
    await _storage.saveString(
      _storage.scopedKey(StorageKeys.gameStats),
      jsonEncode(stats.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }

  Future<List<MatchHistoryModel>> getMatchHistory() async {
    final raw = await _storage.getString(
      _storage.scopedKey(StorageKeys.matchHistory),
    );
    if (raw == null) return [];
    try {
      final decoded = List<dynamic>.from(jsonDecode(raw) as List);
      final history = decoded
          .map(
            (item) => MatchHistoryModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      history.sort((a, b) => b.playedAt.compareTo(a.playedAt));
      return history;
    } catch (_) {
      return [];
    }
  }

  Future<void> addMatchHistory(MatchHistoryModel match) async {
    final history = await getMatchHistory();
    if (history.any((item) => item.id == match.id)) return;
    history.insert(0, match);
    await _storage.saveString(
      _storage.scopedKey(StorageKeys.matchHistory),
      jsonEncode(history.take(250).map((item) => item.toJson()).toList()),
    );
  }

  Future<void> clearMatchHistory() async {
    await _storage.remove(_storage.scopedKey(StorageKeys.matchHistory));
  }

  Future<int?> getBlackjackChips() {
    return _storage.getInt(_storage.scopedKey(StorageKeys.blackjackChips));
  }

  Future<void> saveBlackjackChips(int chips) {
    return _storage.saveInt(
      _storage.scopedKey(StorageKeys.blackjackChips),
      chips,
    );
  }

  Future<ProgressRecord> recordGameResult({
    required String gameType,
    required String gameName,
    required String result,
    required String opponent,
    required int playerScore,
    required int opponentScore,
    required Map<String, dynamic> extraData,
    String? matchId,
    int durationSeconds = 0,
    int? rewardCoins,
    int? rewardXp,
  }) async {
    final now = DateTime.now();
    final defaultReward = _rewardFor(result);
    final reward = (
      rewardCoins ?? defaultReward.$1,
      rewardXp ?? defaultReward.$2,
    );
    final isWin = result == 'win';
    final isLoss = result == 'loss';
    final isDraw = result == 'draw' || result == 'push';
    final profile = await getProfile();
    final stats = await getAllGameStats();
    final gameStats = stats[gameType] ?? GameStatsModel.empty(gameType);

    final gameStreak = isWin ? gameStats.currentStreak + 1 : 0;
    stats[gameType] = gameStats.copyWith(
      gamesPlayed: gameStats.gamesPlayed + 1,
      wins: gameStats.wins + (isWin ? 1 : 0),
      losses: gameStats.losses + (isLoss ? 1 : 0),
      draws: gameStats.draws + (isDraw ? 1 : 0),
      bestScore: playerScore > gameStats.bestScore
          ? playerScore
          : gameStats.bestScore,
      currentStreak: gameStreak,
      bestStreak: gameStreak > gameStats.bestStreak
          ? gameStreak
          : gameStats.bestStreak,
      xpEarned: gameStats.xpEarned + reward.$2,
      coinsEarned: gameStats.coinsEarned + reward.$1,
      lastPlayedAt: now,
    );

    final totalGames = profile.totalGames + 1;
    final totalWins = profile.totalWins + (isWin ? 1 : 0);
    final currentStreak = isWin ? profile.currentStreak + 1 : 0;
    final xp = profile.xp + reward.$2;
    final updatedProfile = profile.copyWith(
      level: calculateLevel(xp),
      xp: xp,
      coins: profile.coins + reward.$1,
      totalGames: totalGames,
      totalWins: totalWins,
      totalLosses: profile.totalLosses + (isLoss ? 1 : 0),
      totalDraws: profile.totalDraws + (isDraw ? 1 : 0),
      winRate: PlayerProfileModel.calculateWinRate(totalWins, totalGames),
      favoriteGame: _favoriteGame(stats),
      currentStreak: currentStreak,
      bestStreak: currentStreak > profile.bestStreak
          ? currentStreak
          : profile.bestStreak,
      updatedAt: now,
    );

    final id =
        matchId ?? '${gameType}_${now.microsecondsSinceEpoch}_$totalGames';
    final match = MatchHistoryModel(
      id: id,
      gameType: gameType,
      gameName: gameName,
      result: result,
      opponent: opponent,
      playerScore: playerScore,
      opponentScore: opponentScore,
      coinsEarned: reward.$1,
      xpEarned: reward.$2,
      durationSeconds: durationSeconds,
      playedAt: now,
      extraData: extraData,
    );

    await saveProfile(updatedProfile);
    await saveGameStats(stats);
    await addMatchHistory(match);
    return ProgressRecord(profile: updatedProfile, stats: stats, match: match);
  }

  Future<void> clearProgress() async {
    await Future.wait([
      _storage.remove(_storage.scopedKey(StorageKeys.playerProfile)),
      _storage.remove(_storage.scopedKey(StorageKeys.gameStats)),
      _storage.remove(_storage.scopedKey(StorageKeys.matchHistory)),
      _storage.remove(_storage.scopedKey(StorageKeys.achievements)),
      _storage.remove(_storage.scopedKey(StorageKeys.leaderboard)),
      _storage.remove(_storage.scopedKey(StorageKeys.blackjackChips)),
    ]);
  }

  static int calculateLevel(int xp) {
    const thresholds = [0, 100, 250, 500, 900];
    for (var index = thresholds.length - 1; index >= 0; index--) {
      if (xp >= thresholds[index]) {
        if (index < thresholds.length - 1) return index + 1;
        return 5 + ((xp - thresholds.last) ~/ 500);
      }
    }
    return 1;
  }

  static (int, int) _rewardFor(String result) {
    return switch (result) {
      'win' => (50, 25),
      'loss' => (10, 10),
      _ => (20, 15),
    };
  }

  static String _favoriteGame(Map<String, GameStatsModel> stats) {
    final played = stats.values.toList()
      ..sort((a, b) => b.gamesPlayed.compareTo(a.gamesPlayed));
    if (played.isEmpty || played.first.gamesPlayed == 0) return 'None';
    return switch (played.first.gameType) {
      'high_card' => 'High Card',
      'high_card_online' => 'Online High Card',
      'blackjack' => 'Blackjack',
      'war' => 'War',
      'war_online' => 'Online War',
      _ => played.first.gameType,
    };
  }
}
