import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/models/room_model.dart';
import 'package:cardverse/features/multiplayer/models/room_player_model.dart';
import 'package:cardverse/features/multiplayer/widgets/chat_bubble_widget.dart';
import 'package:cardverse/features/multiplayer/widgets/chat_input_widget.dart';
import 'package:cardverse/features/multiplayer/widgets/friend_tile_widget.dart';
import 'package:cardverse/features/multiplayer/widgets/ready_button_widget.dart';
import 'package:cardverse/features/multiplayer/widgets/room_player_slot_widget.dart';
import 'package:cardverse/features/multiplayer/widgets/room_settings_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RoomLobbyScreen extends StatefulWidget {
  const RoomLobbyScreen({required this.roomCode, super.key});

  final String roomCode;

  @override
  State<RoomLobbyScreen> createState() => _RoomLobbyScreenState();
}

class _RoomLobbyScreenState extends State<RoomLobbyScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _initialize();
  }

  Future<void> _initialize() async {
    final controllers = MultiplayerScope.of(context);
    var room = controllers.room.currentRoom;
    if (room == null || room.roomCode != widget.roomCode) {
      room = await controllers.room.joinRoom(widget.roomCode);
    }
    if (!mounted || room == null) return;
    await controllers.chat.loadMessages(room.roomCode);
    if (controllers.chat.messages.isEmpty) {
      await controllers.chat.addSystemMessage(
        controllers.room.isCurrentUserHost
            ? 'Room created. Invite friends or add a bot.'
            : 'Guest Player joined the room.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllers = MultiplayerScope.of(context);
    return AnimatedBuilder(
      animation: controllers.room,
      builder: (context, child) {
        final room = controllers.room.currentRoom;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Room Lobby'),
            actions: [
              IconButton(
                tooltip: 'Leave room',
                onPressed: room == null ? null : () => _leaveRoom(controllers),
                icon: const Icon(Icons.exit_to_app_rounded),
              ),
            ],
          ),
          body: room == null
              ? _MissingRoom(
                  isLoading: controllers.room.isLoading,
                  message: controllers.room.errorMessage,
                )
              : SafeArea(
                  top: false,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 36),
                    children: [
                      _RoomHeader(
                        roomName: room.roomName,
                        roomCode: room.roomCode,
                        gameName: room.gameName,
                        roomType: room.roomType,
                        status: room.status,
                        onCopy: () => _copyCode(room.roomCode),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Player Slots',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(
                            '${room.currentPlayerCount}/${room.maxPlayers}',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(room.maxPlayers, (seatIndex) {
                        RoomPlayerModel? player;
                        for (final candidate in room.players) {
                          if (candidate.seatIndex == seatIndex) {
                            player = candidate;
                            break;
                          }
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: RoomPlayerSlotWidget(
                            seatIndex: seatIndex,
                            player: player,
                            isCurrentUser: player?.id == 'current_user',
                            onRemove:
                                controllers.room.isCurrentUserHost &&
                                    player != null &&
                                    player.id != 'current_user'
                                ? () async {
                                    await controllers.room.removePlayer(
                                      player!.id,
                                    );
                                    await controllers.chat.addSystemMessage(
                                      '${player.username} left the room.',
                                    );
                                  }
                                : null,
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      RoomSettingsCardWidget(settings: room.settings),
                      const SizedBox(height: 20),
                      _LobbyControls(
                        room: room,
                        isHost: controllers.room.isCurrentUserHost,
                        canStart: controllers.room.canStartGame,
                        onReady: () async {
                          final changed = await controllers.room.toggleReady();
                          if (!changed) return;
                          final player = _currentPlayer(
                            controllers.room.currentRoom?.players ?? const [],
                          );
                          await controllers.chat.addSystemMessage(
                            player?.isReady == true
                                ? 'Guest Player is ready.'
                                : 'Guest Player is not ready.',
                          );
                        },
                        onAddBot: () async {
                          final added = await controllers.room.addBot();
                          if (added) {
                            await controllers.chat.addSystemMessage(
                              'A card bot joined the room.',
                            );
                          } else if (mounted) {
                            _message(
                              controllers.room.errorMessage ??
                                  'Could not add a bot.',
                            );
                          }
                        },
                        onInvite: () => _showInviteSheet(controllers),
                        onStart: () {
                          final config = controllers.room.startGame();
                          if (config == null) {
                            _message('Waiting for all players to be ready.');
                            return;
                          }
                          context.push(
                            '${AppRoutes.multiplayerPlaceholder}/${room.roomCode}',
                          );
                        },
                      ),
                      if (room.allowChat) ...[
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Room Chat',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ChatPanel(controllers: controllers),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> _copyCode(String roomCode) async {
    await Clipboard.setData(ClipboardData(text: roomCode));
    if (mounted) _message('Room code copied.');
  }

  Future<void> _showInviteSheet(MultiplayerControllers controllers) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.deepGreen,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.72,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Invite Friends',
                        style: Theme.of(sheetContext).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: controllers.friends.friends.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final friend = controllers.friends.friends[index];
                    return FriendTileWidget(
                      friend: friend,
                      onInvite: friend.status == 'offline'
                          ? null
                          : () async {
                              await controllers.invites.sendInvite(
                                friend,
                                controllers.room.currentRoom!,
                              );
                              if (!sheetContext.mounted) return;
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Invite sent to ${friend.username}.',
                                  ),
                                ),
                              );
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _leaveRoom(MultiplayerControllers controllers) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave room?'),
        content: const Text('You will return to the CardVerse home screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await controllers.chat.addSystemMessage('Guest Player left the room.');
    await controllers.room.leaveRoom();
    controllers.chat.clearMessages();
    if (mounted) context.go(AppRoutes.home);
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LobbyControls extends StatelessWidget {
  const _LobbyControls({
    required this.room,
    required this.isHost,
    required this.canStart,
    required this.onReady,
    required this.onAddBot,
    required this.onInvite,
    required this.onStart,
  });

  final RoomModel room;
  final bool isHost;
  final bool canStart;
  final VoidCallback onReady;
  final VoidCallback onAddBot;
  final VoidCallback onInvite;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final currentPlayer = _currentPlayer(room.players);
    return Column(
      children: [
        ReadyButtonWidget(
          isReady: currentPlayer?.isReady ?? false,
          onPressed: onReady,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (room.allowBots)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: room.hasEmptySeats ? onAddBot : null,
                  icon: const Icon(Icons.smart_toy_outlined),
                  label: const Text('Add Bot'),
                ),
              ),
            if (room.allowBots) const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onInvite,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Invite'),
              ),
            ),
          ],
        ),
        if (isHost) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: canStart
                    ? AppColors.gold
                    : AppColors.cardGreen,
                foregroundColor: canStart ? AppColors.ink : AppColors.mutedText,
                side: const BorderSide(color: AppColors.gold),
                minimumSize: const Size.fromHeight(54),
              ),
              icon: const Icon(Icons.sports_esports_rounded),
              label: const Text('Start Game'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({required this.controllers});

  final MultiplayerControllers controllers;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controllers.chat,
    builder: (context, child) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 110, maxHeight: 280),
            child: controllers.chat.messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontFamily: 'Arial',
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: controllers.chat.messages.length,
                    itemBuilder: (context, index) {
                      final message = controllers.chat.messages[index];
                      return ChatBubbleWidget(
                        message: message,
                        isCurrentUser: message.senderId == 'current_user',
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
          ChatInputWidget(onSend: controllers.chat.sendMessage),
        ],
      ),
    ),
  );
}

class _RoomHeader extends StatelessWidget {
  const _RoomHeader({
    required this.roomName,
    required this.roomCode,
    required this.gameName,
    required this.roomType,
    required this.status,
    required this.onCopy,
  });

  final String roomName;
  final String roomCode;
  final String gameName;
  final String roomType;
  final String status;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.cardGreen,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.gold),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(roomName, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                roomCode,
                style: const TextStyle(
                  color: AppColors.paleGold,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                ),
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Copy room code',
              onPressed: onCopy,
              icon: const Icon(Icons.content_copy_rounded),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HeaderChip(icon: Icons.style_rounded, label: gameName),
            _HeaderChip(
              icon: roomType == 'private'
                  ? Icons.lock_rounded
                  : Icons.public_rounded,
              label: roomType,
            ),
            _HeaderChip(icon: Icons.circle, label: status),
          ],
        ),
      ],
    ),
  );
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.inputGreen,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.gold),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontFamily: 'Arial', fontSize: 12)),
      ],
    ),
  );
}

class _MissingRoom extends StatelessWidget {
  const _MissingRoom({required this.isLoading, required this.message});

  final bool isLoading;
  final String? message;

  @override
  Widget build(BuildContext context) => Center(
    child: isLoading
        ? const CircularProgressIndicator(color: AppColors.gold)
        : Text(message ?? 'Room not found.'),
  );
}

RoomPlayerModel? _currentPlayer(List<RoomPlayerModel> players) {
  for (final player in players) {
    if (player.id == 'current_user') return player;
  }
  return null;
}
