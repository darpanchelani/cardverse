import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/widgets/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({
    required this.mode,
    super.key,
    this.embedded = false,
  });

  final String mode;
  final bool? embedded;

  static const _availableGames = [
    _GameData('High Card', Icons.filter_1_rounded, false),
    _GameData('War', Icons.local_fire_department_rounded, false),
    _GameData('Blackjack', Icons.casino_rounded, false),
  ];

  static const _comingSoon = [
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
    final body = SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Play',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode == 'computer'
                        ? 'Choose a game.'
                        : 'Choose a game for your room.',
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 20),
                  _GameGroup(
                    games: _availableGames,
                    onTap: (game) => _handleGameTap(context, game.name),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: AppColors.cardGreen,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.mutedText,
                      ),
                      title: const Text('Coming soon'),
                      subtitle: Text('${_comingSoon.length} more games'),
                      children: [
                        const Divider(height: 1),
                        for (
                          var index = 0;
                          index < _comingSoon.length;
                          index++
                        ) ...[
                          _GameTile(
                            game: _comingSoon[index],
                            onTap: () => _showMessage(
                              context,
                              'This game is coming soon.',
                            ),
                          ),
                          if (index < _comingSoon.length - 1)
                            const Divider(height: 1, indent: 56),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (embedded == true) return body;
    return Scaffold(
      appBar: const CardVerseTopBar(current: AppSection.play),
      bottomNavigationBar: const CardVerseBottomNavigation(
        current: AppSection.play,
      ),
      body: body,
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

class _GameGroup extends StatelessWidget {
  const _GameGroup({required this.games, required this.onTap});

  final List<_GameData> games;
  final ValueChanged<_GameData> onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.cardGreen,
    borderRadius: BorderRadius.circular(12),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var index = 0; index < games.length; index++) ...[
          _GameTile(game: games[index], onTap: () => onTap(games[index])),
          if (index < games.length - 1) const Divider(height: 1, indent: 56),
        ],
      ],
    ),
  );
}

class _GameTile extends StatelessWidget {
  const _GameTile({required this.game, required this.onTap});

  final _GameData game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 62,
    leading: Icon(
      game.isLocked ? Icons.lock_outline_rounded : game.icon,
      color: game.isLocked ? AppColors.mutedText : AppColors.gold,
    ),
    title: Text(game.name),
    subtitle: game.isLocked ? const Text('Coming soon') : null,
    trailing: Icon(
      game.isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded,
      size: 20,
    ),
    onTap: onTap,
  );
}

class _GameData {
  const _GameData(this.name, this.icon, this.isLocked);

  final String name;
  final IconData icon;
  final bool isLocked;
}
