import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/utils/number_format_utils.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/widgets/achievement_badge_widget.dart';
import 'package:cardverse/features/progress/widgets/match_history_tile_widget.dart';
import 'package:cardverse/features/progress/widgets/stats_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProgressScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh progress',
            onPressed: controller.refreshProgress,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }
            final profile = controller.profile;
            final stats = [
              ('Level', '${profile.level}', Icons.military_tech_outlined),
              ('XP', '${profile.xp}', Icons.auto_awesome_outlined),
              ('Coins', '${profile.coins}', Icons.monetization_on_outlined),
              ('Games', '${profile.totalGames}', Icons.style_outlined),
              ('Wins', '${profile.totalWins}', Icons.emoji_events_outlined),
              ('Losses', '${profile.totalLosses}', Icons.close_rounded),
              ('Draws', '${profile.totalDraws}', Icons.sync_rounded),
              (
                'Win Rate',
                NumberFormatUtils.percentage(profile.winRate),
                Icons.donut_large_rounded,
              ),
              (
                'Win Streak',
                '${profile.currentStreak}',
                Icons.local_fire_department_outlined,
              ),
              ('Best Streak', '${profile.bestStreak}', Icons.bolt_rounded),
            ];
            final unlocked = controller.achievements
                .where((item) => item.isUnlocked)
                .take(3)
                .toList();
            final recentMatches = controller.matchHistory.take(3).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              children: [
                const CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.gold,
                  child: Text(
                    'GP',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.username,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Favorite game: ${profile.favoriteGame}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.gold),
                ),
                const SizedBox(height: 28),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 620 ? 3 : 2;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 11,
                        crossAxisSpacing: 11,
                        mainAxisExtent: 125,
                      ),
                      itemBuilder: (context, index) {
                        final stat = stats[index];
                        return StatsCardWidget(
                          label: stat.$1,
                          value: stat.$2,
                          icon: stat.$3,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Recent Achievements',
                  actionLabel: 'View All',
                  onPressed: () => context.push(AppRoutes.achievements),
                ),
                const SizedBox(height: 10),
                if (unlocked.isEmpty)
                  const _EmptyPanel(
                    icon: Icons.lock_outline_rounded,
                    text: 'Play games to unlock achievements.',
                  )
                else
                  ...unlocked.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: AchievementBadgeWidget(
                        achievement: item,
                        compact: true,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'Recent Matches',
                  actionLabel: 'View All',
                  onPressed: () => context.push(AppRoutes.matchHistory),
                ),
                const SizedBox(height: 10),
                if (recentMatches.isEmpty)
                  const _EmptyPanel(
                    icon: Icons.history_rounded,
                    text: 'Your recent matches will appear here.',
                  )
                else
                  ...recentMatches.map(
                    (match) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: MatchHistoryTileWidget(match: match),
                    ),
                  ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.matchHistory),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('View Match History'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.achievements),
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: const Text('View Achievements'),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _confirmReset(context, controller),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Reset Local Progress'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    ProgressController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset local progress?'),
        content: const Text(
          'This clears your profile, stats, rewards, achievements, and history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.clearProgress();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}
