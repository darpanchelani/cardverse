import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final settings = AppServicesScope.of(context).settings;
    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account Settings')),
        body: Center(
          child: FilledButton.icon(
            onPressed: () => context.go(AppRoutes.login),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Login or Create Account'),
          ),
        ),
      );
    }
    final user = auth.user!;
    final cloud = user.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: AnimatedBuilder(
        animation: Listenable.merge([auth, settings]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: Text(auth.user!.username),
              subtitle: Text(auth.user!.email),
              trailing: IconButton(
                tooltip: 'Edit profile',
                onPressed: () => _editProfile(context, auth),
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
            const Divider(height: 28),
            SwitchListTile(
              title: const Text('Show online status'),
              value: cloud['showOnlineStatus'] as bool? ?? true,
              onChanged: (value) =>
                  settings.updateCloud(showOnlineStatus: value),
            ),
            SwitchListTile(
              title: const Text('Private profile'),
              value: cloud['privateProfile'] as bool? ?? false,
              onChanged: (value) => settings.updateCloud(privateProfile: value),
            ),
            SwitchListTile(
              title: const Text('Cloud notifications'),
              value: cloud['notificationsEnabled'] as bool? ?? true,
              onChanged: (value) => settings.updateCloud(notifications: value),
            ),
            const Divider(height: 28),
            OutlinedButton.icon(
              onPressed: () => _logout(context, auth),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log Out'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _deleteAccount(context, settings),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, AuthController auth) async {
    final username = TextEditingController(text: auth.user?.username);
    final avatar = TextEditingController(text: auth.user?.avatar);
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: avatar.text,
              decoration: const InputDecoration(labelText: 'Avatar'),
              items: const ['default', 'ace', 'king', 'queen', 'joker']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => avatar.text = value ?? 'default',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (save == true) {
      await auth.updateProfile(
        username: username.text.trim(),
        avatar: avatar.text,
      );
    }
    username.dispose();
    avatar.dispose();
  }

  Future<void> _logout(BuildContext context, AuthController auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can continue using CardVerse as a guest.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final multiplayer = MultiplayerScope.of(context);
    multiplayer.connection.disconnect();
    multiplayer.socket.resetConnection();
    await auth.logout();
    if (!context.mounted) return;
    AppServicesScope.of(context).notifications.clear();
    AppServicesScope.of(context).invites.clear();
    if (context.mounted) context.go(AppRoutes.login);
  }

  Future<void> _deleteAccount(
    BuildContext context,
    SettingsController settings,
  ) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account permanently?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This soft-deletes your cloud account. Type DELETE to continue.',
            ),
            const SizedBox(height: 12),
            TextField(controller: controller),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim() == 'DELETE'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (confirmed == true &&
        await settings.deleteAccount() &&
        context.mounted) {
      context.go(AppRoutes.login);
    }
  }
}
