import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/friends/models/friend_request_model.dart';
import 'package:cardverse/features/friends/services/friends_api_service.dart';
import 'package:flutter/material.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<FriendRequestModel> _incoming = [];
  List<FriendRequestModel> _outgoing = [];
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  FriendsApiService get _service =>
      FriendsApiService(ApiClient.globalInstance!, AuthScope.of(context));

  Future<void> _load() async {
    try {
      final requests = await _service.getRequests();
      _incoming = requests.incoming;
      _outgoing = requests.outgoing;
      _error = null;
    } catch (error) {
      _error = error.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Friend Requests')),
    body: RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                Text('Incoming', style: Theme.of(context).textTheme.titleLarge),
                if (_incoming.isEmpty)
                  const ListTile(title: Text('No incoming requests.'))
                else
                  ..._incoming.map(
                    (request) => Card(
                      child: ListTile(
                        title: Text(request.fromUser.username),
                        subtitle: Text('Level ${request.fromUser.level}'),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              tooltip: 'Accept',
                              onPressed: () async {
                                await _service.accept(request.id);
                                setState(() => _loading = true);
                                await _load();
                              },
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.greenAccent,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Decline',
                              onPressed: () async {
                                await _service.decline(request.id);
                                setState(() => _loading = true);
                                await _load();
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text('Outgoing', style: Theme.of(context).textTheme.titleLarge),
                if (_outgoing.isEmpty)
                  const ListTile(title: Text('No outgoing requests.'))
                else
                  ..._outgoing.map(
                    (request) => ListTile(
                      title: Text(request.toUser.username),
                      trailing: const Text(
                        'Pending',
                        style: TextStyle(color: AppColors.gold),
                      ),
                    ),
                  ),
              ],
            ),
    ),
  );
}
