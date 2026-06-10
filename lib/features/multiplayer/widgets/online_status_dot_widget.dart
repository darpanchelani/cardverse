import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class OnlineStatusDotWidget extends StatelessWidget {
  const OnlineStatusDotWidget({
    required this.status,
    super.key,
    this.size = 11,
  });

  final String status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'online' => Colors.greenAccent,
      'away' => AppColors.gold,
      'in_game' => Colors.lightBlueAccent,
      _ => AppColors.mutedText,
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.deepGreen, width: 2),
      ),
    );
  }
}
