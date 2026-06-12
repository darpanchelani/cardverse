const HIGH_CARD_CLIENT_EVENTS = Object.freeze({
  INIT: "high_card:init",
  DRAW: "high_card:draw",
  NEXT_ROUND: "high_card:next_round",
  REMATCH_REQUEST: "high_card:rematch_request",
  REMATCH_ACCEPT: "high_card:rematch_accept",
  LEAVE_GAME: "high_card:leave_game",
});

const HIGH_CARD_SERVER_EVENTS = Object.freeze({
  STATE: "high_card:state",
  ROUND_RESULT: "high_card:round_result",
  MATCH_OVER: "high_card:match_over",
  ERROR: "high_card:error",
  REMATCH_REQUESTED: "high_card:rematch_requested",
  REMATCH_STARTED: "high_card:rematch_started",
});

module.exports = { HIGH_CARD_CLIENT_EVENTS, HIGH_CARD_SERVER_EVENTS };
