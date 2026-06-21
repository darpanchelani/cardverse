const assert = require("node:assert/strict");
const http = require("node:http");
const { after, before, beforeEach, test } = require("node:test");
const { io: createClient } = require("socket.io-client");
const { createApp } = require("../src/app");
const {
  createSocketServer,
  roomService,
  highCardService,
  warService,
  blackjackService,
} = require("../src/socket");

let server;
let baseUrl;
const clients = [];

before(async () => {
  server = http.createServer(createApp());
  createSocketServer(server);
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  const address = server.address();
  baseUrl = `http://127.0.0.1:${address.port}`;
});

beforeEach(() => {
  roomService.rooms.clear();
  highCardService.activeHighCardGames.clear();
  warService.activeWarGames.clear();
  blackjackService.activeBlackjackGames.clear();
});

after(async () => {
  for (const client of clients) client.disconnect();
  await new Promise((resolve) => server.close(resolve));
});

test("health endpoint reports backend availability", async () => {
  const response = await fetch(`${baseUrl}/health`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), {
    success: true,
    message: "CardVerse backend is running",
  });
});

test("root and missing routes return production-safe JSON", async () => {
  const root = await fetch(baseUrl);
  assert.equal(root.status, 200);
  assert.equal((await root.json()).message, "CardVerse API");
  const missing = await fetch(`${baseUrl}/api/not-a-route`);
  assert.equal(missing.status, 404);
  const body = await missing.json();
  assert.equal(body.success, false);
  assert.deepEqual(body.errors, []);
});

test("two clients synchronize room, ready, bot, chat, and start events", async () => {
  const host = await connectUser("host_user", "Host Player");
  const guest = await connectUser("guest_user", "Guest Player");

  const created = await emitAck(host, "room:create", {
    gameType: "high_card",
    gameName: "High Card",
    maxPlayers: 3,
    isPrivate: false,
    allowBots: true,
    allowChat: true,
    settings: { turnTimeSeconds: 30, difficulty: "Normal" },
  });
  assert.equal(created.success, true);
  assert.match(created.room.roomCode, /^[A-Z0-9]{6}$/);
  assert.equal(created.room.players[0].isHost, true);

  const publicRooms = await emitAck(guest, "room:get_public", {});
  assert.equal(publicRooms.rooms.length, 1);

  const hostUpdatePromise = once(host, "room:updated");
  const joined = await emitAck(guest, "room:join", {
    roomCode: created.room.roomCode,
  });
  assert.equal(joined.room.players.length, 2);
  assert.equal((await hostUpdatePromise).players.length, 2);

  await emitAck(host, "room:toggle_ready", {
    roomCode: created.room.roomCode,
  });
  await emitAck(guest, "room:toggle_ready", {
    roomCode: created.room.roomCode,
  });

  const botAdded = await emitAck(host, "room:add_bot", {
    roomCode: created.room.roomCode,
  });
  assert.equal(botAdded.room.players.length, 3);
  assert.equal(botAdded.room.status, "ready");

  const chatPromise = onceWhere(
    guest,
    "chat:message",
    (message) => message.message === "Ready for cards",
  );
  const sent = await emitAck(host, "chat:send", {
    roomCode: created.room.roomCode,
    message: "Ready for cards",
  });
  assert.equal(sent.success, true);
  assert.equal((await chatPromise).message, "Ready for cards");

  const startPromise = once(guest, "room:game_starting");
  const started = await emitAck(host, "room:start_game", {
    roomCode: created.room.roomCode,
  });
  assert.equal(started.success, true);
  assert.equal((await startPromise).status, "playing");
});

test("backend rejects invalid room actions", async () => {
  const host = await connectUser("host_errors", "Host");
  const guest = await connectUser("guest_errors", "Guest");
  const invalidCreate = await emitAck(host, "room:create", {
    gameType: "poker",
    maxPlayers: 8,
  });
  assert.equal(invalidCreate.success, false);

  const missingRoom = await emitAck(guest, "room:join", {
    roomCode: "ZZ99ZZ",
  });
  assert.equal(missingRoom.message, "Room not found");

  const created = await emitAck(host, "room:create", {
    gameType: "war",
    maxPlayers: 2,
    isPrivate: true,
    allowBots: true,
    allowChat: true,
    settings: {},
  });
  await emitAck(guest, "room:join", { roomCode: created.room.roomCode });

  const nonHostBot = await emitAck(guest, "room:add_bot", {
    roomCode: created.room.roomCode,
  });
  assert.equal(nonHostBot.message, "Only the host can perform this action");

  const earlyStart = await emitAck(host, "room:start_game", {
    roomCode: created.room.roomCode,
  });
  assert.equal(earlyStart.message, "Waiting for all players to be ready");

  const emptyChat = await emitAck(host, "chat:send", {
    roomCode: created.room.roomCode,
    message: "   ",
  });
  assert.equal(emptyChat.message, "Message cannot be empty");
});

test("online High Card synchronizes rounds, match result, and rematch", async () => {
  const host = await connectUser("high_card_host", "High Host");
  const guest = await connectUser("high_card_guest", "High Guest");
  const created = await emitAck(host, "room:create", {
    gameType: "high_card",
    maxPlayers: 2,
    isPrivate: true,
    allowBots: true,
    allowChat: true,
    settings: { maxRounds: 3 },
  });
  const roomCode = created.room.roomCode;
  await emitAck(guest, "room:join", { roomCode });
  await emitAck(host, "room:toggle_ready", { roomCode });
  await emitAck(guest, "room:toggle_ready", { roomCode });

  const initialStatePromise = once(host, "high_card:state");
  const started = await emitAck(host, "room:start_game", { roomCode });
  assert.equal(started.success, true);
  const initialState = await initialStatePromise;
  assert.equal(initialState.status, "playing");
  assert.equal(initialState.currentRound, 1);
  assert.equal(initialState.maxRounds, 3);
  assert.equal("deck" in initialState, false);

  const loaded = await emitAck(guest, "high_card:init", { roomCode });
  assert.equal(loaded.game.players.length, 2);
  assert.equal("deck" in loaded.game, false);

  for (let round = 1; round <= 3; round += 1) {
    const resultPromise = once(guest, "high_card:round_result");
    const statePromise = onceWhere(
      guest,
      "high_card:state",
      (state) => state.currentRound === round && state.roundResult != null,
    );
    const draw = await emitAck(host, "high_card:draw", { roomCode });
    assert.equal(draw.success, true);
    const result = await resultPromise;
    const state = await statePromise;
    assert.equal(result.roundNumber, round);
    assert.equal(Object.keys(result.cards).length, 2);
    assert.equal("deck" in state, false);

    const duplicate = await emitAck(guest, "high_card:draw", { roomCode });
    assert.equal(duplicate.success, false);

    if (round < 3) {
      const next = await emitAck(guest, "high_card:next_round", { roomCode });
      assert.equal(next.game.currentRound, round + 1);
      assert.equal(next.game.status, "playing");
    } else {
      assert.equal(state.status, "match_over");
      assert.ok(state.matchWinner);
    }
  }

  const requested = await emitAck(host, "high_card:rematch_request", {
    roomCode,
  });
  assert.deepEqual(requested.game.rematchRequests, ["high_card_host"]);

  const rematchPromise = once(guest, "high_card:rematch_started");
  const accepted = await emitAck(guest, "high_card:rematch_accept", {
    roomCode,
  });
  assert.equal(accepted.game.status, "playing");
  const rematch = await rematchPromise;
  assert.equal(rematch.currentRound, 1);
  assert.equal(rematch.roundHistory.length, 0);
  assert.deepEqual(rematch.scores, {
    high_card_host: 0,
    high_card_guest: 0,
  });
});

test("High Card bot participates and full deck stays server-side", async () => {
  const host = await connectUser("bot_host", "Bot Host");
  const created = await emitAck(host, "room:create", {
    gameType: "high_card",
    maxPlayers: 2,
    isPrivate: true,
    allowBots: true,
    allowChat: false,
    settings: { maxRounds: 3 },
  });
  const roomCode = created.room.roomCode;
  await emitAck(host, "room:toggle_ready", { roomCode });
  await emitAck(host, "room:add_bot", { roomCode });
  await emitAck(host, "room:start_game", { roomCode });

  const draw = await emitAck(host, "high_card:draw", { roomCode });
  assert.equal(Object.keys(draw.game.currentCards).length, 2);
  assert.equal("deck" in draw.game, false);
  assert.equal(highCardService.getGame(roomCode).deck.length, 50);
});

test("online War synchronizes battles, hides decks, and starts a rematch", async () => {
  const host = await connectUser("war_host", "War Host");
  const guest = await connectUser("war_guest", "War Guest");
  const created = await emitAck(host, "room:create", {
    gameType: "war",
    maxPlayers: 2,
    isPrivate: true,
    allowBots: true,
    allowChat: true,
    settings: { maxBattles: 25, warMode: "classic" },
  });
  const roomCode = created.room.roomCode;
  await emitAck(guest, "room:join", { roomCode });
  await emitAck(host, "room:toggle_ready", { roomCode });
  await emitAck(guest, "room:toggle_ready", { roomCode });

  const initialStatePromise = once(host, "war:state");
  const startEventPromise = once(guest, "room:game_starting");
  await emitAck(host, "room:start_game", { roomCode });
  assert.equal((await startEventPromise).screen, "war_multiplayer");
  const initial = await initialStatePromise;
  assert.equal(initial.status, "playing");
  assert.equal(initial.currentBattle, 1);
  assert.equal("playerDecks" in initial, false);
  assert.equal("battlePile" in initial, false);

  const game = warService.getGame(roomCode);
  game.maxBattles = 2;
  const battleResultPromise = once(guest, "war:battle_result");
  const first = await emitAck(host, "war:battle", { roomCode });
  assert.equal(first.success, true);
  assert.equal((await battleResultPromise).battleNumber, 1);
  assert.equal("playerDecks" in first.game, false);
  assert.equal(
    Object.values(first.game.cardCounts).reduce((sum, count) => sum + count, 0),
    52,
  );

  const duplicate = await emitAck(guest, "war:battle", { roomCode });
  assert.equal(duplicate.success, false);
  const next = await emitAck(guest, "war:next_battle", { roomCode });
  assert.equal(next.game.currentBattle, 2);
  const final = await emitAck(host, "war:battle", { roomCode });
  assert.equal(final.game.status, "match_over");
  assert.ok(final.game.matchWinner);

  const requested = await emitAck(host, "war:rematch_request", { roomCode });
  assert.deepEqual(requested.game.rematchRequests, ["war_host"]);
  const rematchPromise = once(guest, "war:rematch_started");
  const accepted = await emitAck(guest, "war:rematch_accept", { roomCode });
  assert.equal(accepted.game.status, "playing");
  const rematch = await rematchPromise;
  assert.equal(rematch.currentBattle, 1);
  assert.equal(rematch.battleHistory.length, 0);
  assert.deepEqual(rematch.scores, { war_host: 0, war_guest: 0 });
});

test("War bot participates while server retains all decks", async () => {
  const host = await connectUser("war_bot_host", "War Bot Host");
  const created = await emitAck(host, "room:create", {
    gameType: "war",
    maxPlayers: 2,
    isPrivate: true,
    allowBots: true,
    allowChat: false,
    settings: { maxBattles: 25, warMode: "quick" },
  });
  const roomCode = created.room.roomCode;
  await emitAck(host, "room:toggle_ready", { roomCode });
  await emitAck(host, "room:add_bot", { roomCode });
  await emitAck(host, "room:start_game", { roomCode });

  const battle = await emitAck(host, "war:battle", { roomCode });
  assert.equal(Object.keys(battle.game.currentBattleCards).length, 2);
  assert.equal("playerDecks" in battle.game, false);
  const serverGame = warService.getGame(roomCode);
  assert.equal(
    Object.values(serverGame.playerDecks).reduce(
      (sum, cards) => sum + cards.length,
      0,
    ),
    52,
  );
});

test("online Blackjack synchronizes betting, dealer play, results, and rematch", async () => {
  const host = await connectUser("blackjack_host", "Blackjack Host");
  const guest = await connectUser("blackjack_guest", "Blackjack Guest");
  const created = await emitAck(host, "room:create", {
    gameType: "blackjack",
    maxPlayers: 2,
    isPrivate: true,
    allowBots: true,
    allowChat: true,
    settings: {
      maxRounds: 3,
      startingChips: 1000,
      minimumBet: 10,
      dealerRule: "stand_on_17",
    },
  });
  const roomCode = created.room.roomCode;
  await emitAck(guest, "room:join", { roomCode });
  await emitAck(host, "room:toggle_ready", { roomCode });
  await emitAck(guest, "room:toggle_ready", { roomCode });

  const startEvent = once(guest, "room:game_starting");
  await emitAck(host, "room:start_game", { roomCode });
  assert.equal((await startEvent).screen, "blackjack_multiplayer");
  const initial = blackjackService.getGame(roomCode);
  initial.maxRounds = 1;

  const bet = await emitAck(guest, "blackjack:place_bet", {
    roomCode,
    amount: 100,
  });
  assert.equal(bet.game.playerBets.blackjack_guest, 100);
  assert.equal("deck" in bet.game, false);

  const started = await emitAck(host, "blackjack:start_round", { roomCode });
  assert.equal("deck" in started.game, false);
  assert.equal(started.game.dealer.hand.length, 2);
  const game = blackjackService.getGame(roomCode);
  game.status = "playing";
  game.dealer = {
    hand: [blackjackCard("10"), blackjackCard("7")],
    score: 0,
    isHidden: true,
  };
  game.playerHands = {
    blackjack_host: [blackjackCard("10"), blackjackCard("7")],
    blackjack_guest: [blackjackCard("10"), blackjackCard("7")],
  };
  game.playerStatuses = {
    blackjack_host: "playing",
    blackjack_guest: "playing",
  };
  game.roundHistory = [];
  game.roundResults = {};
  game.matchResults = null;
  game.deck.push(blackjackCard("2"));

  const hit = await emitAck(guest, "blackjack:hit", { roomCode });
  assert.equal(hit.game.playerHands.blackjack_guest.length, 3);
  assert.equal(hit.game.playerStatuses.blackjack_guest, "playing");
  await emitAck(guest, "blackjack:stand", { roomCode });
  await emitAck(host, "blackjack:stand", { roomCode });

  const finished = blackjackService.getGame(roomCode);
  assert.equal(finished.status, "match_over");
  assert.equal(finished.dealer.isHidden, false);
  assert.equal(Object.keys(finished.roundResults).length, 2);
  assert.equal(finished.roundHistory.length, 1);
  assert.ok(finished.matchResults);

  const requested = await emitAck(host, "blackjack:rematch_request", {
    roomCode,
  });
  assert.deepEqual(requested.game.rematchRequests, ["blackjack_host"]);
  const rematch = await emitAck(guest, "blackjack:rematch_accept", {
    roomCode,
  });
  assert.equal(rematch.game.status, "betting");
  assert.equal(rematch.game.currentRound, 1);
  assert.deepEqual(rematch.game.playerChips, {
    blackjack_host: 1000,
    blackjack_guest: 1000,
  });
});

async function connectUser(userId, username) {
  const client = createClient(baseUrl, {
    transports: ["websocket"],
    forceNew: true,
    reconnection: false,
  });
  clients.push(client);
  await once(client, "connect");
  const response = await emitAck(client, "user:connect", {
    userId,
    username,
    avatar: "default",
    level: 1,
  });
  assert.equal(response.success, true);
  return client;
}

function emitAck(client, event, payload) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(
      () => reject(new Error(`${event} timed out`)),
      3000,
    );
    client.emit(event, payload, (response) => {
      clearTimeout(timeout);
      resolve(response);
    });
  });
}

function once(client, event) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(
      () => reject(new Error(`${event} timed out`)),
      3000,
    );
    client.once(event, (payload) => {
      clearTimeout(timeout);
      resolve(payload);
    });
  });
}

function onceWhere(client, event, predicate) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      client.off(event, handler);
      reject(new Error(`${event} timed out`));
    }, 3000);
    function handler(payload) {
      if (!predicate(payload)) return;
      clearTimeout(timeout);
      client.off(event, handler);
      resolve(payload);
    }
    client.on(event, handler);
  });
}

function blackjackCard(rank) {
  return {
    suit: "spades",
    rank,
    value: Number(rank) || 14,
    displayName: `${rank} of Spades`,
    suitSymbol: "♠",
    colorType: "black",
  };
}
