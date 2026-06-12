const {
  activePlayers,
  calculateHandValue,
  calculateMatchResults,
  calculateRoundResult,
  createInitialBlackjackGameState,
  dealInitialCards,
  drawCard,
  ensureDeck,
  isBust,
  isBlackjack,
  resetForRematch,
  resetRound,
  sanitizeBlackjackGameStateForClient,
  shouldDealerHit,
} = require("./blackjack.engine");

class BlackjackService {
  constructor(roomService) {
    this.roomService = roomService;
    this.activeBlackjackGames = new Map();
  }

  initGame(roomCode) {
    const existing = this.getGame(roomCode);
    if (existing) return existing;
    const room = this._room(roomCode);
    if (room.gameType !== "blackjack") {
      throw new Error("This room is not a Blackjack room");
    }
    if (room.status !== "playing") {
      throw new Error("Blackjack game has not started");
    }
    const game = createInitialBlackjackGameState(
      room,
      room.settings?.maxRounds ?? 5,
    );
    this.activeBlackjackGames.set(room.roomCode, game);
    return game;
  }

  getGame(roomCode) {
    return (
      this.activeBlackjackGames.get(
        String(roomCode || "").trim().toUpperCase(),
      ) || null
    );
  }

  getClientState(roomCode, playerId) {
    const game = this._game(roomCode);
    this._player(game, playerId);
    return this.sanitize(game);
  }

  placeBet(roomCode, playerId, amount) {
    const game = this._game(roomCode);
    const player = this._activePlayer(game, playerId);
    if (game.status !== "betting") {
      throw new Error("Bets can only be changed before a round");
    }
    const bet = Number(amount);
    if (!Number.isInteger(bet) || bet < game.minimumBet) {
      throw new Error(`Minimum bet is ${game.minimumBet}`);
    }
    if (bet > game.playerChips[player.id]) {
      throw new Error("Bet cannot exceed available chips");
    }
    game.playerBets[player.id] = bet;
    game.playerStatuses[player.id] = "betting";
    game.updatedAt = new Date().toISOString();
    return game;
  }

  startRound(roomCode, playerId) {
    const game = this._game(roomCode);
    const player = this._activePlayer(game, playerId);
    if (!player.isHost) throw new Error("Only the host can start the round");
    if (game.status !== "betting") throw new Error("Round already active");
    const active = activePlayers(game);
    if (active.length < 2) throw new Error("At least two players are required");
    for (const item of active) {
      const bet = game.playerBets[item.id];
      if (
        !Number.isInteger(bet) ||
        bet < game.minimumBet ||
        bet > game.playerChips[item.id]
      ) {
        throw new Error(`${item.username} must place a valid bet`);
      }
    }
    dealInitialCards(game);
    if (isBlackjack(game.dealer.hand)) {
      for (const item of active) {
        if (game.playerStatuses[item.id] === "playing") {
          game.playerStatuses[item.id] = "standing";
        }
      }
    }
    this._playBots(game);
    const finished = this._finishIfPlayersDone(game);
    return { game, finished };
  }

  hit(roomCode, playerId) {
    const game = this._game(roomCode);
    const player = this._activePlayer(game, playerId);
    if (game.status !== "playing") throw new Error("Round is not active");
    if (game.playerStatuses[player.id] !== "playing") {
      throw new Error("Player cannot hit now");
    }
    ensureDeck(game);
    game.playerHands[player.id].push(drawCard(game.deck));
    const score = calculateHandValue(game.playerHands[player.id]);
    if (isBust(game.playerHands[player.id])) {
      game.playerStatuses[player.id] = "bust";
    } else if (score === 21) {
      game.playerStatuses[player.id] = "standing";
    }
    game.updatedAt = new Date().toISOString();
    this._playBots(game);
    const finished = this._finishIfPlayersDone(game);
    return {
      game,
      action: {
        playerId,
        username: player.username,
        action: "hit",
        score,
        status: game.playerStatuses[player.id],
      },
      finished,
    };
  }

  stand(roomCode, playerId) {
    const game = this._game(roomCode);
    const player = this._activePlayer(game, playerId);
    if (game.status !== "playing") throw new Error("Round is not active");
    if (game.playerStatuses[player.id] !== "playing") {
      throw new Error("Player cannot stand now");
    }
    game.playerStatuses[player.id] = "standing";
    game.updatedAt = new Date().toISOString();
    this._playBots(game);
    const finished = this._finishIfPlayersDone(game);
    return {
      game,
      action: {
        playerId,
        username: player.username,
        action: "stand",
        score: calculateHandValue(game.playerHands[player.id]),
        status: "standing",
      },
      finished,
    };
  }

  dealerPlay(roomCode) {
    const game = this._game(roomCode);
    game.status = "dealer_turn";
    game.dealer.isHidden = false;
    ensureDeck(game);
    while (shouldDealerHit(game.dealer.hand, game.dealerRule)) {
      game.dealer.hand.push(drawCard(game.deck));
    }
    game.dealer.score = calculateHandValue(game.dealer.hand);
    game.updatedAt = new Date().toISOString();
    return game;
  }

  finishRound(roomCode) {
    const game = this._game(roomCode);
    if (game.status !== "dealer_turn") throw new Error("Dealer turn is required");
    const results = {};
    for (const player of game.players) {
      if ((game.playerChips[player.id] || 0) <= 0) continue;
      const result = calculateRoundResult(game, player.id);
      results[player.id] = result;
      game.playerChips[player.id] = Math.max(
        0,
        game.playerChips[player.id] + result.chipsChange,
      );
      game.playerStatuses[player.id] = result.result;
    }
    game.roundResults = results;
    game.roundHistory.push({
      roundNumber: game.currentRound,
      dealerScore: game.dealer.score,
      playerResults: results,
      createdAt: new Date().toISOString(),
    });
    game.status = "round_over";
    game.updatedAt = new Date().toISOString();
    const matchOver = this._isMatchOver(game);
    if (matchOver) {
      game.status = "match_over";
      game.matchResults = calculateMatchResults(game);
    }
    return { game, results, matchOver };
  }

  nextRound(roomCode, playerId) {
    const game = this._game(roomCode);
    this._activePlayer(game, playerId);
    if (game.status === "match_over") throw new Error("Match already over");
    if (game.status !== "round_over") throw new Error("Round is not complete");
    game.currentRound += 1;
    resetRound(game);
    for (const player of game.players) {
      const chips = game.playerChips[player.id] || 0;
      if (chips > 0 && game.playerBets[player.id] > chips) {
        game.playerBets[player.id] = chips;
      }
    }
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
    const humans = game.players.filter(
      (item) => !item.isBot && item.connectionStatus !== "disconnected",
    );
    const accepted = humans.every((item) =>
      game.rematchRequests.includes(item.id),
    );
    if (!accepted) return { game, started: false, player };
    const reset = resetForRematch(game);
    this.activeBlackjackGames.set(game.roomCode, reset);
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
    delete game.playerHands[playerId];
    delete game.playerBets[playerId];
    delete game.playerChips[playerId];
    delete game.playerStatuses[playerId];
    delete game.roundResults[playerId];
    game.rematchRequests = game.rematchRequests.filter(
      (item) => item !== playerId,
    );
    const humans = game.players.filter((item) => !item.isBot);
    if (humans.length === 0 || game.players.length < 2) {
      game.status = "match_over";
      game.matchResults = calculateMatchResults(game);
    } else if (game.status === "playing") {
      this._finishIfPlayersDone(game);
    }
    game.updatedAt = new Date().toISOString();
    return { game, matchOver: game.status === "match_over" };
  }

  restorePlayer(roomCode, roomPlayer) {
    const game = this.getGame(roomCode);
    if (!game || !roomPlayer) return null;
    const player = game.players.find((item) => item.id === roomPlayer.id);
    if (player) {
      player.socketId = roomPlayer.socketId;
      player.connectionStatus = "connected";
      if (game.status === "playing" && game.playerStatuses[player.id] === "disconnected") {
        game.playerStatuses[player.id] = "standing";
      }
    }
    return game;
  }

  markDisconnected(playerId) {
    const updated = [];
    for (const game of this.activeBlackjackGames.values()) {
      const player = game.players.find((item) => item.id === playerId);
      if (!player) continue;
      player.connectionStatus = "disconnected";
      player.socketId = null;
      if (game.status === "playing" && game.playerStatuses[playerId] === "playing") {
        game.playerStatuses[playerId] = "standing";
        this._finishIfPlayersDone(game);
      }
      game.updatedAt = new Date().toISOString();
      updated.push(game);
    }
    return updated;
  }

  cleanupGame(roomCode) {
    this.activeBlackjackGames.delete(
      String(roomCode || "").trim().toUpperCase(),
    );
  }

  sanitize(game) {
    return sanitizeBlackjackGameStateForClient(game);
  }

  _playBots(game) {
    for (const player of game.players.filter((item) => item.isBot)) {
      if (game.playerStatuses[player.id] !== "playing") continue;
      while (calculateHandValue(game.playerHands[player.id]) < 16) {
        ensureDeck(game);
        game.playerHands[player.id].push(drawCard(game.deck));
      }
      game.playerStatuses[player.id] = isBust(game.playerHands[player.id])
        ? "bust"
        : "standing";
    }
  }

  _finishIfPlayersDone(game) {
    const pending = game.players.some(
      (player) => game.playerStatuses[player.id] === "playing",
    );
    if (pending) return null;
    this.dealerPlay(game.roomCode);
    return this.finishRound(game.roomCode);
  }

  _isMatchOver(game) {
    const humansWithChips = game.players.filter(
      (player) => !player.isBot && (game.playerChips[player.id] || 0) > 0,
    );
    const reachedLimit =
      game.maxRounds !== null && game.currentRound >= game.maxRounds;
    return reachedLimit || humansWithChips.length <= 1;
  }

  _room(roomCode) {
    const room = this.roomService.getRoom(roomCode);
    if (!room) throw new Error("Room not found");
    return room;
  }

  _game(roomCode) {
    const game = this.getGame(roomCode);
    if (!game) throw new Error("Blackjack game not found");
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

module.exports = { BlackjackService };
