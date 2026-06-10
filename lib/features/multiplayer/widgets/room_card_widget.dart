import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/models/room_model.dart';
import 'package:flutter/material.dart';

class RoomCardWidget extends StatelessWidget {
  const RoomCardWidget({required this.room, required this.onJoin, super.key});

  final RoomModel room;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  room.roomName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Icon(
                room.isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                color: AppColors.gold,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            room.gameName,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.paleGold),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _Info(
                icon: Icons.groups_rounded,
                text: '${room.currentPlayerCount}/${room.maxPlayers}',
              ),
              _Info(icon: Icons.circle, text: room.status),
              _Info(
                icon: Icons.smart_toy_outlined,
                text: room.allowBots ? 'Bots allowed' : 'No bots',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: room.isFull ? null : onJoin,
              icon: const Icon(Icons.login_rounded),
              label: Text(room.isFull ? 'Room Full' : 'Join Room'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: AppColors.mutedText),
      const SizedBox(width: 5),
      Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.mutedText,
          fontFamily: 'Arial',
        ),
      ),
    ],
  );
}
