const http = require("http");
const { createApp } = require("./src/app");
const { connectDatabase } = require("./src/config/db");
const { env, validateEnvironment } = require("./src/config/env");
const { createSocketServer } = require("./src/socket");
const logger = require("./src/utils/logger");

async function start() {
  try {
    validateEnvironment();
    await connectDatabase();
    const app = createApp();
    const server = http.createServer(app);
    createSocketServer(server);
    server.listen(env.port, "0.0.0.0", () => {
      logger.info(
        `CardVerse backend listening on http://0.0.0.0:${env.port}`,
      );
    });
  } catch (error) {
    logger.error(`CardVerse backend could not start: ${error.message}`);
    process.exitCode = 1;
  }
}

start();
