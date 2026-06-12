import 'dart:convert';

import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/progress/models/achievement_model.dart';
import 'package:cardverse/features/progress/models/game_stats_model.dart';
import 'package:cardverse/features/progress/models/player_profile_model.dart';

class AchievementService {
  AchievementService(this._storage);

  final LocalStorageService _storage;

  static const defaultAchievements = [
    AchievementModel(
      id: 'first_win',
      title: 'First Win',
      description: 'Win your first game.',
      icon: 'trophy',
      isUnlocked: false,
      unlockedAt: null,
      rewardCoins: 50,
      rewardXp: 25,
    ),
    AchievementModel(
      id: 'high_card_rookie',
      title: 'High Card Rookie',
      description: 'Win 5 High Card rounds.',
      icon: 'cards',
      isUnlocked: false,
      unlockedAt: null,
      rewardCoins: 100,
      rewardXp: 50,
    ),
    AchievementModel(
      id: 'war_warrior',
      title: 'War Warrior',
      description: 'Win 3 War games.',
      icon: 'fire',
      isUnlocked: false,
      unlockedAt: null,
      rewardCoins: 150,
      rewardXp: 75,
    ),
    AchievementModel(
      id: 'blackjack_starter',
      title: 'Blackjack Starter',
      description: 'Win your first Blackjack round.',
      icon: 'casino',
      isUnlocked: false,
      unlockedAt: null,
      rewardCoins: 100,
      rewardXp: 50,
    ),
    AchievementModel(
      id: 'blackjack_master',
      title: 'Blackjack Master',
      description: 'Win 10 Blackjack rounds.',
      icon: 'sparkles',
      isUnlocked: false,
      unlockedAt: null,
      rewardCoins: 300,
      rewardXp: 150,
    ),
    AchievementModel(
      id: 'streak_king',
      title: 'Streak King',
      description: 'Reach a 5-win streak.',
      icon: 'crown',
      isUnlocked: false,
      unlockedAt: null,
      rewardCoins: 250,
      rewardXp: 100,
    ),
    AchievementModel(
      id: 'regular_player',
      title: 'Regular Player',
      description: 'Play 25 total games.',
      icon: 'calendar',
      isUnlocked: false,
      unlockedAt: null,
      rewardCoins: 200,
      rewardXp: 100,
    ),
    AchievementModel(
      id: 'card_collector',
      title: 'Card Collector',
      description: 'Earn 1000 total coins.',
      icon: 'coins',
      isUnlocked: false,
      unlockedAt: null,
      rewardCoins: 500,
      rewardXp: 200,
    ),
  ];

  Future<List<AchievementModel>> getAchievements() async {
    final raw = await _storage.getString(
      _storage.scopedKey(StorageKeys.achievements),
    );
    if (raw == null) return List.of(defaultAchievements);
    try {
      final saved = List<dynamic>.from(jsonDecode(raw) as List)
          .map(
            (item) => AchievementModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      final byId = {for (final item in saved) item.id: item};
      return defaultAchievements.map((item) => byId[item.id] ?? item).toList();
    } catch (_) {
      return List.of(defaultAchievements);
    }
  }

  Future<void> saveAchievements(List<AchievementModel> achievements) async {
    await _storage.saveString(
      _storage.scopedKey(StorageKeys.achievements),
      jsonEncode(achievements.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<AchievementModel>> checkAndUnlockAchievements({
    required PlayerProfileModel profile,
    required Map<String, GameStatsModel> stats,
  }) async {
    final achievements = await getAchievements();
    final now = DateTime.now();
    final updated = achievements.map((achievement) {
      if (achievement.isUnlocked) return achievement;
      final shouldUnlock = switch (achievement.id) {
        'first_win' => profile.totalWins >= 1,
        'high_card_rookie' => (stats['high_card']?.wins ?? 0) >= 5,
        'war_warrior' => (stats['war']?.wins ?? 0) >= 3,
        'blackjack_starter' => (stats['blackjack']?.wins ?? 0) >= 1,
        'blackjack_master' => (stats['blackjack']?.wins ?? 0) >= 10,
        'streak_king' => profile.bestStreak >= 5,
        'regular_player' => profile.totalGames >= 25,
        'card_collector' => profile.coins >= 1000,
        _ => false,
      };
      return shouldUnlock
          ? achievement.copyWith(isUnlocked: true, unlockedAt: now)
          : achievement;
    }).toList();
    await saveAchievements(updated);
    return updated;
  }
}
