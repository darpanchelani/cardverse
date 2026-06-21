function createNotificationsController(service) {
  return {
    list: async (request, response, next) => {
      try {
        response.json({
          success: true,
          data: await service.getUserNotifications(
            request.user.id,
            request.query,
          ),
        });
      } catch (error) {
        next(error);
      }
    },
    read: async (request, response, next) => {
      try {
        response.json({
          success: true,
          data: {
            notification: await service.markAsRead(
              request.user.id,
              request.params.notificationId,
            ),
          },
        });
      } catch (error) {
        next(error);
      }
    },
    readAll: async (request, response, next) => {
      try {
        await service.markAllAsRead(request.user.id);
        response.json({ success: true, message: "Notifications marked read" });
      } catch (error) {
        next(error);
      }
    },
    remove: async (request, response, next) => {
      try {
        await service.deleteNotification(
          request.user.id,
          request.params.notificationId,
        );
        response.json({ success: true, message: "Notification deleted" });
      } catch (error) {
        next(error);
      }
    },
  };
}

module.exports = { createNotificationsController };
