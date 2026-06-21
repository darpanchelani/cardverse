import 'package:cardverse/app/routes.dart';
import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:cardverse/features/games/war/war_controller.dart';
import 'package:cardverse/features/games/war/widgets/war_battle_area_widget.dart';
import 'package:cardverse/features/games/war/widgets/war_result_widget.dart';
import 'package:cardverse/features/games/war/widgets/war_score_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WarScreen extends StatefulWidget {
  const WarScreen({super.key, this.controller});

  final WarController? controller;

  @override
  State<WarScreen> createState() => _WarScreenState();
}

class _WarScreenState extends State<WarScreen> {
  late final WarController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? WarController();
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
      backgroundColor: AppServicesScope.maybeOf(
        context,
      )?.customization.tableColor,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to game selection',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('War'),
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
                        'War',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Win battles and collect all cards',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 22),
                      WarScoreBoardWidget(
                        playerCards: state.playerDeck.length,
                        computerCards: state.computerDeck.length,
                        roundNumber: state.roundNumber,
                        warCount: state.warCount,
                        playerRoundsWon: state.playerRoundsWon,
                        computerRoundsWon: state.computerRoundsWon,
                      ),
                      const SizedBox(height: 24),
                      WarBattleAreaWidget(state: state),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: WarResultWidget(
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
                        label: state.isGameOver ? 'Game Over' : 'Battle',
                        icon: state.isGameOver
                            ? Icons.flag_rounded
                            : Icons.local_fire_department_rounded,
                        onPressed: state.isGameOver
                            ? null
                            : _controller.playRound,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'New Game',
                        icon: Icons.refresh_rounded,
                        isOutlined: true,
                        onPressed: _controller.startNewGame,
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
