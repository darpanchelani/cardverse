const crypto = require("crypto");

const CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

function generateRoomCode() {
  const bytes = crypto.randomBytes(6);
  return Array.from(bytes, (byte) => CHARACTERS[byte % CHARACTERS.length]).join(
    "",
  );
}

module.exports = { generateRoomCode };
