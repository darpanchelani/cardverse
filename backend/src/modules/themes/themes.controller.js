function createThemesController(service) {
  return {
    list: (request, response) =>
      response.json({
        success: true,
        data: { themes: service.list(request.user) },
      }),
    purchase: async (request, response, next) => {
      try {
        response.json({
          success: true,
          message: "Theme unlocked",
          data: { user: await service.purchase(request.user, request.body) },
        });
      } catch (error) {
        next(error);
      }
    },
    equip: async (request, response, next) => {
      try {
        response.json({
          success: true,
          message: "Theme equipped",
          data: { user: await service.equip(request.user, request.body) },
        });
      } catch (error) {
        next(error);
      }
    },
  };
}

module.exports = { createThemesController };
