const { FriendRequest } = require("./friend_request.model");
const { User } = require("../users/user.model");
const {
  notificationsService,
} = require("../notifications/notifications.service");

class FriendsService {
  async list(userId) {
    const user = await User.findById(userId).populate(
      "friends",
      "username avatar avatarFrame level totalWins coins isOnline lastSeenAt settings",
    );
    return user.friends.map(friendPayload);
  }

  async requests(userId) {
    const [incoming, outgoing] = await Promise.all([
      FriendRequest.find({ toUser: userId, status: "pending" })
        .populate("fromUser", "username avatar level totalWins isOnline")
        .lean(),
      FriendRequest.find({ fromUser: userId, status: "pending" })
        .populate("toUser", "username avatar level totalWins isOnline")
        .lean(),
    ]);
    return {
      incoming: incoming.map(requestPayload),
      outgoing: outgoing.map(requestPayload),
    };
  }

  async sendRequest(fromUserId, toUserId) {
    if (fromUserId.toString() === toUserId) {
      throw httpError(422, "You cannot add yourself");
    }
    const [fromUser, toUser] = await Promise.all([
      User.findById(fromUserId),
      User.findById(toUserId),
    ]);
    if (!toUser) throw httpError(404, "User not found");
    if (fromUser.friends.some((id) => id.equals(toUser._id))) {
      throw httpError(409, "You are already friends");
    }
    const reverse = await FriendRequest.findOne({
      fromUser: toUser._id,
      toUser: fromUser._id,
      status: "pending",
    });
    if (reverse) return this.accept(reverse.id, fromUser.id);
    const pending = await FriendRequest.findOne({
      fromUser: fromUser._id,
      toUser: toUser._id,
      status: "pending",
    });
    if (pending) throw httpError(409, "Friend request already sent");
    const request = await FriendRequest.create({
      fromUser: fromUser._id,
      toUser: toUser._id,
    });
    await notificationsService.createNotification(toUser._id, {
      type: "friend_request",
      title: "Friend Request",
      message: `${fromUser.username} sent you a friend request`,
      data: { requestId: request.id, fromUserId: fromUser.id },
    });
    return request.populate([
      { path: "fromUser", select: "username avatar level totalWins isOnline" },
      { path: "toUser", select: "username avatar level totalWins isOnline" },
    ]);
  }

  async accept(requestId, recipientId) {
    const request = await FriendRequest.findById(requestId);
    if (!request) throw httpError(404, "Friend request not found");
    if (request.toUser.toString() !== recipientId.toString()) {
      throw httpError(403, "Only the recipient can accept this request");
    }
    if (request.status !== "pending") {
      throw httpError(409, "Friend request is no longer pending");
    }
    await Promise.all([
      User.findByIdAndUpdate(request.fromUser, {
        $addToSet: { friends: request.toUser },
      }),
      User.findByIdAndUpdate(request.toUser, {
        $addToSet: { friends: request.fromUser },
      }),
    ]);
    request.status = "accepted";
    await request.save();
    const recipient = await User.findById(recipientId);
    await notificationsService.createNotification(request.fromUser, {
      type: "friend_accept",
      title: "Friend Request Accepted",
      message: `${recipient?.username || "A player"} accepted your friend request`,
      data: { friendId: recipientId.toString() },
    });
    return request;
  }

  async decline(requestId, recipientId) {
    const request = await FriendRequest.findById(requestId);
    if (!request) throw httpError(404, "Friend request not found");
    if (request.toUser.toString() !== recipientId.toString()) {
      throw httpError(403, "Only the recipient can decline this request");
    }
    request.status = "declined";
    return request.save();
  }

  async remove(userId, friendId) {
    await Promise.all([
      User.findByIdAndUpdate(userId, { $pull: { friends: friendId } }),
      User.findByIdAndUpdate(friendId, { $pull: { friends: userId } }),
    ]);
  }
}

function friendPayload(user) {
  return {
    id: user.id,
    username: user.username,
    avatar: user.avatar,
    avatarFrame: user.avatarFrame,
    level: user.level,
    wins: user.totalWins,
    coins: user.coins,
    isOnline: user.settings?.showOnlineStatus === false ? false : user.isOnline,
    status:
      user.settings?.showOnlineStatus === false || !user.isOnline
        ? "offline"
        : "online",
    lastSeenAt: user.lastSeenAt,
  };
}

function requestPayload(request) {
  return {
    id: request._id.toString(),
    fromUser: request.fromUser,
    toUser: request.toUser,
    status: request.status,
    createdAt: request.createdAt,
    updatedAt: request.updatedAt,
  };
}

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

module.exports = { FriendsService };
