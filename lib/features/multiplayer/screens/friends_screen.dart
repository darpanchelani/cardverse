import 'package:cardverse/app/routes.dart';
import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/models/friend_model.dart';
import 'package:cardverse/features/multiplayer/widgets/friend_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllers = MultiplayerScope.of(context);
    final friends = controllers.friends;
    final auth = AuthScope.maybeOf(context);
    final room = controllers.room.currentRoom;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          if (auth?.isAuthenticated == true)
            IconButton(
              tooltip: 'Friend requests',
              onPressed: () => context.push(AppRoutes.friendRequests),
              icon: const Icon(Icons.mark_email_unread_outlined),
            ),
          if (auth?.isAuthenticated == true)
            IconButton(
              tooltip: 'Find players',
              onPressed: () => context.push(AppRoutes.userSearch),
              icon: const Icon(Icons.person_search_rounded),
            ),
          IconButton(
            tooltip: 'Refresh friends',
            onPressed: friends.refreshFriends,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: friends,
          builder: (context, child) {
            final results = friends.searchResults;
            final online = results.where((friend) => friend.isOnline).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
              children: [
                if (auth?.isAuthenticated != true) ...[
                  const _GuestFriendsBanner(),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _searchController,
                  onChanged: friends.searchFriends,
                  decoration: const InputDecoration(
                    hintText: 'Search friends',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                if (friends.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  )
                else if (results.isEmpty)
                  _NoFriends(
                    query: _searchController.text,
                    onSend: auth?.isAuthenticated == true
                        ? () async {
                            final query = _searchController.text.trim();
                            if (query.isEmpty) return;
                            await friends.sendFriendRequest(query);
                            if (!context.mounted) return;
                            _showMessage(
                              context,
                              friends.actionMessage ?? 'Friend request sent.',
                            );
                            friends.consumeActionMessage();
                          }
                        : () => context.go(AppRoutes.login),
                  )
                else ...[
                  if (online.isNotEmpty) ...[
                    _SectionTitle(title: 'Online Now', count: online.length),
                    const SizedBox(height: 10),
                    ...online.map(
                      (friend) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _friendTile(
                          context,
                          friend,
                          controllers,
                          canInvite: room != null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _SectionTitle(title: 'All Friends', count: results.length),
                  const SizedBox(height: 10),
                  ...results.map(
                    (friend) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _friendTile(
                        context,
                        friend,
                        controllers,
                        canInvite: room != null,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _friendTile(
    BuildContext context,
    FriendModel friend,
    MultiplayerControllers controllers, {
    required bool canInvite,
  }) {
    return FriendTileWidget(
      friend: friend,
      onInvite: canInvite && friend.status != 'offline'
          ? () async {
              final invites = AppServicesScope.maybeOf(context)?.invites;
              final result = await invites?.sendInvite(
                friend.id,
                controllers.room.currentRoom!.roomCode,
              );
              if (context.mounted) {
                _showMessage(
                  context,
                  result == null
                      ? invites?.errorMessage ?? 'Login to invite friends.'
                      : 'Invite sent to ${friend.username}.',
                );
              }
            }
          : null,
      onRemove: () => controllers.friends.removeFriend(friend.id),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _GuestFriendsBanner extends StatelessWidget {
  const _GuestFriendsBanner();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.gold.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.gold),
    ),
    child: const Text(
      'Login to add real friends and invite them online.',
      textAlign: TextAlign.center,
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      Text(
        '$count',
        style: const TextStyle(
          color: AppColors.gold,
          fontFamily: 'Arial',
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _NoFriends extends StatelessWidget {
  const _NoFriends({required this.query, required this.onSend});

  final String query;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Column(
      children: [
        const Icon(
          Icons.person_search_rounded,
          size: 62,
          color: AppColors.gold,
        ),
        const SizedBox(height: 14),
        Text('No friends found', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          query.isEmpty
              ? 'Your friends will appear here.'
              : 'Try another name.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
        ),
        if (query.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onSend,
            icon: const Icon(Icons.person_add_rounded),
            label: Text('Send Friend Request to $query'),
          ),
        ],
      ],
    ),
  );
}
