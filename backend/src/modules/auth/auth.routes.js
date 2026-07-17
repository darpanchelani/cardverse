const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const {
  authRateLimiter,
} = require("../../middleware/rate_limit.middleware");
const { validateRequest } = require("../../middleware/validate.middleware");
const { createAuthController } = require("./auth.controller");
const { AuthService } = require("./auth.service");
const { googleValidators } = require("./auth.validators");

function createAuthRouter() {
  const router = express.Router();
  const controller = createAuthController(new AuthService());
  router.post(
    "/google",
    authRateLimiter,
    googleValidators,
    validateRequest,
    controller.google,
  );
  router.get("/me", authenticate, controller.me);
  router.post("/logout", authenticate, controller.logout);
  return router;
}

module.exports = { createAuthRouter };
