import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/network/socket_connection_state.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/high_card/controllers/high_card_multiplayer_controller.dart';
import 'package:cardverse/features/multiplayer/high_card/widgets/high_card_multiplayer_result_widget.dart';
import 'package:cardverse/features/multiplayer/high_card/widgets/high_card_multiplayer_scoreboard_widget.dart';
import 'package:cardverse/features/multiplayer/high_card/widgets/high_card_multiplayer_table_widget.dart';
import 'package:cardverse/features/multiplayer/high_card/widgets/high_card_round_history_widget.dart';
import 'package:cardverse/features/multiplayer/high_card/widgets/rematch_panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HighCardMultiplayerScreen extends StatefulWidget {
  const HighCardMultiplayerScreen({required this.roomCode, super.key});

  final String roomCode;

  @override
  State<HighCardMultiplayerScreen> createState() =>
      _HighCardMultiplayerScreenState();
}

class _HighCardMultiplayerScreenState extends State<HighCardMultiplayerScreen>
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
    await controllers.highCard.connectAndLoadGame(widget.roomCode);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadGame();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllers = MultiplayerScope.of(context);
    final game = controllers.highCard;
    return AnimatedBuilder(
      animation: Listenable.merge([game, controllers.connection]),
      builder: (context, child) {
        final state = game.gameState;
        final connected =
            game.isConnected &&
            controllers.connection.state == SocketConnectionState.connected;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Online High Card'),
            actions: [
              _ConnectionBadge(connected: connected),
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
                        currentRound: state.currentRound,
                        maxRounds: state.maxRounds,
                        status: state.status,
                      ),
                      const SizedBox(height: 16),
                      HighCardMultiplayerScoreboardWidget(
                        state: state,
                        currentUserId: game.currentUserId,
                      ),
                      const SizedBox(height: 16),
                      HighCardMultiplayerTableWidget(
                        state: state,
                        currentUserId: game.currentUserId,
                      ),
                      const SizedBox(height: 16),
                      HighCardMultiplayerResultWidget(
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
                        RematchPanelWidget(
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
                      if (state.roundHistory.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        HighCardRoundHistoryWidget(rounds: state.roundHistory),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> _confirmLeave(MultiplayerControllers controllers) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave online match?'),
        content: const Text(
          'The remaining player may be declared the match winner.',
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
    await controllers.highCard.leaveGame();
    await controllers.room.leaveRoom();
    controllers.chat.clearMessages();
    if (mounted) context.go(AppRoutes.home);
  }
}

class _GameActions extends StatelessWidget {
  const _GameActions({required this.controller, required this.connected});

  final HighCardMultiplayerController controller;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final status = controller.gameState?.status;
    if (status == 'playing') {
      return FilledButton.icon(
        onPressed: connected && !controller.isDrawing
            ? controller.drawCards
            : null,
        icon: const Icon(Icons.style_rounded),
        label: Text(controller.isDrawing ? 'Drawing...' : 'Draw Cards'),
      );
    }
    if (status == 'round_over') {
      return FilledButton.icon(
        onPressed: connected && !controller.isAdvancing
            ? controller.nextRound
            : null,
        icon: const Icon(Icons.skip_next_rounded),
        label: Text(controller.isAdvancing ? 'Starting...' : 'Next Round'),
      );
    }
    return const SizedBox.shrink();
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.roomCode,
    required this.currentRound,
    required this.maxRounds,
    required this.status,
  });

  final String roomCode;
  final int currentRound;
  final int maxRounds;
  final String status;

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
              'Round $currentRound / $maxRounds',
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              _statusLabel(status),
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
    'round_over' => 'Round Over',
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
  Widget build(BuildContext context) => Material(
    color: AppColors.danger.withValues(alpha: 0.13),
    borderRadius: BorderRadius.circular(16),
    child: ListTile(
      leading: const Icon(Icons.cloud_off_rounded, color: AppColors.danger),
      title: const Text('Disconnected from server'),
      subtitle: const Text('Actions are disabled until the room reconnects.'),
      trailing: TextButton(onPressed: onRetry, child: const Text('Retry')),
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
      child: isLoading
          ? const CircularProgressIndicator(color: AppColors.gold)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.danger,
                  size: 54,
                ),
                const SizedBox(height: 12),
                Text(
                  message ?? 'Online High Card is unavailable.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
    ),
  );
}
