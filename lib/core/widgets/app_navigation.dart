import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppSection { home, play, leaderboard, profile }

class CardVerseTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CardVerseTopBar({
    required this.current,
    super.key,
    this.actions = const [],
  });

  final AppSection current;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: isDesktop ? 28 : 18,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.style_rounded,
              color: AppColors.ink,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          const Text('CardVerse'),
        ],
      ),
      actions: [
        if (isDesktop) ...[
          _TopDestination(
            label: 'Home',
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            section: AppSection.home,
            current: current,
          ),
          _TopDestination(
            label: 'Play',
            icon: Icons.style_outlined,
            selectedIcon: Icons.style_rounded,
            section: AppSection.play,
            current: current,
          ),
          _TopDestination(
            label: 'Leaderboard',
            icon: Icons.emoji_events_outlined,
            selectedIcon: Icons.emoji_events_rounded,
            section: AppSection.leaderboard,
            current: current,
          ),
          _TopDestination(
            label: 'Profile',
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            section: AppSection.profile,
            current: current,
          ),
          const SizedBox(width: 8),
        ],
        ...actions,
        SizedBox(width: isDesktop ? 20 : 8),
      ],
    );
  }
}

class CardVerseBottomNavigation extends StatelessWidget {
  const CardVerseBottomNavigation({required this.current, super.key});

  final AppSection current;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 1024) {
      return const SizedBox.shrink();
    }
    return NavigationBar(
      selectedIndex: current.index,
      onDestinationSelected: (index) {
        final destination = AppSection.values[index];
        if (destination != current) _goTo(context, destination);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.style_outlined),
          selectedIcon: Icon(Icons.style_rounded),
          label: 'Play',
        ),
        NavigationDestination(
          icon: Icon(Icons.emoji_events_outlined),
          selectedIcon: Icon(Icons.emoji_events_rounded),
          label: 'Ranks',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _TopDestination extends StatelessWidget {
  const _TopDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.section,
    required this.current,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final AppSection section;
  final AppSection current;

  @override
  Widget build(BuildContext context) {
    final selected = section == current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton.icon(
        onPressed: selected ? null : () => _goTo(context, section),
        icon: Icon(selected ? selectedIcon : icon, size: 19),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: selected ? AppColors.ink : AppColors.mutedText,
          disabledForegroundColor: AppColors.ink,
          backgroundColor: selected ? AppColors.gold : Colors.transparent,
          disabledBackgroundColor: AppColors.gold,
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

void _goTo(BuildContext context, AppSection section) {
  final route = switch (section) {
    AppSection.home => AppRoutes.home,
    AppSection.play => '${AppRoutes.games}/computer',
    AppSection.leaderboard => AppRoutes.leaderboard,
    AppSection.profile => AppRoutes.profile,
  };
  context.go(route);
}
