const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");
const { env } = require("../../config/env");
const { User } = require("../users/user.model");

class AuthService {
  constructor({
    oauthClient = new OAuth2Client(),
    userModel = User,
    audiences = env.googleClientIds,
    jwtSecret = env.jwtSecret,
    jwtExpiresIn = env.jwtExpiresIn,
  } = {}) {
    this.oauthClient = oauthClient;
    this.userModel = userModel;
    this.audiences = audiences;
    this.jwtSecret = jwtSecret;
    this.jwtExpiresIn = jwtExpiresIn;
  }

  async loginWithGoogle({ idToken }) {
    if (this.audiences.length === 0) {
      const error = new Error("Google OAuth client IDs are not configured");
      error.status = 503;
      throw error;
    }

    let payload;
    try {
      const ticket = await this.oauthClient.verifyIdToken({
        idToken,
        audience: this.audiences,
      });
      payload = ticket.getPayload();
    } catch (_) {
      const error = new Error("Google sign-in could not be verified");
      error.status = 401;
      throw error;
    }

    if (
      !payload?.sub ||
      !payload.email ||
      payload.email_verified !== true
    ) {
      const error = new Error("Google account email must be verified");
      error.status = 401;
      throw error;
    }

    const email = payload.email.trim().toLowerCase();
    let user = await this.userModel.findOne({ googleSubject: payload.sub });

    if (!user) {
      user = await this.userModel.findOne({ email });
      if (user) {
        if (user.googleSubject && user.googleSubject !== payload.sub) {
          const error = new Error("This email belongs to another account");
          error.status = 409;
          throw error;
        }
        user.googleSubject = payload.sub;
        await user.save();
      } else {
        const username = await this.createAvailableUsername(
          payload.name || email.split("@")[0],
        );
        user = await this.userModel.create({
          username,
          email,
          googleSubject: payload.sub,
        });
      }
    }

    return { token: this.createToken(user.id), user: user.toSafeObject() };
  }

  async createAvailableUsername(preferredName) {
    const cleaned = preferredName
      .normalize("NFKD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^A-Za-z0-9_]+/g, "_")
      .replace(/^_+|_+$/g, "")
      .replace(/_+/g, "_");
    const base = (cleaned.length >= 3 ? cleaned : "Player").slice(0, 20);

    for (let index = 0; index < 10000; index += 1) {
      const suffix = index === 0 ? "" : `_${index}`;
      const candidate = `${base.slice(0, 20 - suffix.length)}${suffix}`;
      const existing = await this.userModel.findOne({
        username: new RegExp(`^${escapeRegex(candidate)}$`, "i"),
      });
      if (!existing) return candidate;
    }

    const error = new Error("Could not create an available username");
    error.status = 409;
    throw error;
  }

  createToken(userId) {
    return jwt.sign({}, this.jwtSecret, {
      subject: userId.toString(),
      expiresIn: this.jwtExpiresIn,
    });
  }
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

module.exports = { AuthService };
