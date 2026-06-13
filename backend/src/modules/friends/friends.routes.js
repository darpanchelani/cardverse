const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const { createFriendsController } = require("./friends.controller");
const { FriendsService } = require("./friends.service");

function createFriendsRouter() {
  const router = express.Router();
  const controller = createFriendsController(new FriendsService());
  router.use(authenticate);
  router.get("/", controller.list);
  router.post("/request", controller.send);
  router.get("/requests", controller.requests);
  router.post("/requests/:requestId/accept", controller.accept);
  router.post("/requests/:requestId/decline", controller.decline);
  router.delete("/:friendId", controller.remove);
  return router;
}

module.exports = { createFriendsRouter };
