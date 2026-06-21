import 'package:cardverse/features/invites/models/room_invite_model.dart';
import 'package:flutter/material.dart';

class IncomingInviteDialog extends StatelessWidget {
  const IncomingInviteDialog({
    required this.invite,
    required this.onAccept,
    required this.onDecline,
    required this.onLater,
    super.key,
  });

  final RoomInviteModel invite;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Game Invite'),
    content: Text(
      '${invite.fromUsername} invited you to play ${invite.gameName}.\n\n'
      'Room code: ${invite.roomCode}',
    ),
    actions: [
      TextButton(onPressed: onLater, child: const Text('Later')),
      OutlinedButton(onPressed: onDecline, child: const Text('Decline')),
      FilledButton(onPressed: onAccept, child: const Text('Accept')),
    ],
  );
}
