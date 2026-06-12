import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.of(context);
    final actions = [
      _HomeAction(
        title: 'Play With Computer',
        subtitle: 'Practice against smart bots',
        icon: Icons.smart_toy_rounded,
        emphasized: true,
        onTap: () => context.push('${AppRoutes.games}/computer'),
      ),
      _HomeAction(
        title: 'Play With Friends',
        subtitle: 'Host a private card table',
        icon: Icons.groups_rounded,
        onTap: () => context.push(AppRoutes.createRoom),
      ),
      _HomeAction(
        title: 'Join Room',
        subtitle: 'Enter a friend’s room code',
        icon: Icons.meeting_room_outlined,
        onTap: () => context.push(AppRoutes.joinRoom),
      ),
      _HomeAction(
        title: 'Public Rooms',
        subtitle: 'Browse open multiplayer tables',
        icon: Icons.public_rounded,
        onTap: () => context.push(AppRoutes.publicRooms),
      ),
      _HomeAction(
        title: 'Friends',
        subtitle: 'See who is ready to play',
        icon: Icons.people_outline_rounded,
        onTap: () => context.push(AppRoutes.friends),
      ),
      _HomeAction(
        title: 'Invites',
        subtitle: 'Review your room invitations',
        icon: Icons.mail_outline_rounded,
        onTap: () => context.push(AppRoutes.invites),
      ),
      _HomeAction(
        title: 'Match History',
        subtitle: 'Review your recent results',
        icon: Icons.history_rounded,
        onTap: () => context.push(AppRoutes.matchHistory),
      ),
      _HomeAction(
        title: 'Leaderboard',
        subtitle: 'See the top players',
        icon: Icons.emoji_events_outlined,
        onTap: () => context.push(AppRoutes.leaderboard),
      ),
      _HomeAction(
        title: 'Profile',
        subtitle: 'View your player stats',
        icon: Icons.person_outline_rounded,
        onTap: () => context.push(AppRoutes.profile),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.gold,
                          child: AnimatedBuilder(
                            animation: progress,
                            builder: (context, child) => Text(
                              _initials(progress.profile.username),
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Arial',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to CardVerse',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              AnimatedBuilder(
                                animation: progress,
                                builder: (context, child) => Text(
                                  progress.profile.username,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.gold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Profile',
                          onPressed: () => context.push(AppRoutes.profile),
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 4),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: AnimatedBuilder(
                      animation: progress,
                      builder: (context, child) =>
                          _ProgressSummary(controller: progress),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.crossAxisExtent >= 650
                      ? 2
                      : 1;
                  return SliverGrid.builder(
                    itemCount: actions.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      mainAxisExtent: crossAxisCount == 1 ? 112 : 126,
                    ),
                    itemBuilder: (context, index) =>
                        _HomeActionCard(action: actions[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.controller});

  final ProgressController controller;

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile;
    final stats = [
      ('Level', '${profile.level}', Icons.military_tech_rounded),
      ('Coins', '${profile.coins}', Icons.monetization_on_rounded),
      ('Wins', '${profile.totalWins}', Icons.emoji_events_rounded),
      ('Streak', '${profile.currentStreak}', Icons.bolt_rounded),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: stats
            .map(
              (stat) => Expanded(
                child: Column(
                  children: [
                    Icon(stat.$3, color: AppColors.gold, size: 19),
                    const SizedBox(height: 5),
                    Text(
                      stat.$2,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.paleGold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      stat.$1,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                        fontFamily: 'Arial',
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({required this.action});

  final _HomeAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: action.emphasized ? AppColors.gold : AppColors.cardGreen,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: action.emphasized ? AppColors.paleGold : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: action.emphasized
                      ? AppColors.ink.withValues(alpha: 0.1)
                      : AppColors.inputGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  action.icon,
                  color: action.emphasized ? AppColors.ink : AppColors.paleGold,
                  size: 29,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: action.emphasized
                            ? AppColors.ink
                            : AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      action.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: action.emphasized
                            ? AppColors.ink.withValues(alpha: 0.7)
                            : AppColors.mutedText,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: action.emphasized ? AppColors.ink : AppColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasized;
}
