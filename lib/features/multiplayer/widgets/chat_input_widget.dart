import 'package:flutter/material.dart';

class ChatInputWidget extends StatefulWidget {
  const ChatInputWidget({required this.onSend, super.key});

  final Future<bool> Function(String message) onSend;

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    final sent = await widget.onSend(_controller.text);
    if (sent) _controller.clear();
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          controller: _controller,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _send(),
          decoration: const InputDecoration(
            hintText: 'Message the room',
            prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
          ),
        ),
      ),
      const SizedBox(width: 8),
      IconButton.filled(
        tooltip: 'Send message',
        onPressed: _sending ? null : _send,
        icon: const Icon(Icons.send_rounded),
      ),
    ],
  );
}
