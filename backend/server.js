require("dotenv").config();

const http = require("http");
const { createApp } = require("./src/app");
const { createSocketServer } = require("./src/socket");
const logger = require("./src/utils/logger");

const port = Number(process.env.PORT) || 5050;
const app = createApp();
const server = http.createServer(app);

createSocketServer(server);

server.listen(port, "0.0.0.0", () => {
  logger.info(`CardVerse backend listening on http://0.0.0.0:${port}`);
});
