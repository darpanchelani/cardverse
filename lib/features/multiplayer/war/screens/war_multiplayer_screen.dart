import 'package:cardverse/app/routes.dart';
import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/network/socket_connection_state.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/war/controllers/war_multiplayer_controller.dart';
import 'package:cardverse/features/multiplayer/war/widgets/war_battle_history_widget.dart';
import 'package:cardverse/features/multiplayer/war/widgets/war_multiplayer_result_widget.dart';
import 'package:cardverse/features/multiplayer/war/widgets/war_multiplayer_scoreboard_widget.dart';
import 'package:cardverse/features/multiplayer/war/widgets/war_multiplayer_table_widget.dart';
import 'package:cardverse/features/multiplayer/war/widgets/war_rematch_panel_widget.dart';
import 'package:cardverse/features/multiplayer/war/widgets/war_status_banner_widget.dart';
import 'package:cardverse/features/multiplayer/widgets/chat_bubble_widget.dart';
import 'package:cardverse/features/multiplayer/widgets/chat_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WarMultiplayerScreen extends StatefulWidget {
  const WarMultiplayerScreen({required this.roomCode, super.key});

  final String roomCode;

  @override
  State<WarMultiplayerScreen> createState() => _WarMultiplayerScreenState();
}

class _WarMultiplayerScreenState extends State<WarMultiplayerScreen>
    with WidgetsBindingObserver {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _loadGame();
  }

  Future<void> _loadGame() async {
    final controllers = MultiplayerScope.of(context);
    await controllers.room.connectIfNeeded();
    if (!mounted) return;
    await Future.wait([
      controllers.war.connectAndLoadGame(widget.roomCode),
      controllers.chat.loadMessages(widget.roomCode),
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) _loadGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllers = MultiplayerScope.of(context);
    final game = controllers.war;
    return AnimatedBuilder(
      animation: Listenable.merge([game, controllers.connection]),
      builder: (context, child) {
        final state = game.gameState;
        final connected =
            game.isConnected &&
            controllers.connection.state == SocketConnectionState.connected;
        return Scaffold(
          backgroundColor: AppServicesScope.maybeOf(
            context,
          )?.customization.tableColor,
          appBar: AppBar(
            title: const Text('Online War'),
            actions: [
              _ConnectionBadge(connected: connected),
              IconButton(
                tooltip: 'Room chat',
                onPressed: state == null
                    ? null
                    : () => _showChat(controllers, connected),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
              ),
              IconButton(
                tooltip: 'Leave game',
                onPressed: () => _confirmLeave(controllers),
                icon: const Icon(Icons.exit_to_app_rounded),
              ),
            ],
          ),
          body: state == null
              ? _LoadingState(
                  isLoading: game.isLoading,
                  message: game.errorMessage,
                  onRetry: _loadGame,
                )
              : SafeArea(
                  top: false,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                    children: [
                      if (!connected) ...[
                        _OfflineBanner(
                          onRetry: () async {
                            await controllers.connection.reconnect();
                            if (mounted) await _loadGame();
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      _GameHeader(
                        roomCode: state.roomCode,
                        currentBattle: state.currentBattle,
                        maxBattles: state.maxBattles,
                        status: state.status,
                        warMode: state.warMode,
                      ),
                      const SizedBox(height: 16),
                      WarMultiplayerScoreboardWidget(
                        state: state,
                        currentUserId: game.currentUserId,
                      ),
                      if (state.warCards.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        WarStatusBannerWidget(state: state),
                      ],
                      const SizedBox(height: 16),
                      WarMultiplayerTableWidget(
                        state: state,
                        currentUserId: game.currentUserId,
                      ),
                      const SizedBox(height: 16),
                      WarMultiplayerResultWidget(
                        state: state,
                        currentUserId: game.currentUserId,
                      ),
                      if (game.errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          game.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontFamily: 'Arial',
                          ),
                        ),
                      ],
                      if (game.rematchNotice != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          game.rematchNotice!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.paleGold,
                            fontFamily: 'Arial',
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _GameActions(controller: game, connected: connected),
                      if (state.status == 'match_over') ...[
                        const SizedBox(height: 12),
                        WarRematchPanelWidget(
                          hasRequested: game.hasRequestedRematch,
                          requestCount: state.rematchRequests.length,
                          humanCount: state.players
                              .where((player) => !player.isBot)
                              .length,
                          isLoading: game.isRequestingRematch,
                          onRequest: game.requestRematch,
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => context.go(
                            '${AppRoutes.roomLobby}/${state.roomCode}',
                          ),
                          icon: const Icon(Icons.groups_rounded),
                          label: const Text('Back to Lobby'),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _leaveToHome(controllers),
                          icon: const Icon(Icons.home_outlined),
                          label: const Text('Back to Home'),
                        ),
                      ],
                      if (state.battleHistory.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        WarBattleHistoryWidget(battles: state.battleHistory),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> _showChat(
    MultiplayerControllers controllers,
    bool connected,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.deepGreen,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.72,
          child: AnimatedBuilder(
            animation: controllers.chat,
            builder: (context, child) => Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                12 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'In-Game Chat',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  Expanded(
                    child: controllers.chat.messages.isEmpty
                        ? const Center(child: Text('No messages yet.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: controllers.chat.messages.length,
                            itemBuilder: (context, index) {
                              final message = controllers.chat.messages[index];
                              return ChatBubbleWidget(
                                message: message,
                                isCurrentUser:
                                    message.senderId ==
                                    controllers.room.localUserId,
                              );
                            },
                          ),
                  ),
                  if (controllers.chat.isTyping)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${controllers.chat.typingUsername} is typing...',
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontFamily: 'Arial',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  ChatInputWidget(
                    enabled: connected,
                    onSend: controllers.chat.sendMessage,
                    onTypingStart: controllers.chat.sendTypingStart,
                    onTypingStop: controllers.chat.sendTypingStop,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLeave(MultiplayerControllers controllers) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave online match?'),
        content: const Text(
          'Your deck will be removed and the remaining player may win.',
        ),
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
    if (confirmed == true && mounted) await _leaveToHome(controllers);
  }

  Future<void> _leaveToHome(MultiplayerControllers controllers) async {
    await controllers.war.leaveGame();
    await controllers.room.leaveRoom();
    controllers.chat.clearMessages();
    if (mounted) context.go(AppRoutes.home);
  }
}

class _GameActions extends StatelessWidget {
  const _GameActions({required this.controller, required this.connected});

  final WarMultiplayerController controller;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final status = controller.gameState?.status;
    if (status == 'playing') {
      return FilledButton.icon(
        onPressed: connected && !controller.isBattling
            ? controller.playBattle
            : null,
        icon: const Icon(Icons.bolt_rounded),
        label: Text(controller.isBattling ? 'Battling...' : 'Battle'),
      );
    }
    if (status == 'battle_over') {
      return FilledButton.icon(
        onPressed: connected && !controller.isAdvancing
            ? controller.nextBattle
            : null,
        icon: const Icon(Icons.skip_next_rounded),
        label: Text(controller.isAdvancing ? 'Starting...' : 'Next Battle'),
      );
    }
    return const SizedBox.shrink();
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.roomCode,
    required this.currentBattle,
    required this.maxBattles,
    required this.status,
    required this.warMode,
  });

  final String roomCode;
  final int currentBattle;
  final int? maxBattles;
  final String status;
  final String warMode;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardGreen,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.gold),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Room',
                style: TextStyle(
                  color: AppColors.mutedText,
                  fontFamily: 'Arial',
                  fontSize: 12,
                ),
              ),
              Text(
                roomCode,
                style: const TextStyle(
                  color: AppColors.paleGold,
                  fontFamily: 'Arial',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              maxBattles == null
                  ? 'Battle $currentBattle'
                  : 'Battle $currentBattle / $maxBattles',
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${_statusLabel(status)} · ${warMode == 'quick' ? 'Quick' : 'Classic'}',
              style: const TextStyle(
                color: AppColors.gold,
                fontFamily: 'Arial',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  String _statusLabel(String value) => switch (value) {
    'war_active' => 'War Active',
    'battle_over' => 'Battle Over',
    'match_over' => 'Match Over',
    _ => 'Playing',
  };
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: (connected ? Colors.greenAccent : AppColors.danger).withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        connected ? 'Connected' : 'Offline',
        style: TextStyle(
          color: connected ? Colors.greenAccent : AppColors.danger,
          fontFamily: 'Arial',
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.danger.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.danger),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Disconnected from server. Actions are disabled.',
            style: TextStyle(fontFamily: 'Arial'),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Reconnect')),
      ],
    ),
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const CircularProgressIndicator(color: AppColors.gold)
          else
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.danger,
              size: 52,
            ),
          const SizedBox(height: 16),
          Text(message ?? 'Loading online War...', textAlign: TextAlign.center),
          if (!isLoading) ...[
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ],
      ),
    ),
  );
}
