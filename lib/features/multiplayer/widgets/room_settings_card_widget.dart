import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class RoomSettingsCardWidget extends StatelessWidget {
  const RoomSettingsCardWidget({required this.settings, super.key});

  final Map<String, dynamic> settings;

  @override
  Widget build(BuildContext context) {
    final timer = settings['turnTimeSeconds'];
    final values = [
      ('Turn timer', timer == 0 || timer == null ? 'No timer' : '${timer}s'),
      if (settings['maxRounds'] != null) ('Rounds', '${settings['maxRounds']}'),
      ('Difficulty', '${settings['difficulty'] ?? 'Normal'}'),
      (
        'Spectators',
        settings['allowSpectators'] == true ? 'Allowed' : 'Disabled',
      ),
      ('Auto start', settings['autoStart'] == true ? 'On' : 'Off'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 12,
        children: values
            .map(
              (value) => SizedBox(
                width: 135,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.$1,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                        fontFamily: 'Arial',
                      ),
                    ),
                    Text(
                      value.$2,
                      style: const TextStyle(
                        color: AppColors.paleGold,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
