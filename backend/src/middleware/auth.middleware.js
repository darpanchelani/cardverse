const jwt = require("jsonwebtoken");
const { env } = require("../config/env");
const { User } = require("../modules/users/user.model");

async function authenticate(request, response, next) {
  try {
    const header = request.headers.authorization || "";
    const [scheme, token] = header.split(" ");
    if (scheme !== "Bearer" || !token) {
      return response.status(401).json({
        success: false,
        message: "Authentication required",
        errors: [],
      });
    }
    const payload = jwt.verify(token, env.jwtSecret);
    const user = await User.findById(payload.sub);
    if (!user) {
      return response.status(401).json({
        success: false,
        message: "User account no longer exists",
        errors: [],
      });
    }
    request.user = user;
    request.token = token;
    return next();
  } catch (_) {
    return response.status(401).json({
      success: false,
      message: "Token is invalid or expired",
      errors: [],
    });
  }
}

module.exports = { authenticate };
