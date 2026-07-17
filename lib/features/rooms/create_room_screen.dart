import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/widgets/game_mode_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  String _gameType = 'high_card';
  String _roomType = 'private';  
  int _maxPlayers = 2; 
  bool _allowBots = true;
  bool _allowChat = true;
  int _turnTimeSeconds = 30;
  String _difficulty = 'Normal';
  int _maxRounds = 5;
  int _maxBattles = 50;
  String _warMode = 'classic';
  int _blackjackMaxRounds = 5;
  int _startingChips = 1000;
  int _minimumBet = 10;
  String _dealerRule = 'stand_on_17';

  String get _gameName => switch (_gameType) {
    'war' => 'War',
    'blackjack' => 'Blackjack',
    _ => 'High Card',
  };

  @override
  Widget build(BuildContext context) {
    final controller = MultiplayerScope.of(context).room;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Set up your table',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Choose a game and room rules for your online table.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 26),
                    const _Label('Select Game'),
                    const SizedBox(height: 10),
                    GameModeSelectorWidget(
                      selectedGameType: _gameType,
                      onChanged: (value) => setState(() => _gameType = value),
                    ),
                    const SizedBox(height: 24),
                    const _Label('Room Type'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeCard(
                            label: 'Private',
                            icon: Icons.lock_rounded,
                            selected: _roomType == 'private',
                            onTap: () => setState(() => _roomType = 'private'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TypeCard(
                            label: 'Public',
                            icon: Icons.public_rounded,
                            selected: _roomType == 'public',
                            onTap: () => setState(() => _roomType = 'public'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<int>(
                      initialValue: _maxPlayers,
                      decoration: const InputDecoration(
                        labelText: 'Max players',
                        prefixIcon: Icon(Icons.groups_rounded),
                      ),
                      dropdownColor: AppColors.cardGreen,
                      items: const [2, 3, 4]
                          .map(
                            (count) => DropdownMenuItem(
                              value: count,
                              child: Text('$count players'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _maxPlayers = value ?? 2),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      initialValue: _turnTimeSeconds,
                      decoration: const InputDecoration(
                        labelText: 'Turn timer',
                        prefixIcon: Icon(Icons.timer_outlined),
                      ),
                      dropdownColor: AppColors.cardGreen,
                      items:
                          const [
                                (15, '15 seconds'),
                                (30, '30 seconds'),
                                (60, '60 seconds'),
                                (0, 'No timer'),
                              ]
                              .map(
                                (timer) => DropdownMenuItem(
                                  value: timer.$1,
                                  child: Text(timer.$2),
                                ),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setState(() => _turnTimeSeconds = value ?? 30),
                    ),
                    const SizedBox(height: 14),
                    if (_gameType == 'high_card') ...[
                      DropdownButtonFormField<int>(
                        initialValue: _maxRounds,
                        decoration: const InputDecoration(
                          labelText: 'Rounds',
                          prefixIcon: Icon(Icons.repeat_rounded),
                        ),
                        dropdownColor: AppColors.cardGreen,
                        items: const [3, 5, 10]
                            .map(
                              (rounds) => DropdownMenuItem(
                                value: rounds,
                                child: Text('$rounds rounds'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _maxRounds = value ?? 5),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (_gameType == 'war') ...[
                      DropdownButtonFormField<int>(
                        initialValue: _maxBattles,
                        decoration: const InputDecoration(
                          labelText: 'Battle limit',
                          prefixIcon: Icon(Icons.bolt_rounded),
                        ),
                        dropdownColor: AppColors.cardGreen,
                        items:
                            const [
                                  (25, '25 battles'),
                                  (50, '50 battles'),
                                  (100, '100 battles'),
                                  (0, 'No limit'),
                                ]
                                .map(
                                  (option) => DropdownMenuItem(
                                    value: option.$1,
                                    child: Text(option.$2),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            setState(() => _maxBattles = value ?? 50),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _warMode,
                        decoration: const InputDecoration(
                          labelText: 'War mode',
                          prefixIcon: Icon(Icons.style_rounded),
                        ),
                        dropdownColor: AppColors.cardGreen,
                        items: const [
                          DropdownMenuItem(
                            value: 'classic',
                            child: Text('Classic'),
                          ),
                          DropdownMenuItem(
                            value: 'quick',
                            child: Text('Quick War'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _warMode = value ?? 'classic'),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (_gameType == 'blackjack') ...[
                      DropdownButtonFormField<int>(
                        initialValue: _blackjackMaxRounds,
                        decoration: const InputDecoration(
                          labelText: 'Match length',
                          prefixIcon: Icon(Icons.repeat_rounded),
                        ),
                        dropdownColor: AppColors.cardGreen,
                        items: const [
                          DropdownMenuItem(value: 3, child: Text('3 rounds')),
                          DropdownMenuItem(value: 5, child: Text('5 rounds')),
                          DropdownMenuItem(value: 10, child: Text('10 rounds')),
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Until one player remains'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _blackjackMaxRounds = value ?? 5),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: _startingChips,
                        decoration: const InputDecoration(
                          labelText: 'Starting chips',
                          prefixIcon: Icon(Icons.paid_outlined),
                        ),
                        dropdownColor: AppColors.cardGreen,
                        items: const [500, 1000, 2000]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value chips'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _startingChips = value ?? 1000),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: _minimumBet,
                        decoration: const InputDecoration(
                          labelText: 'Minimum bet',
                          prefixIcon: Icon(Icons.casino_outlined),
                        ),
                        dropdownColor: AppColors.cardGreen,
                        items: const [10, 25, 50]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value chips'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _minimumBet = value ?? 10),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _dealerRule,
                        decoration: const InputDecoration(
                          labelText: 'Dealer rule',
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                        dropdownColor: AppColors.cardGreen,
                        items: const [
                          DropdownMenuItem(
                            value: 'stand_on_17',
                            child: Text('Stand on 17'),
                          ),
                          DropdownMenuItem(
                            value: 'hit_soft_17',
                            child: Text('Hit soft 17'),
                          ),
                        ],
                        onChanged: (value) => setState(
                          () => _dealerRule = value ?? 'stand_on_17',
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    DropdownButtonFormField<String>(
                      initialValue: _difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        prefixIcon: Icon(Icons.tune_rounded),
                      ),
                      dropdownColor: AppColors.cardGreen,
                      items: const ['Casual', 'Normal', 'Competitive']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _difficulty = value ?? 'Normal'),
                    ),
                    const SizedBox(height: 16),
                    _SettingSwitch(
                      title: 'Allow bots',
                      subtitle: 'Fill empty seats with computer players',
                      icon: Icons.smart_toy_outlined,
                      value: _allowBots,
                      onChanged: (value) => setState(() => _allowBots = value),
                    ),
                    const SizedBox(height: 10),
                    _SettingSwitch(
                      title: 'Allow room chat',
                      subtitle: 'Let players send messages in the lobby',
                      icon: Icons.chat_bubble_outline_rounded,
                      value: _allowChat,
                      onChanged: (value) => setState(() => _allowChat = value),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: controller.isLoading
                          ? 'Creating Room...'
                          : 'Create Room',
                      icon: Icons.add_circle_outline_rounded,
                      onPressed: controller.isLoading ? null : _createRoom,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createRoom() async {
    final controllers = MultiplayerScope.of(context);
    final room = await controllers.room.createRoom(
      gameType: _gameType,
      gameName: _gameName,
      maxPlayers: _maxPlayers,
      isPrivate: _roomType == 'private',
      allowBots: _allowBots,
      allowChat: _allowChat,
      settings: {
        'turnTimeSeconds': _turnTimeSeconds,
        'difficulty': _difficulty,
        'allowSpectators': _roomType == 'public',
        'autoStart': false,
        if (_gameType == 'high_card') 'maxRounds': _maxRounds,
        if (_gameType == 'war') 'maxBattles': _maxBattles,
        if (_gameType == 'war') 'warMode': _warMode,
        if (_gameType == 'blackjack')
          'maxRounds': _blackjackMaxRounds == 0 ? null : _blackjackMaxRounds,
        if (_gameType == 'blackjack') 'startingChips': _startingChips,
        if (_gameType == 'blackjack') 'minimumBet': _minimumBet,
        if (_gameType == 'blackjack') 'dealerRule': _dealerRule,
      },
    );
    if (!mounted) return;
    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controllers.room.errorMessage ?? 'Could not create room.',
          ),
        ),
      );
      return;
    }
    await controllers.chat.loadMessages(room.roomCode);
    if (mounted) context.push('${AppRoutes.roomLobby}/${room.roomCode}');
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium);
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(17),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: BoxDecoration(
        color: selected ? AppColors.gold : AppColors.cardGreen,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: selected ? AppColors.paleGold : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? AppColors.ink : AppColors.gold),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.ink : AppColors.white,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.cardGreen,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppColors.gold),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.mutedText, fontFamily: 'Arial'),
      ),
    ),
  );
}
