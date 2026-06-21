const mongoose = require("mongoose");

const inviteSchema = new mongoose.Schema(
  {
    roomCode: { type: String, required: true, uppercase: true, trim: true },
    fromUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    toUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    gameType: { type: String, required: true },
    gameName: { type: String, required: true },
    status: {
      type: String,
      enum: ["pending", "accepted", "declined", "expired", "cancelled"],
      default: "pending",
    },
    expiresAt: { type: Date, required: true },
  },
  { timestamps: true },
);

inviteSchema.index({ toUser: 1, status: 1 });
inviteSchema.index({ roomCode: 1 });
inviteSchema.index({ expiresAt: 1 });

const Invite = mongoose.models.Invite || mongoose.model("Invite", inviteSchema);

module.exports = { Invite };
