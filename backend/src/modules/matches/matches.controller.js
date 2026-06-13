function createMatchesController(service) {
  return {
    create: async (request, response, next) => {
      try {
        const match = await service.create(request.body, request.user.id);
        response.status(201).json({
          success: true,
          message: "Match saved",
          data: { match },
        });
      } catch (error) {
        next(error);
      }
    },
    mine: async (request, response, next) => {
      try {
        response.json({
          success: true,
          data: await service.mine(request.user.id, request.query),
        });
      } catch (error) {
        next(error);
      }
    },
    recent: async (_request, response, next) => {
      try {
        response.json({
          success: true,
          data: { matches: await service.recent() },
        });
      } catch (error) {
        next(error);
      }
    },
  };
}

module.exports = { createMatchesController };
