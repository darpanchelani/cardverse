const { Invite } = require("./invite.model");
const { User } = require("../users/user.model");
const {
  notificationsService,
} = require("../notifications/notifications.service");

class InvitesService {
  constructor(roomService, io = null) {
    this.roomService = roomService;
    this.io = io;
  }

  setSocketServer(io) {
    this.io = io;
  }

  async create(fromUserId, { toUserId, roomCode }) {
    const room = this.roomService.canInviteToRoom(
      roomCode,
      fromUserId,
      toUserId,
    );
    const sender = await User.findById(fromUserId);
    if (!sender?.friends.some((id) => id.toString() === String(toUserId))) {
      throw httpError(403, "You can only invite friends");
    }
    const recipient = await User.findById(toUserId);
    if (!recipient || recipient.isDeleted) throw httpError(404, "User not found");
    await this.expireOldInvites();
    const duplicate = await Invite.findOne({
      roomCode: room.roomCode,
      fromUser: fromUserId,
      toUser: toUserId,
      status: "pending",
      expiresAt: { $gt: new Date() },
    });
    if (duplicate) throw httpError(409, "Invite already sent");
    const invite = await Invite.create({
      roomCode: room.roomCode,
      fromUser: fromUserId,
      toUser: toUserId,
      gameType: room.gameType,
      gameName: room.gameName,
      expiresAt: new Date(Date.now() + 30 * 60 * 1000),
    });
    await invite.populate([
      { path: "fromUser", select: "username avatar" },
      { path: "toUser", select: "username avatar" },
    ]);
    const serialized = serialize(invite);
    await notificationsService.createNotification(toUserId, {
      type: "room_invite",
      title: "Game Invite",
      message: `${sender.username} invited you to play ${room.gameName}`,
      data: {
        inviteId: invite.id,
        roomCode: room.roomCode,
        gameType: room.gameType,
      },
    });
    this.io?.to(`user:${toUserId}`).emit("invite:received", serialized);
    return serialized;
  }

  async list(userId) {
    await this.expireOldInvites();
    const [incoming, outgoing] = await Promise.all([
      Invite.find({ toUser: userId })
        .populate("fromUser", "username avatar")
        .populate("toUser", "username avatar")
        .sort({ createdAt: -1 })
        .limit(100),
      Invite.find({ fromUser: userId })
        .populate("fromUser", "username avatar")
        .populate("toUser", "username avatar")
        .sort({ createdAt: -1 })
        .limit(100),
    ]);
    return {
      incoming: incoming.map(serialize),
      outgoing: outgoing.map(serialize),
    };
  }

  async accept(inviteId, userId) {
    const invite = await this._pending(inviteId);
    if (invite.toUser.toString() !== String(userId)) {
      throw httpError(403, "Only the recipient can accept this invite");
    }
    this.roomService.canInviteToRoom(
      invite.roomCode,
      invite.fromUser.toString(),
      userId,
    );
    const senderId = invite.fromUser.toString();
    invite.status = "accepted";
    await invite.save();
    const recipient = await User.findById(userId);
    await notificationsService.createNotification(senderId, {
      type: "invite_accepted",
      title: "Invite Accepted",
      message: `${recipient?.username || "Your friend"} accepted your invite`,
      data: { inviteId: invite.id, roomCode: invite.roomCode },
    });
    const serialized = await this._serialized(invite);
    this.io?.to(`user:${senderId}`).emit("invite:accepted", serialized);
    return serialized;
  }

  async decline(inviteId, userId) {
    const invite = await this._pending(inviteId);
    if (invite.toUser.toString() !== String(userId)) {
      throw httpError(403, "Only the recipient can decline this invite");
    }
    const senderId = invite.fromUser.toString();
    invite.status = "declined";
    await invite.save();
    const recipient = await User.findById(userId);
    await notificationsService.createNotification(senderId, {
      type: "invite_declined",
      title: "Invite Declined",
      message: `${recipient?.username || "Your friend"} declined your invite`,
      data: { inviteId: invite.id, roomCode: invite.roomCode },
    });
    const serialized = await this._serialized(invite);
    this.io?.to(`user:${senderId}`).emit("invite:declined", serialized);
    return serialized;
  }

  async cancel(inviteId, userId) {
    const invite = await this._pending(inviteId);
    if (invite.fromUser.toString() !== String(userId)) {
      throw httpError(403, "Only the sender can cancel this invite");
    }
    const recipientId = invite.toUser.toString();
    invite.status = "cancelled";
    await invite.save();
    const serialized = await this._serialized(invite);
    this.io?.to(`user:${recipientId}`).emit("invite:cancelled", serialized);
    return serialized;
  }

  async expireOldInvites() {
    await Invite.updateMany(
      { status: "pending", expiresAt: { $lte: new Date() } },
      { status: "expired" },
    );
  }

  async _pending(inviteId) {
    const invite = await Invite.findById(inviteId);
    if (!invite) throw httpError(404, "Invite not found");
    if (invite.status !== "pending") {
      throw httpError(409, "Invite is no longer pending");
    }
    if (invite.expiresAt <= new Date()) {
      invite.status = "expired";
      await invite.save();
      throw httpError(410, "Invite has expired");
    }
    return invite;
  }

  async _serialized(invite) {
    await invite.populate([
      { path: "fromUser", select: "username avatar" },
      { path: "toUser", select: "username avatar" },
    ]);
    return serialize(invite);
  }
}

function serialize(invite) {
  const value = invite.toObject ? invite.toObject() : invite;
  return {
    id: value._id.toString(),
    roomCode: value.roomCode,
    fromUserId: value.fromUser?._id?.toString() || value.fromUser.toString(),
    fromUsername: value.fromUser?.username || "Player",
    toUserId: value.toUser?._id?.toString() || value.toUser.toString(),
    toUsername: value.toUser?.username || "Player",
    gameType: value.gameType,
    gameName: value.gameName,
    status: value.status,
    expiresAt: value.expiresAt,
    createdAt: value.createdAt,
    updatedAt: value.updatedAt,
  };
}

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

module.exports = { InvitesService };
