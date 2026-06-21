const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const {
  createNotificationsController,
} = require("./notifications.controller");
const { notificationsService } = require("./notifications.service");

function createNotificationsRouter() {
  const router = express.Router();
  const controller = createNotificationsController(notificationsService);
  router.use(authenticate);
  router.get("/", controller.list);
  router.post("/read-all", controller.readAll);
  router.post("/:notificationId/read", controller.read);
  router.delete("/:notificationId", controller.remove);
  return router;
}

module.exports = { createNotificationsRouter };
