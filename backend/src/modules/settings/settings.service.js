const ALLOWED_SETTINGS = [
  "soundEnabled",
  "vibrationEnabled",
  "notificationsEnabled",
  "privateProfile",
  "showOnlineStatus",
];

class SettingsService {
  async update(user, updates) {
    for (const key of ALLOWED_SETTINGS) {
      if (updates[key] !== undefined) {
        if (typeof updates[key] !== "boolean") {
          throw httpError(422, `${key} must be a boolean`);
        }
        user.settings[key] = updates[key];
      }
    }
    await user.save();
    return user.toSafeObject();
  }
}

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

module.exports = { SettingsService };
