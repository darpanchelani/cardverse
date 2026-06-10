import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/widgets/game_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({required this.mode, super.key});

  final String mode;

  static const _games = [
    _GameData('High Card', Icons.filter_1_rounded, false),
    _GameData('War', Icons.local_fire_department_rounded, false),
    _GameData('Blackjack', Icons.casino_rounded, false),
    _GameData('Rummy', Icons.view_carousel_rounded, true),
    _GameData('Teen Patti', Icons.filter_3_rounded, true),
    _GameData('Poker', Icons.paid_outlined, true),
    _GameData('Crazy Eights', Icons.casino_outlined, true),
    _GameData('Bluff', Icons.visibility_off_outlined, true),
    _GameData('Spades', Icons.spa_outlined, true),
    _GameData('Hearts', Icons.favorite_outline_rounded, true),
    _GameData('Solitaire', Icons.layers_outlined, true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Game')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 600
                ? 3
                : 2;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      mode == 'computer'
                          ? 'Pick a table and challenge the house.'
                          : 'Pick a game for your room.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  sliver: SliverGrid.builder(
                    itemCount: _games.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      mainAxisExtent: 182,
                    ),
                    itemBuilder: (context, index) {
                      final game = _games[index];
                      return GameCard(
                        name: game.name,
                        icon: game.icon,
                        isLocked: game.isLocked,
                        onTap: () => _handleGameTap(context, game.name),
                        onLockedTap: () =>
                            _showMessage(context, 'This game is coming soon.'),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleGameTap(BuildContext context, String gameName) {
    switch (gameName) {
      case 'High Card':
        context.push(AppRoutes.highCard);
      case 'War':
        context.push(AppRoutes.war);
      case 'Blackjack':
        context.push(AppRoutes.blackjack);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _GameData {
  const _GameData(this.name, this.icon, this.isLocked);

  final String name;
  final IconData icon;
  final bool isLocked;
}
