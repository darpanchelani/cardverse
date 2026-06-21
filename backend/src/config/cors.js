const { env } = require("./env");

function corsOptions() {
  const configured = env.corsOrigin.trim();
  if (configured === "*") {
    return { origin: true, credentials: true };
  }
  const allowed = configured
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
  return {
    credentials: true,
    origin(origin, callback) {
      if (!origin || allowed.includes(origin)) return callback(null, true);
      return callback(new Error("Origin is not allowed by CORS"));
    },
  };
}

module.exports = { corsOptions };
