function createWarGameState({
  roomCode,
  players,
  playerDecks,
  maxBattles,
  warMode,
}) {
  const now = new Date().toISOString();
  return {
    roomCode,
    gameType: "war",
    status: "playing",
    players,
    playerDecks,
    currentBattleCards: {},
    battlePile: [],
    warCards: {},
    currentBattle: 1,
    maxBattles,
    warMode,
    battleHistory: [],
    scores: Object.fromEntries(players.map((player) => [player.id, 0])),
    cardCounts: Object.fromEntries(
      players.map((player) => [player.id, playerDecks[player.id]?.length || 0]),
    ),
    warCount: 0,
    battleResult: null,
    matchWinner: null,
    createdAt: now,
    updatedAt: now,
    rematchRequests: [],
  };
}

module.exports = { createWarGameState };
