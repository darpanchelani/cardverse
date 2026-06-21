const { COSMETICS, cosmeticList } = require("./theme.model");

const TYPE_CONFIG = {
  cardTheme: {
    unlocked: "unlockedCardThemes",
    equipped: "equippedCardTheme",
  },
  tableTheme: {
    unlocked: "unlockedTableThemes",
    equipped: "equippedTableTheme",
  },
  avatarFrame: {
    unlocked: "unlockedAvatarFrames",
    equipped: "avatarFrame",
  },
};

class ThemesService {
  list(user = null) {
    const catalog = cosmeticList();
    return Object.fromEntries(
      Object.entries(catalog).map(([type, items]) => {
        const config = TYPE_CONFIG[type];
        return [
          type,
          items.map((item) => ({
            ...item,
            isUnlocked: user ? user[config.unlocked].includes(item.id) : item.price === 0,
            isEquipped: user ? user[config.equipped] === item.id : item.price === 0,
          })),
        ];
      }),
    );
  }

  async purchase(user, { type, themeId }) {
    const { config, item } = lookup(type, themeId);
    if (user[config.unlocked].includes(item.id)) {
      throw httpError(409, "Theme is already unlocked");
    }
    if (user.coins < item.price) throw httpError(422, "Not enough coins");
    user.coins -= item.price;
    user[config.unlocked].push(item.id);
    await user.save();
    return user.toSafeObject();
  }

  async equip(user, { type, themeId }) {
    const { config, item } = lookup(type, themeId);
    if (!user[config.unlocked].includes(item.id)) {
      throw httpError(403, "Unlock this theme before equipping it");
    }
    user[config.equipped] = item.id;
    await user.save();
    return user.toSafeObject();
  }
}

function lookup(type, themeId) {
  const config = TYPE_CONFIG[type];
  const values = COSMETICS[type];
  if (!config || !values) throw httpError(422, "Invalid cosmetic type");
  const raw = values.find(([id]) => id === themeId);
  if (!raw) throw httpError(404, "Theme not found");
  return {
    config,
    item: { id: raw[0], name: raw[1], price: raw[2], type },
  };
}

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

module.exports = { ThemesService };
