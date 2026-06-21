function createUserController(service) {
  return {
    me: (request, response) =>
      response.json({
        success: true,
        data: { user: request.user.toSafeObject() },
      }),
    update: async (request, response, next) => {
      try {
        const user = await service.update(request.user, request.body);
        response.json({
          success: true,
          message: "Profile updated",
          data: { user },
        });
      } catch (error) {
        next(error);
      }
    },
    search: async (request, response, next) => {
      try {
        const users = await service.search(request.query.query, request.user.id);
        response.json({ success: true, data: { users } });
      } catch (error) {
        next(error);
      }
    },
    profile: async (request, response, next) => {
      try {
        const user = await service.publicProfile(request.params.userId);
        response.json({ success: true, data: { user } });
      } catch (error) {
        next(error);
      }
    },
    remove: async (request, response, next) => {
      try {
        await service.softDelete(request.user);
        response.json({
          success: true,
          message: "Account deleted",
          data: {},
        });
      } catch (error) {
        next(error);
      }
    },
  };
}

module.exports = { createUserController };
