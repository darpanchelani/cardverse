import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/widgets/room_player_slot_widget.dart';
import 'package:cardverse/features/multiplayer/widgets/room_settings_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MultiplayerGamePlaceholderScreen extends StatelessWidget {
  const MultiplayerGamePlaceholderScreen({required this.roomCode, super.key});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    final controllers = MultiplayerScope.of(context);
    final room = controllers.room.currentRoom;
    if (room == null || room.roomCode != roomCode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Multiplayer')),
        body: const Center(child: Text('Room session is no longer available.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(room.gameName)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          children: [
            const Icon(
              Icons.sports_esports_rounded,
              color: AppColors.gold,
              size: 72,
            ),
            const SizedBox(height: 14),
            Text(
              '${room.gameName} Room',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 6),
            Text(
              room.roomCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.paleGold,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.gold),
              ),
              child: const Text(
                'This multiplayer game is not available yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Arial', height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            Text('Players', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...room.players.map(
              (player) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: RoomPlayerSlotWidget(
                  seatIndex: player.seatIndex,
                  player: player,
                  isCurrentUser: player.id == controllers.room.localUserId,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Room Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            RoomSettingsCardWidget(settings: room.settings),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  context.go('${AppRoutes.roomLobby}/${room.roomCode}'),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Lobby'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                MultiplayerScope.of(context).room.clearRoom();
                context.go(AppRoutes.home);
              },
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
