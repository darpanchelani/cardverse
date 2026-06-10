const { Server } = require("socket.io");
const {
  CLIENT_EVENTS,
  SERVER_EVENTS,
} = require("./constants/socket_events");
const { createPlayer } = require("./models/player.model");
const { ChatService } = require("./services/chat.service");
const { RoomService } = require("./services/room.service");
const logger = require("./utils/logger");
const { failure, success } = require("./utils/response");
const { validateUser } = require("./utils/validators");

const roomService = new RoomService();
const chatService = new ChatService(roomService);
roomService.setChatService(chatService);

function createSocketServer(httpServer) {
  const io = new Server(httpServer, {
    cors: { origin: true, methods: ["GET", "POST"], credentials: true },
  });

  io.on("connection", (socket) => {
    logger.info(`Socket connected: ${socket.id}`);

    socket.on(CLIENT_EVENTS.USER_CONNECT, (payload = {}, acknowledge) => {
      safely(socket, acknowledge, () => {
        const validationError = validateUser(payload);
        if (validationError) throw new Error(validationError);
        socket.data.player = createPlayer(payload, socket.id);
        const response = success(
          { socketId: socket.id, player: socket.data.player },
          "Connected to CardVerse",
        );
        socket.emit(SERVER_EVENTS.CONNECTION_SUCCESS, response);
        logger.info(`User connected: ${socket.data.player.username}`);
        return response;
      });
    });

    socket.on(CLIENT_EVENTS.ROOM_CREATE, (payload = {}, acknowledge) => {
      safely(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        leaveCurrentRoom(io, socket, player.id);
        const room = roomService.createRoom(payload, player);
        socket.join(room.roomCode);
        socket.data.roomCode = room.roomCode;
        const serialized = roomService.serializeRoom(room);
        socket.emit(SERVER_EVENTS.ROOM_CREATED, serialized);
        socket.emit(SERVER_EVENTS.CHAT_HISTORY, room.chatMessages);
        emitPublicRooms(io);
        logger.info(`Room created: ${room.roomCode}`);
        return success({ room: serialized }, "Room created");
      });
    });

    socket.on(CLIENT_EVENTS.ROOM_JOIN, (payload = {}, acknowledge) => {
      safely(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = String(payload.roomCode || "").trim().toUpperCase();
        leaveCurrentRoom(io, socket, player.id, roomCode);
        const result = roomService.joinRoom(roomCode, { ...player });
        socket.join(roomCode);
        socket.data.roomCode = roomCode;
        const serialized = roomService.serializeRoom(result.room);
        socket.emit(SERVER_EVENTS.ROOM_JOINED, serialized);
        socket.emit(
          SERVER_EVENTS.CHAT_HISTORY,
          chatService.getMessages(roomCode),
        );
        if (result.joined) {
          socket.to(roomCode).emit(SERVER_EVENTS.PLAYER_JOINED, {
            player: result.room.players.find((item) => item.id === player.id),
          });
          const joinMessage = result.room.chatMessages.at(-1);
          if (joinMessage) {
            socket.to(roomCode).emit(SERVER_EVENTS.CHAT_MESSAGE, joinMessage);
          }
        }
        roomService.broadcastRoomUpdate(io, roomCode);
        emitPublicRooms(io);
        logger.info(`User joined room: ${player.username} -> ${roomCode}`);
        return success({ room: serialized }, "Room joined");
      });
    });

    socket.on(CLIENT_EVENTS.ROOM_LEAVE, (payload = {}, acknowledge) => {
      safely(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode =
          String(payload.roomCode || socket.data.roomCode || "").toUpperCase();
        const result = roomService.leaveRoom(roomCode, player.id);
        socket.leave(roomCode);
        socket.data.roomCode = null;
        socket.emit(SERVER_EVENTS.ROOM_LEFT, { roomCode });
        if (!result.deleted) {
          io.to(roomCode).emit(SERVER_EVENTS.PLAYER_LEFT, { playerId: player.id });
          roomService.broadcastRoomUpdate(io, roomCode);
          emitLatestChatMessage(io, result.room);
        }
        emitPublicRooms(io);
        logger.info(`User left room: ${player.username} -> ${roomCode}`);
        return success(
          { room: result.room ? roomService.serializeRoom(result.room) : null },
          "Room left",
        );
      });
    });

    socket.on(CLIENT_EVENTS.ROOM_GET_PUBLIC, (_payload, acknowledge) => {
      const rooms = roomService.getPublicRooms();
      socket.emit(SERVER_EVENTS.ROOM_PUBLIC_LIST, rooms);
      acknowledge?.(success({ rooms }, "Public rooms loaded"));
    });

    socket.on(CLIENT_EVENTS.ROOM_TOGGLE_READY, (payload = {}, acknowledge) => {
      safely(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const result = roomService.toggleReady(roomCode, player.id);
        io.to(roomCode).emit(SERVER_EVENTS.PLAYER_READY_CHANGED, {
          playerId: result.player.id,
          isReady: result.player.isReady,
        });
        roomService.broadcastRoomUpdate(io, roomCode);
        emitPublicRooms(io);
        return success(
          { room: roomService.serializeRoom(result.room) },
          "Ready status updated",
        );
      });
    });

    socket.on(CLIENT_EVENTS.ROOM_ADD_BOT, (payload = {}, acknowledge) => {
      safely(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const result = roomService.addBot(roomCode, player.id);
        roomService.broadcastRoomUpdate(io, roomCode);
        emitLatestChatMessage(io, result.room);
        emitPublicRooms(io);
        return success(
          { room: roomService.serializeRoom(result.room), bot: result.bot },
          "Bot added",
        );
      });
    });

    socket.on(CLIENT_EVENTS.ROOM_REMOVE_BOT, (payload = {}, acknowledge) => {
      safely(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const result = roomService.removeBot(
          roomCode,
          payload.botId,
          player.id,
        );
        roomService.broadcastRoomUpdate(io, roomCode);
        emitLatestChatMessage(io, result.room);
        emitPublicRooms(io);
        return success(
          { room: roomService.serializeRoom(result.room) },
          "Bot removed",
        );
      });
    });

    socket.on(CLIENT_EVENTS.ROOM_START_GAME, (payload = {}, acknowledge) => {
      safely(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const room = roomService.startGame(roomCode, player.id);
        const serialized = roomService.serializeRoom(room);
        io.to(roomCode).emit(SERVER_EVENTS.ROOM_GAME_STARTING, serialized);
        roomService.broadcastRoomUpdate(io, roomCode);
        emitPublicRooms(io);
        logger.info(`Room started: ${roomCode}`);
        return success({ room: serialized }, "Game starting");
      });
    });

    socket.on(CLIENT_EVENTS.CHAT_SEND, (payload = {}, acknowledge) => {
      safely(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const room = roomService.getRoom(roomCode);
        if (!room?.allowChat) throw new Error("Chat is disabled");
        const message = chatService.addMessage(
          roomCode,
          player,
          payload.message,
        );
        io.to(roomCode).emit(SERVER_EVENTS.CHAT_MESSAGE, message);
        logger.info(`Chat message sent in room: ${roomCode}`);
        return success({ chatMessage: message }, "Message sent");
      });
    });

    socket.on(CLIENT_EVENTS.TYPING_START, (payload = {}) => {
      emitTyping(socket, payload, true);
    });

    socket.on(CLIENT_EVENTS.TYPING_STOP, (payload = {}) => {
      emitTyping(socket, payload, false);
    });

    socket.on("disconnect", () => {
      const player = socket.data.player;
      if (!player) return;
      const updates = roomService.removePlayerFromAllRooms(player.id);
      for (const update of updates) {
        if (!update.deleted) {
          io.to(update.roomCode).emit(SERVER_EVENTS.PLAYER_LEFT, {
            playerId: player.id,
          });
          roomService.broadcastRoomUpdate(io, update.roomCode);
          emitLatestChatMessage(io, update.room);
        }
      }
      roomService.cleanupEmptyRooms();
      emitPublicRooms(io);
      logger.info(`User disconnected: ${player.username}`);
    });
  });

  return io;
}

function safely(socket, acknowledge, action) {
  try {
    const result = action();
    acknowledge?.(result);
  } catch (error) {
    const response = failure(error.message);
    socket.emit(SERVER_EVENTS.ROOM_ERROR, response);
    socket.emit(SERVER_EVENTS.ERROR_MESSAGE, response);
    acknowledge?.(response);
  }
}

function requiredPlayer(socket) {
  if (!socket.data.player) throw new Error("Connect the user first");
  return socket.data.player;
}

function currentRoomCode(socket, payload) {
  const roomCode = String(
    payload.roomCode || socket.data.roomCode || "",
  ).toUpperCase();
  if (!roomCode) throw new Error("Room code is required");
  return roomCode;
}

function leaveCurrentRoom(io, socket, playerId, nextRoomCode = null) {
  const current = socket.data.roomCode;
  if (!current || current === nextRoomCode) return;
  const result = roomService.leaveRoom(current, playerId);
  socket.leave(current);
  if (!result.deleted) {
    roomService.broadcastRoomUpdate(io, current);
    emitLatestChatMessage(io, result.room);
  }
}

function emitLatestChatMessage(io, room) {
  const message = room?.chatMessages.at(-1);
  if (message) io.to(room.roomCode).emit(SERVER_EVENTS.CHAT_MESSAGE, message);
}

function emitPublicRooms(io) {
  io.emit(SERVER_EVENTS.ROOM_PUBLIC_LIST, roomService.getPublicRooms());
}

function emitTyping(socket, payload, isTyping) {
  const player = socket.data.player;
  const roomCode = payload.roomCode || socket.data.roomCode;
  if (!player || !roomCode) return;
  socket.to(roomCode).emit(SERVER_EVENTS.TYPING_UPDATE, {
    userId: player.id,
    username: player.username,
    isTyping,
  });
}

module.exports = {
  createSocketServer,
  roomService,
  chatService,
};
