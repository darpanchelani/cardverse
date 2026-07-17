const mongoose = require("mongoose");

const achievementSchema = new mongoose.Schema(
  {
    id: { type: String, required: true },
    title: { type: String, required: true },
    unlockedAt: { type: Date, required: true },
    rewardCoins: { type: Number, default: 0 },
    rewardXp: { type: Number, default: 0 },
  },
  { _id: false },
);

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      minlength: 3,
      maxlength: 20,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    // Kept optional so an existing password account can be linked by verified
    // Google email during migration. Password login is no longer exposed.
    passwordHash: { type: String, select: false },
    googleSubject: { type: String, unique: true, sparse: true },
    avatar: { type: String, default: "default" },
    level: { type: Number, default: 1, min: 1 },
    xp: { type: Number, default: 0, min: 0 },
    coins: { type: Number, default: 500, min: 0 },
    totalGames: { type: Number, default: 0, min: 0 },
    totalWins: { type: Number, default: 0, min: 0 },
    totalLosses: { type: Number, default: 0, min: 0 },
    totalDraws: { type: Number, default: 0, min: 0 },
    currentStreak: { type: Number, default: 0, min: 0 },
    bestStreak: { type: Number, default: 0, min: 0 },
    favoriteGame: { type: String, default: "None" },
    isOnline: { type: Boolean, default: false },
    lastSeenAt: { type: Date, default: Date.now },
    socketId: { type: String, default: null },
    avatarFrame: { type: String, default: "default" },
    equippedCardTheme: { type: String, default: "classic" },
    equippedTableTheme: { type: String, default: "green_felt" },
    unlockedCardThemes: { type: [String], default: ["classic"] },
    unlockedTableThemes: { type: [String], default: ["green_felt"] },
    unlockedAvatarFrames: { type: [String], default: ["default"] },
    settings: {
      soundEnabled: { type: Boolean, default: true },
      vibrationEnabled: { type: Boolean, default: true },
      notificationsEnabled: { type: Boolean, default: true },
      privateProfile: { type: Boolean, default: false },
      showOnlineStatus: { type: Boolean, default: true },
    },
    isDeleted: { type: Boolean, default: false },
    deletedAt: { type: Date, default: null },
    friends: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    achievements: { type: [achievementSchema], default: [] },
  },
  { timestamps: true },
);

userSchema.index({ xp: -1 });
userSchema.index({ coins: -1 });
userSchema.index({ totalWins: -1 });

userSchema.methods.toSafeObject = function toSafeObject() {
  const value = this.toObject();
  delete value.passwordHash;
  delete value.googleSubject;
  value.id = value._id.toString();
  delete value._id;
  delete value.__v;
  value.winRate =
    value.totalGames > 0 ? (value.totalWins / value.totalGames) * 100 : 0;
  return value;
};

const User = mongoose.models.User || mongoose.model("User", userSchema);

module.exports = { User };
