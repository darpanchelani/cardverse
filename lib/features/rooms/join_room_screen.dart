import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/services/room_code_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _roomCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _roomCodeService = RoomCodeService();

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomController = MultiplayerScope.of(context).room;
    return Scaffold(
      appBar: AppBar(title: const Text('Join Room')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const Icon(
                      Icons.meeting_room_outlined,
                      size: 76,
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Take your seat',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Enter the six-character code shared by the room host.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _roomCodeController,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp('[a-zA-Z0-9]'),
                        ),
                        UpperCaseTextFormatter(),
                      ],
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 22,
                        letterSpacing: 5,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Room code',
                        prefixIcon: Icon(Icons.key_rounded),
                        counterText: '',
                      ),
                      validator: (value) {
                        final code = value?.trim() ?? '';
                        if (code.isEmpty) return 'Room code is required.';
                        if (!_roomCodeService.isValidRoomCode(code)) {
                          return 'Enter a valid 6-character room code.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _joinRoom(),
                    ),
                    const SizedBox(height: 18),
                    AnimatedBuilder(
                      animation: roomController,
                      builder: (context, child) => CustomButton(
                        label: roomController.isLoading
                            ? 'Joining Room...'
                            : 'Join Room',
                        icon: Icons.login_rounded,
                        onPressed: roomController.isLoading ? null : _joinRoom,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'Browse Public Rooms',
                      icon: Icons.public_rounded,
                      isOutlined: true,
                      onPressed: () => context.push(AppRoutes.publicRooms),
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

  Future<void> _joinRoom() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controllers = MultiplayerScope.of(context);
    final code = _roomCodeController.text.trim().toUpperCase();
    final room = await controllers.room.joinRoom(code);
    if (!mounted) return;
    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controllers.room.errorMessage ?? 'Could not join this room.',
          ),
        ),
      );
      return;
    }
    await controllers.chat.loadMessages(room.roomCode);
    if (mounted) context.push('${AppRoutes.roomLobby}/${room.roomCode}');
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
