const cors = require("cors");
const express = require("express");
const helmet = require("helmet");
const morgan = require("morgan");
const { env } = require("./config/env");
const {
  errorMiddleware,
  notFoundMiddleware,
} = require("./middleware/error.middleware");
const { createAuthRouter } = require("./modules/auth/auth.routes");
const {
  createAchievementsRouter,
} = require("./modules/achievements/achievements.routes");
const { createFriendsRouter } = require("./modules/friends/friends.routes");
const {
  createLeaderboardRouter,
} = require("./modules/leaderboard/leaderboard.routes");
const { createMatchesRouter } = require("./modules/matches/matches.routes");
const { createUserRouter } = require("./modules/users/user.routes");
const { createHealthRouter } = require("./routes/health.routes");
const { createRoomsRouter } = require("./routes/rooms.routes");
const { roomService } = require("./socket");

function createApp() {
  const app = express();
  app.use(helmet());
  app.use(
    cors({
      origin: env.nodeEnv === "development" ? true : env.clientUrl,
      credentials: true,
    }),
  );
  app.use(morgan(env.nodeEnv === "development" ? "dev" : "combined"));
  app.use(express.json({ limit: "1mb" }));
  app.use("/health", createHealthRouter());
  app.use("/api/auth", createAuthRouter());
  app.use("/api/users", createUserRouter());
  app.use("/api/friends", createFriendsRouter());
  app.use("/api/matches", createMatchesRouter());
  app.use("/api/leaderboard", createLeaderboardRouter());
  app.use("/api/achievements", createAchievementsRouter());
  app.use("/api/rooms", createRoomsRouter(roomService));
  app.use(notFoundMiddleware);
  app.use(errorMiddleware);
  return app;
}

module.exports = { createApp };
