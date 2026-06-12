const { Server } = require("socket.io");
const { CLIENT_EVENTS, SERVER_EVENTS } = require("./constants/socket_events");
const { createPlayer } = require("./models/player.model");
const { ChatService } = require("./services/chat.service");
const { RoomService } = require("./services/room.service");
const { HighCardService } = require("./games/high-card/high_card.service");
const { WarService } = require("./games/war/war.service");
const logger = require("./utils/logger");
const { failure, success } = require("./utils/response");
const { validateUser } = require("./utils/validators");

const roomService = new RoomService();
const chatService = new ChatService(roomService);
roomService.setChatService(chatService);
const highCardService = new HighCardService(roomService);
const warService = new WarService(roomService);
const disconnectTimers = new Map();

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
        const pendingCleanup = disconnectTimers.get(socket.data.player.id);
        if (pendingCleanup) {
          clearTimeout(pendingCleanup);
          disconnectTimers.delete(socket.data.player.id);
        }
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
        const roomCode = String(payload.roomCode || "")
          .trim()
          .toUpperCase();
        leaveCurrentRoom(io, socket, player.id, roomCode);
        const result = roomService.joinRoom(roomCode, { ...player });
        const restoredGame = highCardService.restorePlayer(
          roomCode,
          result.room.players.find((item) => item.id === player.id),
        );
        const restoredWarGame = warService.restorePlayer(
          roomCode,
          result.room.players.find((item) => item.id === player.id),
        );
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
        if (restoredGame) emitHighCardState(io, restoredGame);
        if (restoredWarGame) emitWarState(io, restoredWarGame);
        emitPublicRooms(io);
        logger.info(`User joined room: ${player.username} -> ${roomCode}`);
        return success({ room: serialized }, "Room joined");
      });
    });

    socket.on(CLIENT_EVENTS.ROOM_LEAVE, (payload = {}, acknowledge) => {
      safely(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = String(
          payload.roomCode || socket.data.roomCode || "",
        ).toUpperCase();
        const result = roomService.leaveRoom(roomCode, player.id);
        const gameResult = highCardService.leaveGame(roomCode, player.id);
        const warResult = warService.leaveGame(roomCode, player.id);
        socket.leave(roomCode);
        socket.data.roomCode = null;
        socket.emit(SERVER_EVENTS.ROOM_LEFT, { roomCode });
        if (!result.deleted) {
          io.to(roomCode).emit(SERVER_EVENTS.PLAYER_LEFT, {
            playerId: player.id,
          });
          roomService.broadcastRoomUpdate(io, roomCode);
          emitLatestChatMessage(io, result.room);
        }
        if (gameResult.game) emitHighCardState(io, gameResult.game);
        if (gameResult.matchOver) emitHighCardMatchOver(io, gameResult.game);
        if (warResult.game) emitWarState(io, warResult.game);
        if (warResult.matchOver) emitWarMatchOver(io, warResult.game);
        if (result.deleted) {
          highCardService.cleanupGame(roomCode);
          warService.cleanupGame(roomCode);
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
        const startPayload = {
          ...serialized,
          screen: gameScreen(room.gameType),
        };
        io.to(roomCode).emit(SERVER_EVENTS.ROOM_GAME_STARTING, startPayload);
        if (room.gameType === "high_card") {
          const game = highCardService.initGame(roomCode);
          emitHighCardState(io, game);
        } else if (room.gameType === "war") {
          const game = warService.initGame(roomCode);
          emitWarState(io, game);
        }
        roomService.broadcastRoomUpdate(io, roomCode);
        emitPublicRooms(io);
        logger.info(`Room started: ${roomCode}`);
        return success({ room: serialized }, "Game starting");
      });
    });

    socket.on(CLIENT_EVENTS.HIGH_CARD_INIT, (payload = {}, acknowledge) => {
      safelyHighCard(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const joined = roomService.joinRoom(roomCode, { ...player });
        socket.join(roomCode);
        socket.data.roomCode = roomCode;
        highCardService.restorePlayer(
          roomCode,
          joined.room.players.find((item) => item.id === player.id),
        );
        const game =
          highCardService.getGame(roomCode) ??
          highCardService.initGame(roomCode);
        const state = highCardService.getClientState(roomCode, player.id);
        socket.emit(SERVER_EVENTS.HIGH_CARD_STATE, state);
        return success({ game: state }, "High Card game loaded");
      });
    });

    socket.on(CLIENT_EVENTS.HIGH_CARD_DRAW, (payload = {}, acknowledge) => {
      safelyHighCard(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const result = highCardService.drawCards(roomCode, player.id);
        const state = highCardService.sanitize(result.game);
        io.to(roomCode).emit(
          SERVER_EVENTS.HIGH_CARD_ROUND_RESULT,
          result.result,
        );
        io.to(roomCode).emit(SERVER_EVENTS.HIGH_CARD_STATE, state);
        if (result.matchOver) {
          io.to(roomCode).emit(SERVER_EVENTS.HIGH_CARD_MATCH_OVER, state);
        }
        return success({ game: state }, "Cards drawn");
      });
    });

    socket.on(
      CLIENT_EVENTS.HIGH_CARD_NEXT_ROUND,
      (payload = {}, acknowledge) => {
        safelyHighCard(socket, acknowledge, () => {
          const player = requiredPlayer(socket);
          const roomCode = currentRoomCode(socket, payload);
          const game = highCardService.nextRound(roomCode, player.id);
          const state = highCardService.sanitize(game);
          io.to(roomCode).emit(SERVER_EVENTS.HIGH_CARD_STATE, state);
          return success({ game: state }, "Next round started");
        });
      },
    );

    socket.on(
      CLIENT_EVENTS.HIGH_CARD_REMATCH_REQUEST,
      (payload = {}, acknowledge) => {
        handleRematch(socket, acknowledge, payload);
      },
    );

    socket.on(
      CLIENT_EVENTS.HIGH_CARD_REMATCH_ACCEPT,
      (payload = {}, acknowledge) => {
        handleRematch(socket, acknowledge, payload);
      },
    );

    socket.on(
      CLIENT_EVENTS.HIGH_CARD_LEAVE_GAME,
      (payload = {}, acknowledge) => {
        safelyHighCard(socket, acknowledge, () => {
          const player = requiredPlayer(socket);
          const roomCode = currentRoomCode(socket, payload);
          const result = highCardService.leaveGame(roomCode, player.id);
          if (result.game) emitHighCardState(io, result.game);
          if (result.matchOver) emitHighCardMatchOver(io, result.game);
          return success(
            {
              game: result.game ? highCardService.sanitize(result.game) : null,
            },
            "High Card game left",
          );
        });
      },
    );

    socket.on(CLIENT_EVENTS.WAR_INIT, (payload = {}, acknowledge) => {
      safelyWar(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const joined = roomService.joinRoom(roomCode, { ...player });
        socket.join(roomCode);
        socket.data.roomCode = roomCode;
        warService.restorePlayer(
          roomCode,
          joined.room.players.find((item) => item.id === player.id),
        );
        warService.getGame(roomCode) ?? warService.initGame(roomCode);
        const state = warService.getClientState(roomCode, player.id);
        socket.emit(SERVER_EVENTS.WAR_STATE, state);
        return success({ game: state }, "War game loaded");
      });
    });

    socket.on(CLIENT_EVENTS.WAR_BATTLE, (payload = {}, acknowledge) => {
      safelyWar(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const result = warService.playBattle(roomCode, player.id);
        const state = warService.sanitize(result.game);
        if (result.warStarted) {
          io.to(roomCode).emit(SERVER_EVENTS.WAR_STARTED, {
            battleNumber: result.result.battleNumber,
            tiedPlayerIds: Object.keys(result.result.warCards),
            warCards: result.result.warCards,
            pileCount: result.result.pileCount,
          });
        }
        io.to(roomCode).emit(SERVER_EVENTS.WAR_BATTLE_RESULT, result.result);
        io.to(roomCode).emit(SERVER_EVENTS.WAR_STATE, state);
        if (result.matchOver) {
          io.to(roomCode).emit(SERVER_EVENTS.WAR_MATCH_OVER, state);
        }
        return success({ game: state }, "Battle resolved");
      });
    });

    socket.on(CLIENT_EVENTS.WAR_NEXT_BATTLE, (payload = {}, acknowledge) => {
      safelyWar(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const game = warService.nextBattle(roomCode, player.id);
        const state = warService.sanitize(game);
        io.to(roomCode).emit(SERVER_EVENTS.WAR_STATE, state);
        return success({ game: state }, "Next battle started");
      });
    });

    socket.on(
      CLIENT_EVENTS.WAR_REMATCH_REQUEST,
      (payload = {}, acknowledge) => {
        handleWarRematch(socket, acknowledge, payload);
      },
    );

    socket.on(CLIENT_EVENTS.WAR_REMATCH_ACCEPT, (payload = {}, acknowledge) => {
      handleWarRematch(socket, acknowledge, payload);
    });

    socket.on(CLIENT_EVENTS.WAR_LEAVE_GAME, (payload = {}, acknowledge) => {
      safelyWar(socket, acknowledge, () => {
        const player = requiredPlayer(socket);
        const roomCode = currentRoomCode(socket, payload);
        const result = warService.leaveGame(roomCode, player.id);
        if (result.game) emitWarState(io, result.game);
        if (result.matchOver) emitWarMatchOver(io, result.game);
        return success(
          { game: result.game ? warService.sanitize(result.game) : null },
          "War game left",
        );
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
      const rooms = roomService.markPlayerDisconnected(player.id);
      const games = highCardService.markDisconnected(player.id);
      const warGames = warService.markDisconnected(player.id);
      for (const room of rooms) {
        roomService.broadcastRoomUpdate(io, room.roomCode);
      }
      for (const game of games) emitHighCardState(io, game);
      for (const game of warGames) emitWarState(io, game);
      emitPublicRooms(io);
      const timer = setTimeout(() => {
        disconnectTimers.delete(player.id);
        const updates = roomService.removePlayerFromAllRooms(player.id);
        for (const update of updates) {
          const gameResult = highCardService.leaveGame(
            update.roomCode,
            player.id,
          );
          const warResult = warService.leaveGame(update.roomCode, player.id);
          if (!update.deleted) {
            io.to(update.roomCode).emit(SERVER_EVENTS.PLAYER_LEFT, {
              playerId: player.id,
            });
            roomService.broadcastRoomUpdate(io, update.roomCode);
            emitLatestChatMessage(io, update.room);
          } else {
            highCardService.cleanupGame(update.roomCode);
            warService.cleanupGame(update.roomCode);
          }
          if (gameResult.game) emitHighCardState(io, gameResult.game);
          if (gameResult.matchOver) {
            emitHighCardMatchOver(io, gameResult.game);
          }
          if (warResult.game) emitWarState(io, warResult.game);
          if (warResult.matchOver) emitWarMatchOver(io, warResult.game);
        }
        roomService.cleanupEmptyRooms();
        emitPublicRooms(io);
      }, 30000);
      timer.unref?.();
      disconnectTimers.set(player.id, timer);
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

function safelyHighCard(socket, acknowledge, action) {
  try {
    const result = action();
    acknowledge?.(result);
  } catch (error) {
    const response = failure(error.message);
    socket.emit(SERVER_EVENTS.HIGH_CARD_ERROR, response);
    acknowledge?.(response);
  }
}

function safelyWar(socket, acknowledge, action) {
  try {
    const result = action();
    acknowledge?.(result);
  } catch (error) {
    const response = failure(error.message);
    socket.emit(SERVER_EVENTS.WAR_ERROR, response);
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
  const highCardResult = highCardService.leaveGame(current, playerId);
  const warResult = warService.leaveGame(current, playerId);
  socket.leave(current);
  if (!result.deleted) {
    roomService.broadcastRoomUpdate(io, current);
    emitLatestChatMessage(io, result.room);
  }
  if (highCardResult.game) emitHighCardState(io, highCardResult.game);
  if (highCardResult.matchOver) {
    emitHighCardMatchOver(io, highCardResult.game);
  }
  if (warResult.game) emitWarState(io, warResult.game);
  if (warResult.matchOver) emitWarMatchOver(io, warResult.game);
  if (result.deleted) {
    highCardService.cleanupGame(current);
    warService.cleanupGame(current);
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

function emitHighCardState(io, game) {
  if (!game) return;
  io.to(game.roomCode).emit(
    SERVER_EVENTS.HIGH_CARD_STATE,
    highCardService.sanitize(game),
  );
}

function emitHighCardMatchOver(io, game) {
  if (!game) return;
  io.to(game.roomCode).emit(
    SERVER_EVENTS.HIGH_CARD_MATCH_OVER,
    highCardService.sanitize(game),
  );
}

function emitWarState(io, game) {
  if (!game) return;
  io.to(game.roomCode).emit(SERVER_EVENTS.WAR_STATE, warService.sanitize(game));
}

function emitWarMatchOver(io, game) {
  if (!game) return;
  io.to(game.roomCode).emit(
    SERVER_EVENTS.WAR_MATCH_OVER,
    warService.sanitize(game),
  );
}

function handleRematch(socket, acknowledge, payload) {
  safelyHighCard(socket, acknowledge, () => {
    const player = requiredPlayer(socket);
    const roomCode = currentRoomCode(socket, payload);
    const result = highCardService.requestRematch(roomCode, player.id);
    const state = highCardService.sanitize(result.game);
    if (result.started) {
      ioForSocket(socket)
        .to(roomCode)
        .emit(SERVER_EVENTS.HIGH_CARD_REMATCH_STARTED, state);
      ioForSocket(socket)
        .to(roomCode)
        .emit(SERVER_EVENTS.HIGH_CARD_STATE, state);
    } else {
      ioForSocket(socket)
        .to(roomCode)
        .emit(SERVER_EVENTS.HIGH_CARD_REMATCH_REQUESTED, {
          playerId: result.player.id,
          username: result.player.username,
          rematchRequests: state.rematchRequests,
        });
      ioForSocket(socket)
        .to(roomCode)
        .emit(SERVER_EVENTS.HIGH_CARD_STATE, state);
    }
    return success({ game: state }, "Rematch request updated");
  });
}

function handleWarRematch(socket, acknowledge, payload) {
  safelyWar(socket, acknowledge, () => {
    const player = requiredPlayer(socket);
    const roomCode = currentRoomCode(socket, payload);
    const result = warService.requestRematch(roomCode, player.id);
    const state = warService.sanitize(result.game);
    if (result.started) {
      ioForSocket(socket)
        .to(roomCode)
        .emit(SERVER_EVENTS.WAR_REMATCH_STARTED, state);
      ioForSocket(socket).to(roomCode).emit(SERVER_EVENTS.WAR_STATE, state);
    } else {
      ioForSocket(socket)
        .to(roomCode)
        .emit(SERVER_EVENTS.WAR_REMATCH_REQUESTED, {
          playerId: result.player.id,
          username: result.player.username,
          rematchRequests: state.rematchRequests,
        });
      ioForSocket(socket).to(roomCode).emit(SERVER_EVENTS.WAR_STATE, state);
    }
    return success({ game: state }, "Rematch request updated");
  });
}

function gameScreen(gameType) {
  if (gameType === "high_card") return "high_card_multiplayer";
  if (gameType === "war") return "war_multiplayer";
  return "multiplayer_placeholder";
}

function ioForSocket(socket) {
  return socket.nsp;
}

module.exports = {
  createSocketServer,
  roomService,
  chatService,
  highCardService,
  warService,
};
