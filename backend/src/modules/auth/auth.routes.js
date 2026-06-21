const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const {
  authRateLimiter,
} = require("../../middleware/rate_limit.middleware");
const { validateRequest } = require("../../middleware/validate.middleware");
const { createAuthController } = require("./auth.controller");
const { AuthService } = require("./auth.service");
const { registerValidators, loginValidators } = require("./auth.validators");

function createAuthRouter() {
  const router = express.Router();
  const controller = createAuthController(new AuthService());
  router.post(
    "/register",
    authRateLimiter,
    registerValidators,
    validateRequest,
    controller.register,
  );
  router.post(
    "/login",
    authRateLimiter,
    loginValidators,
    validateRequest,
    controller.login,
  );
  router.get("/me", authenticate, controller.me);
  router.post("/logout", authenticate, controller.logout);
  return router;
}

module.exports = { createAuthRouter };
