const mongoose = require("mongoose");
const { Match } = require("./match.model");
const { User } = require("../users/user.model");
const {
  AchievementsService,
} = require("../achievements/achievements.service");
const {
  notificationsService,
} = require("../notifications/notifications.service");

class MatchesService {
  constructor() {
    this.achievementsService = new AchievementsService();
  }

  async create(payload, requestingUserId) {
    const participants = (payload.players || []).filter(
      (player) => player.userId && mongoose.isValidObjectId(player.userId),
    );
    if (
      !participants.some(
        (player) => player.userId.toString() === requestingUserId.toString(),
      )
    ) {
      throw httpError(403, "Current user must be a match participant");
    }
    const matchKey =
      payload.matchKey ||
      `${payload.gameType}:${payload.roomCode}:${payload.createdAt || Date.now()}`;
    const existing = await Match.findOne({ matchKey });
    if (existing) return existing;

    const rewardedPlayers = [];
    for (const participant of participants) {
      const user = await User.findById(participant.userId);
      if (!user) continue;
      const result = normalizeResult(participant.result);
      const reward = rewardFor(payload.gameType, result);
      participant.result = result;
      participant.coinsEarned = reward.coins;
      participant.xpEarned = reward.xp;
      user.totalGames += 1;
      user.totalWins += result === "win" ? 1 : 0;
      user.totalLosses += result === "loss" ? 1 : 0;
      user.totalDraws += ["draw", "push"].includes(result) ? 1 : 0;
      user.currentStreak = result === "win" ? user.currentStreak + 1 : 0;
      user.bestStreak = Math.max(user.bestStreak, user.currentStreak);
      user.coins += reward.coins;
      user.xp += reward.xp;
      user.level = calculateLevel(user.xp);
      user.favoriteGame = payload.gameName;
      const unlocked = await this.achievementsService.checkAndUnlock(
        user,
        payload.gameType,
        result,
      );
      user.level = calculateLevel(user.xp);
      await user.save();
      notificationsService.emitUserStats(user);
      await notificationsService.createNotification(user.id, {
        type: "match_result",
        title: "Match Complete",
        message:
          result === "win"
            ? `You won ${payload.gameName}`
            : `${payload.gameName} match finished`,
        data: { gameType: payload.gameType, roomCode: payload.roomCode, result },
      });
      for (const achievement of unlocked) {
        await notificationsService.createNotification(user.id, {
          type: "achievement_unlocked",
          title: "Achievement Unlocked",
          message: achievement.title,
          data: { achievementId: achievement.id },
        });
      }
      rewardedPlayers.push(user);
    }

    const resultByPlayer = Object.fromEntries(
      participants.map((player) => [
        player.userId.toString(),
        {
          result: player.result,
          score: Number(player.score) || 0,
          opponentScore: Number(player.opponentScore) || 0,
          coinsEarned: player.coinsEarned,
          xpEarned: player.xpEarned,
        },
      ]),
    );
    const match = await Match.create({
      gameType: payload.gameType,
      gameName: payload.gameName,
      mode: "online",
      roomCode: payload.roomCode,
      players: participants,
      winnerId:
        payload.winnerId && mongoose.isValidObjectId(payload.winnerId)
          ? payload.winnerId
          : undefined,
      resultByPlayer,
      roundHistory: (payload.roundHistory || []).slice(-100),
      durationSeconds: Number(payload.durationSeconds) || 0,
      matchKey,
    });
    match.rewardedUsers = rewardedPlayers;
    return match;
  }

  async mine(userId, { gameType, limit = 20, page = 1 } = {}) {
    const safeLimit = Math.min(Math.max(Number(limit) || 20, 1), 100);
    const safePage = Math.max(Number(page) || 1, 1);
    const query = { "players.userId": userId };
    if (gameType) query.gameType = gameType;
    const [matches, total] = await Promise.all([
      Match.find(query)
        .sort({ createdAt: -1 })
        .skip((safePage - 1) * safeLimit)
        .limit(safeLimit)
        .lean(),
      Match.countDocuments(query),
    ]);
    return { matches, total, page: safePage, limit: safeLimit };
  }

  async recent() {
    return Match.find({ mode: "online" })
      .sort({ createdAt: -1 })
      .limit(20)
      .lean();
  }
}

function rewardFor(gameType, result) {
  if (result === "win") {
    if (gameType === "blackjack_online") return { coins: 200, xp: 100 };
    if (gameType === "war_online") return { coins: 150, xp: 75 };
    return { coins: 100, xp: 50 };
  }
  if (result === "loss") return { coins: 25, xp: 20 };
  return { coins: 40, xp: 30 };
}

function calculateLevel(xp) {
  const thresholds = [0, 100, 250, 500, 900];
  for (let index = thresholds.length - 1; index >= 0; index -= 1) {
    if (xp >= thresholds[index]) {
      return index < 4 ? index + 1 : 5 + Math.floor((xp - 900) / 500);
    }
  }
  return 1;
}

function normalizeResult(value) {
  return ["win", "loss", "draw", "push"].includes(value) ? value : "draw";
}

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

module.exports = { MatchesService, calculateLevel, rewardFor };
