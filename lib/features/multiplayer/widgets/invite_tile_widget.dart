import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/models/invite_model.dart';
import 'package:flutter/material.dart';

class InviteTileWidget extends StatelessWidget {
  const InviteTileWidget({
    required this.invite,
    super.key,
    this.onAccept,
    this.onDecline,
  });

  final InviteModel invite;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final pending = invite.status == 'pending';
    final age = DateTime.now().difference(invite.createdAt);
    final time = age.inMinutes < 60
        ? '${age.inMinutes}m ago'
        : '${age.inHours}h ago';
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.inputGreen,
                child: Icon(Icons.mail_outline_rounded, color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${invite.fromUsername} invited you',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${invite.gameName}  •  ${invite.roomCode}  •  $time',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          if (pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            )
          else
            Text(
              invite.status.toUpperCase(),
              style: const TextStyle(
                color: AppColors.gold,
                fontFamily: 'Arial',
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}
