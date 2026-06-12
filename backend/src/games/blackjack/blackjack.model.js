function createBlackjackGameState({
  roomCode,
  players,
  maxRounds,
  startingChips,
  minimumBet,
  dealerRule,
  deck,
}) {
  const now = new Date().toISOString();
  return {
    roomCode,
    gameType: "blackjack",
    status: "betting",
    players,
    dealer: { hand: [], score: 0, isHidden: true },
    deck,
    playerHands: Object.fromEntries(players.map((player) => [player.id, []])),
    playerBets: Object.fromEntries(
      players.map((player) => [
        player.id,
        Math.min(Math.max(50, minimumBet), startingChips),
      ]),
    ),
    playerChips: Object.fromEntries(
      players.map((player) => [player.id, startingChips]),
    ),
    playerStatuses: Object.fromEntries(
      players.map((player) => [player.id, "betting"]),
    ),
    currentRound: 1,
    maxRounds,
    startingChips,
    minimumBet,
    dealerRule,
    currentTurnPlayerId: null,
    roundResults: {},
    matchResults: null,
    roundHistory: [],
    createdAt: now,
    updatedAt: now,
    rematchRequests: [],
  };
}

module.exports = { createBlackjackGameState };
