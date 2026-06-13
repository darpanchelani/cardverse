function createFriendsController(service) {
  return {
    list: async (request, response, next) => {
      try {
        response.json({
          success: true,
          data: { friends: await service.list(request.user.id) },
        });
      } catch (error) {
        next(error);
      }
    },
    requests: async (request, response, next) => {
      try {
        response.json({
          success: true,
          data: await service.requests(request.user.id),
        });
      } catch (error) {
        next(error);
      }
    },
    send: async (request, response, next) => {
      try {
        const friendRequest = await service.sendRequest(
          request.user.id,
          request.body.toUserId,
        );
        response.status(201).json({
          success: true,
          message: "Friend request sent",
          data: { request: friendRequest },
        });
      } catch (error) {
        next(error);
      }
    },
    accept: async (request, response, next) => {
      try {
        await service.accept(request.params.requestId, request.user.id);
        response.json({
          success: true,
          message: "Friend request accepted",
          data: {},
        });
      } catch (error) {
        next(error);
      }
    },
    decline: async (request, response, next) => {
      try {
        await service.decline(request.params.requestId, request.user.id);
        response.json({
          success: true,
          message: "Friend request declined",
          data: {},
        });
      } catch (error) {
        next(error);
      }
    },
    remove: async (request, response, next) => {
      try {
        await service.remove(request.user.id, request.params.friendId);
        response.json({
          success: true,
          message: "Friend removed",
          data: {},
        });
      } catch (error) {
        next(error);
      }
    },
  };
}

module.exports = { createFriendsController };
