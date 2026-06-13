const mongoose = require("mongoose");

const matchPlayerSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    username: { type: String, required: true },
    score: { type: Number, default: 0 },
    result: {
      type: String,
      enum: ["win", "loss", "draw", "push"],
      required: true,
    },
    coinsEarned: { type: Number, default: 0 },
    xpEarned: { type: Number, default: 0 },
  },
  { _id: false },
);

const matchSchema = new mongoose.Schema(
  {
    gameType: {
      type: String,
      enum: [
        "high_card",
        "war",
        "blackjack",
        "high_card_online",
        "war_online",
        "blackjack_online",
      ],
      required: true,
    },
    gameName: { type: String, required: true },
    mode: { type: String, enum: ["offline", "online"], required: true },
    roomCode: { type: String, uppercase: true, trim: true },
    players: { type: [matchPlayerSchema], required: true },
    winnerId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    resultByPlayer: { type: mongoose.Schema.Types.Mixed, default: {} },
    roundHistory: { type: [mongoose.Schema.Types.Mixed], default: [] },
    durationSeconds: { type: Number, default: 0 },
    matchKey: { type: String, unique: true, sparse: true },
  },
  { timestamps: true },
);

matchSchema.index({ "players.userId": 1, createdAt: -1 });
matchSchema.index({ gameType: 1, createdAt: -1 });

const Match = mongoose.models.Match || mongoose.model("Match", matchSchema);

module.exports = { Match };
