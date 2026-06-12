import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/models/leaderboard_entry_model.dart';
import 'package:cardverse/features/progress/widgets/leaderboard_tile_widget.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _filter = 'overall';
  List<LeaderboardEntryModel> _entries = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entries.isEmpty) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final controller = ProgressScope.of(context);
    final entries = await controller.leaderboardFor(
      _filter == 'overall' ? null : _filter,
    );
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProgressScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh leaderboard',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Row(
                children: [
                  _Filter('Overall', 'overall', _filter, _changeFilter),
                  _Filter('High Card', 'high_card', _filter, _changeFilter),
                  _Filter(
                    'Online High Card',
                    'high_card_online',
                    _filter,
                    _changeFilter,
                  ),
                  _Filter('War', 'war', _filter, _changeFilter),
                  _Filter('Online War', 'war_online', _filter, _changeFilter),
                  _Filter('Blackjack', 'blackjack', _filter, _changeFilter),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      itemCount: _entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 11),
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return LeaderboardTileWidget(
                          rank: index + 1,
                          entry: entry,
                          isCurrentUser:
                              entry.username == controller.profile.username,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeFilter(String value) {
    if (_filter == value) return;
    setState(() => _filter = value);
    _load();
  }
}

class _Filter extends StatelessWidget {
  const _Filter(this.label, this.value, this.selected, this.onSelected);

  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onSelected(value),
        selectedColor: AppColors.gold,
        backgroundColor: AppColors.cardGreen,
        labelStyle: TextStyle(
          color: active ? AppColors.ink : AppColors.white,
          fontFamily: 'Arial',
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
