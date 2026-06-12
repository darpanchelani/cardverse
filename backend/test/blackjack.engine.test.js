const assert = require("node:assert/strict");
const test = require("node:test");
const {
  calculateHandValue,
  comparePlayerWithDealer,
  createInitialBlackjackGameState,
  isBlackjack,
  sanitizeBlackjackGameStateForClient,
} = require("../src/games/blackjack/blackjack.engine");

test("Blackjack hand scoring handles face cards and multiple aces", () => {
  assert.equal(calculateHandValue([card("A"), card("K")]), 21);
  assert.equal(calculateHandValue([card("A"), card("9"), card("5")]), 15);
  assert.equal(calculateHandValue([card("A"), card("A"), card("9")]), 21);
  assert.equal(
    calculateHandValue([card("A"), card("A"), card("9"), card("5")]),
    16,
  );
  assert.equal(isBlackjack([card("A"), card("K")]), true);
  assert.equal(isBlackjack([card("A"), card("5"), card("5")]), false);
});

test("Blackjack compares naturals, busts, dealer busts, and pushes", () => {
  assert.equal(
    comparePlayerWithDealer([card("A"), card("K")], [card("10"), card("9")]),
    "blackjack",
  );
  assert.equal(
    comparePlayerWithDealer(
      [card("10"), card("9"), card("5")],
      [card("10"), card("9")],
    ),
    "bust",
  );
  assert.equal(
    comparePlayerWithDealer(
      [card("10"), card("9")],
      [card("10"), card("9"), card("5")],
    ),
    "dealer_bust",
  );
  assert.equal(
    comparePlayerWithDealer([card("10"), card("8")], [card("K"), card("8")]),
    "push",
  );
});

test("Blackjack state hides the deck and dealer hole card", () => {
  const state = createInitialBlackjackGameState(
    {
      roomCode: "AB12CD",
      players: [
        { id: "one", username: "One", seatIndex: 0 },
        { id: "two", username: "Two", seatIndex: 1 },
      ],
      settings: { maxRounds: 5, startingChips: 1000, minimumBet: 10 },
    },
    5,
  );
  state.dealer.hand = [card("10"), card("A")];
  const safe = sanitizeBlackjackGameStateForClient(state);
  assert.equal("deck" in safe, false);
  assert.equal(safe.dealer.hand[1], null);
  assert.equal(safe.dealer.score, 10);
});

function card(rank) {
  const value = rank === "A" ? 14 : ["J", "Q", "K"].includes(rank) ? 10 : Number(rank);
  return {
    suit: "spades",
    rank,
    value,
    displayName: `${rank} of Spades`,
    suitSymbol: "♠",
    colorType: "black",
  };
}
