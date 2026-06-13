import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/history/services/match_history_api_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/models/match_history_model.dart';
import 'package:cardverse/features/progress/widgets/match_history_tile_widget.dart';
import 'package:flutter/material.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  String _filter = 'all';
  bool _showCloud = true;
  bool _loadingCloud = false;
  List<MatchHistoryModel> _cloudMatches = [];
  String? _cloudError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = AuthScope.maybeOf(context);
    if (auth?.isAuthenticated != true) _showCloud = false;
    if (_showCloud && _cloudMatches.isEmpty && !_loadingCloud) {
      _loadCloud();
    }
  }

  Future<void> _loadCloud() async {
    final api = ApiClient.globalInstance;
    final auth = AuthScope.maybeOf(context);
    if (api == null || auth?.isAuthenticated != true) return;
    setState(() {
      _loadingCloud = true;
      _cloudError = null;
    });
    try {
      _cloudMatches = await MatchHistoryApiService(api, auth!).getMyMatches();
    } catch (error) {
      _cloudError = error.toString();
    }
    if (mounted) setState(() => _loadingCloud = false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProgressScope.of(context);
    final auth = AuthScope.maybeOf(context);
    final isAuthenticated = auth?.isAuthenticated == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match History'),
        actions: [
          IconButton(
            tooltip: 'Clear match history',
            onPressed: _showCloud || controller.matchHistory.isEmpty
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
            final source = _showCloud ? _cloudMatches : controller.matchHistory;
            final matches = source
                .where((match) => _filter == 'all' || match.gameType == _filter)
                .toList();
            return Column(
              children: [
                if (isAuthenticated)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Cloud Online'),
                          icon: Icon(Icons.cloud_outlined),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('Local Offline'),
                          icon: Icon(Icons.phone_android_rounded),
                        ),
                      ],
                      selected: {_showCloud},
                      onSelectionChanged: (value) {
                        setState(() {
                          _showCloud = value.first;
                          _filter = 'all';
                        });
                        if (_showCloud) _loadCloud();
                      },
                    ),
                  ),
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
                        label: 'Online High Card',
                        value: 'high_card_online',
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
                        label: 'Online War',
                        value: 'war_online',
                        selected: _filter,
                        onSelected: _select,
                      ),
                      _FilterChip(
                        label: 'Blackjack',
                        value: 'blackjack',
                        selected: _filter,
                        onSelected: _select,
                      ),
                      _FilterChip(
                        label: 'Online Blackjack',
                        value: 'blackjack_online',
                        selected: _filter,
                        onSelected: _select,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _showCloud && _loadingCloud
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        )
                      : _showCloud && _cloudError != null
                      ? _CloudError(message: _cloudError!, onRetry: _loadCloud)
                      : matches.isEmpty
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

class _CloudError extends StatelessWidget {
  const _CloudError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 54, color: AppColors.gold),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    ),
  );
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
