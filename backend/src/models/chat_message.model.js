function createChatMessage({
  id,
  roomCode,
  senderId,
  senderName,
  message,
  isSystemMessage = false,
}) {
  return {
    id,
    roomCode,
    senderId,
    senderName,
    message,
    sentAt: new Date().toISOString(),
    isSystemMessage,
  };
}

module.exports = { createChatMessage };
