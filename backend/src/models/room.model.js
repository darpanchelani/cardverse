const { ROOM_STATUSES } = require("../constants/game_types");

function createRoomModel(payload, roomCode, hostPlayer) {
  const isPrivate = payload.isPrivate !== false;
  return {
    roomCode,
    roomName: payload.roomName || `${hostPlayer.username}'s Table`,
    gameType: payload.gameType,
    gameName: payload.gameName,
    roomType: isPrivate ? "private" : "public",
    maxPlayers: Number(payload.maxPlayers),
    players: [{ ...hostPlayer, isHost: true, seatIndex: 0 }],
    allowBots: payload.allowBots !== false,
    allowChat: payload.allowChat !== false,
    isPrivate,
    status: ROOM_STATUSES.WAITING,
    createdAt: new Date().toISOString(),
    settings: payload.settings || {},
    chatMessages: [],
  };
}

module.exports = { createRoomModel };
