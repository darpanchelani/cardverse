import 'dart:async';

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
  const FriendsScreen({super.key, this.embedded = false});

  final bool? embedded;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) return;
    _hasLoaded = true;
    final friends = MultiplayerScope.of(context).friends;
    if (!friends.hasLoaded && !friends.isLoading) {
      unawaited(friends.refreshFriends());
    }
  }

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
    final isAuthenticated = auth?.isAuthenticated == true;
    final body = SafeArea(
      top: false,
      child: AnimatedBuilder(
        animation: friends,
        builder: (context, child) {
          final results = friends.searchResults;
          final online = results.where((friend) => friend.isOnline).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
            children: [
              if (widget.embedded == true) ...[
                _FriendsHeader(
                  isAuthenticated: isAuthenticated,
                  onBack: () => context.go(AppRoutes.home),
                  onAdd: () => isAuthenticated
                      ? context.push(AppRoutes.userSearch)
                      : context.go(AppRoutes.login),
                  onRequests: isAuthenticated
                      ? () => context.push(AppRoutes.friendRequests)
                      : null,
                  onRefresh: friends.refreshFriends,
                ),
                const SizedBox(height: 22),
              ],
              if (!isAuthenticated) ...[
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
                  onSend: isAuthenticated
                      ? () async {
                          final query = _searchController.text.trim();
                          if (query.isEmpty) return;
                          try {
                            await friends.sendFriendRequest(query);
                            if (!context.mounted) return;
                            _showMessage(
                              context,
                              friends.actionMessage ?? 'Friend request sent.',
                            );
                            friends.consumeActionMessage();
                          } catch (error) {
                            if (!context.mounted) return;
                            _showMessage(
                              context,
                              error is StateError
                                  ? error.message
                                  : 'Could not send the friend request.',
                            );
                          }
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
    );
    if (widget.embedded == true) return body;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          if (isAuthenticated)
            IconButton(
              tooltip: 'Friend requests',
              onPressed: () => context.push(AppRoutes.friendRequests),
              icon: const Icon(Icons.mark_email_unread_outlined),
            ),
          IconButton(
            tooltip: isAuthenticated
                ? 'Find players'
                : 'Sign in to add friends',
            onPressed: () => isAuthenticated
                ? context.push(AppRoutes.userSearch)
                : context.go(AppRoutes.login),
            icon: const Icon(Icons.person_add_rounded),
          ),
          IconButton(
            tooltip: 'Refresh friends',
            onPressed: friends.refreshFriends,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: body,
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

class _FriendsHeader extends StatelessWidget {
  const _FriendsHeader({
    required this.isAuthenticated,
    required this.onBack,
    required this.onAdd,
    required this.onRequests,
    required this.onRefresh,
  });

  final bool isAuthenticated;
  final VoidCallback onBack;
  final VoidCallback onAdd;
  final VoidCallback? onRequests;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        IconButton(
          tooltip: 'Back to Home',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 4),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.people_rounded, color: AppColors.ink),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Friends', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'Find players, manage requests, and invite friends to a table.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
        ),
      ],
    );
    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: onAdd,
          icon: Icon(
            isAuthenticated ? Icons.person_add_rounded : Icons.login_rounded,
          ),
          label: Text(isAuthenticated ? 'Add friends' : 'Sign in to add'),
        ),
        if (onRequests != null)
          OutlinedButton.icon(
            onPressed: onRequests,
            icon: const Icon(Icons.mark_email_unread_outlined),
            label: const Text('Requests'),
          ),
        IconButton(
          tooltip: 'Refresh friends',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, const SizedBox(height: 18), actions],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 24),
            actions,
          ],
        );
      },
    );
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
