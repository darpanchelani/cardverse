const express = require("express");
const { success } = require("../utils/response");

function createHealthRouter() {
  const router = express.Router();
  router.get("/", (_request, response) => {
    response.json(success({}, "CardVerse backend is running"));
  });
  return router;
}

module.exports = { createHealthRouter };
