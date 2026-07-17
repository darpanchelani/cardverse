const { User } = require("../users/user.model");
const { Match } = require("../matches/match.model");

class LeaderboardService {
  async overall({ type = "wins", period = "overall", limit = 50 } = {}) {
    if (["daily", "weekly"].includes(period)) {
      return this.period(period, type, limit);
    }
    const fields = {
      wins: "totalWins",
      xp: "xp",
      coins: "coins",
      winRate: "totalWins",
    };
    const sortField = fields[type] || "totalWins";
    const safeLimit = Math.min(Math.max(Number(limit) || 50, 1), 100);
    let users = await User.find()
      .select(
        "username avatar avatarFrame level xp coins totalGames totalWins updatedAt",
      )
      .sort({ [sortField]: -1, totalGames: -1 })
      .limit(safeLimit)
      .lean();
    users = users.map(entryPayload);
    if (type === "winRate") users.sort((a, b) => b.winRate - a.winRate);
    return users.map((entry, index) => ({ rank: index + 1, ...entry }));
  }

  async period(period, type = "wins", limit = 50) {
    const safeLimit = Math.min(Math.max(Number(limit) || 50, 1), 100);
    const start = periodStart(period);
    let users = await Match.aggregate([
      { $match: { createdAt: { $gte: start } } },
      { $unwind: "$players" },
      { $match: { "players.userId": { $exists: true, $ne: null } } },
      {
        $group: {
          _id: "$players.userId",
          wins: {
            $sum: { $cond: [{ $eq: ["$players.result", "win"] }, 1, 0] },
          },
          totalGames: { $sum: 1 },
          coins: { $sum: { $ifNull: ["$players.coinsEarned", 0] } },
          xp: { $sum: { $ifNull: ["$players.xpEarned", 0] } },
          updatedAt: { $max: "$createdAt" },
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "_id",
          foreignField: "_id",
          as: "user",
        },
      },
      { $unwind: "$user" },
      { $match: { "user.isDeleted": { $ne: true } } },
      {
        $project: {
          _id: 0,
          userId: { $toString: "$_id" },
          username: "$user.username",
          avatar: "$user.avatar",
          avatarFrame: "$user.avatarFrame",
          level: "$user.level",
          wins: 1,
          totalGames: 1,
          coins: 1,
          xp: 1,
          updatedAt: 1,
          gameType: { $literal: "overall" },
        },
      },
    ]);

    users = users.map((entry) => ({
      ...entry,
      winRate: entry.totalGames ? (entry.wins / entry.totalGames) * 100 : 0,
    }));
    users.sort((a, b) => {
      if (type === "xp") return b.xp - a.xp || b.totalGames - a.totalGames;
      if (type === "coins") {
        return b.coins - a.coins || b.totalGames - a.totalGames;
      }
      if (type === "winRate") {
        return b.winRate - a.winRate || b.totalGames - a.totalGames;
      }
      return b.wins - a.wins || b.totalGames - a.totalGames;
    });
    return users
      .slice(0, safeLimit)
      .map((entry, index) => ({ rank: index + 1, ...entry }));
  }

  async mine(userId) {
    const user = await User.findById(userId).lean();
    if (!user) return null;
    const [wins, xp, coins] = await Promise.all([
      User.countDocuments({ totalWins: { $gt: user.totalWins } }),
      User.countDocuments({ xp: { $gt: user.xp } }),
      User.countDocuments({ coins: { $gt: user.coins } }),
    ]);
    return { wins: wins + 1, xp: xp + 1, coins: coins + 1 };
  }
}

function periodStart(period) {
  const now = new Date();
  now.setUTCHours(0, 0, 0, 0);
  if (period === "daily") return now;
  const daysSinceMonday = (now.getUTCDay() + 6) % 7;
  now.setUTCDate(now.getUTCDate() - daysSinceMonday);
  return now;
}

function entryPayload(user) {
  return {
    userId: user._id.toString(),
    username: user.username,
    avatar: user.avatar,
    avatarFrame: user.avatarFrame,
    level: user.level,
    xp: user.xp,
    coins: user.coins,
    totalGames: user.totalGames,
    totalWins: user.totalWins,
    wins: user.totalWins,
    winRate: user.totalGames ? (user.totalWins / user.totalGames) * 100 : 0,
    updatedAt: user.updatedAt,
    gameType: "overall",
  };
}

module.exports = { LeaderboardService };
