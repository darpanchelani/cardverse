const { User } = require("./user.model");

class UserService {
  async update(user, updates) {
    if (updates.username !== undefined) {
      const username = String(updates.username).trim();
      if (!/^[A-Za-z0-9_]{3,20}$/.test(username)) {
        const error = new Error("Username must be 3 to 20 valid characters");
        error.status = 422;
        throw error;
      }
      const taken = await User.exists({
        _id: { $ne: user.id },
        username: new RegExp(`^${escapeRegex(username)}$`, "i"),
      });
      if (taken) {
        const error = new Error("Username is already taken");
        error.status = 409;
        throw error;
      }
      user.username = username;
    }
    if (updates.avatar !== undefined) {
      user.avatar = String(updates.avatar).trim().slice(0, 200) || "default";
    }
    await user.save();
    return user.toSafeObject();
  }

  async search(query, currentUserId) {
    const normalized = String(query || "").trim();
    if (normalized.length < 2) return [];
    return User.find({
      _id: { $ne: currentUserId },
      username: { $regex: escapeRegex(normalized), $options: "i" },
    })
      .select("username avatar level totalWins isOnline lastSeenAt friends")
      .limit(20)
      .lean();
  }

  async publicProfile(userId) {
    const user = await User.findById(userId)
      .select(
        "username avatar avatarFrame level totalWins totalGames favoriteGame lastSeenAt isOnline settings",
      )
      .lean();
    if (!user) {
      const error = new Error("User not found");
      error.status = 404;
      throw error;
    }
    if (user.settings?.privateProfile) {
      return {
        id: user._id.toString(),
        username: user.username,
        avatar: user.avatar,
        avatarFrame: user.avatarFrame,
        level: user.level,
        privateProfile: true,
      };
    }
    return {
      ...user,
      id: user._id.toString(),
      isOnline:
        user.settings?.showOnlineStatus === false ? false : user.isOnline,
      winRate: user.totalGames
        ? (user.totalWins / user.totalGames) * 100
        : 0,
    };
  }

  async softDelete(user) {
    const suffix = `${user.id}_${Date.now()}`;
    user.isDeleted = true;
    user.deletedAt = new Date();
    user.isOnline = false;
    user.socketId = null;
    user.username = `deleted_${suffix}`.slice(0, 20);
    user.email = `deleted_${suffix}@cardverse.invalid`;
    user.friends = [];
    await user.save();
  }
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

module.exports = { UserService };
