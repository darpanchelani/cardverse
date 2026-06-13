const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const {
  createLeaderboardController,
} = require("./leaderboard.controller");
const { LeaderboardService } = require("./leaderboard.service");

function createLeaderboardRouter() {
  const router = express.Router();
  const controller = createLeaderboardController(new LeaderboardService());
  router.get("/", controller.list);
  router.get("/me", authenticate, controller.mine);
  return router;
}

module.exports = { createLeaderboardRouter };
