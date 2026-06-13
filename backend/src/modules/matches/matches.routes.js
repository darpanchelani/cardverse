const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const { createMatchesController } = require("./matches.controller");
const { MatchesService } = require("./matches.service");

function createMatchesRouter() {
  const router = express.Router();
  const controller = createMatchesController(new MatchesService());
  router.use(authenticate);
  router.post("/", controller.create);
  router.get("/me", controller.mine);
  router.get("/recent", controller.recent);
  return router;
}

module.exports = { createMatchesRouter };
