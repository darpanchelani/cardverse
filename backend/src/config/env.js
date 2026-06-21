const path = require("path");
const dotenv = require("dotenv");

dotenv.config({ path: path.resolve(__dirname, "../../.env") });

const env = Object.freeze({
  port: Number(process.env.PORT) || 5050,
  mongoUri:
    process.env.MONGO_URI || "mongodb://127.0.0.1:27017/cardverse",
  jwtSecret: process.env.JWT_SECRET || "",
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || "7d",
  clientUrl: process.env.CLIENT_URL || "http://localhost:3000",
  corsOrigin: process.env.CORS_ORIGIN || "*",
  nodeEnv: process.env.NODE_ENV || "development",
  rateLimitWindowMinutes:
    Number(process.env.RATE_LIMIT_WINDOW_MINUTES) || 15,
  rateLimitMaxRequests: Number(process.env.RATE_LIMIT_MAX_REQUESTS) || 200,
});

function validateEnvironment() {
  if (!env.jwtSecret) {
    throw new Error("JWT_SECRET is required. Copy .env.example to .env.");
  }
}

module.exports = { env, validateEnvironment };
