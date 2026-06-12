const { createWarGameState } = require("./war.model");

const SUITS = Object.freeze([
  { name: "hearts", symbol: "♥", colorType: "red" },
  { name: "diamonds", symbol: "♦", colorType: "red" },
  { name: "clubs", symbol: "♣", colorType: "black" },
  { name: "spades", symbol: "♠", colorType: "black" },
]);

const RANKS = Object.freeze([
  ["2", 2],
  ["3", 3],
  ["4", 4],
  ["5", 5],
  ["6", 6],
  ["7", 7],
  ["8", 8],
  ["9", 9],
  ["10", 10],
  ["J", 11],
  ["Q", 12],
  ["K", 13],
  ["A", 14],
]);

function createDeck() {
  return SUITS.flatMap((suit) =>
    RANKS.map(([rank, value]) => ({
      suit: suit.name,
      rank,
      value,
      displayName: `${rank} of ${capitalize(suit.name)}`,
      suitSymbol: suit.symbol,
      colorType: suit.colorType,
    })),
  );
}

function shuffleDeck(deck) {
  const shuffled = [...deck];
  for (let index = shuffled.length - 1; index > 0; index -= 1) {
    const target = Math.floor(Math.random() * (index + 1));
    [shuffled[index], shuffled[target]] = [shuffled[target], shuffled[index]];
  }
  return shuffled;
}

function splitDeckForPlayers(deck, players) {
  const playerDecks = Object.fromEntries(
    players.map((player) => [player.id, []]),
  );
  deck.forEach((card, index) => {
    playerDecks[players[index % players.length].id].push(card);
  });
  return playerDecks;
}

function drawTopCard(playerDeck) {
  return playerDeck.length ? playerDeck.shift() : null;
}

function compareCards(cardA, cardB) {
  return cardA.value - cardB.value;
}

function createInitialWarGameState(room, maxBattles = 50) {
  const players = room.players.map(sanitizePlayer);
  if (players.length < 2) throw new Error("At least two players are required");
  const deck = shuffleDeck(createDeck());
  return createWarGameState({
    roomCode: room.roomCode,
    players,
    playerDecks: splitDeckForPlayers(deck, players),
    maxBattles: normalizeMaxBattles(maxBattles),
    warMode: room.settings?.warMode === "quick" ? "quick" : "classic",
  });
}

function resolveBattle(gameState) {
  const activePlayers = gameState.players.filter(
    (player) => (gameState.playerDecks[player.id]?.length || 0) > 0,
  );
  if (activePlayers.length < 2) throw new Error("Not enough active players");

  const cards = {};
  gameState.currentBattleCards = {};
  gameState.battlePile = [];
  gameState.warCards = {};

  for (const player of activePlayers) {
    const card = drawTopCard(gameState.playerDecks[player.id]);
    if (!card) continue;
    cards[player.id] = card;
    gameState.currentBattleCards[player.id] = card;
    gameState.battlePile.push(card);
  }

  const leaders = highestPlayers(Object.keys(cards), cards);
  let resolution;
  let warStarted = false;
  if (leaders.length === 1) {
    resolution = awardPile(gameState, leaders[0]);
  } else {
    warStarted = true;
    resolution = handleWar(gameState, leaders);
  }

  updateCardCounts(gameState);
  const winner = gameState.players.find(
    (player) => player.id === resolution.winnerId,
  );
  if (winner) {
    gameState.scores[winner.id] = (gameState.scores[winner.id] || 0) + 1;
  }
  const result = {
    battleNumber: gameState.currentBattle,
    winnerId: winner?.id ?? null,
    winnerName: winner?.username ?? null,
    result: winner ? "player_win" : "draw",
    message: resolution.message,
    cards: { ...cards },
    warCards: cloneWarCards(gameState.warCards),
    pileCount: resolution.pileCount,
    createdAt: new Date().toISOString(),
  };
  gameState.battleResult = result;
  gameState.battleHistory.push(result);
  gameState.status = "battle_over";
  gameState.updatedAt = new Date().toISOString();
  return { result, warStarted };
}

function handleWar(gameState, initialTiedPlayerIds) {
  let tiedPlayerIds = [...initialTiedPlayerIds];
  while (tiedPlayerIds.length > 1) {
    gameState.status = "war_active";
    gameState.warCount += 1;
    const faceUpCards = {};
    const contenders = [];

    for (const playerId of tiedPlayerIds) {
      const deck = gameState.playerDecks[playerId] || [];
      const existing = gameState.warCards[playerId] || {
        faceDownCount: 0,
        faceUpCard: null,
      };
      const requestedFaceDown = gameState.warMode === "quick" ? 0 : 3;
      const faceDownCount = Math.min(
        requestedFaceDown,
        Math.max(deck.length - 1, 0),
      );
      for (let index = 0; index < faceDownCount; index += 1) {
        const hiddenCard = drawTopCard(deck);
        if (hiddenCard) gameState.battlePile.push(hiddenCard);
      }
      const faceUpCard = drawTopCard(deck);
      if (faceUpCard) {
        gameState.battlePile.push(faceUpCard);
        faceUpCards[playerId] = faceUpCard;
        contenders.push(playerId);
      }
      gameState.warCards[playerId] = {
        faceDownCount: existing.faceDownCount + faceDownCount,
        faceUpCard: faceUpCard || existing.faceUpCard,
      };
    }

    if (contenders.length === 1) {
      return awardPile(gameState, contenders[0], true);
    }
    if (contenders.length === 0) {
      return splitPile(gameState, tiedPlayerIds);
    }
    const leaders = highestPlayers(contenders, faceUpCards);
    if (leaders.length === 1) {
      return awardPile(gameState, leaders[0], true);
    }
    if (gameState.warMode === "quick") {
      return splitPile(gameState, leaders);
    }
    tiedPlayerIds = leaders;
  }
  return awardPile(gameState, tiedPlayerIds[0], true);
}

function calculateMatchWinner(gameState) {
  const active = gameState.players.filter(
    (player) => (gameState.playerDecks[player.id]?.length || 0) > 0,
  );
  if (active.length === 1) return winnerPayload(active[0], "won the war!");

  const ranked = gameState.players.map((player) => ({
    player,
    cardCount: gameState.playerDecks[player.id]?.length || 0,
    score: gameState.scores[player.id] || 0,
  }));
  const highestCount = Math.max(...ranked.map((entry) => entry.cardCount));
  let leaders = ranked.filter((entry) => entry.cardCount === highestCount);
  if (leaders.length > 1) {
    const highestScore = Math.max(...leaders.map((entry) => entry.score));
    leaders = leaders.filter((entry) => entry.score === highestScore);
  }
  if (leaders.length !== 1) {
    return {
      winnerId: null,
      winnerName: null,
      message: "War ended in a draw.",
    };
  }
  return winnerPayload(leaders[0].player, "won the war!");
}

function sanitizeWarGameStateForClient(gameState) {
  const {
    playerDecks: _playerDecks,
    battlePile: _battlePile,
    ...safeState
  } = gameState;
  return {
    ...safeState,
    players: gameState.players.map((player) => ({ ...player })),
    currentBattleCards: { ...gameState.currentBattleCards },
    battlePileCount: gameState.battlePile.length,
    warCards: cloneWarCards(gameState.warCards),
    scores: { ...gameState.scores },
    cardCounts: { ...gameState.cardCounts },
    battleHistory: gameState.battleHistory.map(cloneBattleResult),
    battleResult: gameState.battleResult
      ? cloneBattleResult(gameState.battleResult)
      : null,
    matchWinner: gameState.matchWinner ? { ...gameState.matchWinner } : null,
    rematchRequests: [...gameState.rematchRequests],
  };
}

function resetWarForRematch(gameState) {
  const deck = shuffleDeck(createDeck());
  return createWarGameState({
    roomCode: gameState.roomCode,
    players: gameState.players.map((player) => ({ ...player })),
    playerDecks: splitDeckForPlayers(deck, gameState.players),
    maxBattles: gameState.maxBattles,
    warMode: gameState.warMode,
  });
}

function updateCardCounts(gameState) {
  gameState.cardCounts = Object.fromEntries(
    gameState.players.map((player) => [
      player.id,
      gameState.playerDecks[player.id]?.length || 0,
    ]),
  );
}

function highestPlayers(playerIds, cards) {
  const highest = Math.max(...playerIds.map((id) => cards[id].value));
  return playerIds.filter((id) => cards[id].value === highest);
}

function awardPile(gameState, winnerId, wonWar = false) {
  const pile = [...gameState.battlePile];
  gameState.playerDecks[winnerId].push(...pile);
  const winner = gameState.players.find((player) => player.id === winnerId);
  return {
    winnerId,
    pileCount: pile.length,
    message: wonWar
      ? `${winner.username} wins the war and takes ${pile.length} cards!`
      : `${winner.username} wins Battle ${gameState.currentBattle}!`,
  };
}

function splitPile(gameState, playerIds) {
  const pile = [...gameState.battlePile];
  pile.forEach((card, index) => {
    gameState.playerDecks[playerIds[index % playerIds.length]].push(card);
  });
  return {
    winnerId: null,
    pileCount: pile.length,
    message: "Battle draw. Cards split.",
  };
}

function normalizeMaxBattles(value) {
  if (value === null || value === undefined || Number(value) === 0) return null;
  const battles = Number(value);
  return [25, 50, 100].includes(battles) ? battles : 50;
}

function sanitizePlayer(player) {
  return {
    id: player.id,
    socketId: player.socketId || null,
    username: player.username,
    avatar: player.avatar || "default",
    level: Number(player.level) || 1,
    isHost: player.isHost === true,
    isReady: player.isReady === true,
    isBot: player.isBot === true,
    seatIndex: Number(player.seatIndex) || 0,
    connectionStatus: player.connectionStatus || "connected",
    joinedAt: player.joinedAt || new Date().toISOString(),
  };
}

function cloneWarCards(warCards) {
  return Object.fromEntries(
    Object.entries(warCards).map(([key, value]) => [key, { ...value }]),
  );
}

function cloneBattleResult(result) {
  return {
    ...result,
    cards: { ...result.cards },
    warCards: cloneWarCards(result.warCards || {}),
  };
}

function winnerPayload(player, suffix) {
  return {
    winnerId: player.id,
    winnerName: player.username,
    message: `${player.username} ${suffix}`,
  };
}

function capitalize(value) {
  return value.charAt(0).toUpperCase() + value.slice(1);
}

module.exports = {
  createDeck,
  shuffleDeck,
  splitDeckForPlayers,
  drawTopCard,
  compareCards,
  createInitialWarGameState,
  resolveBattle,
  handleWar,
  calculateMatchWinner,
  sanitizeWarGameStateForClient,
  resetWarForRematch,
  updateCardCounts,
};
