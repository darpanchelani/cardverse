import 'package:cardverse/app/routes.dart';
import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/core/utils/number_format_utils.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
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
    final auth = AuthScope.maybeOf(context);
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
            final cloud = auth?.user;
            final stats = [
              (
                'Level',
                '${cloud?.level ?? profile.level}',
                Icons.military_tech_outlined,
              ),
              ('XP', '${cloud?.xp ?? profile.xp}', Icons.auto_awesome_outlined),
              (
                'Coins',
                '${cloud?.coins ?? profile.coins}',
                Icons.monetization_on_outlined,
              ),
              (
                'Games',
                '${cloud?.totalGames ?? profile.totalGames}',
                Icons.style_outlined,
              ),
              (
                'Wins',
                '${cloud?.totalWins ?? profile.totalWins}',
                Icons.emoji_events_outlined,
              ),
              (
                'Losses',
                '${cloud?.totalLosses ?? profile.totalLosses}',
                Icons.close_rounded,
              ),
              (
                'Draws',
                '${cloud?.totalDraws ?? profile.totalDraws}',
                Icons.sync_rounded,
              ),
              (
                'Win Rate',
                NumberFormatUtils.percentage(cloud?.winRate ?? profile.winRate),
                Icons.donut_large_rounded,
              ),
              (
                'Win Streak',
                '${cloud?.currentStreak ?? profile.currentStreak}',
                Icons.local_fire_department_outlined,
              ),
              (
                'Best Streak',
                '${cloud?.bestStreak ?? profile.bestStreak}',
                Icons.bolt_rounded,
              ),
            ];
            final unlocked = controller.achievements
                .where((item) => item.isUnlocked)
                .take(3)
                .toList();
            final recentMatches = controller.matchHistory.take(3).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              children: [
                _CloudBanner(isAuthenticated: auth?.isAuthenticated ?? false),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _avatarFrameColor(cloud?.avatarFrame ?? 'default'),
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.gold,
                    child: Text(
                      _initials(cloud?.username ?? profile.username),
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  cloud?.username ?? profile.username,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (cloud != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Card: ${cloud.equippedCardTheme} · Table: ${cloud.equippedTableTheme}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  cloud == null
                      ? 'Favorite game: ${profile.favoriteGame}'
                      : '${cloud.email} · Favorite game: ${cloud.favoriteGame}',
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
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.customization),
                  icon: const Icon(Icons.palette_outlined),
                  label: const Text('Customize Cards and Table'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.accountSettings),
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: const Text('Account Settings'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.appSettings),
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('App Settings'),
                ),
                const SizedBox(height: 10),
                if (auth?.isAuthenticated == true) ...[
                  OutlinedButton.icon(
                    onPressed: () => _editProfile(context, auth!),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Cloud Profile'),
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Login to Save Online'),
                  ),
                  const SizedBox(height: 10),
                ],
                OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, auth),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                  ),
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

  Future<void> _confirmLogout(
    BuildContext context,
    AuthController? auth,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Your account progress and match history will stay saved on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final multiplayer = MultiplayerScope.of(context);
    final progress = ProgressScope.of(context);
    if (multiplayer.room.currentRoom != null &&
        multiplayer.connection.isConnected) {
      await multiplayer.room.leaveRoom();
    }
    multiplayer.chat.clearMessages();
    multiplayer.highCard.clear();
    multiplayer.war.clear();
    multiplayer.blackjack.clear();
    multiplayer.room.clearRoom();
    multiplayer.connection.disconnect();

    await auth?.logout();
    if (!context.mounted) return;
    AppServicesScope.maybeOf(context)?.notifications.clear();
    AppServicesScope.maybeOf(context)?.invites.clear();
    final storage = await LocalStorageService.create();
    var guestId = await storage.getString(StorageKeys.multiplayerUserId);
    guestId ??=
        'guest_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
    await storage.saveString(StorageKeys.multiplayerUserId, guestId);
    await progress.switchAccount(accountId: 'guest', username: 'Guest Player');
    multiplayer.updateIdentity(
      userId: guestId,
      username: 'Guest Player',
      level: progress.profile.level,
    );
    if (context.mounted) context.go(AppRoutes.login);
  }

  Future<void> _editProfile(BuildContext context, AuthController auth) async {
    final username = TextEditingController(text: auth.user?.username);
    final avatar = TextEditingController(text: auth.user?.avatar);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit cloud profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: avatar,
              decoration: const InputDecoration(labelText: 'Avatar'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await auth.updateProfile(
        username: username.text.trim(),
        avatar: avatar.text.trim(),
      );
    }
    username.dispose();
    avatar.dispose();
  }
}

class _CloudBanner extends StatelessWidget {
  const _CloudBanner({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: (isAuthenticated ? Colors.greenAccent : AppColors.gold).withValues(
        alpha: 0.1,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isAuthenticated ? Colors.greenAccent : AppColors.gold,
      ),
    ),
    child: Row(
      children: [
        Icon(
          isAuthenticated ? Icons.cloud_done_outlined : Icons.cloud_off,
          color: isAuthenticated ? Colors.greenAccent : AppColors.gold,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isAuthenticated
                ? 'Cloud profile active. Online matches sync automatically.'
                : 'Guest mode: create an account to save online progress.',
          ),
        ),
      ],
    ),
  );
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'CV';
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length.clamp(1, 2))
        .toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

Color _avatarFrameColor(String frame) => switch (frame) {
  'bronze' => const Color(0xFFB87333),
  'silver' => const Color(0xFFC0C0C0),
  'gold' || 'champion' => AppColors.gold,
  _ => AppColors.border,
};

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
