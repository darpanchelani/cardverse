const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { env } = require("../../config/env");
const { User } = require("../users/user.model");

class AuthService {
  async register({ username, email, password }) {
    const normalizedEmail = email.trim().toLowerCase();
    const normalizedUsername = username.trim();
    const existing = await User.findOne({
      $or: [
        { email: normalizedEmail },
        { username: new RegExp(`^${escapeRegex(normalizedUsername)}$`, "i") },
      ],
    });
    if (existing) {
      const error = new Error(
        existing.email === normalizedEmail
          ? "Email is already registered"
          : "Username is already taken",
      );
      error.status = 409;
      throw error;
    }
    const passwordHash = await bcrypt.hash(password, 12);
    const user = await User.create({
      username: normalizedUsername,
      email: normalizedEmail,
      passwordHash,
    });
    return { token: this.createToken(user.id), user: user.toSafeObject() };
  }

  async login({ email, password }) {
    const user = await User.findOne({
      email: email.trim().toLowerCase(),
    }).select("+passwordHash");
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      const error = new Error("Email or password is incorrect");
      error.status = 401;
      throw error;
    }
    return { token: this.createToken(user.id), user: user.toSafeObject() };
  }

  createToken(userId) {
    return jwt.sign({}, env.jwtSecret, {
      subject: userId.toString(),
      expiresIn: env.jwtExpiresIn,
    });
  }
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

module.exports = { AuthService };
