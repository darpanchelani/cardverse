const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const { createSettingsController } = require("./settings.controller");
const { SettingsService } = require("./settings.service");

function createSettingsRouter() {
  const router = express.Router();
  const controller = createSettingsController(new SettingsService());
  router.patch("/me/settings", authenticate, controller.update);
  return router;
}

module.exports = { createSettingsRouter };
