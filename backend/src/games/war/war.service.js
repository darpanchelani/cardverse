const {
  calculateMatchWinner,
  createInitialWarGameState,
  resetWarForRematch,
  resolveBattle,
  sanitizeWarGameStateForClient,
  updateCardCounts,
} = require("./war.engine");

class WarService {
  constructor(roomService) {
    this.roomService = roomService;
    this.activeWarGames = new Map();
  }

  initGame(roomCode) {
    const existing = this.getGame(roomCode);
    if (existing) return existing;
    const room = this._room(roomCode);
    if (room.gameType !== "war") throw new Error("This room is not a War room");
    if (room.status !== "playing") throw new Error("War game has not started");
    const game = createInitialWarGameState(
      room,
      room.settings?.maxBattles ?? 50,
    );
    this.activeWarGames.set(room.roomCode, game);
    return game;
  }

  getGame(roomCode) {
    return (
      this.activeWarGames.get(
        String(roomCode || "")
          .trim()
          .toUpperCase(),
      ) || null
    );
  }

  getClientState(roomCode, playerId) {
    const game = this._game(roomCode);
    this._player(game, playerId);
    return this.sanitize(game);
  }

  playBattle(roomCode, playerId) {
    const game = this._game(roomCode);
    this._activePlayer(game, playerId);
    if (game.status === "battle_over")
      throw new Error("Battle already resolved");
    if (game.status === "match_over") throw new Error("Match already over");
    if (game.status !== "playing") throw new Error("Game is not ready");
    if (Object.keys(game.currentBattleCards).length) {
      throw new Error("Battle already resolved");
    }

    const { result, warStarted } = resolveBattle(game);
    const matchOver = this._finishIfNeeded(game);
    return { game, result, warStarted, matchOver };
  }

  nextBattle(roomCode, playerId) {
    const game = this._game(roomCode);
    this._activePlayer(game, playerId);
    if (game.status === "match_over") throw new Error("Match already over");
    if (game.status !== "battle_over") {
      throw new Error("Battle is not complete");
    }
    game.currentBattle += 1;
    game.currentBattleCards = {};
    game.battlePile = [];
    game.warCards = {};
    game.battleResult = null;
    game.status = "playing";
    game.updatedAt = new Date().toISOString();
    return game;
  }

  requestRematch(roomCode, playerId) {
    const game = this._game(roomCode);
    const player = this._activePlayer(game, playerId);
    if (game.status !== "match_over") {
      throw new Error("Rematch is only available after the match");
    }
    if (game.players.length < 2) {
      throw new Error("At least two players are required for a rematch");
    }
    if (!game.rematchRequests.includes(player.id)) {
      game.rematchRequests.push(player.id);
    }
    game.updatedAt = new Date().toISOString();
    const humans = game.players.filter((item) => !item.isBot);
    const accepted = humans.every((item) =>
      game.rematchRequests.includes(item.id),
    );
    if (!accepted) return { game, started: false, player };

    const reset = resetWarForRematch(game);
    this.activeWarGames.set(game.roomCode, reset);
    return { game: reset, started: true, player };
  }

  acceptRematch(roomCode, playerId) {
    return this.requestRematch(roomCode, playerId);
  }

  leaveGame(roomCode, playerId) {
    const game = this.getGame(roomCode);
    if (!game) return { game: null, matchOver: false };
    const player = game.players.find((item) => item.id === playerId);
    if (!player) return { game, matchOver: game.status === "match_over" };
    game.players = game.players.filter((item) => item.id !== playerId);
    delete game.playerDecks[playerId];
    delete game.currentBattleCards[playerId];
    delete game.warCards[playerId];
    delete game.scores[playerId];
    delete game.cardCounts[playerId];
    game.rematchRequests = game.rematchRequests.filter(
      (item) => item !== playerId,
    );
    game.updatedAt = new Date().toISOString();
    const matchOver = this._finishIfNeeded(game, true);
    return { game, matchOver };
  }

  restorePlayer(roomCode, roomPlayer) {
    const game = this.getGame(roomCode);
    if (!game || !roomPlayer) return null;
    const existing = game.players.find((item) => item.id === roomPlayer.id);
    if (existing) {
      Object.assign(existing, {
        socketId: roomPlayer.socketId,
        connectionStatus: "connected",
      });
    }
    return game;
  }

  markDisconnected(playerId) {
    const updated = [];
    for (const game of this.activeWarGames.values()) {
      const player = game.players.find((item) => item.id === playerId);
      if (!player) continue;
      player.connectionStatus = "disconnected";
      player.socketId = null;
      game.updatedAt = new Date().toISOString();
      updated.push(game);
    }
    return updated;
  }

  cleanupGame(roomCode) {
    this.activeWarGames.delete(
      String(roomCode || "")
        .trim()
        .toUpperCase(),
    );
  }

  sanitize(game) {
    return sanitizeWarGameStateForClient(game);
  }

  _finishIfNeeded(game, playerLeft = false) {
    updateCardCounts(game);
    const active = game.players.filter(
      (player) => (game.playerDecks[player.id]?.length || 0) > 0,
    );
    const humans = game.players.filter((player) => !player.isBot);
    const reachedLimit =
      game.maxBattles !== null && game.currentBattle >= game.maxBattles;
    if (active.length > 1 && humans.length > 0 && !reachedLimit) return false;

    game.status = "match_over";
    game.matchWinner = calculateMatchWinner(game);
    if (playerLeft && active.length === 1) {
      game.matchWinner.message = `${active[0].username} won because the other player left.`;
    }
    game.updatedAt = new Date().toISOString();
    return true;
  }

  _room(roomCode) {
    const room = this.roomService.getRoom(roomCode);
    if (!room) throw new Error("Room not found");
    return room;
  }

  _game(roomCode) {
    const game = this.getGame(roomCode);
    if (!game) throw new Error("War game not found");
    return game;
  }

  _player(game, playerId) {
    const player = game.players.find((item) => item.id === playerId);
    if (!player) throw new Error("Player is not in this game");
    return player;
  }

  _activePlayer(game, playerId) {
    const player = this._player(game, playerId);
    if (!player.isBot && player.connectionStatus === "disconnected") {
      throw new Error("Player is disconnected");
    }
    return player;
  }
}

module.exports = { WarService };
