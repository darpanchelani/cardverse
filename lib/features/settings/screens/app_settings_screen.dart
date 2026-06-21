import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/core/widgets/confirm_dialog.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/material.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppServicesScope.of(context).settings;
    final progress = ProgressScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: AnimatedBuilder(
        animation: settings,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            SwitchListTile(
              title: const Text('Sound'),
              subtitle: const Text('Enable game and interface sounds'),
              value: settings.soundEnabled,
              onChanged: (value) => settings.updateLocal(sound: value),
            ),
            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Use haptic feedback for game actions'),
              value: settings.vibrationEnabled,
              onChanged: (value) => settings.updateLocal(vibration: value),
            ),
            SwitchListTile(
              title: const Text('In-app notifications'),
              subtitle: const Text('Show banners for invites and achievements'),
              value: settings.notificationsEnabled,
              onChanged: (value) => settings.updateLocal(notifications: value),
            ),
            const ListTile(
              leading: Icon(Icons.dark_mode_outlined),
              title: Text('Appearance'),
              subtitle: Text('CardVerse dark theme'),
              trailing: Text('Dark'),
            ),
            const Divider(height: 32),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: 'Clear local match history?',
                  message:
                      'Cloud history and profile statistics are not removed.',
                  confirmLabel: 'Clear',
                );
                if (confirmed) await progress.clearHistory();
              },
              icon: const Icon(Icons.history_toggle_off_rounded),
              label: const Text('Clear Local Match History'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: 'Reset local progress?',
                  message:
                      'This clears local XP, coins, achievements, and offline history.',
                  confirmLabel: 'Reset',
                );
                if (confirmed) await progress.clearProgress();
              },
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Reset Local Progress'),
            ),
          ],
        ),
      ),
    );
  }
}
