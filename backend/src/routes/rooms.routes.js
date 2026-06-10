const express = require("express");
const { success } = require("../utils/response");

function createRoomsRouter(roomService) {
  const router = express.Router();
  router.get("/public", (_request, response) => {
    response.json(
      success({ rooms: roomService.getPublicRooms() }, "Public rooms loaded"),
    );
  });
  return router;
}

module.exports = { createRoomsRouter };
