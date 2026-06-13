const express = require("express");
const rateLimit = require("express-rate-limit");
const { authenticate } = require("../../middleware/auth.middleware");
const { validateRequest } = require("../../middleware/validate.middleware");
const { createAuthController } = require("./auth.controller");
const { AuthService } = require("./auth.service");
const { registerValidators, loginValidators } = require("./auth.validators");

function createAuthRouter() {
  const router = express.Router();
  const controller = createAuthController(new AuthService());
  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 50,
    standardHeaders: true,
    legacyHeaders: false,
  });
  router.post(
    "/register",
    limiter,
    registerValidators,
    validateRequest,
    controller.register,
  );
  router.post(
    "/login",
    limiter,
    loginValidators,
    validateRequest,
    controller.login,
  );
  router.get("/me", authenticate, controller.me);
  router.post("/logout", authenticate, controller.logout);
  return router;
}

module.exports = { createAuthRouter };
