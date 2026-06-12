const WAR_CLIENT_EVENTS = Object.freeze({
  INIT: "war:init",
  BATTLE: "war:battle",
  NEXT_BATTLE: "war:next_battle",
  REMATCH_REQUEST: "war:rematch_request",
  REMATCH_ACCEPT: "war:rematch_accept",
  LEAVE_GAME: "war:leave_game",
});

const WAR_SERVER_EVENTS = Object.freeze({
  STATE: "war:state",
  BATTLE_RESULT: "war:battle_result",
  WAR_STARTED: "war:war_started",
  MATCH_OVER: "war:match_over",
  ERROR: "war:error",
  REMATCH_REQUESTED: "war:rematch_requested",
  REMATCH_STARTED: "war:rematch_started",
});

module.exports = { WAR_CLIENT_EVENTS, WAR_SERVER_EVENTS };
