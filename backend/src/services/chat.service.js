const { createChatMessage } = require("../models/chat_message.model");
const { validateMessage } = require("../utils/validators");

class ChatService {
  constructor(roomService) {
    this.roomService = roomService;
  }

  addMessage(roomCode, sender, message) {
    const room = this._room(roomCode);
    const validationError = validateMessage(message);
    if (validationError) throw new Error(validationError);
    const chatMessage = createChatMessage({
      id: `message_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
      roomCode,
      senderId: sender.id,
      senderName: sender.username,
      message: String(message).trim(),
    });
    this._append(room, chatMessage);
    return chatMessage;
  }

  addSystemMessage(roomCode, message) {
    const room = this._room(roomCode);
    const chatMessage = createChatMessage({
      id: `system_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
      roomCode,
      senderId: "system",
      senderName: "CardVerse",
      message,
      isSystemMessage: true,
    });
    this._append(room, chatMessage);
    return chatMessage;
  }

  getMessages(roomCode) {
    return [...this._room(roomCode).chatMessages];
  }

  _append(room, message) {
    room.chatMessages.push(message);
    if (room.chatMessages.length > 100) {
      room.chatMessages.splice(0, room.chatMessages.length - 100);
    }
  }

  _room(roomCode) {
    const room = this.roomService.getRoom(roomCode);
    if (!room) throw new Error("Room not found");
    return room;
  }
}

module.exports = { ChatService };
