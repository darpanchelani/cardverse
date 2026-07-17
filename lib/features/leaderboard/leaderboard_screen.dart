import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/utils/number_format_utils.dart';
import 'package:cardverse/core/widgets/app_navigation.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/leaderboard/services/leaderboard_api_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/models/leaderboard_entry_model.dart';
import 'package:cardverse/features/progress/widgets/leaderboard_tile_widget.dart';
import 'package:flutter/material.dart';

enum LeaderboardPeriod { daily, weekly, overall }

extension on LeaderboardPeriod {
  String get apiValue => switch (this) {
    LeaderboardPeriod.daily => 'daily',
    LeaderboardPeriod.weekly => 'weekly',
    LeaderboardPeriod.overall => 'overall',
  };

  String get label => switch (this) {
    LeaderboardPeriod.daily => 'Daily',
    LeaderboardPeriod.weekly => 'Weekly',
    LeaderboardPeriod.overall => 'Overall',
  };
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, this.embedded = false});

  final bool? embedded;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardPeriod _period = LeaderboardPeriod.overall;
  String _metric = 'wins';
  List<LeaderboardEntryModel> _entries = [];
  bool _loading = true;
  bool _hasLoaded = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final controller = ProgressScope.of(context);
    final auth = AuthScope.maybeOf(context);
    final useCloud =
        auth?.isAuthenticated == true && ApiClient.globalInstance != null;
    try {
      final entries = useCloud
          ? await LeaderboardApiService(
              ApiClient.globalInstance!,
            ).getLeaderboard(_metric, period: _period.apiValue)
          : await controller.leaderboardFor(
              null,
              period: _period.apiValue,
              metric: _metric,
            );
      if (!mounted) return;
      setState(() => _entries = entries);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _entries = [];
        _errorMessage = useCloud
            ? 'Global rankings could not be loaded.'
            : 'Practice rankings could not be loaded.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProgressScope.of(context);
    final auth = AuthScope.maybeOf(context);
    final isCloud =
        auth?.isAuthenticated == true && ApiClient.globalInstance != null;
    final currentUsername = auth?.user?.username ?? controller.profile.username;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final body = SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: _LeaderboardHeader(
                    metric: _metric,
                    showRefresh: widget.embedded == true,
                    refreshing: _loading,
                    onRefresh: _load,
                    onMetricChanged: (metric) {
                      if (metric == _metric) return;
                      setState(() => _metric = metric);
                      _load();
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    children: [
                      _ModeBanner(isCloud: isCloud),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<LeaderboardPeriod>(
                          expandedInsets: EdgeInsets.zero,
                          showSelectedIcon: false,
                          segments: LeaderboardPeriod.values
                              .map(
                                (period) => ButtonSegment(
                                  value: period,
                                  label: Text(period.label),
                                ),
                              )
                              .toList(),
                          selected: {_period},
                          onSelectionChanged: (selection) {
                            final period = selection.first;
                            if (period == _period) return;
                            setState(() => _period = period);
                            _load();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey(
                        '${_period.apiValue}-$_metric-$_loading-${_errorMessage != null}',
                      ),
                      child: _LeaderboardBody(
                        entries: _entries,
                        metric: _metric,
                        period: _period,
                        currentUsername: currentUsername,
                        loading: _loading,
                        errorMessage: _errorMessage,
                        onRetry: _load,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.embedded == true) return body;
    return Scaffold(
      appBar: CardVerseTopBar(
        current: AppSection.leaderboard,
        actions: [
          IconButton(
            tooltip: 'Refresh leaderboard',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const CardVerseBottomNavigation(
        current: AppSection.leaderboard,
      ),
      body: body,
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader({
    required this.metric,
    required this.onMetricChanged,
    required this.showRefresh,
    required this.refreshing,
    required this.onRefresh,
  });

  final String metric;
  final ValueChanged<String> onMetricChanged;
  final bool showRefresh;
  final bool refreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;
        final title = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.ink,
                size: 27,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leaderboard',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'See who is setting the pace across CardVerse.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
            if (showRefresh) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Refresh leaderboard',
                onPressed: refreshing ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ],
        );
        final metricControl = _MetricMenu(
          value: metric,
          onChanged: onMetricChanged,
        );
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, const SizedBox(height: 18), metricControl],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: title),
            const SizedBox(width: 28),
            metricControl,
          ],
        );
      },
    );
  }
}

class _MetricMenu extends StatelessWidget {
  const _MetricMenu({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _metrics = {
    'wins': 'Wins',
    'xp': 'XP',
    'coins': 'Coins',
    'winRate': 'Win rate',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Change ranking metric',
      initialValue: value,
      onSelected: onChanged,
      color: AppColors.elevatedGreen,
      itemBuilder: (context) => _metrics.entries
          .map(
            (entry) =>
                PopupMenuItem(value: entry.key, child: Text(entry.value)),
          )
          .toList(),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.cardGreen,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.gold, size: 20),
            const SizedBox(width: 9),
            Text(
              'Rank by ${_metrics[value] ?? 'Wins'}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeBanner extends StatelessWidget {
  const _ModeBanner({required this.isCloud});

  final bool isCloud;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.cardGreen,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(
          isCloud ? Icons.public_rounded : Icons.phone_android_rounded,
          size: 20,
          color: AppColors.gold,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isCloud
                ? 'Global rankings from verified online matches'
                : 'Practice rankings on this device. Sign in for global standings.',
            style: const TextStyle(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _LeaderboardBody extends StatelessWidget {
  const _LeaderboardBody({
    required this.entries,
    required this.metric,
    required this.period,
    required this.currentUsername,
    required this.loading,
    required this.errorMessage,
    required this.onRetry,
  });

  final List<LeaderboardEntryModel> entries;
  final String metric;
  final LeaderboardPeriod period;
  final String currentUsername;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) return const _LeaderboardSkeleton();
    if (errorMessage != null) {
      return _LeaderboardMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Rankings are unavailable',
        message: errorMessage!,
        actionLabel: 'Try again',
        onPressed: onRetry,
      );
    }
    if (entries.isEmpty) {
      return const _LeaderboardMessage(
        icon: Icons.style_outlined,
        title: 'No ranked matches yet',
        message: 'Complete a match and your standing will appear here.',
      );
    }

    final podiumEntries = entries.take(3).toList();
    final remaining = entries.skip(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _periodSummary(period, metric),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.mutedText),
        ),
        const SizedBox(height: 14),
        _Podium(entries: podiumEntries, metric: metric),
        if (remaining.isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.cardGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (var index = 0; index < remaining.length; index++) ...[
                  LeaderboardTileWidget(
                    rank: index + 4,
                    entry: remaining[index],
                    metric: metric,
                    isCurrentUser: remaining[index].username == currentUsername,
                  ),
                  if (index < remaining.length - 1)
                    const Divider(height: 1, indent: 72),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.entries, required this.metric});

  final List<LeaderboardEntryModel> entries;
  final String metric;

  @override
  Widget build(BuildContext context) {
    final players = [
      if (entries.length > 1) (2, entries[1]),
      if (entries.isNotEmpty) (1, entries[0]),
      if (entries.length > 2) (3, entries[2]),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          final champion = players.firstWhere((player) => player.$1 == 1);
          final runners = players.where((player) => player.$1 != 1).toList();
          return Column(
            children: [
              _PodiumPlayer(
                rank: champion.$1,
                entry: champion.$2,
                metric: metric,
              ),
              if (runners.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: runners
                      .map(
                        (player) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: player == runners.first ? 5 : 0,
                              left: player == runners.last ? 5 : 0,
                            ),
                            child: _PodiumPlayer(
                              rank: player.$1,
                              entry: player.$2,
                              metric: metric,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: players
              .map(
                (player) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _PodiumPlayer(
                      rank: player.$1,
                      entry: player.$2,
                      metric: metric,
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PodiumPlayer extends StatelessWidget {
  const _PodiumPlayer({
    required this.rank,
    required this.entry,
    required this.metric,
  });

  final int rank;
  final LeaderboardEntryModel entry;
  final String metric;

  @override
  Widget build(BuildContext context) {
    final isChampion = rank == 1;
    final foreground = isChampion ? AppColors.ink : AppColors.white;
    final muted = isChampion
        ? AppColors.ink.withValues(alpha: 0.68)
        : AppColors.mutedText;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isChampion ? 190 : 164),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isChampion ? AppColors.gold : AppColors.cardGreen,
        borderRadius: BorderRadius.circular(16),
        border: isChampion ? null : Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isChampion
                ? Icons.workspace_premium_rounded
                : Icons.shield_outlined,
            color: isChampion ? AppColors.ink : AppColors.gold,
            size: 25,
          ),
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 24,
            backgroundColor: isChampion
                ? AppColors.ink.withValues(alpha: 0.12)
                : AppColors.inputGreen,
            foregroundColor: foreground,
            child: Text(
              _initials(entry.username),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            entry.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '#$rank  ${_metricValue(entry, metric)} ${_metricLabel(metric)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: muted, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardSkeleton extends StatelessWidget {
  const _LeaderboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading leaderboard',
      liveRegion: true,
      child: Column(
        children: [
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: index == 1 ? 190 : 164,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: AppColors.cardGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(
                5,
                (index) => Container(
                  height: 76,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardMessage extends StatelessWidget {
  const _LeaderboardMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 42),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mutedText),
          ),
          if (actionLabel != null && onPressed != null) ...[
            const SizedBox(height: 18),
            FilledButton(onPressed: onPressed, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

String _periodSummary(LeaderboardPeriod period, String metric) {
  final metricLabel = _metricLabel(metric);
  return switch (period) {
    LeaderboardPeriod.daily => 'Today, ranked by $metricLabel',
    LeaderboardPeriod.weekly => 'This week, ranked by $metricLabel',
    LeaderboardPeriod.overall => 'All time, ranked by $metricLabel',
  };
}

String _metricValue(LeaderboardEntryModel entry, String metric) {
  return switch (metric) {
    'xp' => NumberFormatUtils.compact(entry.xp),
    'coins' => NumberFormatUtils.compact(entry.coins),
    'winRate' => NumberFormatUtils.percentage(entry.winRate),
    _ => NumberFormatUtils.compact(entry.wins),
  };
}

String _metricLabel(String metric) => switch (metric) {
  'xp' => 'XP',
  'coins' => 'coins',
  'winRate' => 'win rate',
  _ => 'wins',
};

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
