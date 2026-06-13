const { User } = require("../users/user.model");

class LeaderboardService {
  async overall({ type = "wins", limit = 50 } = {}) {
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
        "username avatar level xp coins totalGames totalWins updatedAt",
      )
      .sort({ [sortField]: -1, totalGames: -1 })
      .limit(safeLimit)
      .lean();
    users = users.map(entryPayload);
    if (type === "winRate") users.sort((a, b) => b.winRate - a.winRate);
    return users.map((entry, index) => ({ rank: index + 1, ...entry }));
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

function entryPayload(user) {
  return {
    userId: user._id.toString(),
    username: user.username,
    avatar: user.avatar,
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
