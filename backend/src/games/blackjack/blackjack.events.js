const BLACKJACK_CLIENT_EVENTS = Object.freeze({
  INIT: "blackjack:init",
  PLACE_BET: "blackjack:place_bet",
  START_ROUND: "blackjack:start_round",
  HIT: "blackjack:hit",
  STAND: "blackjack:stand",
  NEXT_ROUND: "blackjack:next_round",
  REMATCH_REQUEST: "blackjack:rematch_request",
  REMATCH_ACCEPT: "blackjack:rematch_accept",
  LEAVE_GAME: "blackjack:leave_game",
});

const BLACKJACK_SERVER_EVENTS = Object.freeze({
  STATE: "blackjack:state",
  ROUND_STARTED: "blackjack:round_started",
  PLAYER_ACTION: "blackjack:player_action",
  DEALER_TURN: "blackjack:dealer_turn",
  ROUND_RESULT: "blackjack:round_result",
  MATCH_OVER: "blackjack:match_over",
  ERROR: "blackjack:error",
  REMATCH_REQUESTED: "blackjack:rematch_requested",
  REMATCH_STARTED: "blackjack:rematch_started",
});

module.exports = { BLACKJACK_CLIENT_EVENTS, BLACKJACK_SERVER_EVENTS };
