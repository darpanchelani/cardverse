const assert = require("node:assert/strict");
const test = require("node:test");
const { ThemesService } = require("../src/modules/themes/themes.service");
const {
  SettingsService,
} = require("../src/modules/settings/settings.service");
const { RoomService } = require("../src/services/room.service");

test("theme purchase deducts virtual coins and equip requires ownership", async () => {
  const user = fakeUser();
  const service = new ThemesService();
  await service.purchase(user, {
    type: "cardTheme",
    themeId: "royal_gold",
  });
  assert.equal(user.coins, 500);
  assert.ok(user.unlockedCardThemes.includes("royal_gold"));
  await service.equip(user, {
    type: "cardTheme",
    themeId: "royal_gold",
  });
  assert.equal(user.equippedCardTheme, "royal_gold");
  await assert.rejects(
    service.equip(user, {
      type: "tableTheme",
      themeId: "night_casino",
    }),
    /Unlock this theme/,
  );
});

test("account settings only accept boolean values", async () => {
  const user = fakeUser();
  const service = new SettingsService();
  await service.update(user, {
    notificationsEnabled: false,
    privateProfile: true,
  });
  assert.equal(user.settings.notificationsEnabled, false);
  assert.equal(user.settings.privateProfile, true);
  await assert.rejects(
    service.update(user, { showOnlineStatus: "yes" }),
    /must be a boolean/,
  );
});

test("room invite validation requires membership and an available seat", () => {
  const service = new RoomService();
  const room = service.createRoom(
    {
      gameType: "high_card",
      maxPlayers: 2,
      isPrivate: true,
      allowBots: false,
      allowChat: true,
      settings: {},
    },
    {
      id: "host",
      username: "Host",
      isHost: true,
      isReady: false,
      isBot: false,
      seatIndex: 0,
    },
  );
  assert.equal(
    service.canInviteToRoom(room.roomCode, "host", "friend").roomCode,
    room.roomCode,
  );
  assert.throws(
    () => service.canInviteToRoom(room.roomCode, "outsider", "friend"),
    /must be in the room/,
  );
});

function fakeUser() {
  return {
    coins: 1000,
    unlockedCardThemes: ["classic"],
    unlockedTableThemes: ["green_felt"],
    unlockedAvatarFrames: ["default"],
    equippedCardTheme: "classic",
    equippedTableTheme: "green_felt",
    avatarFrame: "default",
    settings: {
      soundEnabled: true,
      vibrationEnabled: true,
      notificationsEnabled: true,
      privateProfile: false,
      showOnlineStatus: true,
    },
    async save() {},
    toSafeObject() {
      return this;
    },
  };
}
