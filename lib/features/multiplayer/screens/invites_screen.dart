import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/widgets/app_empty_state.dart';
import 'package:cardverse/core/widgets/app_error_view.dart';
import 'package:cardverse/core/widgets/app_loading_indicator.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/invites/widgets/room_invite_tile_widget.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvitesScreen extends StatelessWidget {
  const InvitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.maybeOf(context);
    final controller = AppServicesScope.of(context).invites;
    final multiplayer = MultiplayerScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invites'),
        actions: [
          IconButton(
            onPressed: controller.loadInvites,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: auth?.isAuthenticated != true
          ? const AppEmptyState(
              icon: Icons.login_rounded,
              title: 'Login required',
              message: 'Login to send and receive real room invitations.',
            )
          : AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                if (controller.isLoading) return const AppLoadingIndicator();
                if (controller.errorMessage != null &&
                    controller.invites.isEmpty) {
                  return AppErrorView(
                    message: controller.errorMessage!,
                    onRetry: controller.loadInvites,
                  );
                }
                if (controller.invites.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.mail_outline_rounded,
                    title: 'No invites yet',
                    message: 'Room invitations from your friends appear here.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.loadInvites,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      if (controller.incomingInvites.isNotEmpty) ...[
                        Text(
                          'Incoming',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        ...controller.incomingInvites.map(
                          (invite) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RoomInviteTileWidget(
                              invite: invite,
                              onAccept: invite.status == 'pending'
                                  ? () async {
                                      final accepted = await controller
                                          .acceptInvite(invite);
                                      final room = await multiplayer.room
                                          .joinRoom(accepted.roomCode);
                                      if (!context.mounted || room == null) {
                                        return;
                                      }
                                      context.push(
                                        '${AppRoutes.roomLobby}/${accepted.roomCode}',
                                      );
                                    }
                                  : null,
                              onDecline: invite.status == 'pending'
                                  ? () => controller.declineInvite(invite)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                      if (controller.outgoingInvites.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text(
                          'Sent',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        ...controller.outgoingInvites.map(
                          (invite) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RoomInviteTileWidget(
                              invite: invite,
                              onCancel: invite.status == 'pending'
                                  ? () => controller.cancelInvite(invite)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
