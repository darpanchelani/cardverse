const GAME_TYPES = Object.freeze({
  HIGH_CARD: "high_card",
  WAR: "war",
  BLACKJACK: "blackjack",
});

const GAME_NAMES = Object.freeze({
  high_card: "High Card",
  war: "War",
  blackjack: "Blackjack",
});

const ROOM_STATUSES = Object.freeze({
  WAITING: "waiting",
  READY: "ready",
  PLAYING: "playing",
  FINISHED: "finished",
});

module.exports = {
  GAME_TYPES,
  GAME_NAMES,
  ROOM_STATUSES,
  VALID_GAME_TYPES: Object.values(GAME_TYPES),
};
