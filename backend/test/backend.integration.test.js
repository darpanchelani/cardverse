const assert = require("node:assert/strict");
const http = require("node:http");
const { after, before, beforeEach, test } = require("node:test");
const { io: createClient } = require("socket.io-client");
const { createApp } = require("../src/app");
const { createSocketServer, roomService } = require("../src/socket");

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
    const timeout = setTimeout(() => reject(new Error(`${event} timed out`)), 3000);
    client.emit(event, payload, (response) => {
      clearTimeout(timeout);
      resolve(response);
    });
  });
}

function once(client, event) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error(`${event} timed out`)), 3000);
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
