function createPlayer(payload, socketId, overrides = {}) {
  return {
    id: payload.userId,
    socketId,
    username: payload.username,
    avatar: payload.avatar || "default",
    level: Number(payload.level) || 1,
    isGuest: payload.isGuest !== false,
    isHost: false,
    isReady: false,
    isBot: false,
    seatIndex: 0,
    connectionStatus: "connected",
    joinedAt: new Date().toISOString(),
    ...overrides,
  };
}

module.exports = { createPlayer };
