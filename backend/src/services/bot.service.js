const BOT_NAMES = ["Bot Nova", "Bot Ace", "Bot King", "Bot Ruby"];

function createBot(roomCode, seatIndex, existingBots) {
  const availableName =
    BOT_NAMES.find((name) => !existingBots.some((bot) => bot.username === name)) ||
    `Bot ${seatIndex + 1}`;
  return {
    id: `bot_${roomCode}_${seatIndex}_${Date.now()}`,
    socketId: null,
    username: availableName,
    avatar: "BOT",
    level: 1,
    isHost: false,
    isReady: true,
    isBot: true,
    seatIndex,
    connectionStatus: "connected",
    joinedAt: new Date().toISOString(),
  };
}

module.exports = { createBot };
