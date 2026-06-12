import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/network/socket_connection_state.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/controllers/room_controller.dart';
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
  RoomController? _roomController;
  int _handledGameStartRevision = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final roomController = MultiplayerScope.of(context).room;
    if (_roomController != roomController) {
      _roomController?.removeListener(_handleGameStart);
      _roomController = roomController;
      _handledGameStartRevision = roomController.gameStartRevision;
      roomController.addListener(_handleGameStart);
    }
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
  }

  void _handleGameStart() {
    final controller = _roomController;
    if (!mounted ||
        controller == null ||
        controller.gameStartRevision <= _handledGameStartRevision ||
        controller.gameStartingConfig?.roomCode != widget.roomCode) {
      return;
    }
    _handledGameStartRevision = controller.gameStartRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final config = controller.gameStartingConfig!;
        final route = config.gameType == 'high_card'
            ? AppRoutes.multiplayerHighCard
            : AppRoutes.multiplayerPlaceholder;
        context.push('$route/${widget.roomCode}');
      }
    });
  }

  @override
  void dispose() {
    _roomController?.removeListener(_handleGameStart);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllers = MultiplayerScope.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([controllers.room, controllers.connection]),
      builder: (context, child) {
        final room = controllers.room.currentRoom;
        final connected = controllers.room.isConnected;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Room Lobby'),
            actions: [
              _ConnectionIndicator(
                state: connected
                    ? SocketConnectionState.connected
                    : controllers.connection.state,
              ),
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
                      if (!connected) ...[
                        _DisconnectedBanner(
                          isConnecting: controllers.connection.isConnecting,
                          onReconnect: controllers.connection.reconnect,
                        ),
                        const SizedBox(height: 12),
                      ],
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
                            isCurrentUser:
                                player?.id == controllers.room.localUserId,
                            onRemove:
                                connected &&
                                    controllers.room.isCurrentUserHost &&
                                    player != null &&
                                    player.id != controllers.room.localUserId &&
                                    player.isBot
                                ? () async {
                                    await controllers.room.removePlayer(
                                      player!.id,
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
                        localUserId: controllers.room.localUserId,
                        isHost: controllers.room.isCurrentUserHost,
                        canStart: controllers.room.canStartGame,
                        isConnected: connected,
                        onReady: () {
                          controllers.room.toggleReady();
                        },
                        onAddBot: () async {
                          final added = await controllers.room.addBot();
                          if (!added && mounted) {
                            _message(
                              controllers.room.errorMessage ??
                                  'Could not add a bot.',
                            );
                          }
                        },
                        onInvite: () => _showInviteSheet(controllers),
                        onStart: () async {
                          final started = await controllers.room.startGame();
                          if (!started && mounted) {
                            _message(
                              controllers.room.errorMessage ??
                                  'Waiting for all players to be ready.',
                            );
                          }
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
                        _ChatPanel(
                          controllers: controllers,
                          isConnected: connected,
                          localUserId: controllers.room.localUserId,
                        ),
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
    required this.localUserId,
    required this.isHost,
    required this.canStart,
    required this.onReady,
    required this.onAddBot,
    required this.onInvite,
    required this.onStart,
    required this.isConnected,
  });

  final RoomModel room;
  final String localUserId;
  final bool isHost;
  final bool canStart;
  final VoidCallback onReady;
  final VoidCallback onAddBot;
  final VoidCallback onInvite;
  final VoidCallback onStart;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final currentPlayer = _currentPlayer(
      room.players,
      localUserId: localUserId,
    );
    return Column(
      children: [
        ReadyButtonWidget(
          isReady: currentPlayer?.isReady ?? false,
          onPressed: isConnected ? onReady : null,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (room.allowBots)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isConnected && room.hasEmptySeats
                      ? onAddBot
                      : null,
                  icon: const Icon(Icons.smart_toy_outlined),
                  label: const Text('Add Bot'),
                ),
              ),
            if (room.allowBots) const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isConnected ? onInvite : null,
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
              onPressed: isConnected ? onStart : null,
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
  const _ChatPanel({
    required this.controllers,
    required this.isConnected,
    required this.localUserId,
  });

  final MultiplayerControllers controllers;
  final bool isConnected;
  final String localUserId;

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
                        isCurrentUser: message.senderId == localUserId,
                      );
                    },
                  ),
          ),
          if (controllers.chat.isTyping &&
              controllers.chat.typingUsername != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${controllers.chat.typingUsername} is typing...',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          ChatInputWidget(
            onSend: controllers.chat.sendMessage,
            enabled: isConnected,
            onTypingStart: controllers.chat.sendTypingStart,
            onTypingStop: controllers.chat.sendTypingStop,
          ),
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

RoomPlayerModel? _currentPlayer(
  List<RoomPlayerModel> players, {
  required String localUserId,
}) {
  for (final player in players) {
    if (player.id == localUserId) return player;
  }
  return null;
}

class _ConnectionIndicator extends StatelessWidget {
  const _ConnectionIndicator({required this.state});

  final SocketConnectionState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      SocketConnectionState.connected => ('Connected', Colors.greenAccent),
      SocketConnectionState.connecting ||
      SocketConnectionState.reconnecting => ('Connecting', AppColors.gold),
      _ => ('Offline', AppColors.danger),
    };
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontFamily: 'Arial',
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DisconnectedBanner extends StatelessWidget {
  const _DisconnectedBanner({
    required this.isConnecting,
    required this.onReconnect,
  });

  final bool isConnecting;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.danger.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.danger),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off_rounded, color: AppColors.danger),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Disconnected from server. Trying to reconnect...',
            style: TextStyle(fontFamily: 'Arial'),
          ),
        ),
        TextButton(
          onPressed: isConnecting ? null : onReconnect,
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
