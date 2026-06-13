function createAchievementsController(service) {
  return {
    mine: (request, response) =>
      response.json({
        success: true,
        data: { achievements: service.listFor(request.user) },
      }),
  };
}

module.exports = { createAchievementsController };
