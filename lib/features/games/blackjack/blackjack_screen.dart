import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/blackjack/blackjack_controller.dart';
import 'package:cardverse/features/games/blackjack/widgets/blackjack_action_buttons_widget.dart';
import 'package:cardverse/features/games/blackjack/widgets/blackjack_bet_widget.dart';
import 'package:cardverse/features/games/blackjack/widgets/blackjack_hand_widget.dart';
import 'package:cardverse/features/games/blackjack/widgets/blackjack_result_widget.dart';
import 'package:cardverse/features/games/blackjack/widgets/blackjack_score_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlackjackScreen extends StatefulWidget {
  const BlackjackScreen({super.key, this.controller});

  final BlackjackController? controller;

  @override
  State<BlackjackScreen> createState() => _BlackjackScreenState();
}

class _BlackjackScreenState extends State<BlackjackScreen> {
  late final BlackjackController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? BlackjackController();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('${AppRoutes.games}/computer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to game selection',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Blackjack'),
        actions: [
          IconButton(
            tooltip: 'Start a new game',
            onPressed: _controller.startNewGame,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final state = _controller.state;
            final dealerScore = state.isDealerCardHidden
                ? '?'
                : '${state.dealerScore}';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Blackjack',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Beat the dealer without going over 21',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 22),
                      BlackjackScoreBoardWidget(
                        chips: state.chips,
                        currentBet: state.currentBet,
                        roundNumber: state.roundNumber,
                        wins: state.wins,
                        losses: state.losses,
                        pushes: state.pushes,
                      ),
                      const SizedBox(height: 22),
                      BlackjackHandWidget(
                        label: 'Dealer',
                        cards: state.dealerHand,
                        scoreLabel: dealerScore,
                        hiddenCardIndex:
                            state.isDealerCardHidden &&
                                state.dealerHand.length > 1
                            ? 1
                            : null,
                      ),
                      const SizedBox(height: 14),
                      BlackjackHandWidget(
                        label: 'You',
                        cards: state.playerHand,
                        scoreLabel: '${state.playerScore}',
                      ),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: BlackjackResultWidget(
                          key: ValueKey(
                            '${state.roundNumber}-${state.resultMessage}',
                          ),
                          message: state.resultMessage,
                          result: state.roundResult,
                        ),
                      ),
                      const SizedBox(height: 18),
                      BlackjackBetWidget(
                        currentBet: state.currentBet,
                        chips: state.chips,
                        enabled: state.canChangeBet && !state.isGameOver,
                        onBetSelected: _controller.placeBet,
                        onDecrease: _controller.decreaseBet,
                        onIncrease: _controller.increaseBet,
                      ),
                      const SizedBox(height: 18),
                      BlackjackActionButtonsWidget(
                        state: state,
                        onStartRound: _controller.startRound,
                        onHit: _controller.hit,
                        onStand: _controller.stand,
                        onNewGame: _controller.startNewGame,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
