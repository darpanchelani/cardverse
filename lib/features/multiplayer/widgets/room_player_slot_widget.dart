import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/models/room_player_model.dart';
import 'package:flutter/material.dart';

class RoomPlayerSlotWidget extends StatelessWidget {
  const RoomPlayerSlotWidget({
    required this.seatIndex,
    super.key,
    this.player,
    this.isCurrentUser = false,
    this.onRemove,
  });

  final int seatIndex;
  final RoomPlayerModel? player;
  final bool isCurrentUser;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final occupant = player;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.gold.withValues(alpha: 0.12)
            : AppColors.cardGreen,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: isCurrentUser ? AppColors.gold : AppColors.border,
        ),
      ),
      child: occupant == null
          ? Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.inputGreen,
                  child: Icon(Icons.person_outline, color: AppColors.mutedText),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Waiting for player...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.inputGreen,
                  child: Icon(
                    occupant.isBot
                        ? Icons.smart_toy_rounded
                        : Icons.person_rounded,
                    color: AppColors.paleGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        occupant.username,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: [
                          if (occupant.isHost)
                            const _Badge(label: 'HOST', color: AppColors.gold),
                          _Badge(
                            label: occupant.isReady ? 'READY' : 'NOT READY',
                            color: occupant.isReady
                                ? Colors.greenAccent
                                : AppColors.mutedText,
                          ),
                          if (occupant.isBot)
                            const _Badge(
                              label: 'BOT',
                              color: Colors.lightBlueAccent,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    tooltip: 'Remove player',
                    onPressed: onRemove,
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontFamily: 'Arial',
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
