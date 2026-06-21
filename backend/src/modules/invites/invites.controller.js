function createInvitesController(service) {
  return {
    create: async (request, response, next) => {
      try {
        response.status(201).json({
          success: true,
          message: "Invite sent",
          data: {
            invite: await service.create(request.user.id, request.body),
          },
        });
      } catch (error) {
        next(error);
      }
    },
    list: async (request, response, next) => {
      try {
        response.json({
          success: true,
          data: await service.list(request.user.id),
        });
      } catch (error) {
        next(error);
      }
    },
    accept: action("accept"),
    decline: action("decline"),
    cancel: action("cancel"),
  };

  function action(method) {
    return async (request, response, next) => {
      try {
        const invite = await service[method](
          request.params.inviteId,
          request.user.id,
        );
        response.json({
          success: true,
          message: `Invite ${method}ed`,
          data: { invite, roomCode: invite.roomCode },
        });
      } catch (error) {
        next(error);
      }
    };
  }
}

module.exports = { createInvitesController };
