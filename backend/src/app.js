const cors = require("cors");
const express = require("express");
const { createHealthRouter } = require("./routes/health.routes");
const { createRoomsRouter } = require("./routes/rooms.routes");
const { roomService } = require("./socket");

function createApp() {
  const app = express();
  app.use(cors({ origin: true, credentials: true }));
  app.use(express.json());
  app.use("/health", createHealthRouter());
  app.use("/api/rooms", createRoomsRouter(roomService));
  return app;
}

module.exports = { createApp };
