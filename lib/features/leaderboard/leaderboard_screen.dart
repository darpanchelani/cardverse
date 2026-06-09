import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const _players = [
    ('Darpan', 120),
    ('Ali', 95),
    ('Sara', 80),
    ('Ahmed', 60),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
          itemCount: _players.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final player = _players[index];
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: index == 0 ? AppColors.gold : AppColors.cardGreen,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: index == 0 ? AppColors.paleGold : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: index == 0
                        ? AppColors.ink.withValues(alpha: 0.12)
                        : AppColors.inputGreen,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: index == 0 ? AppColors.ink : AppColors.paleGold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      player.$1,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: index == 0 ? AppColors.ink : AppColors.white,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.emoji_events_rounded,
                    color: index == 0 ? AppColors.ink : AppColors.gold,
                    size: 20,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '${player.$2} wins',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: index == 0 ? AppColors.ink : AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
