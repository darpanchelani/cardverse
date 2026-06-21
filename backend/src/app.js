const cors = require("cors");
const compression = require("compression");
const express = require("express");
const helmet = require("helmet");
const morgan = require("morgan");
const { env } = require("./config/env");
const { corsOptions } = require("./config/cors");
const { apiRateLimiter } = require("./middleware/rate_limit.middleware");
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
const {
  createNotificationsRouter,
} = require("./modules/notifications/notifications.routes");
const { createInvitesRouter } = require("./modules/invites/invites.routes");
const { createThemesRouter } = require("./modules/themes/themes.routes");
const { createSettingsRouter } = require("./modules/settings/settings.routes");
const { createHealthRouter } = require("./routes/health.routes");
const { createRoomsRouter } = require("./routes/rooms.routes");
const { roomService, invitesService } = require("./socket");

function createApp() {
  const app = express();
  app.use(helmet());
  app.use(cors(corsOptions()));
  app.use(compression());
  app.use(morgan(env.nodeEnv === "development" ? "dev" : "combined"));
  app.use(express.json({ limit: "1mb" }));
  app.get("/", (_request, response) => {
    response.json({ success: true, message: "CardVerse API" });
  });
  app.use("/health", createHealthRouter());
  app.use("/api", apiRateLimiter);
  app.use("/api/auth", createAuthRouter());
  app.use("/api/users", createUserRouter());
  app.use("/api/friends", createFriendsRouter());
  app.use("/api/matches", createMatchesRouter());
  app.use("/api/leaderboard", createLeaderboardRouter());
  app.use("/api/achievements", createAchievementsRouter());
  app.use("/api/notifications", createNotificationsRouter());
  app.use("/api/invites", createInvitesRouter(roomService, invitesService));
  app.use("/api/themes", createThemesRouter());
  app.use("/api/users", createSettingsRouter());
  app.use("/api/rooms", createRoomsRouter(roomService));
  app.use(notFoundMiddleware);
  app.use(errorMiddleware);
  return app;
}

module.exports = { createApp };
