import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/constants/app_strings.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:cardverse/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Room')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.meeting_room_outlined,
                    size: 74,
                    color: AppColors.gold,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Take your seat',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter the six-character code shared by the room host.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 32),
                  const CustomTextField(
                    label: 'Room code',
                    icon: Icons.key_rounded,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    label: 'Join Room',
                    icon: Icons.login_rounded,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.multiplayerMessage),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
