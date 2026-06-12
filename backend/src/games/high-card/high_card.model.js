function createHighCardGameState({ roomCode, players, deck, maxRounds }) {
  const now = new Date().toISOString();
  return {
    roomCode,
    gameType: "high_card",
    status: "playing",
    players,
    deck,
    currentRound: 1,
    maxRounds,
    roundHistory: [],
    currentCards: {},
    scores: Object.fromEntries(players.map((player) => [player.id, 0])),
    roundResult: null,
    matchWinner: null,
    createdAt: now,
    updatedAt: now,
    rematchRequests: [],
  };
}

module.exports = { createHighCardGameState };
