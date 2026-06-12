import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/network/socket_connection_state.dart';
import 'package:cardverse/features/multiplayer/blackjack/widgets/blackjack_multiplayer_action_buttons_widget.dart';
import 'package:cardverse/features/multiplayer/blackjack/widgets/blackjack_multiplayer_bet_widget.dart';
import 'package:cardverse/features/multiplayer/blackjack/widgets/blackjack_multiplayer_dealer_widget.dart';
import 'package:cardverse/features/multiplayer/blackjack/widgets/blackjack_multiplayer_result_widget.dart';
import 'package:cardverse/features/multiplayer/blackjack/widgets/blackjack_multiplayer_scoreboard_widget.dart';
import 'package:cardverse/features/multiplayer/blackjack/widgets/blackjack_multiplayer_table_widget.dart';
import 'package:cardverse/features/multiplayer/blackjack/widgets/blackjack_rematch_panel_widget.dart';
import 'package:cardverse/features/multiplayer/blackjack/widgets/blackjack_round_history_widget.dart';
import 'package:cardverse/features/multiplayer/blackjack/widgets/blackjack_status_banner_widget.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/widgets/chat_bubble_widget.dart';
import 'package:cardverse/features/multiplayer/widgets/chat_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlackjackMultiplayerScreen extends StatefulWidget {
  const BlackjackMultiplayerScreen({required this.roomCode, super.key});

  final String roomCode;

  @override
  State<BlackjackMultiplayerScreen> createState() =>
      _BlackjackMultiplayerScreenState();
}

class _BlackjackMultiplayerScreenState extends State<BlackjackMultiplayerScreen>
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
      controllers.blackjack.connectAndLoadGame(widget.roomCode),
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
    final game = controllers.blackjack;
    return AnimatedBuilder(
      animation: Listenable.merge([game, controllers.connection]),
      builder: (context, child) {
        final state = game.gameState;
        final connected =
            game.isConnected &&
            controllers.connection.state == SocketConnectionState.connected;
        final currentPlayers =
            state?.players
                .where((player) => player.id == game.currentUserId)
                .toList() ??
            const [];
        final currentPlayer = currentPlayers.isEmpty
            ? null
            : currentPlayers.first;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Online Blackjack'),
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
                      BlackjackStatusBannerWidget(
                        roomCode: state.roomCode,
                        currentRound: state.currentRound,
                        maxRounds: state.maxRounds,
                        status: state.status,
                      ),
                      const SizedBox(height: 14),
                      BlackjackMultiplayerScoreboardWidget(
                        state: state,
                        currentUserId: game.currentUserId,
                      ),
                      const SizedBox(height: 14),
                      BlackjackMultiplayerDealerWidget(dealer: state.dealer),
                      const SizedBox(height: 14),
                      BlackjackMultiplayerTableWidget(
                        state: state,
                        currentUserId: game.currentUserId,
                      ),
                      const SizedBox(height: 14),
                      BlackjackMultiplayerResultWidget(
                        state: state,
                        currentUserId: game.currentUserId,
                      ),
                      if (state.status == 'betting') ...[
                        const SizedBox(height: 14),
                        BlackjackMultiplayerBetWidget(
                          chips: state.playerChips[game.currentUserId] ?? 0,
                          currentBet: state.playerBets[game.currentUserId] ?? 0,
                          minimumBet: state.minimumBet,
                          enabled: connected,
                          isLoading: game.isPlacingBet,
                          onBet: game.placeBet,
                        ),
                      ],
                      if (game.actionNotice != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          game.actionNotice!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.paleGold,
                            fontFamily: 'Arial',
                          ),
                        ),
                      ],
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
                      const SizedBox(height: 14),
                      BlackjackMultiplayerActionButtonsWidget(
                        status: state.status,
                        canAct: game.canAct,
                        isHost: currentPlayer?.isHost ?? false,
                        connected: connected,
                        isBusy:
                            game.isStartingRound ||
                            game.isActing ||
                            game.isAdvancing,
                        onStartRound: game.startRound,
                        onHit: game.hit,
                        onStand: game.stand,
                        onNextRound: game.nextRound,
                      ),
                      if (state.status == 'match_over') ...[
                        const SizedBox(height: 12),
                        BlackjackRematchPanelWidget(
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
                        const SizedBox(height: 16),
                        BlackjackRoundHistoryWidget(rounds: state.roundHistory),
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
        title: const Text('Leave Blackjack table?'),
        content: const Text('You will be removed from this online match.'),
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
    await controllers.blackjack.leaveGame();
    await controllers.room.leaveRoom();
    controllers.chat.clearMessages();
    if (mounted) context.go(AppRoutes.home);
  }
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
          child: Text('Disconnected. Blackjack actions are disabled.'),
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
          Text(
            message ?? 'Loading online Blackjack...',
            textAlign: TextAlign.center,
          ),
          if (!isLoading) ...[
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ],
      ),
    ),
  );
}
