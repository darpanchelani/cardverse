function createAuthController(authService) {
  return {
    google: async (request, response, next) => {
      try {
        const data = await authService.loginWithGoogle(request.body);
        response.json({
          success: true,
          message: "Google sign-in successful",
          data,
        });
      } catch (error) {
        next(error);
      }
    },
    me: async (request, response) => {
      response.json({
        success: true,
        message: "Authenticated user loaded",
        data: { user: request.user.toSafeObject() },
      });
    },
    logout: async (request, response) => {
      request.user.isOnline = false;
      request.user.socketId = null;
      request.user.lastSeenAt = new Date();
      await request.user.save();
      response.json({ success: true, message: "Logout successful", data: {} });
    },
  };
}

module.exports = { createAuthController };
