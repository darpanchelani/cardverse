import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:cardverse/features/games/high_card/high_card_controller.dart';
import 'package:cardverse/features/games/high_card/high_card_state.dart';
import 'package:cardverse/features/games/high_card/widgets/game_result_widget.dart';
import 'package:cardverse/features/games/high_card/widgets/playing_card_widget.dart';
import 'package:cardverse/features/games/high_card/widgets/score_board_widget.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HighCardScreen extends StatefulWidget {
  const HighCardScreen({super.key});

  @override
  State<HighCardScreen> createState() => _HighCardScreenState();
}

class _HighCardScreenState extends State<HighCardScreen> {
  late final HighCardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HighCardController();
  }

  @override
  void dispose() {
    _controller.dispose();
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
        title: const Text('High Card'),
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
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'High Card',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Draw cards and beat the computer',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ScoreBoardWidget(
                        playerScore: state.playerScore,
                        computerScore: state.computerScore,
                        drawScore: state.drawScore,
                        roundNumber: state.roundNumber,
                        remainingCards: state.remainingCards,
                      ),
                      const SizedBox(height: 24),
                      _GameTable(state: state),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: GameResultWidget(
                          key: ValueKey(
                            '${state.roundNumber}-${state.resultMessage}',
                          ),
                          message: state.resultMessage,
                          result: state.lastResult,
                          isGameOver: state.isGameOver,
                        ),
                      ),
                      const SizedBox(height: 18),
                      CustomButton(
                        label: state.isGameOver
                            ? 'Deck Finished'
                            : 'Draw Cards',
                        icon: state.isGameOver
                            ? Icons.layers_clear_rounded
                            : Icons.style_rounded,
                        onPressed: state.isGameOver
                            ? null
                            : _controller.drawCards,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: 'New Game',
                              icon: Icons.refresh_rounded,
                              isOutlined: true,
                              onPressed: _controller.startNewGame,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: _controller.resetScores,
                              icon: const Icon(Icons.restart_alt_rounded),
                              label: const Text('Reset Scores'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.mutedText,
                                minimumSize: const Size(0, 54),
                              ),
                            ),
                          ),
                        ],
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

class _GameTable extends StatelessWidget {
  const _GameTable({required this.state});

  final HighCardState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          radius: 1.1,
          colors: [AppColors.tableGreen, AppColors.inputGreen],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 310;
          final cardWidth =
              (horizontal
                      ? ((constraints.maxWidth - 22) / 2).clamp(110.0, 210.0)
                      : constraints.maxWidth.clamp(120.0, 190.0))
                  .toDouble();

          final player = _AnimatedPlayingCard(
            width: cardWidth,
            roundNumber: state.roundNumber,
            label: 'You',
            card: state.playerCard,
          );
          final computer = _AnimatedPlayingCard(
            width: cardWidth,
            roundNumber: state.roundNumber,
            label: 'Computer',
            card: state.computerCard,
          );

          if (!horizontal) {
            return Column(
              children: [player, const SizedBox(height: 22), computer],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [player, const SizedBox(width: 22), computer],
          );
        },
      ),
    );
  }
}

class _AnimatedPlayingCard extends StatelessWidget {
  const _AnimatedPlayingCard({
    required this.width,
    required this.roundNumber,
    required this.label,
    required this.card,
  });

  final double width;
  final int roundNumber;
  final String label;
  final PlayingCardModel? card;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: PlayingCardWidget(
          key: ValueKey('$label-$roundNumber'),
          label: label,
          card: card,
          showBack: card == null,
        ),
      ),
    );
  }
}
