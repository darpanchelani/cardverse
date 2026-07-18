import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/widgets/app_navigation.dart';
import 'package:cardverse/features/notifications/widgets/notification_badge_widget.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.embedded = false});

  final bool? embedded;

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.of(context);
    final multiplayerActions = [
      _HomeAction(
        title: 'Create a room',
        icon: Icons.add_rounded,
        onTap: () => context.push(AppRoutes.createRoom),
      ),
      _HomeAction(
        title: 'Join a room',
        icon: Icons.login_rounded,
        onTap: () => context.push(AppRoutes.joinRoom),
      ),
      _HomeAction(
        title: 'Public rooms',
        icon: Icons.public_rounded,
        onTap: () => context.push(AppRoutes.publicRooms),
      ),
    ];
    final moreActions = [
      _HomeAction(
        title: 'Invites',
        icon: Icons.mail_outline_rounded,
        onTap: () => context.push(AppRoutes.invites),
      ),
      _HomeAction(
        title: 'Match history',
        icon: Icons.history_rounded,
        onTap: () => context.push(AppRoutes.matchHistory),
      ),
      _HomeAction(
        title: 'Customize',
        icon: Icons.palette_outlined,
        onTap: () => context.push(AppRoutes.customization),
      ),
      _HomeAction(
        title: 'Settings',
        icon: Icons.settings_outlined,
        onTap: () => context.push(AppRoutes.accountSettings),
      ),
    ];

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
                  AnimatedBuilder(
                    animation: progress,
                    builder: (context, child) =>
                        _HomeHeader(username: progress.profile.username),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: progress,
                    builder: (context, child) =>
                        _ProgressSummary(controller: progress),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => context.go('${AppRoutes.games}/computer'),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play against computer'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('Play with friends'),
                  const SizedBox(height: 8),
                  _ActionGroup(actions: multiplayerActions),
                  const SizedBox(height: 24),
                  const _SectionLabel('More'),
                  const SizedBox(height: 8),
                  _ActionGroup(actions: moreActions),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (embedded == true) return body;
    return Scaffold(
      appBar: const CardVerseTopBar(current: AppSection.home),
      bottomNavigationBar: const CardVerseBottomNavigation(
        current: AppSection.home,
      ),
      body: body,
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $username',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 3),
            const Text(
              'Ready for a game?',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
      if (AppServicesScope.maybeOf(context) != null)
        AnimatedBuilder(
          animation: AppServicesScope.of(context).notifications,
          builder: (context, child) => NotificationBadgeWidget(
            count: AppServicesScope.of(context).notifications.unreadCount,
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: () => context.push(AppRoutes.notifications),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ),
        ),
    ],
  );
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.controller});

  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile;
    final stats = [
      ('Level', '${profile.level}'),
      ('Wins', '${profile.totalWins}'),
      ('Coins', '${profile.coins}'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var index = 0; index < stats.length; index++) ...[
            if (index > 0)
              const SizedBox(height: 30, child: VerticalDivider(width: 1)),
            Expanded(
              child: Column(
                children: [
                  Text(
                    stats[index].$2,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stats[index].$1,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(color: AppColors.mutedText),
  );
}

class _ActionGroup extends StatelessWidget {
  const _ActionGroup({required this.actions});

  final List<_HomeAction> actions;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.cardGreen,
    borderRadius: BorderRadius.circular(12),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          ListTile(
            minTileHeight: 58,
            leading: Icon(actions[index].icon, color: AppColors.gold),
            title: Text(actions[index].title),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: actions[index].onTap,
          ),
          if (index < actions.length - 1) const Divider(height: 1, indent: 56),
        ],
      ],
    ),
  );
}

class _HomeAction {
  const _HomeAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}
