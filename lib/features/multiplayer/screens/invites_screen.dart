import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/widgets/invite_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvitesScreen extends StatelessWidget {
  const InvitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = MultiplayerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Invites')),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controllers.invites,
          builder: (context, child) {
            final invites = controllers.invites.invites;
            if (controllers.invites.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }
            if (invites.isEmpty) {
              return const _EmptyInvites();
            }
            final pending = invites
                .where((invite) => invite.status == 'pending')
                .toList();
            final previous = invites
                .where((invite) => invite.status != 'pending')
                .toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
              children: [
                if (pending.isNotEmpty) ...[
                  Text(
                    'Pending Invites',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  ...pending.map(
                    (invite) => Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: InviteTileWidget(
                        invite: invite,
                        onAccept: () async {
                          await controllers.invites.acceptInvite(invite);
                          final room = await controllers.room.joinRoom(
                            invite.roomCode,
                          );
                          if (!context.mounted || room == null) return;
                          context.push(
                            '${AppRoutes.roomLobby}/${invite.roomCode}',
                          );
                        },
                        onDecline: () =>
                            controllers.invites.declineInvite(invite),
                      ),
                    ),
                  ),
                ],
                if (previous.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Previous',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  ...previous.map(
                    (invite) => Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: InviteTileWidget(invite: invite),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyInvites extends StatelessWidget {
  const _EmptyInvites();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mail_outline_rounded, size: 62, color: AppColors.gold),
        const SizedBox(height: 14),
        Text('No invites yet', style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  );
}
