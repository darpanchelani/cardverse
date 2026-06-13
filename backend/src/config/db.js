const mongoose = require("mongoose");
const { env } = require("./env");
const logger = require("../utils/logger");

async function connectDatabase() {
  try {
    await mongoose.connect(env.mongoUri, {
      serverSelectionTimeoutMS: 8000,
    });
    logger.info("MongoDB connected");
    return mongoose.connection;
  } catch (error) {
    logger.error(`MongoDB connection failed: ${error.message}`);
    throw error;
  }
}

module.exports = { connectDatabase };
