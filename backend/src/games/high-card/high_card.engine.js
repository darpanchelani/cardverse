const { createHighCardGameState } = require("./high_card.model");

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

function drawCard(deck) {
  if (!deck.length) throw new Error("Deck is empty");
  return deck.pop();
}

function compareCards(cardA, cardB) {
  return cardA.value - cardB.value;
}

function createInitialGameState(room, maxRounds = 5) {
  const players = room.players.map(sanitizePlayer);
  if (players.length < 2) throw new Error("At least two players are required");
  return createHighCardGameState({
    roomCode: room.roomCode,
    players,
    deck: shuffleDeck(createDeck()),
    maxRounds: normalizeMaxRounds(maxRounds),
  });
}

function sanitizeGameStateForClient(gameState) {
  const { deck: _deck, ...safeState } = gameState;
  return {
    ...safeState,
    players: gameState.players.map((player) => ({ ...player })),
    currentCards: { ...gameState.currentCards },
    scores: { ...gameState.scores },
    roundHistory: gameState.roundHistory.map((round) => ({
      ...round,
      cards: { ...round.cards },
      playerCards: { ...round.playerCards },
    })),
    roundResult: gameState.roundResult
      ? {
          ...gameState.roundResult,
          cards: { ...gameState.roundResult.cards },
        }
      : null,
    matchWinner: gameState.matchWinner
      ? { ...gameState.matchWinner }
      : null,
    rematchRequests: [...gameState.rematchRequests],
  };
}

function calculateMatchWinner(gameState) {
  const scores = gameState.players.map((player) => ({
    player,
    score: gameState.scores[player.id] || 0,
  }));
  const highest = Math.max(...scores.map((entry) => entry.score));
  const leaders = scores.filter((entry) => entry.score === highest);
  if (leaders.length !== 1) {
    return {
      winnerId: null,
      winnerName: null,
      message: "Match ended in a draw.",
    };
  }
  return {
    winnerId: leaders[0].player.id,
    winnerName: leaders[0].player.username,
    message: `${leaders[0].player.username} won the match!`,
  };
}

function resetForRematch(gameState) {
  return createHighCardGameState({
    roomCode: gameState.roomCode,
    players: gameState.players.map((player) => ({ ...player })),
    deck: shuffleDeck(createDeck()),
    maxRounds: gameState.maxRounds,
  });
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

function normalizeMaxRounds(value) {
  const rounds = Number(value);
  return [3, 5, 10].includes(rounds) ? rounds : 5;
}

function capitalize(value) {
  return value.charAt(0).toUpperCase() + value.slice(1);
}

module.exports = {
  createDeck,
  shuffleDeck,
  drawCard,
  compareCards,
  createInitialGameState,
  sanitizeGameStateForClient,
  calculateMatchWinner,
  resetForRematch,
};
