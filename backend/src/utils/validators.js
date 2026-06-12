const { VALID_GAME_TYPES } = require("../constants/game_types");

function validateUser(payload = {}) {
  if (!String(payload.userId || "").trim()) return "User ID is required";
  if (!String(payload.username || "").trim()) return "Username is required";
  return null;
}

function validateRoomCode(roomCode) {
  return /^[A-Z0-9]{6}$/.test(
    String(roomCode || "")
      .trim()
      .toUpperCase(),
  )
    ? null
    : "Room code must be 6 uppercase letters or numbers";
}

function validateCreateRoom(payload = {}) {
  if (!VALID_GAME_TYPES.includes(payload.gameType)) {
    return "Invalid game type";
  }
  if (![2, 3, 4].includes(Number(payload.maxPlayers))) {
    return "Max players must be 2, 3, or 4";
  }
  return null;
}

function validateMessage(message) {
  const value = String(message || "").trim();
  if (!value) return "Message cannot be empty";
  if (value.length > 300) return "Message cannot exceed 300 characters";
  return null;
}

module.exports = {
  validateUser,
  validateRoomCode,
  validateCreateRoom,
  validateMessage,
};
