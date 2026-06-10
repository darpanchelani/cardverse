import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/models/chat_message_model.dart';
import 'package:flutter/material.dart';

class ChatBubbleWidget extends StatelessWidget {
  const ChatBubbleWidget({
    required this.message,
    required this.isCurrentUser,
    super.key,
  });

  final ChatMessageModel message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    if (message.isSystemMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          message.message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.gold,
            fontFamily: 'Arial',
          ),
        ),
      );
    }
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrentUser ? AppColors.gold : AppColors.inputGreen,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentUser ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Text(
                message.senderName,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontFamily: 'Arial',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(
              message.message,
              style: TextStyle(
                color: isCurrentUser ? AppColors.ink : AppColors.white,
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
