const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const {
  createAchievementsController,
} = require("./achievements.controller");
const { AchievementsService } = require("./achievements.service");

function createAchievementsRouter() {
  const router = express.Router();
  const controller = createAchievementsController(new AchievementsService());
  router.get("/me", authenticate, controller.mine);
  return router;
}

module.exports = { createAchievementsRouter };
