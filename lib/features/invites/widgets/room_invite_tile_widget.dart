import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/invites/models/room_invite_model.dart';
import 'package:flutter/material.dart';

class RoomInviteTileWidget extends StatelessWidget {
  const RoomInviteTileWidget({
    required this.invite,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    super.key,
  });

  final RoomInviteModel invite;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${invite.fromUsername} invited you',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            '${invite.gameName} · ${invite.roomCode}',
            style: const TextStyle(color: AppColors.gold),
          ),
          const SizedBox(height: 5),
          Text(
            invite.status.toUpperCase(),
            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
          if (invite.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onAccept != null)
                  Expanded(
                    child: FilledButton(
                      onPressed: onAccept,
                      child: const Text('Accept'),
                    ),
                  ),
                if (onAccept != null && onDecline != null)
                  const SizedBox(width: 10),
                if (onDecline != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('Cancel Invite'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}
