import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppSection { home, play, friends, leaderboard, profile }

class CardVerseTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CardVerseTopBar({
    required this.current,
    super.key,
    this.actions = const [],
    this.onSectionSelected,
  });

  final AppSection current;
  final List<Widget> actions;
  final ValueChanged<AppSection>? onSectionSelected;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: isDesktop ? 24 : 18,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.style_rounded, color: AppColors.gold, size: 24),
          const SizedBox(width: 9),
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
            onSelected: onSectionSelected,
          ),
          _TopDestination(
            label: 'Play',
            icon: Icons.style_outlined,
            selectedIcon: Icons.style_rounded,
            section: AppSection.play,
            current: current,
            onSelected: onSectionSelected,
          ),
          _TopDestination(
            label: 'Friends',
            icon: Icons.people_outline_rounded,
            selectedIcon: Icons.people_rounded,
            section: AppSection.friends,
            current: current,
            onSelected: onSectionSelected,
          ),
          _TopDestination(
            label: 'Leaderboard',
            icon: Icons.emoji_events_outlined,
            selectedIcon: Icons.emoji_events_rounded,
            section: AppSection.leaderboard,
            current: current,
            onSelected: onSectionSelected,
          ),
          _TopDestination(
            label: 'Profile',
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            section: AppSection.profile,
            current: current,
            onSelected: onSectionSelected,
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
  const CardVerseBottomNavigation({
    required this.current,
    super.key,
    this.onSectionSelected,
  });

  final AppSection current;
  final ValueChanged<AppSection>? onSectionSelected;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 1024) {
      return const SizedBox.shrink();
    }
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return NavigationBar(
      animationDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 200),
      selectedIndex: current.index,
      onDestinationSelected: (index) {
        final destination = AppSection.values[index];
        if (destination == current) return;
        if (onSectionSelected != null) {
          onSectionSelected!(destination);
        } else {
          _goTo(context, destination);
        }
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
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_rounded),
          label: 'Friends',
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
    this.onSelected,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final AppSection section;
  final AppSection current;
  final ValueChanged<AppSection>? onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = section == current;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 180);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        selected: selected,
        button: true,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          height: 38,
          decoration: ShapeDecoration(
            color: selected
                ? AppColors.gold.withValues(alpha: 0.14)
                : Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: selected
                  ? null
                  : () {
                      if (onSelected != null) {
                        onSelected!(section);
                      } else {
                        _goTo(context, section);
                      }
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: duration,
                      child: Icon(
                        selected ? selectedIcon : icon,
                        key: ValueKey(selected),
                        size: 19,
                        color: selected ? AppColors.gold : AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedDefaultTextStyle(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        color: selected ? AppColors.gold : AppColors.mutedText,
                        fontWeight: FontWeight.w800,
                      ),
                      child: Text(label),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardVerseNavigationShell extends StatelessWidget {
  const CardVerseNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final current = AppSection.values[navigationShell.currentIndex];
    return Scaffold(
      appBar: CardVerseTopBar(
        current: current,
        onSectionSelected: _selectSection,
      ),
      body: navigationShell,
      bottomNavigationBar: CardVerseBottomNavigation(
        current: current,
        onSectionSelected: _selectSection,
      ),
    );
  }

  void _selectSection(AppSection section) {
    if (section.index == navigationShell.currentIndex) return;
    navigationShell.goBranch(section.index);
  }
}

class CardVerseBranchContainer extends StatelessWidget {
  const CardVerseBranchContainer({
    required this.currentIndex,
    required this.children,
    super.key,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IndexedStack(
    index: currentIndex,
    sizing: StackFit.expand,
    children: [
      for (var index = 0; index < children.length; index++)
        TickerMode(
          enabled: index == currentIndex,
          child: RepaintBoundary(child: children[index]),
        ),
    ],
  );
}

void _goTo(BuildContext context, AppSection section) {
  final route = switch (section) {
    AppSection.home => AppRoutes.home,
    AppSection.play => '${AppRoutes.games}/computer',
    AppSection.friends => AppRoutes.friends,
    AppSection.leaderboard => AppRoutes.leaderboard,
    AppSection.profile => AppRoutes.profile,
  };
  context.go(route);
}
