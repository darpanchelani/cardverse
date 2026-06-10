const CLIENT_EVENTS = Object.freeze({
  USER_CONNECT: "user:connect",
  ROOM_CREATE: "room:create",
  ROOM_JOIN: "room:join",
  ROOM_LEAVE: "room:leave",
  ROOM_GET_PUBLIC: "room:get_public",
  ROOM_TOGGLE_READY: "room:toggle_ready",
  ROOM_ADD_BOT: "room:add_bot",
  ROOM_REMOVE_BOT: "room:remove_bot",
  ROOM_START_GAME: "room:start_game",
  CHAT_SEND: "chat:send",
  TYPING_START: "typing:start",
  TYPING_STOP: "typing:stop",
});

const SERVER_EVENTS = Object.freeze({
  CONNECTION_SUCCESS: "connection:success",
  ROOM_CREATED: "room:created",
  ROOM_JOINED: "room:joined",
  ROOM_LEFT: "room:left",
  ROOM_UPDATED: "room:updated",
  ROOM_PUBLIC_LIST: "room:public_list",
  ROOM_ERROR: "room:error",
  ROOM_GAME_STARTING: "room:game_starting",
  CHAT_MESSAGE: "chat:message",
  CHAT_HISTORY: "chat:history",
  TYPING_UPDATE: "typing:update",
  PLAYER_JOINED: "player:joined",
  PLAYER_LEFT: "player:left",
  PLAYER_READY_CHANGED: "player:ready_changed",
  ERROR_MESSAGE: "error:message",
});

module.exports = { CLIENT_EVENTS, SERVER_EVENTS };
