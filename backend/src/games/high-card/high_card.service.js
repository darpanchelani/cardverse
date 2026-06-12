const {
  calculateMatchWinner,
  createDeck,
  createInitialGameState,
  drawCard,
  resetForRematch,
  sanitizeGameStateForClient,
  shuffleDeck,
} = require("./high_card.engine");

class HighCardService {
  constructor(roomService) {
    this.roomService = roomService;
    this.activeHighCardGames = new Map();
  }

  initGame(roomCode) {
    const existing = this.getGame(roomCode);
    if (existing) return existing;
    const room = this._room(roomCode);
    if (room.gameType !== "high_card") {
      throw new Error("This room is not a High Card room");
    }
    if (room.status !== "playing") {
      throw new Error("High Card game has not started");
    }
    const game = createInitialGameState(
      room,
      room.settings?.maxRounds ?? room.settings?.roundsLimit ?? 5,
    );
    this.activeHighCardGames.set(room.roomCode, game);
    return game;
  }

  getGame(roomCode) {
    return (
      this.activeHighCardGames.get(
        String(roomCode || "")
          .trim()
          .toUpperCase(),
      ) || null
    );
  }

  getClientState(roomCode, playerId) {
    const game = this._game(roomCode);
    this._player(game, playerId);
    return sanitizeGameStateForClient(game);
  }

  drawCards(roomCode, playerId) {
    const game = this._game(roomCode);
    this._activePlayer(game, playerId);
    if (game.status === "round_over") throw new Error("Round already resolved");
    if (game.status === "match_over") throw new Error("Match already over");
    if (game.status !== "playing") throw new Error("Game is not ready");
    if (Object.keys(game.currentCards).length) {
      throw new Error("Round already resolved");
    }
    if (game.deck.length < game.players.length) {
      game.deck = shuffleDeck(createDeck());
    }

    const cards = {};
    for (const player of game.players) {
      cards[player.id] = drawCard(game.deck);
    }
    const highestValue = Math.max(
      ...Object.values(cards).map((card) => card.value),
    );
    const leaders = game.players.filter(
      (player) => cards[player.id].value === highestValue,
    );
    const winner = leaders.length === 1 ? leaders[0] : null;
    if (winner) game.scores[winner.id] = (game.scores[winner.id] || 0) + 1;

    const result = {
      roundNumber: game.currentRound,
      winnerId: winner?.id ?? null,
      winnerName: winner?.username ?? null,
      result: winner ? "player_win" : "draw",
      message: winner
        ? `${winner.username} wins Round ${game.currentRound}!`
        : "Round draw!",
      cards,
      playerCards: cards,
      createdAt: new Date().toISOString(),
    };
    game.currentCards = cards;
    game.roundResult = result;
    game.roundHistory.push(result);
    game.updatedAt = new Date().toISOString();

    let matchOver = false;
    if (game.currentRound >= game.maxRounds) {
      game.status = "match_over";
      game.matchWinner = calculateMatchWinner(game);
      matchOver = true;
    } else {
      game.status = "round_over";
    }
    return { game, result, matchOver };
  }

  nextRound(roomCode, playerId) {
    const game = this._game(roomCode);
    this._activePlayer(game, playerId);
    if (game.status === "match_over") throw new Error("Match already over");
    if (game.status !== "round_over") {
      throw new Error("Round is not complete");
    }
    game.currentRound += 1;
    game.currentCards = {};
    game.roundResult = null;
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
    if (!game.rematchRequests.includes(player.id)) {
      game.rematchRequests.push(player.id);
    }
    game.updatedAt = new Date().toISOString();
    const humans = game.players.filter((item) => !item.isBot);
    const accepted = humans.every((item) =>
      game.rematchRequests.includes(item.id),
    );
    if (!accepted) return { game, started: false, player };

    const reset = resetForRematch(game);
    this.activeHighCardGames.set(game.roomCode, reset);
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
    delete game.currentCards[playerId];
    delete game.scores[playerId];
    game.rematchRequests = game.rematchRequests.filter(
      (item) => item !== playerId,
    );
    game.updatedAt = new Date().toISOString();

    const humans = game.players.filter((item) => !item.isBot);
    if (game.players.length < 2 || humans.length === 0) {
      game.status = "match_over";
      const remaining = game.players[0] || null;
      game.matchWinner = {
        winnerId: remaining?.id ?? null,
        winnerName: remaining?.username ?? null,
        message: remaining
          ? `${remaining.username} won because the other player left.`
          : "Match ended.",
      };
      return { game, matchOver: true };
    }
    return { game, matchOver: game.status === "match_over" };
  }

  restorePlayer(roomCode, roomPlayer) {
    const game = this.getGame(roomCode);
    if (!game) return null;
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
    for (const game of this.activeHighCardGames.values()) {
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
    this.activeHighCardGames.delete(
      String(roomCode || "")
        .trim()
        .toUpperCase(),
    );
  }

  sanitize(game) {
    return sanitizeGameStateForClient(game);
  }

  _room(roomCode) {
    const room = this.roomService.getRoom(roomCode);
    if (!room) throw new Error("Room not found");
    return room;
  }

  _game(roomCode) {
    const game = this.getGame(roomCode);
    if (!game) throw new Error("High Card game not found");
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

module.exports = { HighCardService };
