const assert = require("node:assert/strict");
const test = require("node:test");
const {
  createDeck,
  createInitialWarGameState,
  resolveBattle,
  sanitizeWarGameStateForClient,
  splitDeckForPlayers,
} = require("../src/games/war/war.engine");

test("War deck is split evenly and private deck data is sanitized", () => {
  const players = [
    { id: "one", username: "One", seatIndex: 0 },
    { id: "two", username: "Two", seatIndex: 1 },
  ];
  const deck = createDeck();
  const split = splitDeckForPlayers(deck, players);
  assert.equal(split.one.length, 26);
  assert.equal(split.two.length, 26);

  const state = createInitialWarGameState(
    {
      roomCode: "AB12CD",
      players,
      settings: { maxBattles: 25, warMode: "classic" },
    },
    25,
  );
  const safe = sanitizeWarGameStateForClient(state);
  assert.equal("playerDecks" in safe, false);
  assert.equal("battlePile" in safe, false);
  assert.deepEqual(safe.cardCounts, { one: 26, two: 26 });
});

test("classic War burns three cards and awards the full pile", () => {
  const state = createInitialWarGameState(
    {
      roomCode: "AB12CD",
      players: [
        { id: "one", username: "One", seatIndex: 0 },
        { id: "two", username: "Two", seatIndex: 1 },
      ],
      settings: { maxBattles: 25, warMode: "classic" },
    },
    25,
  );
  state.playerDecks = {
    one: [
      card("10", 10),
      card("2", 2),
      card("3", 3),
      card("4", 4),
      card("A", 14),
    ],
    two: [
      card("10", 10),
      card("5", 5),
      card("6", 6),
      card("7", 7),
      card("K", 13),
    ],
  };

  const resolved = resolveBattle(state);
  assert.equal(resolved.warStarted, true);
  assert.equal(resolved.result.winnerId, "one");
  assert.equal(resolved.result.pileCount, 10);
  assert.equal(state.warCount, 1);
  assert.equal(state.playerDecks.one.length, 10);
  assert.equal(state.playerDecks.two.length, 0);
});

function card(rank, value) {
  return {
    suit: "spades",
    rank,
    value,
    displayName: `${rank} of Spades`,
    suitSymbol: "♠",
    colorType: "black",
  };
}
