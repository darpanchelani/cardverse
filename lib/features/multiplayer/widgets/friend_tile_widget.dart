import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/models/friend_model.dart';
import 'package:cardverse/features/multiplayer/widgets/online_status_dot_widget.dart';
import 'package:flutter/material.dart';

class FriendTileWidget extends StatelessWidget {
  const FriendTileWidget({
    required this.friend,
    super.key,
    this.onInvite,
    this.onRemove,
    this.actionTooltip,
  });

  final FriendModel friend;
  final VoidCallback? onInvite;
  final VoidCallback? onRemove;
  final String? actionTooltip;

  @override
  Widget build(BuildContext context) {
    final statusLabel = friend.status.replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.inputGreen,
                child: Text(
                  friend.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.paleGold,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: OnlineStatusDotWidget(status: friend.status, size: 13),
              ),
            ],
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.username,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  'Level ${friend.level}  •  ${friend.wins} wins',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                    fontFamily: 'Arial',
                  ),
                ),
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: friend.isOnline
                        ? AppColors.gold
                        : AppColors.mutedText,
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
          ),
          if (onInvite != null)
            IconButton(
              tooltip: actionTooltip ?? 'Invite ${friend.username}',
              onPressed: onInvite,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              color: AppColors.gold,
            ),
          if (onRemove != null)
            PopupMenuButton<String>(
              tooltip: 'Friend options',
              onSelected: (value) {
                if (value == 'remove') onRemove?.call();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'remove', child: Text('Remove friend')),
              ],
            ),
        ],
      ),
    );
  }
}
