import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/widgets/match_history_tile_widget.dart';
import 'package:flutter/material.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final controller = ProgressScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match History'),
        actions: [
          IconButton(
            tooltip: 'Clear match history',
            onPressed: controller.matchHistory.isEmpty
                ? null
                : () => _confirmClear(context, controller),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final matches = controller.matchHistory
                .where((match) => _filter == 'all' || match.gameType == _filter)
                .toList();
            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        value: 'all',
                        selected: _filter,
                        onSelected: _select,
                      ),
                      _FilterChip(
                        label: 'High Card',
                        value: 'high_card',
                        selected: _filter,
                        onSelected: _select,
                      ),
                      _FilterChip(
                        label: 'War',
                        value: 'war',
                        selected: _filter,
                        onSelected: _select,
                      ),
                      _FilterChip(
                        label: 'Blackjack',
                        value: 'blackjack',
                        selected: _filter,
                        onSelected: _select,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: matches.isEmpty
                      ? const _EmptyHistory()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                          itemCount: matches.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 11),
                          itemBuilder: (context, index) =>
                              MatchHistoryTileWidget(match: matches[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _select(String value) => setState(() => _filter = value);

  Future<void> _confirmClear(
    BuildContext context,
    ProgressController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear match history?'),
        content: const Text(
          'This removes saved matches but keeps your profile statistics.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.clearHistory();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected == value,
        onSelected: (_) => onSelected(value),
        selectedColor: AppColors.gold,
        backgroundColor: AppColors.cardGreen,
        labelStyle: TextStyle(
          color: selected == value ? AppColors.ink : AppColors.white,
          fontFamily: 'Arial',
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 64, color: AppColors.gold),
            const SizedBox(height: 18),
            Text(
              'No match history yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Play a game to see your results here.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
