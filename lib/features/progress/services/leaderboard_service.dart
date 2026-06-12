import 'dart:convert';

import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/progress/models/game_stats_model.dart';
import 'package:cardverse/features/progress/models/leaderboard_entry_model.dart';
import 'package:cardverse/features/progress/models/player_profile_model.dart';

class LeaderboardService {
  LeaderboardService(this._storage);

  final LocalStorageService _storage;

  Future<List<LeaderboardEntryModel>> getLeaderboard({
    String? gameType,
    PlayerProfileModel? profile,
    Map<String, GameStatsModel>? stats,
  }) async {
    final currentProfile = profile ?? PlayerProfileModel.defaults();
    final currentStats = stats ?? const {};
    final selectedType = gameType ?? 'overall';
    final selectedStats = currentStats[selectedType];
    final now = DateTime.now();

    final entries = [
      _dummy('Darpan', selectedType, 120, 160, 3200, 2600, 8, now),
      _dummy('Ali', selectedType, 95, 140, 2500, 2100, 7, now),
      _dummy('Sara', selectedType, 80, 125, 2100, 1700, 6, now),
      _dummy('Ahmed', selectedType, 60, 105, 1600, 1250, 5, now),
      LeaderboardEntryModel(
        username: currentProfile.username,
        gameType: selectedType,
        wins: selectedType == 'overall'
            ? currentProfile.totalWins
            : selectedStats?.wins ?? 0,
        totalGames: selectedType == 'overall'
            ? currentProfile.totalGames
            : selectedStats?.gamesPlayed ?? 0,
        winRate: selectedType == 'overall'
            ? currentProfile.winRate
            : selectedStats?.winRate ?? 0,
        coins: currentProfile.coins,
        xp: currentProfile.xp,
        level: currentProfile.level,
        updatedAt: currentProfile.updatedAt,
      ),
    ];
    entries.sort((a, b) {
      final wins = b.wins.compareTo(a.wins);
      if (wins != 0) return wins;
      final rate = b.winRate.compareTo(a.winRate);
      if (rate != 0) return rate;
      return b.level.compareTo(a.level);
    });
    return entries;
  }

  Future<void> refreshLeaderboard(List<LeaderboardEntryModel> entries) async {
    await _storage.saveString(
      _storage.scopedKey(StorageKeys.leaderboard),
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }

  LeaderboardEntryModel _dummy(
    String username,
    String gameType,
    int wins,
    int totalGames,
    int coins,
    int xp,
    int level,
    DateTime now,
  ) {
    final multiplier = switch (gameType) {
      'high_card' => 0.45,
      'high_card_online' => 0.2,
      'war' => 0.3,
      'war_online' => 0.18,
      'blackjack' => 0.25,
      _ => 1.0,
    };
    final filteredWins = (wins * multiplier).round();
    final filteredGames = (totalGames * multiplier).round();
    return LeaderboardEntryModel(
      username: username,
      gameType: gameType,
      wins: filteredWins,
      totalGames: filteredGames,
      winRate: filteredGames == 0 ? 0 : filteredWins / filteredGames * 100,
      coins: coins,
      xp: xp,
      level: level,
      updatedAt: now,
    );
  }
}
