const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const { createUserController } = require("./user.controller");
const { UserService } = require("./user.service");

function createUserRouter() {
  const router = express.Router();
  const controller = createUserController(new UserService());
  router.use(authenticate);
  router.get("/me", controller.me);
  router.patch("/me", controller.update);
  router.get("/search", controller.search);
  router.get("/:userId", controller.profile);
  return router;
}

module.exports = { createUserRouter };
