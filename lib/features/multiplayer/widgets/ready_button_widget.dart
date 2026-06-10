import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ReadyButtonWidget extends StatelessWidget {
  const ReadyButtonWidget({
    required this.isReady,
    required this.onPressed,
    super.key,
  });

  final bool isReady;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isReady ? AppColors.cardGreen : AppColors.gold,
        foregroundColor: isReady ? AppColors.paleGold : AppColors.ink,
        side: BorderSide(color: isReady ? AppColors.gold : AppColors.paleGold),
        minimumSize: const Size.fromHeight(54),
      ),
      icon: Icon(
        isReady ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
      ),
      label: Text(isReady ? 'Ready' : 'Mark Ready'),
    ),
  );
}
