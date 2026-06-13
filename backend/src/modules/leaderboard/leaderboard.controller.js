function createLeaderboardController(service) {
  return {
    list: async (request, response, next) => {
      try {
        response.json({
          success: true,
          data: { leaderboard: await service.overall(request.query) },
        });
      } catch (error) {
        next(error);
      }
    },
    mine: async (request, response, next) => {
      try {
        response.json({
          success: true,
          data: { ranks: await service.mine(request.user.id) },
        });
      } catch (error) {
        next(error);
      }
    },
  };
}

module.exports = { createLeaderboardController };
