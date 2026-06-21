const { Notification } = require("./notification.model");

class NotificationsService {
  constructor(io = null) {
    this.io = io;
  }

  setSocketServer(io) {
    this.io = io;
  }

  async createNotification(userId, payload) {
    const notification = await Notification.create({ userId, ...payload });
    const serialized = serialize(notification);
    if (this.io) {
      this.io.to(`user:${userId}`).emit("notification:new", serialized);
      await this.emitUnreadCount(userId);
    }
    return serialized;
  }

  async getUserNotifications(
    userId,
    { unreadOnly = false, limit = 30, page = 1 } = {},
  ) {
    const query = { userId };
    if (String(unreadOnly) === "true") query.isRead = false;
    const safeLimit = Math.min(Math.max(Number(limit) || 30, 1), 100);
    const safePage = Math.max(Number(page) || 1, 1);
    const [notifications, unreadCount] = await Promise.all([
      Notification.find(query)
        .sort({ createdAt: -1 })
        .skip((safePage - 1) * safeLimit)
        .limit(safeLimit)
        .lean(),
      Notification.countDocuments({ userId, isRead: false }),
    ]);
    return {
      notifications: notifications.map(serialize),
      unreadCount,
      page: safePage,
      limit: safeLimit,
    };
  }

  async markAsRead(userId, notificationId) {
    const notification = await Notification.findOneAndUpdate(
      { _id: notificationId, userId },
      { isRead: true },
      { new: true },
    );
    if (!notification) throw httpError(404, "Notification not found");
    await this.emitUnreadCount(userId);
    return serialize(notification);
  }

  async markAllAsRead(userId) {
    await Notification.updateMany({ userId, isRead: false }, { isRead: true });
    await this.emitUnreadCount(userId);
  }

  async deleteNotification(userId, notificationId) {
    const result = await Notification.deleteOne({
      _id: notificationId,
      userId,
    });
    if (!result.deletedCount) throw httpError(404, "Notification not found");
    await this.emitUnreadCount(userId);
  }

  async emitUnreadCount(userId) {
    const unreadCount = await Notification.countDocuments({
      userId,
      isRead: false,
    });
    this.io
      ?.to(`user:${userId}`)
      .emit("notification:unread_count", { unreadCount });
    return unreadCount;
  }

  emitUserStats(user) {
    this.io?.to(`user:${user.id}`).emit("user:stats_updated", {
      userId: user.id,
      level: user.level,
      xp: user.xp,
      coins: user.coins,
      totalGames: user.totalGames,
      totalWins: user.totalWins,
      totalLosses: user.totalLosses,
      totalDraws: user.totalDraws,
    });
  }
}

function serialize(notification) {
  const value = notification.toObject ? notification.toObject() : notification;
  return {
    id: value._id.toString(),
    type: value.type,
    title: value.title,
    message: value.message,
    data: value.data || {},
    isRead: value.isRead,
    createdAt: value.createdAt,
  };
}

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

const notificationsService = new NotificationsService();

module.exports = { NotificationsService, notificationsService };
