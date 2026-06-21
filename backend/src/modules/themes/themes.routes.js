const express = require("express");
const { authenticate } = require("../../middleware/auth.middleware");
const { createThemesController } = require("./themes.controller");
const { ThemesService } = require("./themes.service");

function createThemesRouter() {
  const router = express.Router();
  const controller = createThemesController(new ThemesService());
  router.use(authenticate);
  router.get("/", controller.list);
  router.post("/purchase", controller.purchase);
  router.post("/equip", controller.equip);
  return router;
}

module.exports = { createThemesRouter };
