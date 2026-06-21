function createSettingsController(service) {
  return {
    update: async (request, response, next) => {
      try {
        response.json({
          success: true,
          message: "Settings updated",
          data: { user: await service.update(request.user, request.body) },
        });
      } catch (error) {
        next(error);
      }
    },
  };
}

module.exports = { createSettingsController };
