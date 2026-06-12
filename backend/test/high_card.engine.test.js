const assert = require("node:assert/strict");
const test = require("node:test");
const {
  compareCards,
  createDeck,
  createInitialGameState,
  sanitizeGameStateForClient,
} = require("../src/games/high-card/high_card.engine");

test("High Card deck contains 52 unique cards with Ace high", () => {
  const deck = createDeck();
  assert.equal(deck.length, 52);
  assert.equal(
    new Set(deck.map((card) => `${card.rank}-${card.suit}`)).size,
    52,
  );
  assert.equal(
    deck.find((card) => card.rank === "A" && card.suit === "spades").value,
    14,
  );
});

test("High Card comparison ignores suit and sanitized state hides deck", () => {
  const aceHearts = {
    rank: "A",
    suit: "hearts",
    value: 14,
  };
  const aceClubs = {
    rank: "A",
    suit: "clubs",
    value: 14,
  };
  assert.equal(compareCards(aceHearts, aceClubs), 0);

  const state = createInitialGameState(
    {
      roomCode: "AB12CD",
      players: [
        { id: "one", username: "One", seatIndex: 0 },
        { id: "two", username: "Two", seatIndex: 1 },
      ],
    },
    3,
  );
  const safe = sanitizeGameStateForClient(state);
  assert.equal("deck" in safe, false);
  assert.equal(state.deck.length, 52);
});
