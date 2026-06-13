const { ACHIEVEMENTS } = require("./achievement.model");

class AchievementsService {
  async checkAndUnlock(user, gameType, result) {
    const unlocked = new Set(user.achievements.map((item) => item.id));
    const candidates = [];
    if (result === "win") {
      candidates.push("first_online_win");
      if (gameType === "high_card_online")
        candidates.push("online_high_card_winner");
      if (gameType === "war_online") candidates.push("online_war_winner");
      if (gameType === "blackjack_online")
        candidates.push("online_blackjack_winner");
    }
    if (user.totalWins >= 5) candidates.push("five_online_wins");
    if (user.totalWins >= 10) candidates.push("ten_total_wins");
    if (user.coins >= 1000) candidates.push("coin_collector");
    if (user.level >= 5) candidates.push("level_5_player");
    const newlyUnlocked = ACHIEVEMENTS.filter(
      (item) => candidates.includes(item.id) && !unlocked.has(item.id),
    );
    for (const item of newlyUnlocked) {
      user.achievements.push({ ...item, unlockedAt: new Date() });
      user.coins += item.rewardCoins;
      user.xp += item.rewardXp;
    }
    return newlyUnlocked;
  }

  listFor(user) {
    const unlocked = new Map(
      user.achievements.map((item) => [item.id, item]),
    );
    return ACHIEVEMENTS.map((item) => ({
      ...item,
      isUnlocked: unlocked.has(item.id),
      unlockedAt: unlocked.get(item.id)?.unlockedAt ?? null,
    }));
  }
}

module.exports = { AchievementsService };
