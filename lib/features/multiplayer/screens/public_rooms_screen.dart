import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/widgets/room_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicRoomsScreen extends StatefulWidget {
  const PublicRoomsScreen({super.key});

  @override
  State<PublicRoomsScreen> createState() => _PublicRoomsScreenState();
}

class _PublicRoomsScreenState extends State<PublicRoomsScreen> {
  String _filter = 'all';
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      MultiplayerScope.of(context).room.loadPublicRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = MultiplayerScope.of(context).room;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Rooms'),
        actions: [
          IconButton(
            tooltip: 'Refresh rooms',
            onPressed: controller.loadPublicRooms,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final rooms = controller.publicRooms
                .where((room) => _filter == 'all' || room.gameType == _filter)
                .toList();
            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                  child: Row(
                    children: [
                      _Filter('All', 'all', _filter, _select),
                      _Filter('High Card', 'high_card', _filter, _select),
                      _Filter('War', 'war', _filter, _select),
                      _Filter('Blackjack', 'blackjack', _filter, _select),
                    ],
                  ),
                ),
                Expanded(
                  child: controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        )
                      : rooms.isEmpty
                      ? const _EmptyRooms()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                          itemCount: rooms.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            return RoomCardWidget(
                              room: room,
                              onJoin: () async {
                                final joined = await controller.joinRoom(
                                  room.roomCode,
                                );
                                if (!context.mounted) return;
                                if (joined == null) {
                                  _message(
                                    context,
                                    controller.errorMessage ??
                                        'Could not join room.',
                                  );
                                  return;
                                }
                                context.push(
                                  '${AppRoutes.roomLobby}/${room.roomCode}',
                                );
                              },
                            );
                          },
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

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Filter extends StatelessWidget {
  const _Filter(this.label, this.value, this.selected, this.onSelected);

  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected == value,
      onSelected: (_) => onSelected(value),
      selectedColor: AppColors.gold,
      backgroundColor: AppColors.cardGreen,
      side: const BorderSide(color: AppColors.border),
      labelStyle: TextStyle(
        color: selected == value ? AppColors.ink : AppColors.white,
        fontFamily: 'Arial',
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _EmptyRooms extends StatelessWidget {
  const _EmptyRooms();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.public_off_rounded, size: 60, color: AppColors.gold),
        const SizedBox(height: 14),
        Text(
          'No public rooms found',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    ),
  );
}
