const rateLimit = require("express-rate-limit");
const { env } = require("../config/env");

function createRateLimiter({ limit = env.rateLimitMaxRequests } = {}) {
  return rateLimit({
    windowMs: env.rateLimitWindowMinutes * 60 * 1000,
    limit,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
      success: false,
      message: "Too many requests. Please try again later.",
      errors: [],
    },
  });
}

const apiRateLimiter = createRateLimiter();
const authRateLimiter = createRateLimiter({
  limit: Math.min(env.rateLimitMaxRequests, 50),
});

module.exports = { createRateLimiter, apiRateLimiter, authRateLimiter };
