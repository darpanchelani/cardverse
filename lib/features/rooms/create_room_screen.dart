import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/constants/app_strings.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  String _game = 'High Card';
  int _maxPlayers = 2;
  bool _roomCreated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Private Room')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Set the table',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a game and decide how many seats are available.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    initialValue: _game,
                    decoration: const InputDecoration(
                      labelText: 'Game',
                      prefixIcon: Icon(Icons.style_rounded),
                    ),
                    dropdownColor: AppColors.cardGreen,
                    items: const ['High Card', 'War', 'Blackjack']
                        .map(
                          (game) =>
                              DropdownMenuItem(value: game, child: Text(game)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _game = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _maxPlayers,
                    decoration: const InputDecoration(
                      labelText: 'Max players',
                      prefixIcon: Icon(Icons.groups_rounded),
                    ),
                    dropdownColor: AppColors.cardGreen,
                    items: const [2, 3, 4, 5, 6]
                        .map(
                          (count) => DropdownMenuItem(
                            value: count,
                            child: Text('$count players'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _maxPlayers = value!),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Create Room',
                    icon: Icons.add_circle_outline_rounded,
                    onPressed: () => setState(() => _roomCreated = true),
                  ),
                  if (_roomCreated) ...[
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardGreen,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'YOUR ROOM CODE',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppColors.mutedText,
                                  letterSpacing: 2,
                                ),
                          ),
                          const SizedBox(height: 12),
                          const SelectableText(
                            AppStrings.roomCode,
                            style: TextStyle(
                              color: AppColors.paleGold,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 7,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share this code with your friends.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.mutedText),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: 'Copy Room Code',
                            icon: Icons.copy_rounded,
                            isOutlined: true,
                            onPressed: () {
                              Clipboard.setData(
                                const ClipboardData(text: AppStrings.roomCode),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Room code copied.'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
