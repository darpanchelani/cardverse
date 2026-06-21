const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const { createInvitesController } = require("./invites.controller");
const { InvitesService } = require("./invites.service");

function createInvitesRouter(roomService, service) {
  const router = express.Router();
  const controller = createInvitesController(
    service || new InvitesService(roomService),
  );
  router.use(authenticate);
  router.get("/", controller.list);
  router.post("/", controller.create);
  router.post("/:inviteId/accept", controller.accept);
  router.post("/:inviteId/decline", controller.decline);
  router.post("/:inviteId/cancel", controller.cancel);
  return router;
}

module.exports = { createInvitesRouter };
