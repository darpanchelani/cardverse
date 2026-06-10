const { GAME_NAMES, ROOM_STATUSES } = require("../constants/game_types");
const { createRoomModel } = require("../models/room.model");
const { createBot } = require("./bot.service");
const { generateRoomCode } = require("./room_code.service");
const {
  validateCreateRoom,
  validateRoomCode,
} = require("../utils/validators");

class RoomService {
  constructor() {
    this.rooms = new Map();
    this.chatService = null;
  }

  setChatService(chatService) {
    this.chatService = chatService;
  }

  createRoom(payload, hostPlayer) {
    const validationError = validateCreateRoom(payload);
    if (validationError) throw new Error(validationError);
    const roomCode = this._uniqueRoomCode();
    const normalized = {
      ...payload,
      gameName: GAME_NAMES[payload.gameType],
    };
    const room = createRoomModel(normalized, roomCode, hostPlayer);
    this.rooms.set(roomCode, room);
    this.chatService?.addSystemMessage(
      roomCode,
      "Room created. Invite friends or add a bot.",
    );
    return room;
  }

  joinRoom(roomCode, player) {
    const code = this._code(roomCode);
    const room = this.getRoom(code);
    if (!room) throw new Error("Room not found");
    if (![ROOM_STATUSES.WAITING, ROOM_STATUSES.READY].includes(room.status)) {
      throw new Error("Room is already playing");
    }
    const existing = room.players.find((item) => item.id === player.id);
    if (existing) {
      Object.assign(existing, {
        socketId: player.socketId,
        connectionStatus: "connected",
      });
      return { room, joined: false };
    }
    if (room.players.length >= room.maxPlayers) throw new Error("Room is full");
    player.seatIndex = this._firstEmptySeat(room);
    room.players.push(player);
    this._updateStatus(room);
    this.chatService?.addSystemMessage(
      room.roomCode,
      `${player.username} joined the room.`,
    );
    return { room, joined: true };
  }

  leaveRoom(roomCode, playerId) {
    const room = this.getRoom(roomCode);
    if (!room) return { deleted: true, room: null, player: null };
    const player = room.players.find((item) => item.id === playerId);
    room.players = room.players.filter((item) => item.id !== playerId);
    if (player) {
      this.chatService?.addSystemMessage(
        room.roomCode,
        `${player.username} left the room.`,
      );
    }
    const humans = room.players.filter((item) => !item.isBot);
    if (humans.length === 0) {
      this.rooms.delete(room.roomCode);
      return { deleted: true, room: null, player };
    }
    if (player?.isHost) {
      room.players = room.players.map((item) => ({
        ...item,
        isHost: item.id === humans[0].id,
      }));
    }
    this._updateStatus(room);
    return { deleted: false, room, player };
  }

  getRoom(roomCode) {
    return this.rooms.get(String(roomCode || "").trim().toUpperCase()) || null;
  }

  getPublicRooms() {
    return [...this.rooms.values()]
      .filter((room) => !room.isPrivate && room.status !== ROOM_STATUSES.FINISHED)
      .map((room) => this.serializeRoom(room));
  }

  toggleReady(roomCode, playerId) {
    const room = this._requiredRoom(roomCode);
    const player = room.players.find((item) => item.id === playerId);
    if (!player) throw new Error("Player is not in this room");
    if (player.isBot) throw new Error("Bots are always ready");
    player.isReady = !player.isReady;
    this._updateStatus(room);
    return { room, player };
  }

  addBot(roomCode, playerId) {
    const room = this._requiredRoom(roomCode);
    this._assertHost(room, playerId);
    if (!room.allowBots) throw new Error("Bots are disabled for this room");
    if (room.players.length >= room.maxPlayers) throw new Error("Room is full");
    const bot = createBot(
      room.roomCode,
      this._firstEmptySeat(room),
      room.players.filter((item) => item.isBot),
    );
    room.players.push(bot);
    this._updateStatus(room);
    this.chatService?.addSystemMessage(
      room.roomCode,
      `${bot.username} joined the room.`,
    );
    return { room, bot };
  }

  removeBot(roomCode, botId, playerId) {
    const room = this._requiredRoom(roomCode);
    this._assertHost(room, playerId);
    const bot = room.players.find((item) => item.id === botId && item.isBot);
    if (!bot) throw new Error("Bot not found");
    room.players = room.players.filter((item) => item.id !== botId);
    this._updateStatus(room);
    this.chatService?.addSystemMessage(
      room.roomCode,
      `${bot.username} was removed.`,
    );
    return { room, bot };
  }

  canStartGame(roomCode, playerId) {
    const room = this._requiredRoom(roomCode);
    this._assertHost(room, playerId);
    if (room.players.length < 2) {
      throw new Error("At least two players are required");
    }
    const humans = room.players.filter((item) => !item.isBot);
    if (!humans.every((player) => player.isReady)) {
      throw new Error("Waiting for all players to be ready");
    }
    return true;
  }

  startGame(roomCode, playerId) {
    this.canStartGame(roomCode, playerId);
    const room = this._requiredRoom(roomCode);
    room.status = ROOM_STATUSES.PLAYING;
    return room;
  }

  removePlayerFromAllRooms(playerId) {
    const updates = [];
    for (const room of [...this.rooms.values()]) {
      if (room.players.some((player) => player.id === playerId)) {
        updates.push({ roomCode: room.roomCode, ...this.leaveRoom(room.roomCode, playerId) });
      }
    }
    return updates;
  }

  cleanupEmptyRooms() {
    for (const [code, room] of this.rooms.entries()) {
      if (!room.players.some((player) => !player.isBot)) this.rooms.delete(code);
    }
  }

  broadcastRoomUpdate(io, roomCode) {
    const room = this.getRoom(roomCode);
    if (room) io.to(roomCode).emit("room:updated", this.serializeRoom(room));
  }

  serializeRoom(room) {
    return {
      ...room,
      players: room.players.map((player) => ({ ...player })),
      settings: { ...room.settings },
      chatMessages: [...room.chatMessages],
    };
  }

  _requiredRoom(roomCode) {
    const room = this.getRoom(roomCode);
    if (!room) throw new Error("Room not found");
    return room;
  }

  _assertHost(room, playerId) {
    const player = room.players.find((item) => item.id === playerId);
    if (!player?.isHost) throw new Error("Only the host can perform this action");
  }

  _updateStatus(room) {
    if (room.status === ROOM_STATUSES.PLAYING) return;
    const humans = room.players.filter((player) => !player.isBot);
    room.status =
      room.players.length >= 2 &&
      humans.length > 0 &&
      humans.every((player) => player.isReady)
        ? ROOM_STATUSES.READY
        : ROOM_STATUSES.WAITING;
  }

  _firstEmptySeat(room) {
    const occupied = new Set(room.players.map((player) => player.seatIndex));
    for (let index = 0; index < room.maxPlayers; index += 1) {
      if (!occupied.has(index)) return index;
    }
    throw new Error("Room is full");
  }

  _uniqueRoomCode() {
    let code = generateRoomCode();
    while (this.rooms.has(code)) code = generateRoomCode();
    return code;
  }

  _code(roomCode) {
    const validationError = validateRoomCode(roomCode);
    if (validationError) throw new Error(validationError);
    return String(roomCode).trim().toUpperCase();
  }
}

module.exports = { RoomService };
