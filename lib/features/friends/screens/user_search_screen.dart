import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/friends/services/friends_api_service.dart';
import 'package:cardverse/features/multiplayer/models/friend_model.dart';
import 'package:cardverse/features/multiplayer/widgets/friend_tile_widget.dart';
import 'package:flutter/material.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _controller = TextEditingController();
  List<FriendModel> _results = [];
  final Set<String> _sendingRequests = {};
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final api = ApiClient.globalInstance;
    if (api == null || _controller.text.trim().length < 2) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _results = await FriendsApiService(
        api,
        AuthScope.of(context),
      ).searchFriends(_controller.text);
    } catch (error) {
      _error = error.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _sendFriendRequest(FriendModel user) async {
    if (_sendingRequests.contains(user.id)) return;
    setState(() => _sendingRequests.add(user.id));
    try {
      await FriendsApiService(
        ApiClient.globalInstance!,
        AuthScope.of(context),
      ).sendFriendRequestById(user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${user.username}.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send the friend request.')),
      );
    } finally {
      if (mounted) setState(() => _sendingRequests.remove(user.id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Find Players')),
    body: SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Search by username',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                onPressed: _search,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(36),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.danger),
              ),
            )
          else if (_results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(36),
              child: Center(child: Text('Search for CardVerse players.')),
            )
          else
            ..._results.map(
              (user) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FriendTileWidget(
                  friend: user,
                  actionTooltip: 'Add ${user.username} as a friend',
                  onInvite: () => _sendFriendRequest(user),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
