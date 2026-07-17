const path = require("path");
const dotenv = require("dotenv");

dotenv.config({ path: path.resolve(__dirname, "../../.env") });

const env = Object.freeze({
  port: Number(process.env.PORT) || 5050,
  mongoUri:
    process.env.MONGO_URI || "mongodb://127.0.0.1:27017/cardverse",
  jwtSecret: process.env.JWT_SECRET || "",
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || "7d",
  googleClientIds: (process.env.GOOGLE_CLIENT_IDS || process.env.GOOGLE_CLIENT_ID || "")
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean),
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
  if (env.googleClientIds.length === 0) {
    throw new Error(
      "GOOGLE_CLIENT_IDS is required for verified Google sign-in.",
    );
  }
}

module.exports = { env, validateEnvironment };
