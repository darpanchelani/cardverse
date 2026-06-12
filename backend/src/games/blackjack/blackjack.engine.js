const { createBlackjackGameState } = require("./blackjack.model");

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
  return deck.pop() || null;
}

function getBlackjackCardValue(card) {
  if (card.rank === "A") return 11;
  if (["J", "Q", "K"].includes(card.rank)) return 10;
  return Number(card.rank) || Math.min(Number(card.value) || 0, 10);
}

function calculateHandValue(hand) {
  let total = 0;
  let aces = 0;
  for (const card of hand) {
    total += getBlackjackCardValue(card);
    if (card.rank === "A") aces += 1;
  }
  while (total > 21 && aces > 0) {
    total -= 10;
    aces -= 1;
  }
  return total;
}

function isBust(hand) {
  return calculateHandValue(hand) > 21;
}

function isBlackjack(hand) {
  return hand.length === 2 && calculateHandValue(hand) === 21;
}

function shouldDealerHit(hand, dealerRule = "stand_on_17") {
  const score = calculateHandValue(hand);
  if (score < 17) return true;
  if (score > 17 || dealerRule !== "hit_soft_17") return false;
  return hand.some((card) => card.rank === "A") && rawHandValue(hand) === 17;
}

function createInitialBlackjackGameState(room, maxRounds = 5) {
  const players = room.players.map(sanitizePlayer);
  if (players.length < 2) throw new Error("At least two players are required");
  const settings = room.settings || {};
  return createBlackjackGameState({
    roomCode: room.roomCode,
    players,
    maxRounds: normalizeMaxRounds(maxRounds),
    startingChips: normalizeOption(settings.startingChips, [500, 1000, 2000], 1000),
    minimumBet: normalizeOption(settings.minimumBet, [10, 25, 50], 10),
    dealerRule:
      settings.dealerRule === "hit_soft_17" ? "hit_soft_17" : "stand_on_17",
    deck: shuffleDeck(createDeck()),
  });
}

function dealInitialCards(gameState) {
  ensureDeck(gameState, gameState.players.length * 2 + 8);
  for (const player of activePlayers(gameState)) {
    gameState.playerHands[player.id] = [
      drawCard(gameState.deck),
      drawCard(gameState.deck),
    ];
    gameState.playerStatuses[player.id] = isBlackjack(
      gameState.playerHands[player.id],
    )
      ? "blackjack"
      : "playing";
  }
  gameState.dealer = {
    hand: [drawCard(gameState.deck), drawCard(gameState.deck)],
    score: 0,
    isHidden: true,
  };
  gameState.status = "playing";
  gameState.roundResults = {};
  gameState.updatedAt = new Date().toISOString();
  return gameState;
}

function comparePlayerWithDealer(playerHand, dealerHand) {
  const playerScore = calculateHandValue(playerHand);
  const dealerScore = calculateHandValue(dealerHand);
  if (playerScore > 21) return "bust";
  const playerNatural = isBlackjack(playerHand);
  const dealerNatural = isBlackjack(dealerHand);
  if (playerNatural && dealerNatural) return "push";
  if (playerNatural) return "blackjack";
  if (dealerNatural) return "dealer_blackjack";
  if (dealerScore > 21) return "dealer_bust";
  if (playerScore > dealerScore) return "win";
  if (playerScore < dealerScore) return "loss";
  return "push";
}

function calculateRoundResult(gameState, playerId) {
  const hand = gameState.playerHands[playerId] || [];
  const bet = gameState.playerBets[playerId] || 0;
  const result = comparePlayerWithDealer(hand, gameState.dealer.hand);
  const chipsChange = ["win", "dealer_bust"].includes(result)
    ? bet
    : result === "blackjack"
      ? Math.round(bet * 1.5)
      : ["loss", "bust", "dealer_blackjack"].includes(result)
        ? -bet
        : 0;
  return {
    playerId,
    result,
    message: resultMessage(result, chipsChange),
    playerScore: calculateHandValue(hand),
    dealerScore: calculateHandValue(gameState.dealer.hand),
    chipsChange,
  };
}

function calculateMatchResults(gameState) {
  const rankings = gameState.players
    .map((player) => ({
      playerId: player.id,
      username: player.username,
      chips: gameState.playerChips[player.id] || 0,
      isBot: player.isBot,
    }))
    .sort((a, b) => b.chips - a.chips);
  const highest = rankings[0]?.chips ?? 0;
  const leaders = rankings.filter((entry) => entry.chips === highest);
  const winner = leaders.length === 1 ? leaders[0] : null;
  return {
    winnerId: winner?.playerId ?? null,
    winnerName: winner?.username ?? null,
    message: winner
      ? `${winner.username} wins the Blackjack table with ${winner.chips} chips!`
      : "Blackjack match ended in a draw.",
    rankings,
  };
}

function sanitizeBlackjackGameStateForClient(gameState) {
  const { deck: _deck, ...safeState } = gameState;
  const hideDealer = gameState.dealer.isHidden;
  const dealerHand = hideDealer
    ? gameState.dealer.hand.map((card, index) => (index === 1 ? null : card))
    : [...gameState.dealer.hand];
  return {
    ...safeState,
    players: gameState.players.map((player) => ({ ...player })),
    dealer: {
      hand: dealerHand,
      score: hideDealer
        ? calculateHandValue(gameState.dealer.hand.slice(0, 1))
        : calculateHandValue(gameState.dealer.hand),
      isHidden: hideDealer,
    },
    playerHands: cloneHands(gameState.playerHands),
    playerBets: { ...gameState.playerBets },
    playerChips: { ...gameState.playerChips },
    playerStatuses: { ...gameState.playerStatuses },
    roundResults: cloneResults(gameState.roundResults),
    matchResults: gameState.matchResults
      ? {
          ...gameState.matchResults,
          rankings: gameState.matchResults.rankings.map((item) => ({ ...item })),
        }
      : null,
    roundHistory: gameState.roundHistory.map(cloneRound),
    rematchRequests: [...gameState.rematchRequests],
  };
}

function resetRound(gameState) {
  gameState.playerHands = Object.fromEntries(
    gameState.players.map((player) => [player.id, []]),
  );
  gameState.playerStatuses = Object.fromEntries(
    gameState.players.map((player) => [
      player.id,
      (gameState.playerChips[player.id] || 0) > 0 ? "betting" : "eliminated",
    ]),
  );
  gameState.dealer = { hand: [], score: 0, isHidden: true };
  gameState.roundResults = {};
  gameState.status = "betting";
  gameState.currentTurnPlayerId = null;
  gameState.updatedAt = new Date().toISOString();
  return gameState;
}

function resetForRematch(gameState) {
  return createBlackjackGameState({
    roomCode: gameState.roomCode,
    players: gameState.players.map((player) => ({ ...player })),
    maxRounds: gameState.maxRounds,
    startingChips: gameState.startingChips,
    minimumBet: gameState.minimumBet,
    dealerRule: gameState.dealerRule,
    deck: shuffleDeck(createDeck()),
  });
}

function ensureDeck(gameState, minimumCards = 15) {
  if (gameState.deck.length < minimumCards) {
    gameState.deck = shuffleDeck(createDeck());
  }
}

function activePlayers(gameState) {
  return gameState.players.filter(
    (player) =>
      player.connectionStatus !== "disconnected" &&
      (gameState.playerChips[player.id] || 0) > 0,
  );
}

function normalizeMaxRounds(value) {
  if (value === null || value === 0 || value === "until_one_remains") {
    return null;
  }
  const rounds = Number(value);
  return [3, 5, 10].includes(rounds) ? rounds : 5;
}

function normalizeOption(value, allowed, fallback) {
  const number = Number(value);
  return allowed.includes(number) ? number : fallback;
}

function rawHandValue(hand) {
  return hand.reduce((total, card) => total + getBlackjackCardValue(card), 0);
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

function cloneHands(hands) {
  return Object.fromEntries(
    Object.entries(hands).map(([id, cards]) => [id, [...cards]]),
  );
}

function cloneResults(results) {
  return Object.fromEntries(
    Object.entries(results).map(([id, result]) => [id, { ...result }]),
  );
}

function cloneRound(round) {
  return {
    ...round,
    playerResults: cloneResults(round.playerResults || {}),
  };
}

function resultMessage(result, change) {
  return {
    blackjack: `Blackjack! Won +${change} chips.`,
    dealer_bust: `Dealer busted. Won +${change} chips.`,
    win: `Won +${change} chips.`,
    bust: `Busted. Lost ${Math.abs(change)} chips.`,
    dealer_blackjack: `Dealer has Blackjack. Lost ${Math.abs(change)} chips.`,
    loss: `Dealer wins. Lost ${Math.abs(change)} chips.`,
    push: "Push. Chips stay the same.",
  }[result];
}

function capitalize(value) {
  return value.charAt(0).toUpperCase() + value.slice(1);
}

module.exports = {
  createDeck,
  shuffleDeck,
  drawCard,
  createInitialBlackjackGameState,
  getBlackjackCardValue,
  calculateHandValue,
  isBust,
  isBlackjack,
  shouldDealerHit,
  dealInitialCards,
  comparePlayerWithDealer,
  calculateRoundResult,
  calculateMatchResults,
  sanitizeBlackjackGameStateForClient,
  resetRound,
  resetForRematch,
  ensureDeck,
  activePlayers,
};
